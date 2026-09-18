# Deploying to GitHub Pages

This project is served from the `gh-pages` branch at:
`https://sam-stud.github.io/Portfolio/`

The `gh-pages` branch only contains the compiled web build (`index.html`, `main.dart.js`, etc.) — it is **not** kept in sync automatically with `main` or `dev`. Every time you want the live site to reflect your latest code, you need to rebuild and redeploy manually using the steps below.

## Steps to update the live site

1. **Make sure you're on your working branch** (e.g. `main` or `dev`) with your latest changes committed.

2. **Build the web app**, from the Flutter project root:
   ```bash
   flutter build web --base-href "/Portfolio/"
   ```

3. **Switch to the `gh-pages` branch:**
   ```bash
   git checkout gh-pages
   ```

4. **Clear out the old build files** (everything except `.git`), then copy the new build to the repo root:
   ```bash
   find . -maxdepth 1 ! -name '.git' ! -name '.' -exec rm -rf {} +
   cp -r build/web/* .
   cp build/web/.nojekyll . 2>/dev/null || touch .nojekyll
   ```

5. **Commit and push:**
   ```bash
   git add -A
   git commit -m "Deploy latest build"
   git push origin gh-pages
   ```

6. **Switch back to your working branch:**
   ```bash
   git checkout main
   ```

7. Give GitHub Pages a minute or two to redeploy, then refresh the site.

## Notes

- `index.html` and the other build files must live at the **root** of the `gh-pages` branch — not in a subfolder — or GitHub Pages won't find them.
- The `.nojekyll` file must exist at the root to stop GitHub from running Jekyll processing on the build output.
- The `--base-href "/Portfolio/"` flag must match the repo name exactly (case-sensitive) or assets won't load correctly.
