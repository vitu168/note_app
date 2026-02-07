#!/usr/bin/env python3
"""
Usage: ./scripts/ios/set_development_team.py TEAM_ID
Sets or replaces DEVELOPMENT_TEAM entries in ios/Runner.xcodeproj/project.pbxproj
Creates a backup at project.pbxproj.bak
"""
import re
import sys
from pathlib import Path

if len(sys.argv) != 2:
    print("Usage: set_development_team.py TEAM_ID")
    sys.exit(1)

team_id = sys.argv[1]
proj_path = Path('ios/Runner.xcodeproj/project.pbxproj')
if not proj_path.exists():
    print(f"project.pbxproj not found at {proj_path}")
    sys.exit(1)

text = proj_path.read_text()
backup = proj_path.with_suffix(proj_path.suffix + '.bak')
backup.write_text(text)

# pattern finds PRODUCT_BUNDLE_IDENTIFIER line and optional following DEVELOPMENT_TEAM line
pattern = re.compile(r"(PRODUCT_BUNDLE_IDENTIFIER\s*=\s*.*?;\n)(\s*)(DEVELOPMENT_TEAM\s*=\s*.*?;\n)?", flags=re.S)

new_text, count = pattern.subn(lambda m: m.group(1) + m.group(2) + f"DEVELOPMENT_TEAM = {team_id};\n", text)

if count == 0:
    print("No PRODUCT_BUNDLE_IDENTIFIER occurrences found — nothing changed.")
    sys.exit(1)

proj_path.write_text(new_text)
print(f"DEVELOPMENT_TEAM set to {team_id} in {proj_path}")
print(f"Backup saved to {backup}")
