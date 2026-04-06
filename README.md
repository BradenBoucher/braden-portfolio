# Braden Boucher — Portfolio Site

## Setup (all from terminal)

### 1. Unzip and enter the project
```bash
unzip braden-portfolio.zip -d braden-portfolio
cd braden-portfolio
```

### 2. Init git repo
```bash
git init
git add .
git commit -m "Initial portfolio site"
```

### 3. Create GitHub repo and push
```bash
# Create repo on GitHub (install gh CLI if needed: brew install gh)
gh repo create braden-portfolio --public --source=. --push
```

### 4. Deploy to Vercel
```bash
# Install Vercel CLI if needed: npm i -g vercel
vercel
# Follow the prompts — it'll auto-detect static site
# For production: vercel --prod
```

### 5. Custom domain (optional)
```bash
vercel domains add yourdomain.com
# Then point your DNS A record to 76.76.21.21
```

That's it — live site in ~2 minutes.
