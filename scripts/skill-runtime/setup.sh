#!/usr/bin/env bash
set -euo pipefail
LUNWEN_SETUP_REPO="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
export LUNWEN_SETUP_REPO
export UV_CACHE_DIR=/workspace/.cache/uv
export UV_SYSTEM_CERTS=true
export PYTHONDONTWRITEBYTECODE=1
cd "$LUNWEN_SETUP_REPO"
mkdir -p /workspace/.venvs /workspace/.tooling/lunwen-skills/bin
if [[ ! -x /workspace/.venvs/lunwen-skills/bin/python ]]; then
  uv venv --system-site-packages /workspace/.venvs/lunwen-skills
fi
uv pip install --index-url https://pypi.org/simple --require-hashes \
  --python /workspace/.venvs/lunwen-skills/bin/python \
  -r scripts/skill-runtime/requirements.lock

# Keep npm's integrity-checked lock and use the platform's Chromium. Do not
# download another browser through Puppeteer's package-install hook.
if [[ ! -d /workspace/.tooling/mermaid/node_modules/@mermaid-js/mermaid-cli ]] || \
   ! cmp -s scripts/skill-runtime/mermaid/package-lock.json /workspace/.tooling/mermaid/package-lock.json; then
  mkdir -p /workspace/.tooling/mermaid
  cp scripts/skill-runtime/mermaid/package*.json /workspace/.tooling/mermaid/
  npm ci --prefix /workspace/.tooling/mermaid --cache /workspace/.cache/npm \
    --registry https://registry.npmjs.org --ignore-scripts
fi

# Extract R into workspace from Debian's signature-verified package repository.
# The isolated APT state and download-only mode never modify system packages.
if ! RHOME=/workspace/.tooling/r/usr/lib/R /workspace/.tooling/r/usr/bin/Rscript \
  -e 'stopifnot(getRversion() >= "4.5.0")' >/dev/null 2>&1; then
  python - <<'PY'
from pathlib import Path
import shutil
r=Path('/workspace/.tooling/apt')
for d in ['empty','state/lists/partial','cache/archives/partial','log']:
    (r/d).mkdir(parents=True,exist_ok=True)
shutil.copyfile('/var/lib/dpkg/status',r/'state/status')
(r/'sources.list').write_text('deb [signed-by=/usr/share/keyrings/debian-archive-keyring.gpg] https://deb.debian.org/debian trixie main\n')
(r/'apt.conf').write_text('''Dir::Etc::main "/dev/null";
Dir::Etc::parts "/workspace/.tooling/apt/empty";
Dir::Etc::sourcelist "/workspace/.tooling/apt/sources.list";
Dir::Etc::sourceparts "-";
Dir::State "/workspace/.tooling/apt/state";
Dir::State::status "/workspace/.tooling/apt/state/status";
Dir::Cache "/workspace/.tooling/apt/cache";
Dir::Log "/workspace/.tooling/apt/log";
APT::Sandbox::User "agent";
Debug::NoLocking "true";
''')
PY
  APT_CONFIG=/workspace/.tooling/apt/apt.conf /usr/bin/apt-get update
  APT_CONFIG=/workspace/.tooling/apt/apt.conf /usr/bin/apt-get \
    --download-only --no-install-recommends --yes install r-base-core
  python - <<'PY'
from pathlib import Path
import shutil,subprocess
base=Path('/workspace/.tooling/r');base.mkdir(parents=True,exist_ok=True)
deb=max(Path('/workspace/.tooling/apt/cache/archives').glob('r-base-core_*.deb'),key=lambda p:p.stat().st_mtime)
subprocess.run(['dpkg-deb','-x',str(deb),str(base)],check=True)
rh=base/'usr/lib/R'
for p in (rh/'etc').iterdir():
    if p.is_symlink():
        target=base/str(p.readlink()).lstrip('/')
        p.unlink()
        if target.exists():shutil.copy2(target,p)
        elif p.name=='Renviron':shutil.copy2(rh/'etc/Renviron.ucf',p)
        else:raise RuntimeError(f'Missing R configuration {target}')
for p in [base/'usr/bin/R',rh/'bin/R']:
    text=p.read_text()
    for prefix in ['/usr/lib/R','/usr/share/R']:
        text=text.replace(prefix,str(base/prefix.lstrip('/')))
    p.write_text(text)
PY
fi

python - <<'PY'
import os
from pathlib import Path
b=Path('/workspace/.tooling/lunwen-skills/bin')
repo=Path(os.environ['LUNWEN_SETUP_REPO'])
for name,body in {
 'Rscript':'#!/bin/sh\nexport RHOME=/workspace/.tooling/r/usr/lib/R\nexec /workspace/.tooling/r/usr/bin/Rscript "$@"\n',
 'R':'#!/bin/sh\nexec /workspace/.tooling/r/usr/bin/R "$@"\n',
 'mmdc':f'#!/bin/sh\nexec node "{repo}/scripts/skill-runtime/mermaid-local-http.mjs" "$@"\n',
}.items():
    p=b/name;p.write_text(body);p.chmod(0o755)
PY
source scripts/skill-runtime/activate.sh
python .agents/skills/nature-image2ppt/cli/image2ppt/cli.py doctor --json
Rscript -e 'stopifnot(mean(c(1,2,3)) == 2); cat(R.version.string,"\n")'
mmdc --version
