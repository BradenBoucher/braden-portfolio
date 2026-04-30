#!/usr/bin/env bash
# apply.sh — one-shot ship. Backup tag + unpack + commit + push + vercel --prod.
# Run from ~/Downloads/braden-portfolio.

set -euo pipefail

ZIP="${1:-aero-cards.zip}"
TAG="pre-aero-cards-$(date +%Y%m%d-%H%M%S)"
COMMIT_MSG="feat: lighten cards (override aero.css), nudge hero icons further right"

[ -d .git ]       || { echo "✗ Not a git repo. cd into ~/Downloads/braden-portfolio."; exit 1; }
[ -f index.html ] || { echo "✗ No index.html here."; exit 1; }
[ -f "$ZIP" ]     || { echo "✗ Zip not found: $ZIP"; exit 1; }

# stash any uncommitted work so the tag captures it
if ! git diff-index --quiet HEAD --; then
  git add -A
  git commit -m "WIP: snapshot before $COMMIT_MSG" || true
fi

# tag rollback point + push
git tag "$TAG"
git push origin HEAD
git push origin "$TAG"

# unpack + ship
unzip -o "$ZIP" index.html -d .
git add index.html
git commit -m "$COMMIT_MSG"
git push
vercel --prod

echo ""
echo "✓ Shipped. Rollback tag: $TAG"
echo "  git reset --hard $TAG && git push --force-with-lease && vercel --prod"
