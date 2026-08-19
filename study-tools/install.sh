#!/usr/bin/env bash
#
# install.sh — Make `studyprep` runnable from anywhere, and set up the study hub.
#
# Does three things:
#   1. Runs setup.sh (creates the Python environment + installs MarkItDown)
#   2. Links `studyprep` into a folder on your PATH
#   3. Creates ~/Desktop/StudyMaterials with a starter subject folder
#
# USAGE:
#   ./study-tools/install.sh
#
# Safe to re-run.

set -uo pipefail

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -P "$SCRIPT_DIR/.." && pwd)"
HUB="${STUDYPREP_HUB:-$HOME/Desktop/StudyMaterials}"

echo "==> Step 1/3: Python environment and MarkItDown"
if ! "$SCRIPT_DIR/setup.sh"; then
  echo "ERROR: setup failed. Fix the errors above and re-run." >&2
  exit 1
fi

echo
echo "==> Step 2/3: Making 'studyprep' available from any folder"
chmod +x "$SCRIPT_DIR/studyprep" "$SCRIPT_DIR/setup.sh" 2>/dev/null

# Prefer /usr/local/bin (already on PATH on macOS); fall back to ~/.local/bin.
BIN_DIR=""
if [ -d "/usr/local/bin" ] && [ -w "/usr/local/bin" ]; then
  BIN_DIR="/usr/local/bin"
else
  BIN_DIR="$HOME/.local/bin"
  mkdir -p "$BIN_DIR"
fi

ln -sf "$SCRIPT_DIR/studyprep" "$BIN_DIR/studyprep"
echo "Linked: $BIN_DIR/studyprep -> $SCRIPT_DIR/studyprep"

# Make sure that folder is actually on PATH; if not, add it to the shell profile.
case ":$PATH:" in
  *":$BIN_DIR:"*)
    echo "$BIN_DIR is already on your PATH."
    ;;
  *)
    # macOS defaults to zsh; fall back to bash profile if that's the shell.
    if [ -n "${ZSH_VERSION:-}" ] || [ "$(basename "${SHELL:-}")" = "zsh" ]; then
      PROFILE="$HOME/.zshrc"
    else
      PROFILE="$HOME/.bash_profile"
    fi
    LINE="export PATH=\"$BIN_DIR:\$PATH\""
    if ! grep -qsF "$LINE" "$PROFILE"; then
      printf '\n# Added by markitdown study-tools installer\n%s\n' "$LINE" >> "$PROFILE"
      echo "Added $BIN_DIR to your PATH in $PROFILE"
    fi
    echo "NOTE: open a new Terminal window (or run: source $PROFILE) to pick this up."
    ;;
esac

echo
echo "==> Step 3/3: Study hub folder"
mkdir -p "$HUB/Example-Subject"
if [ ! -f "$HUB/Example-Subject/urls.txt" ]; then
  cat > "$HUB/Example-Subject/urls.txt" <<'EOF'
# Put one link per line — YouTube videos or article/web pages.
# Lines starting with # are ignored.
#
# https://www.youtube.com/watch?v=VIDEO_ID
# https://en.wikipedia.org/wiki/Photosynthesis
EOF
fi
echo "Study hub ready: $HUB"

cat <<EOF

============================================================
✅ All set.

How to use it from now on:

  1. In Finder, open:  $HUB
  2. Make a folder for a subject (e.g. "Pharmacology")
  3. Drag your PDFs / PowerPoints / Word docs into it
     (optional) put YouTube + article links in urls.txt
  4. In Terminal, from anywhere, run:

         studyprep Pharmacology

  5. Drag the new "markdown" folder into a Claude Project.

Prefer not to use Terminal? Double-click:
  $SCRIPT_DIR/StudyPrep.command

============================================================
EOF
