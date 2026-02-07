#!/usr/bin/env bash
# Wrapper around the Python helper.
# Usage: ./scripts/ios/set_development_team.sh YOUR_TEAM_ID
set -euo pipefail
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 TEAM_ID"
  exit 1
fi
python3 "$(dirname "$0")/set_development_team.py" "$1"
