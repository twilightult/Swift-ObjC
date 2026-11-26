# MCShell engine (private)

Private repo. Swift + Objective-C + Metal. Zero JIT, zero WebView, all AOT.
Launcher shell lives in the public repo; this repo only builds the IPA.

## Layout

All files sit flat at repo root on purpose. No subdirectories to create.

```
repo-root/
  .gitignore
  README.md
  project.yml
  Info.plist
  Shaders.metal
  MCMemoryProbe.h / .m
  MCShell-Bridging-Header.h
  AppDelegate.swift
  GameVC.swift
  ChunkMesh.swift
  TextureAtlas.swift
  AssetImporter.swift
  MemoryBudget.swift
  TitleView.swift
  .github/workflows/build.yml   <- the ONLY file with a path
```

## Upload order (iPad / GitHub web)

1. Add file -> Upload files -> multi-select all 15 flat files. They land at root.
2. Add file -> Create new file -> name it exactly
   `.github/workflows/build.yml` (the slashes create the folders), paste the
   workflow content, commit. This is the only path-typed file.
3. Commit .gitignore from the same Create new file screen if the dotfile was
   hidden in Files app.

## Build

- `xcodegen generate` -> `xcodebuild archive CODE_SIGNING_ALLOWED=NO`
- CI packs `MCShell.app` straight into an unsigned IPA. No Export.plist, no
  certificate, no secrets in the pipeline.
- Sign locally once (Sideloadly / SideStore), install on a NON-jailbroken
  device for acceptance. A jailbroken iPad hides every signature problem.

## Assets

User imports 16x16 PNGs via Files app into Documents/assets/. If nothing is
imported, TextureAtlas falls back to three solid 16x16 colors so the first
frame still renders. CI never checks out any asset directory.

Ticket / versionSalt / watermark coordinates are generated offline and never
enter this repo or the workflow.
