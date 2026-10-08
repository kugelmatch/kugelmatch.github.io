# KugelMatch website

GitHub Pages site for [KugelMatch](https://github.com/Grumbel/kugelmatch):
play the WebAssembly build in the browser and download Windows, Android, and
R36S (PortMaster) packages built from the same revision.

## Layout

| Path | Content |
|------|---------|
| `index.html` | Landing page (`@version@` substituted at build time) |
| `images/` | Screenshots |
| `play/` | WASM build from `.#kugelmatch-wasm` (produced by Nix) |
| `downloads/` | Win32/64 zips, APK, R36S PortMaster zip (produced by Nix) |

## Build

```bash
nix build          # result/ is the static site
nix run .#serve    # serve result/ on http://127.0.0.1:8765/
```

The flake input `kugelmatch` points at `git+https://github.com/Grumbel/kugelmatch`.
Pin or override it when you want a specific game revision:

```bash
nix build --override-input kugelmatch /path/to/kugelmatch
```

## Deploy

Push to `master`/`main`; `.github/workflows/pages.yml` builds with Nix and
deploys the `result` directory to GitHub Pages.

Suggested repo name: **`kugelmatch.github.io`** (user/org site) or
**`kugelmatch`** with Pages source = GitHub Actions.
