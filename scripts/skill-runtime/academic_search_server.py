"""Launch the bundled MCP server from the installed, unchanged Skill."""
from pathlib import Path
import runpy
import sys

ROOT = Path(__file__).resolve().parents[2]
SERVER = ROOT / '.agents/skills/nature-academic-search/mcp-server'
sys.path.insert(0, str(SERVER))
namespace = runpy.run_path(str(SERVER / 'academic_search_server.py'))
# The upstream empty configuration substitutes user@example.com. Do not send a
# fictitious contact address; use a truthful identifier until mailto is supplied.
from utils.config import get_config
if not get_config().crossref_mailto:
    namespace['_crossref']._headers['User-Agent'] = 'lunwen-academic-search/1.0'
namespace['mcp'].run(transport='stdio')
