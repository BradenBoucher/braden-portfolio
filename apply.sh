#!/usr/bin/env bash
# apply.sh — backup, unpack, commit-if-needed, ALWAYS deploy.
# Run from ~/Downloads/braden-portfolio.

set -uo pipefail

ZIP="${1:-aero-deep.zip}"
TAG="pre-aero-deep-$(date +%Y%m%d-%H%M%S)"
COMMIT_MSG="feat: deep Aero — skeuo buttons, inner glow halos, aurora streaks, embossed type"

[ -d .git ]       || { echo "✗ Not a git repo. cd into ~/Downloads/braden-portfolio."; exit 1; }
[ -f index.html ] || { echo "✗ No index.html here."; exit 1; }
[ -f "$ZIP" ]     || { echo "✗ Zip not found: $ZIP"; exit 1; }

if ! git diff-index --quiet HEAD --; then
  git add -A
  git commit -m "WIP: snapshot before $COMMIT_MSG" || true
fi

git tag "$TAG"
git push origin HEAD
git push origin "$TAG"

unzip -o "$ZIP" index.html -d .

git add index.html
if git diff --cached --quiet; then
  echo "→ index.html unchanged from current HEAD — skipping commit."
else
  git commit -m "$COMMIT_MSG"
  git push
fi

echo "→ vercel --prod (always)..."
vercel --prod

echo ""
echo "✓ Shipped. Rollback tag: $TAG"
echo "  git reset --hard $TAG && git push --force-with-lease && vercel --prod"
