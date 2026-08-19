#!/usr/bin/env bash
#
# StudyPrep.command — Double-click this file in Finder to convert a subject folder.
#
# macOS treats a .command file as double-clickable: it opens Terminal and runs this
# script. No typing required — it lists your subject folders and you pick a number.
#
# (If double-clicking says "cannot be opened", run this once in Terminal:
#      chmod +x "/path/to/StudyPrep.command"
#  or right-click the file -> Open -> Open.)

set -uo pipefail

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HUB="${STUDYPREP_HUB:-$HOME/Desktop/StudyMaterials}"

clear
echo "============================================"
echo "        StudyPrep — files to Markdown"
echo "============================================"
echo

if [ ! -d "$HUB" ]; then
  echo "Your study hub folder doesn't exist yet:"
  echo "  $HUB"
  echo
  echo "Run the installer first:"
  echo "  $SCRIPT_DIR/install.sh"
  echo
  read -r -p "Press Return to close..." _
  exit 1
fi

# Collect subject folders (skip the generated output folders).
subjects=()
for d in "$HUB"/*/; do
  [ -d "$d" ] || continue
  name="$(basename "$d")"
  [ "$name" = "markdown" ] && continue
  subjects+=("$name")
done

if [ "${#subjects[@]}" -eq 0 ]; then
  echo "No subject folders found in:"
  echo "  $HUB"
  echo
  echo "Create a folder there (e.g. 'Pharmacology'), drag your files in,"
  echo "then double-click this again."
  echo
  read -r -p "Press Return to close..." _
  exit 1
fi

echo "Which subject do you want to convert?"
echo
i=1
for s in "${subjects[@]}"; do
  printf "  %2d) %s\n" "$i" "$s"
  i=$((i + 1))
done
printf "  %2d) ALL of them\n" "$i"
echo

read -r -p "Enter a number: " choice
echo

# Validate the choice.
case "$choice" in
  ''|*[!0-9]*)
    echo "That wasn't a number. Nothing was converted."
    read -r -p "Press Return to close..." _
    exit 1 ;;
esac

if [ "$choice" -eq "$i" ]; then
  for s in "${subjects[@]}"; do
    echo "--------------------------------------------"
    echo "Converting: $s"
    "$SCRIPT_DIR/studyprep" "$s"
  done
elif [ "$choice" -ge 1 ] && [ "$choice" -lt "$i" ]; then
  idx=$((choice - 1))
  "$SCRIPT_DIR/studyprep" "${subjects[$idx]}"
else
  echo "No such option. Nothing was converted."
  read -r -p "Press Return to close..." _
  exit 1
fi

echo
echo "============================================"
echo "Finished. You can close this window."
echo "Drag the 'markdown' folder into a Claude Project."
echo "============================================"
echo
read -r -p "Press Return to close..." _
