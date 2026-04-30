#!/usr/bin/env bash
# Apply aero-parallax-v2 patch: snapshot → unzip → commit → push → deploy.
# Usage: bash apply.sh <path-to-aero-parallax-v2.zip>
set -euo pipefail

ZIP="${1:-}"
if [[ -z "$ZIP" || ! -f "$ZIP" ]]; then
  echo "Usage: bash apply.sh <path-to-aero-parallax-v2.zip>" >&2
  exit 1
fi

NAME="aero-parallax-v2"
STAMP="$(date +%Y%m%d-%H%M%S)"
TAG="pre-${NAME}-${STAMP}"
WIP_MSG="WIP: snapshot before feat: parallax v2 — dedicated fixed bg div + transform translate (rAF-throttled, motion-reduced)"
FEAT_MSG="feat: parallax v2 — dedicated fixed bg div + transform translate (rAF-throttled, motion-reduced)"

# 1. WIP snapshot of any uncommitted work
git add -A
if ! git diff --cached --quiet; then
  git commit -m "$WIP_MSG"
  git push
fi

# 2. Tag current HEAD as rollback point + push tag
git tag "$TAG"
git push origin "$TAG"

# 3. Unzip patch (only the actual file, not apply.sh itself)
unzip -o "$ZIP" index.html -d .

# 4. Commit + push if index.html actually changed
git add -A
if git diff --cached --quiet; then
  echo "→ index.html unchanged — skipping commit."
else
  git commit -m "$FEAT_MSG"
  git push
fi

# 5. Deploy
vercel --prod

# 6. Rollback hint
echo ""
echo "✓ Shipped. Rollback tag: $TAG"
echo "  git reset --hard $TAG && git push --force-with-lease && vercel --prod"
