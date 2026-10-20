#!/usr/bin/env bash
set -euo pipefail
# Explicit, process-local MCP settings work even when project config is untrusted.
# Authentication remains in the existing Codex configuration; no keys are copied.
exec codex \
  -c 'mcp_servers.academic-search.command="/workspace/.venvs/lunwen-skills/bin/python"' \
  -c 'mcp_servers.academic-search.args=["-B","/workspace/lunwen/scripts/skill-runtime/academic_search_server.py"]' \
  -c 'mcp_servers.academic-search.startup_timeout_sec=30' \
  -c 'mcp_servers.academic-search.tool_timeout_sec=90' \
  -c 'mcp_servers.academic-search.env_vars=["HTTPS_PROXY","HTTP_PROXY","ALL_PROXY","NO_PROXY","REQUESTS_CA_BUNDLE","SSL_CERT_FILE","PUBMED_EMAIL","NCBI_API_KEY"]' \
  "$@"
