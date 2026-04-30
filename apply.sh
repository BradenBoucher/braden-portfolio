#!/usr/bin/env bash
# apply.sh — backup + unpack + commit-if-needed + ALWAYS deploy.
# Run from ~/Downloads/braden-portfolio.

set -uo pipefail   # NOT -e — we handle non-zero ourselves so deploy always runs

ZIP="${1:-aero-final.zip}"
TAG="pre-aero-final-$(date +%Y%m%d-%H%M%S)"
COMMIT_MSG="feat: unify all containers to light Aero glass"

[ -d .git ]       || { echo "✗ Not a git repo. cd into ~/Downloads/braden-portfolio."; exit 1; }
[ -f index.html ] || { echo "✗ No index.html here."; exit 1; }
[ -f "$ZIP" ]     || { echo "✗ Zip not found: $ZIP"; exit 1; }

# 1. capture any uncommitted work as a snapshot
if ! git diff-index --quiet HEAD --; then
  git add -A
  git commit -m "WIP: snapshot before $COMMIT_MSG" || true
fi

# 2. tag rollback point + push
git tag "$TAG"
git push origin HEAD
git push origin "$TAG"

# 3. unpack new index.html
unzip -o "$ZIP" index.html -d .

# 4. commit only if there's a real diff (don't fail if not)
git add index.html
if git diff --cached --quiet; then
  echo "→ index.html unchanged from current HEAD — skipping commit."
else
  git commit -m "$COMMIT_MSG"
  git push
fi

# 5. ALWAYS deploy — production may be behind even if HEAD is current
echo "→ vercel --prod (always)..."
vercel --prod

echo ""
echo "✓ Shipped. Rollback tag: $TAG"
echo "  git reset --hard $TAG && git push --force-with-lease && vercel --prod"
