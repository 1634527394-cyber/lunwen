# Source this file from a Bash shell before executing installed Skill helpers.
LUNWEN_SKILLS_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
export LUNWEN_SKILLS_ROOT
export VIRTUAL_ENV=/workspace/.venvs/lunwen-skills
export PATH="/workspace/.tooling/lunwen-skills/bin:$VIRTUAL_ENV/bin:$PATH"
export RHOME=/workspace/.tooling/r/usr/lib/R
export R_HOME="$RHOME"
export MPLCONFIGDIR=/workspace/.cache/lunwen-matplotlib
export XDG_CACHE_HOME=/workspace/.cache
export UV_CACHE_DIR=/workspace/.cache/uv
export PYTHONDONTWRITEBYTECODE=1
