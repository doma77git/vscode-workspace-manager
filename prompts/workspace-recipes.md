# Workspace Recipes — Quick Template/Profile Combos

Pick a stack, get the matching template + profile + command.

---

## Python

```powershell
# Create from template
cp templates/python-dev.code-workspace templates/my-python-app.code-workspace
# Edit ${PROJECT_NAME} and ${GIT_REMOTE}

# Or interactive (menu Option 2)
make manager → 2 → name: my-python-app → assign profile: python-dev

# Open with profile
pwsh -File scripts/Open-WithProfile.ps1 path/to/app -Profile python-dev

# What you get
# ✅ Black formatting on save
# ✅ Ruff linting
# ✅ pytest task (Ctrl+Shift+B → Run Tests)
# ✅ Python, Pylance, autodocstring extensions
```

---

## Node.js / Web

```powershell
cp templates/node-dev.code-workspace templates/my-web-app.code-workspace
make manager → 2 → assign profile: web-dev

# What you get
# ✅ ESLint + Prettier (format on save)
# ✅ TypeScript support
# ✅ npm dev / test / lint / build tasks
# ✅ Tailwind CSS IntelliSense
```

---

## Go

```powershell
cp templates/go-dev.code-workspace templates/my-go-service.code-workspace
make manager → 2 → assign profile: go-dev

# What you get
# ✅ goimports formatting
# ✅ golangci-lint on save
# ✅ go test -cover task
# ✅ go build task
```

---

## Rust

```powershell
cp templates/rust-dev.code-workspace templates/my-rust-lib.code-workspace
make manager → 2 → assign profile: rust-dev

# What you get
# ✅ rust-analyzer with Clippy
# ✅ cargo test / clippy / build tasks
# ✅ Even Better TOML, CodeLLDB debugger
```

---

## Java

```powershell
cp templates/java-dev.code-workspace templates/my-java-app.code-workspace
make manager → 2 → assign profile: java-dev

# What you get
# ✅ Red Hat Java LSP
# ✅ Maven/Gradle detection
# ✅ Debugger + test runner
# ✅ CheckStyle linting
```

---

## C/C++

```powershell
cp templates/cpp-dev.code-workspace templates/my-cpp-project.code-workspace
make manager → 2 → assign profile: cpp-dev

# What you get
# ✅ C/C++ IntelliSense
# ✅ CMake support
# ✅ build/test/debug tasks
```

---

## .NET

```powershell
cp templates/dotnet-dev.code-workspace templates/my-dotnet-app.code-workspace
make manager → 2 → assign profile: dotnet-dev

# What you get
# ✅ C# Dev Kit
# ✅ dotnet build / test / run tasks
# ✅ NuGet package manager
```

---

## Multi-Stack (Monorepo)

```powershell
# Create multi-root template
make manager → 2 → multi-root: y
# Add folders: backend (Python), frontend (Node), shared (Go)

# Assign base profile, override per folder in .vscode/settings.json

# What you get
# ✅ Each folder has its own settings
# ✅ Terminal profile per root
# ✅ Shared extensions for the workspace
```

---

## Quick Matrix

| Stack | Template | Profile | Key Extension |
|-------|----------|---------|---------------|
| Python | `python-dev.code-workspace` | `python-dev.json` | ms-python.python |
| Node/Web | `node-dev.code-workspace` | `web-dev.json` | dbaeumer.vscode-eslint |
| Go | `go-dev.code-workspace` | `go-dev.json` | golang.go |
| Rust | `rust-dev.code-workspace` | `rust-dev.json` | rust-lang.rust-analyzer |
| Java | `java-dev.code-workspace` | `java-dev.json` | redhat.java |
| C/C++ | `cpp-dev.code-workspace` | `cpp-dev.json` | ms-vscode.cpptools |
| .NET | `dotnet-dev.code-workspace` | `dotnet-dev.json` | ms-dotnettools.csdevkit |
| Base | `sample-project.code-workspace` | `sample-profile.json` | editorconfig.editorconfig |
