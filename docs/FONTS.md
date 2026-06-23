# Fonts — Recommended Setup

For the best terminal experience with this project.

---

## Recommended: Nerd Font

Nerd Fonts patch developer fonts with extra glyphs (icons, symbols, powerline symbols).

**Recommended font:** `CaskaydiaCove Nerd Font` (Cascadia Code + Nerd Font)

### Install

```powershell
# Option A: Direct download
# https://github.com/ryanoasis/nerd-fonts/releases
# → Download CaskaydiaCove.zip → Extract → Install all .ttf files

# Option B: winget (Windows)
winget install XP8K1G4FQJX4F0  # Cascadia Code
# Then download Nerd Font patched version from releases

# Option C: brew (macOS)
brew install font-caskaydia-cove-nerd-font

# Option D: Linux
# Download from https://github.com/ryanoasis/nerd-fonts/releases
# Copy to ~/.local/share/fonts/ → fc-cache -fv
```

### Configure VS Code

```json
{
  "terminal.integrated.fontFamily": "CaskaydiaCove Nerd Font",
  "editor.fontFamily": "CaskaydiaCove Nerd Font, Consolas, monospace",
  "terminal.integrated.fontSize": 14
}
```

---

## Fallback Fonts (no Nerd Font)

If Nerd Font is not available, the project falls back to standard Unicode emoji. These work in any modern terminal:

- ✅❌⚠️ℹ️⚡ — basic status icons (always available)
- 📁📋📄📖 — document icons (available on Windows 10+)
- ⚙️🛡️🔑🔧 — tool icons (available on most systems)

---

## Terminal Compatibility

| Terminal | Nerd Font | Unicode Emoji | Box Drawing |
|----------|-----------|---------------|-------------|
| Windows Terminal | ✅ Full | ✅ Full | ✅ ╭╮╰╯ |
| VS Code Terminal | ✅ Full | ✅ Full | ✅ ╭╮╰╯ |
| PowerShell ISE | ❌ | ⚠️ Limited | ⚠️ ─ only |
| cmd.exe | ❌ | ❌ | ❌ |
| Git Bash | ✅ | ✅ | ✅ |
| WSL Terminal | ✅ | ✅ | ✅ |
| macOS Terminal | ✅ | ✅ Full | ✅ |
| iTerm2 | ✅ Full | ✅ Full | ✅ Full |
| GNOME Terminal | ✅ | ✅ | ✅ |

---

## VS Code Profile Font Settings

Add to any profile JSON:

```json
{
  "settings": "{\"terminal.integrated.fontFamily\":\"CaskaydiaCove Nerd Font\",\"editor.fontFamily\":\"CaskaydiaCove Nerd Font\",\"terminal.integrated.fontSize\":14,\"editor.fontSize\":14}"
}
```

---

## ASCII Fallback Mode

If Unicode rendering is broken, set this in your terminal:

```powershell
# PowerShell: force ASCII code page
[Console]::OutputEncoding = [Text.Encoding]::ASCII
```

The project's scripts will still work — box-drawing characters will render as `+---+` and emoji as `[OK]`/`[FAIL]`.
