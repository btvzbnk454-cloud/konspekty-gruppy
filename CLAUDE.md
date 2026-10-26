# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A private, link-only static site where the owner shares exam-prep materials with classmates. All user-facing text is in Russian. No build step, no dependencies, no tests.

- Live: https://virus-1v4.pages.dev
- Repo: private GitHub `btvzbnk454-cloud/konspekty-gruppy`, branch `main`
- Deploy: Cloudflare Pages is connected to the repo with build output directory `site`. **Every push to `main` goes live in about a minute**, so pushing is publishing.

## Layout

- `site/` is the only deployed directory.
  - `site/index.html` is the home page, a "desk" (1600×900 layout scaled to the window; stacked on phones ≤860px) with a notebook, a weekly planner and a calendar. Inline CSS and JS, images in `site/img/web/`. In its script, `MATERIALS` (subject, kind, title, file, date, note) drives the notebook tabs, the "Обновления" note and the per-subject lists; `EVENTS` (date, kind, subject) drives РК marks in the planner and calendar; `WEEKS`/`TERM` hold the class schedule. Month and year are set from per-letter PNGs in `img/web/vyaz/<hex code>.png`.
  - `site/index.html` is generated from `drafts/stol.html` with comments stripped and `BASE` set to `m/`. Edit the draft, then regenerate with `drafts/build_site.py` (untracked; it replaces `BASE`, adds the old favicon, strips `/* */`, `//` and `<!-- -->` comments and copies `drafts/img/web` minus `vyaz-old`).
  - `site/m/*.html` are the materials. Each is a standalone page exported from a Claude artifact. Treat them as opaque and don't restyle them unless asked.
  - `site/robots.txt` and `site/_headers` (`X-Robots-Tag: noindex`) keep the site out of search engines.
- `drafts/` holds design mockups and `stol.html`, the commented source of the home page. It is untracked and not deployed. Draft links point to `../site/m/...`.
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
- `python` on PATH is the Microsoft Store stub and doesn't work, which is why the preview server is a PowerShell `HttpListener`. A real Python 3.12 with Pillow and numpy is at `C:\Users\zapas\AppData\Local\Programs\Python\Python312\python.exe`; `drafts/seg.py` and `drafts/cut.py` used it to cut the vyaz glyphs.
- Pixel fonts often lack proper Cyrillic. Pixelify Sans renders it wrongly. Press Start 2P, IBM Plex Mono and PT Mono are safe.
