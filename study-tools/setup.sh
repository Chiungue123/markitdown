#!/usr/bin/env bash
#
# setup.sh — One-time setup for the study-materials → Markdown workflow.
#
# Creates a Python virtual environment and installs MarkItDown with all
# converters, so the very next thing you can do is run ./convert.sh.
#
# USAGE:
#   ./study-tools/setup.sh
#
# Safe to re-run: it reuses an existing .venv instead of recreating it.

set -euo pipefail

# Resolve paths (this script lives in study-tools/; the venv goes in the repo root).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
VENV_DIR="$REPO_ROOT/.venv"

# --- Find a Python 3.10+ interpreter -------------------------------------------
PYTHON_BIN=""
for cand in python3 python; do
  if command -v "$cand" >/dev/null 2>&1; then
    ver="$("$cand" -c 'import sys; print("%d.%d" % sys.version_info[:2])')"
    major="${ver%%.*}"; minor="${ver##*.}"
    if [ "$major" -eq 3 ] && [ "$minor" -ge 10 ]; then PYTHON_BIN="$cand"; break; fi
  fi
done
if [ -z "$PYTHON_BIN" ]; then
  echo "ERROR: Python 3.10 or newer is required but was not found." >&2
  echo "Install it from https://www.python.org/downloads/ and re-run this script." >&2
  exit 1
fi
echo "Using $("$PYTHON_BIN" --version) ($(command -v "$PYTHON_BIN"))"

# --- Create (or reuse) the virtual environment ---------------------------------
if [ ! -d "$VENV_DIR" ]; then
  echo "Creating virtual environment at $VENV_DIR ..."
  "$PYTHON_BIN" -m venv "$VENV_DIR"
else
  echo "Reusing existing virtual environment at $VENV_DIR"
fi

# --- Install MarkItDown --------------------------------------------------------
# shellcheck disable=SC1091
source "$VENV_DIR/bin/activate"
echo "Upgrading pip ..."
python -m pip install --quiet --upgrade pip
echo "Installing markitdown[all] (this can take a minute) ..."
python -m pip install --quiet 'markitdown[all]'

# --- Done ----------------------------------------------------------------------
cat <<EOF

✅ Setup complete.

Next steps:
  1) Activate the environment (do this in each new terminal):
       source "$VENV_DIR/bin/activate"
       # Windows (PowerShell): $VENV_DIR\\Scripts\\Activate.ps1
  2) Put your files in study-tools/input/
     (and any YouTube links, one per line, in study-tools/input/youtube-urls.txt)
  3) Convert everything to Markdown:
       ./study-tools/convert.sh
  4) Upload the .md files from study-tools/markdown/ into a Claude Project.

See study-tools/STUDY-GUIDE.md for the full walkthrough.
EOF
