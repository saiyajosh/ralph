#!/bin/bash
# flick.sh — Ralph cleanup utility
# Finds and deletes Ralph intermediary files (prd.json, progress.txt).
# Run this from your project directory after a successful Ralph run.
#
# Usage: bash /path/to/ralph/flick.sh [--nuke]
#   --nuke  Skip confirmation prompts and delete all files immediately

nuke=false
project_dir="${PWD}"

[[ "$1" == "--nuke" ]] && nuke=true

search_dirs=(
  "${project_dir}"
  "${project_dir}/ralph"
  "${project_dir}/.agents/ralph"
  "${project_dir}/.claude/ralph"
  "${HOME}/.agents/ralph"
  "${HOME}/.claude/ralph"
)

found_any=false

for dir in "${search_dirs[@]}"; do
  dir_files=()
  for fname in prd.json progress.txt; do
    [[ -f "${dir}/${fname}" ]] && dir_files+=("${dir}/${fname}")
  done

  [[ ${#dir_files[@]} -eq 0 ]] && continue
  found_any=true

  echo ""
  echo "════════════════════════════════════════"
  echo "Location: ${dir}"

  filenames=()
  for f in "${dir_files[@]}"; do
    filenames+=("$(basename "$f")")
  done
  echo "Files:    $(IFS=', '; echo "${filenames[*]}")"

  prd="${dir}/prd.json"
  if [[ -f "$prd" ]]; then
    echo ""
    echo "── prd.json (first 15 lines) ──────────"
    head -15 "$prd"
  fi

  echo ""

  if $nuke; then
    for f in "${dir_files[@]}"; do
      rm "$f" && echo "  Deleted: $f"
    done
  else
    read -p "Delete these files? (y/n) " reply
    echo ""
    if [[ "$reply" =~ ^[Yy]$ ]]; then
      for f in "${dir_files[@]}"; do
        rm "$f" && echo "  Deleted: $f"
      done
    else
      echo "  Skipped."
    fi
  fi
done

if ! $found_any; then
  echo "No Ralph files found in any expected location."
else
  echo ""
  echo "════════════════════════════════════════"
  echo "Done."
fi
