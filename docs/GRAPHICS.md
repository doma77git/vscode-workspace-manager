# Graphics — ASCII Art & Box-Drawing Reference

Style guide for all terminal output in the project. Every script uses these patterns consistently.

---

## Box-Drawing Characters (Unicode)

```
╔══════════════╗     ╔  U+2554  Box Drawings Double Down and Right
║  Title       ║     ║  U+2551  Box Drawings Double Vertical
╠══════════════╣     ╠  U+2560  Box Drawings Double Vertical and Right
║  Content     ║     ╣  U+2563  Box Drawings Double Vertical and Left
╚══════════════╝     ╚  U+255A  Box Drawings Double Up and Right
                      ═  U+2550  Box Drawings Double Horizontal
```

## Banners

Used for all script headers:

```powershell
Write-Host "╔══════════════════════════════════════════════════╗" -F Cyan
Write-Host "║" -NoNewline -F Cyan
Write-Host "  $emoji  $title" -F White -NoNewline
# Pad to 46 chars total
$padding = 46 - $title.Length - 4
if ($padding -gt 0) { Write-Host (" " * $padding) -NoNewline }
Write-Host "║" -F Cyan
Write-Host "╚══════════════════════════════════════════════════╝" -F Cyan
```

## Section Dividers

```powershell
Write-Host "  ── Section Name ──────────────────────────────" -F DarkGray
# Dashes fill to 50 chars
Write-Host ("  {0} {1}" -f "──", "Section" + ("─" * (50 - $name.Length)))
```

## Pass / Fail / Warn

```powershell
Write-Pass "file.json" "valid"        # ✅  file.json                         valid
Write-Fail "bad.ps1"  "error at L5"   # ❌  bad.ps1                           error at L5
Write-Warn "optional" "not installed" # ⚠️   optional                          not installed
```

Alignment: label padded to 35 chars, detail right-aligned.

## Result Bar

```powershell
Write-Host "  ── Result ────────────────────────────────────" -F DarkGray
if ($pass) { Write-Host "  ✅  $text" -F Green }
else       { Write-Host "  ❌  $text" -F Red }
```

## Color Palette

| Purpose | Color | `-ForegroundColor` |
|---------|-------|--------------------|
| Headers, borders | Cyan | `Cyan` |
| Titles, key text | White | `White` |
| Pass, success | Green | `Green` |
| Fail, error | Red | `Red` |
| Warning, caution | Yellow | `Yellow` |
| Detail, secondary | DarkGray | `DarkGray` |
| Background labels | DarkGray | `DarkGray` |

## Emoji Icons

```
✅ PASS      ❌ FAIL      ⚠️  WARN      ℹ️  INFO
🧪 Test      🔍 Search    📁 Folder    📄 File
📖 Doc       📋 List      📊 Stats     📦 Package
🔧 Tool      🛠️  Setup    🔑 Key       🛡️  Shield
🚀 Launch    💾 Save      🔄 Sync      ⏰ Clock
💡 Idea      🎯 Target    🧭 Nav       🔬 Inspect
⚡ Fast      🎬 Demo      🏗️  Build    🚪 Exit
🆕 New       👤 Profile   📚 Library   ✅ Check
```

## Menu Layout

```
╔════════════════════════════════════════════════╗   ← 48-wide box
║  ⚙️  VS Code Workspace Manager v1.1.0         ║   ← Title with emoji + version
╠════════════════════════════════════════════════╣   ← Separator
║  📁 Templates: N  │  📋 Profiles: M            ║   ← Live stats
╚════════════════════════════════════════════════╝

  ── Section ────────────────────────────────────     ← Section header (DarkGray)
   1) 📄 Description                                  ← Menu item (4-space indent)
   ...
   0) 🚪 Exit                                         ← Exit item

> Select                                            ← Prompt
```

## Summary Table

```
PowerShell : 18 passed, 0 failed     ← Green if 0 fail, Red otherwise
JSON       : 10 passed, 0 failed
YAML       :  5 passed, 0 failed
Total      : 33 checks
```

## ASCII Fallbacks (if Unicode fails)

```
+==============+     Instead of ╔══╗
|  Title       |     Instead of ║  ║
+==============+     Instead of ╚══╝

[OK]   instead of ✅
[FAIL] instead of ❌
[WARN] instead of ⚠️
[INFO] instead of ℹ️
```
