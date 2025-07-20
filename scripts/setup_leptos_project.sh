#!/usr/bin/env bash
set -e

# Prüfe, ob ein Projektname übergeben wurde
if [ -z "$1" ]; then
  echo "❌ Fehler: Bitte gib einen Projektnamen als Parameter an."
  echo "➡️  Beispiel: ./setup_leptos_project.sh mein-projekt"
  exit 1
fi

# Projektname aus erstem Argument
PROJECT_NAME="$1"

# 1. Leptos Template initialisieren
cargo leptos new "$PROJECT_NAME" --git https://github.com/leptos-rs/start-axum
cd "$PROJECT_NAME"

# 2. npm initialisieren
npm init -y

# 3. .gitignore ergänzen, falls nicht vorhanden
echo -e "\n# Node.js\nnode_modules/" >> .gitignore

# 4. tailwindcss und daisyUI installieren
npm install -D tailwindcss @tailwindcss/cli daisyui@latest

# 5. input.css anlegen
mkdir -p style
cat <<EOF > style/input.css
@import "tailwindcss";

@plugin "daisyui" {
  themes: fantasy --default, business --prefersdark;
}
EOF

# 6. Cargo.toml anpassen
sed -i 's|style-file = "style/main.scss"|tailwind-input-file = "style/input.css"|' Cargo.toml
rm -f style/main.scss

# 7. Playwright Pakete installieren
cd end2end
npm ci
cd ..

# 8. e2e-testing.sh anlegen
mkdir -p scripts
cat <<'EOF' > scripts/e2e-testing.sh
#!/usr/bin/env bash
set -e
ENGINE=${CONTAINER_ENGINE:-docker}
ENVIRONMENT=${LEPTOS_ENV:-DEV}
TEST_DIR="$(pwd)"
IMAGE="mcr.microsoft.com/playwright:v1.44.1-jammy"

echo "Detected LEPTOS_ENV=$ENVIRONMENT"

if [[ "$ENVIRONMENT" == "DEV" ]]; then
  echo "🔧 Running Playwright E2E tests via Docker (local DEV mode)..."
  $ENGINE run --rm -it \
    --network=host \
    -v "$TEST_DIR":/app \
    -w /app \
    "$IMAGE" \
    bash -c "npx playwright test"
elif [[ "$ENVIRONMENT" == "PROD" ]]; then
  echo "⚙️  Running Playwright E2E tests directly (CI mode)..."
  npx playwright test --reporter=html || exit 1
  echo "✅ Playwright tests finished (CI)"
else
  echo "❗️Unknown LEPTOS_ENV value: $ENVIRONMENT"
  exit 1
fi
EOF

chmod +x scripts/e2e-testing.sh

# 9. Cargo.toml um end2end-cmd ergänzen
grep -q 'end2end-cmd' Cargo.toml || echo 'end2end-cmd = "./scripts/e2e-testing.sh"' >> Cargo.toml

# 10. .cargo/config.toml anlegen
mkdir -p .cargo
cat <<EOF > .cargo/config.toml
[target.wasm32-unknown-unknown]
rustflags = [
   "--cfg",
   "getrandom_backend=\"wasm_js\"",
]

[target.x86_64-unknown-linux-gnu]
linker = "clang"
rustflags = ["-C", "link-arg=-fuse-ld=lld"]
EOF

# 11. ./vscode/settings.json schreiben
mkdir -p .vscode
cat << 'EOF' > .vscode/settings.json
{
  "rust-analyzer.procMacro.ignored": {
    "leptos_macro": [
      "server"
    ]
  },
  "rust-analyzer.cargo.features": ["ssr"],
  "rust-analyzer.rustfmt.overrideCommand": [
    "leptosfmt",
    "--stdin",
    "--rustfmt"
  ],
  "css.validate": false,
  "makefile.configureOnOpen": false,
  "tailwindCSS.includeLanguages": {
    "html": "html",
    "rust": "html"
  },
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.formatOnSave": true,
  "[rust]": {
    "editor.defaultFormatter": "rust-lang.rust-analyzer",
    "editor.formatOnSave": true
  },
  "cSpell.language": "en,de-de",
  "cSpell.dictionaries": ["en", "de-de"],
  "cSpell.enabled": true,
  "cSpell.words": [
    "axum", "bindgen", "browserlist", "browserquery", "buildx",
    "Buildx", "cdylib", "codegen", "daisyui", "drflowerkick",
    "dtolnay", "github", "GITHUB", "leptos", "leptosfmt",
    "linux", "prefersdark", "rlib", "rustc", "srcset",
    "stylesheet", "Swatinem", "taiki", "tailwindcss", "tokio"
  ],
  "cSpell.ignorePaths": [
    "package-lock.json",
    "node_modules",
    "vscode-extension",
    ".git/{info,lfs,logs,refs,objects}/**",
    ".git/{index,*refs,*HEAD}",
    ".vscode",
    ".vscode-insiders",
    "**/*.lock",
    "LICENSE"
  ]
}
EOF

echo "✅ Setup abgeschlossen für Projekt: $PROJECT_NAME"
echo "Open github desktop -> File -> Add local repository..."
echo "Passe bei Bedarf die LICENCE Datei in github an."
echo "Nutze den Drei Branches Workflow für die Entwicklung."
