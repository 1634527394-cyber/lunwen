# Project Skill runtime

For commands that execute the installed Skills' Python, R, or Mermaid helpers,
first run `source scripts/skill-runtime/activate.sh` in the same Bash command.
The canonical Python environment is `/workspace/.venvs/lunwen-skills`; the system
Python intentionally remains unchanged and is not the environment used to assess
whether these installed Skill requirements are satisfied.

The academic-search MCP launch configuration is in `.codex/config.toml`. New Codex
sessions may need to load the trusted project configuration before tools appear.
Do not infer that a tool is available in the current chat from configuration alone.

Keep installed upstream Skill files unchanged. Local runtime adapters belong in
`scripts/skill-runtime/`. Do not put API keys, tokens, private provider configuration,
or a personal contact email into version control. Do not claim subscription APIs,
OCR or external image services are usable without checking their actual access.
