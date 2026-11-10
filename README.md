# Design

The site uses the **Tempered steel** theme: blued-steel darks, a brushed-steel
light mode and the heat-tint gradient of tempered steel (straw to blue) as its
one signature element, with Big Shoulders for headlines and IBM Plex Sans for
text. It was designed in Figma:
[Portfolio — Tempered steel redesign + Synapse OS showcase](https://www.figma.com/design/OGWIDIf19lEsgXTltUo4sq)
(the colour variables there match `portfolio/lib/theme/palette.dart`).

The Synapse OS section shows the real iPhone and Mac screens from the app's own
design file, as 2x WebP renders in `portfolio/assets/synapse/`. The device
frames are drawn in `portfolio/lib/widgets/devices.dart` to match the Figma
"Device" components, so their shadows stay transparent in both themes.

# Deploying to GitHub Pages

This project is served from the `gh-pages` branch at:
[`https://samuelrosengarten.github.io/Portfolio/`](https://samuelrosengarten.github.io/Portfolio/)

The `gh-pages` branch only contains the compiled web build (`index.html`, `main.dart.js`, etc.) — it is **not** kept in sync automatically with `main` or `dev`. Every time you want the live site to reflect your latest code, you need to rebuild and redeploy manually using the steps below.

## Steps to update the live site

1. **Make sure you're on your working branch** (e.g. `main` or `dev`) with your latest changes committed.

2. **Build the web app**, from the Flutter project root:
   ```bash
   flutter build web --base-href "/Portfolio/"
   ```
## Notes

- `index.html` and the other build files must live at the **root** of the `gh-pages` branch — not in a subfolder — or GitHub Pages won't find them.
- The `.nojekyll` file must exist at the root to stop GitHub from running Jekyll processing on the build output.
- The `--base-href "/Portfolio/"` flag must match the repo name exactly (case-sensitive) or assets won't load correctly.
