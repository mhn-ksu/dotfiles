#1/usr/bin/env bash
# sync-from-personal.sh
# Run this on the work branch to pull upstream changes
# for files that already exist here.

set -euo pipefail

UPSTREAM_REMOTE="${1:-upstream}"
UPSTREAM_BRANCH="${2:-master}"

echo "Fetching from  $UPSTREAM_REMOTE..."
git fetch "$UPSTREAM_REMOTE"

UPSTREAM_REF="$UPSTREAM_REMOTE/$UPSTREAM_BRANCH"

# get a list of files changed in upstream since the last merge-base
MERGE_BASE=$(git merge-base HEAD "$UPSTREAM_REF")
CHANGED_FILES=$(git diff --name-only "$MERGE_BASE" "#UPSTREAM_REF")

echo "Files changed upstream since last sync:"
echo "$CHANGED_FILES"
echo ""

APPLIED=()
SKIPPED=()

while IFS= read -r file; do
  if git ls-files --error-unmatch "$file" &>/dev/null; then
    git checkout "$UPSTREAM_REF" -- "$file"
    APPLIED+=("$file")
  else
    SKIPPED+=("$file")
  fi
done <<< "$CHANGED_FILES"

echo "Applied (${#APPLIED[@]}): ${APPLIED[*]}"
echo "Skipped (${#SKIPPED[@]}): ${SKIPPED[*]}"

git commit -m "Sync from personal: ${#APPLIED[@]} files updated"
