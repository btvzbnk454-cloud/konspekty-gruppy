# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A private, link-only static site where the owner shares exam-prep materials with classmates. All user-facing text is in Russian. No build step, no dependencies, no tests.

- Live: https://virus-1v4.pages.dev
- Repo: private GitHub `btvzbnk454-cloud/konspekty-gruppy`, branch `main`
- Deploy: Cloudflare Pages is connected to the repo with build output directory `site`. **Every push to `main` goes live in about a minute**, so pushing is publishing.

## Layout

- `site/` is the only deployed directory.
  - `site/index.html` is the home page: a self-contained page with inline CSS and JS. The `MATERIALS` array in its script is the single source of truth for what appears on the home page (subject, kind, title, file, date, note). Sections, filter chips and the "новое" badge (last 7 days) are all derived from that array.
  - `site/m/*.html` are the materials. Each is a standalone page exported from a Claude artifact. Treat them as opaque and don't restyle them unless asked.
  - `site/robots.txt` and `site/_headers` (`X-Robots-Tag: noindex`) keep the site out of search engines.
- `drafts/` holds design mockups for a home page redesign. It is untracked and not deployed. Draft links point to `../site/m/...`.
- `КАК-ОПУБЛИКОВАТЬ.md` is the owner-facing guide, in Russian.

## Adding a material

1. Get the artifact's HTML. With the Artifact tool, use `action: "read"`, `path: "index.html"`. The saved path can exceed Windows' 260-char limit, so copy it with .NET `[IO.File]` APIs and a `\\?\` prefix instead of `Get-ChildItem` or `Copy-Item`.
2. Save it as `site/m/<latin-slug>.html` and insert `<meta name="robots" content="noindex,nofollow">` right after `<head>`.
3. Add an entry to `MATERIALS` in `site/index.html`.
4. Commit and push to `main`.

Some materials call `window.claude.use("db" | "user")` to sync progress when opened inside Claude. They already fall back to `localStorage` when `window.claude` is absent, so they work on the static host as-is. Keep that fallback intact if you edit one.

## Commands

Local preview (`.claude/launch.json` defines both configs for `preview_start`):

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File serve.ps1                       # site/ on :8080
powershell -NoProfile -ExecutionPolicy Bypass -File serve.ps1 -Root . -Port 8081    # repo root on :8081, for drafts/
```

`build-zip.ps1` packs `site/` into `site.zip` (gitignored) with forward-slash entry paths. It is only needed for manual uploads; normal deploys go through git.

## Environment gotchas

- Windows PowerShell 5.1 reads BOM-less `.ps1` files as ANSI, so **keep PowerShell scripts ASCII-only**. Cyrillic in a script breaks parsing.
- Git and the GitHub CLI were installed via winget and may be missing from PATH in the Bash tool. Prepend `/c/Program Files/Git/cmd:/c/Program Files/GitHub CLI` if needed.
- `python` on this machine is the Microsoft Store stub and doesn't work. That's why the preview server is a PowerShell `HttpListener`.
- Pixel fonts often lack proper Cyrillic. Pixelify Sans renders it wrongly. Press Start 2P, IBM Plex Mono and PT Mono are safe.
