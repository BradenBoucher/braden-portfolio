#!/usr/bin/env bash
# apply.sh — backup → unpack → preview → ship the cards-fix pass.
# Run from ~/Downloads/braden-portfolio.

set -euo pipefail

ZIP="${1:-aero-cards.zip}"
TAG="pre-aero-cards-$(date +%Y%m%d-%H%M%S)"
COMMIT_MSG="feat: lighten cards (override aero.css), nudge hero icons further right"

[ -d .git ]       || { echo "✗ Not a git repo. cd into ~/Downloads/braden-portfolio."; exit 1; }
[ -f index.html ] || { echo "✗ No index.html here."; exit 1; }
[ -f "$ZIP" ]     || { echo "✗ Zip not found: $ZIP — pass it explicitly:  bash apply.sh ~/Downloads/aero-cards.zip"; exit 1; }

echo "→ Repo:    $(pwd)"
echo "→ Branch:  $(git rev-parse --abbrev-ref HEAD)"
echo "→ Backup tag: $TAG"
echo ""
read -rp "Proceed with backup + unpack? [y/N] " yn
[[ "$yn" =~ ^[yY]$ ]] || { echo "aborted."; exit 1; }

if ! git diff-index --quiet HEAD --; then
  echo "→ Committing existing uncommitted changes first..."
  git add -A
  git commit -m "WIP: snapshot before cards-fix" || true
fi

echo "→ Tagging $TAG and pushing..."
git tag "$TAG"
git push origin HEAD
git push origin "$TAG"

echo "→ Unpacking $ZIP..."
unzip -o "$ZIP" index.html -d .

echo "→ Opening index.html for preview..."
open index.html
echo ""
read -rp "Ship to production (commit + push + vercel --prod)? [y/N] " ship
if [[ ! "$ship" =~ ^[yY]$ ]]; then
  echo ""
  echo "Held back. Files unpacked locally; only the backup tag was pushed."
  echo "  Manual ship:"
  echo "    git add index.html && git commit -m \"$COMMIT_MSG\" && git push && vercel --prod"
  echo "  Roll back:"
  echo "    git checkout -- index.html"
  echo "  (full reset:  git reset --hard $TAG && git push --force-with-lease)"
  exit 0
fi

echo "→ git add + commit + push..."
git add index.html
git commit -m "$COMMIT_MSG"
git push

echo "→ vercel --prod..."
vercel --prod

echo ""
echo "──────────────────────────────────────────────────────────"
echo "✓ Shipped. Rollback tag: $TAG"
echo "    git reset --hard $TAG && git push --force-with-lease && vercel --prod"
echo "──────────────────────────────────────────────────────────"
