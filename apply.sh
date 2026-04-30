#!/usr/bin/env bash
set -uo pipefail

ZIP="${1:-aero-pop3d.zip}"
TAG="pre-aero-pop3d-$(date +%Y%m%d-%H%M%S)"
COMMIT_MSG="feat: 3D pop containers — diagonal gloss + radial pool + dark frame + stacked shadows; remove canary X"

[ -d .git ]       || { echo "✗ Not a git repo."; exit 1; }
[ -f index.html ] || { echo "✗ No index.html."; exit 1; }
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
  echo "→ index.html unchanged — skipping commit."
else
  git commit -m "$COMMIT_MSG"
  git push
fi

vercel --prod

echo ""
echo "✓ Shipped. Rollback tag: $TAG"
echo "  git reset --hard $TAG && git push --force-with-lease && vercel --prod"
