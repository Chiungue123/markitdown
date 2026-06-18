#!/usr/bin/env bash
#
# convert.sh — Batch-convert a folder of study materials into Markdown.
#
# Wraps the `markitdown` CLI (https://github.com/microsoft/markitdown) in a loop,
# so you can turn a whole folder of PDFs / PowerPoint / Word / Excel / HTML files —
# plus a list of YouTube URLs — into clean Markdown in one command. Markdown is far
# more token-efficient for Claude to read than the original binary files, which
# makes for cheaper, more focused study sessions.
#
# USAGE:
#   ./convert.sh [INPUT_DIR] [OUTPUT_DIR]
#
#   INPUT_DIR    Folder containing your source files. Default: ./input
#   OUTPUT_DIR   Folder where .md files are written.    Default: ./markdown
#
# YOUTUBE:
#   Put one YouTube URL per line in <INPUT_DIR>/youtube-urls.txt. Blank lines and
#   lines starting with # are ignored. Each video's title, description, metadata
#   and transcript are saved (the video must have captions/auto-captions).
#
# SETUP (one time):
#   python -m venv .venv && source .venv/bin/activate
#   pip install 'markitdown[all]'
#
# See STUDY-GUIDE.md (next to this script) for the full walkthrough, including how
# to load the resulting Markdown into a Claude Project for token-efficient studying.

set -euo pipefail

INPUT_DIR="${1:-./input}"
OUTPUT_DIR="${2:-./markdown}"

# --- Pre-flight: make sure markitdown is installed ------------------------------
if ! command -v markitdown >/dev/null 2>&1; then
  cat >&2 <<'EOF'
ERROR: the `markitdown` command was not found on your PATH.

Install it first (Python 3.10+ required):

    python -m venv .venv
    source .venv/bin/activate          # Windows: .venv\Scripts\activate
    pip install 'markitdown[all]'

Then re-run this script.
EOF
  exit 1
fi

if [ ! -d "$INPUT_DIR" ]; then
  echo "ERROR: input directory '$INPUT_DIR' does not exist." >&2
  echo "Create it and drop your PDFs/PPTX/DOCX files in, then re-run." >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

converted=0
failed=0

# --- Convert one file, reporting success/failure --------------------------------
convert_one() {
  # $1 = source path, $2 = destination .md path, $3 = label for logging
  local src="$1" dst="$2" label="$3"
  if markitdown "$src" -o "$dst" 2>/dev/null; then
    echo "  ✓ $label -> $dst"
    converted=$((converted + 1))
  else
    echo "  ✗ $label (conversion failed — is the right extra installed?)" >&2
    failed=$((failed + 1))
  fi
}

# --- 1) Local files -------------------------------------------------------------
echo "Converting files in '$INPUT_DIR' -> '$OUTPUT_DIR' ..."
shopt -s nullglob nocaseglob
for src in "$INPUT_DIR"/*.pdf "$INPUT_DIR"/*.pptx "$INPUT_DIR"/*.docx \
           "$INPUT_DIR"/*.xlsx "$INPUT_DIR"/*.html "$INPUT_DIR"/*.htm; do
  base="$(basename "$src")"
  name="${base%.*}"
  convert_one "$src" "$OUTPUT_DIR/$name.md" "$base"
done
shopt -u nullglob nocaseglob

# --- 2) YouTube URLs ------------------------------------------------------------
urls_file="$INPUT_DIR/youtube-urls.txt"
if [ -f "$urls_file" ]; then
  echo "Converting YouTube URLs from '$urls_file' ..."
  while IFS= read -r url || [ -n "$url" ]; do
    # Trim whitespace; skip blanks and comments.
    url="$(echo "$url" | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    [ -z "$url" ] && continue
    case "$url" in \#*) continue ;; esac

    # Build a filesystem-safe name from the video id (or a fallback slug).
    slug="$(echo "$url" | sed -n 's/.*[?&]v=\([A-Za-z0-9_-]\{6,\}\).*/\1/p')"
    if [ -z "$slug" ]; then
      slug="$(echo "$url" | sed 's#https\?://##; s/[^A-Za-z0-9_-]/_/g' | cut -c1-60)"
    fi
    convert_one "$url" "$OUTPUT_DIR/youtube-$slug.md" "$url"
  done < "$urls_file"
fi

# --- Summary --------------------------------------------------------------------
echo "------------------------------------------------------------"
echo "Done: $converted converted, $failed failed. Output in '$OUTPUT_DIR'."
if [ "$converted" -eq 0 ] && [ "$failed" -eq 0 ]; then
  echo "Nothing to convert. Add files to '$INPUT_DIR' (and/or a youtube-urls.txt)."
fi
