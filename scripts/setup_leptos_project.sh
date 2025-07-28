#!/usr/bin/env bash
# setup-leptos: Erstellt ein neues Leptos-Projekt mit Tailwind & Playwright
# Usage: setup-leptos <projektname>
set -e

# Prüfe, ob ein Projektname übergeben wurde
if [ -z "$1" ]; then
  echo "❌ Fehler: Bitte gib einen Projektnamen als Parameter an."
  echo "➡️  Beispiel: ./setup_leptos_project.sh mein-projekt"
  exit 1
fi

# Projektname aus erstem Argument
PROJECT_NAME="$1"

echo "1. Leptos Template initialisieren mit Projektname $PROJECT_NAME initialisieren"
cargo leptos new --name "$PROJECT_NAME" --git https://github.com/leptos-rs/start-axum
cd "$PROJECT_NAME"

echo "2. npm initialisieren"
npm init -y

echo "3. .gitignore um node_modules ergänzen"
echo -e "\n# Node.js\nnode_modules/" >> .gitignore

echo "4. tailwindcss und daisyUI installieren"
npm install -D tailwindcss @tailwindcss/cli daisyui@latest

echo "5. input.css anlegen"
mkdir -p style
cat <<EOF > style/input.css
@import "tailwindcss";

@plugin "daisyui" {
  themes: fantasy --default, business --prefersdark;
}
EOF

echo "6. Cargo.toml ende2end-cmd und CSS config anpassen"
sed -i 's|end2end-cmd = "npx playwright test"|end2end-cmd = "./scripts/e2e-testing.sh"|' Cargo.toml
sed -i 's|style-file = "style/main.scss"|tailwind-input-file = "style/input.css"|' Cargo.toml
rm -f style/main.scss

echo "7. Playwright Pakete installieren"
cd end2end
npm ci
cd ..

echo "8. e2e-testing.sh anlegen"
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

echo "9. Cargo.toml um end2end-cmd ergänzen"
grep -q 'end2end-cmd' Cargo.toml || echo 'end2end-cmd = "./scripts/e2e-testing.sh"' >> Cargo.toml

echo "10. .cargo/config.toml anlegen"
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

echo "11. ./vscode/settings.json schreiben"
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

echo "12. .prettierignore schreiben"
cat << 'EOF' >  .prettierignore
#*.rs
target/
EOF

echo "13. .markdownlint-cli2.yaml schreiben"
cat << 'EOF' >  .markdownlint-cli2.yaml
# .markdownlint-cli2.yaml
config: .markdownlint.json
ignores:
  - "LICENSE"
EOF

echo "14. Makefile schreiben"
cat << EOF >  Makefile
# -------- Constants & Configuration --------

CARGO_LEPTOS := cargo leptos

# use this flags when developing for faster compile
DEV_RUSTFLAGS := RUSTFLAGS="--cfg erase_components"

# -------- App Configuration --------
SERVER_NAME := $PROJECT_NAME
WEB_PORT := 3000

# -------- Code Formatting --------

.PHONY: fmt
fmt:
	cargo fmt && leptosfmt ./**/*.rs

# -------- Leptos clippy --------

.PHONY: clippy
clippy:
    cargo clippy

# -------- Leptos lint: fmt + clippy --------

.PHONY: lint
lint:
    leptosfmt ./**/*.rs && cargo fmt && cargo clippy

# -------- Cleanup --------

.PHONY: clean
clean:
	cargo clean

# -------- SSR Build, E2E Test & & Run --------

.PHONY: dev-ssr
dev-ssr:
	\$(DEV_RUSTFLAGS) \$(CARGO_LEPTOS) watch

.PHONY: e2e-ssr
e2e-ssr:
	\$(DEV_RUSTFLAGS) \$(CARGO_LEPTOS) end-to-end --release

.PHONY: build-ssr
build-ssr:
	\$(CARGO_LEPTOS) build --release

.PHONY: run-ssr
run-ssr:
	\$(CARGO_LEPTOS) serve --release

# -------- Webserver Monitoring & Control --------

.PHONY: webserver
webserver:
	@lsof -i :\$(WEB_PORT)

.PHONY: kill-webserver
kill-webserver:
	@echo "🔍 Checking for running \$(SERVER_NAME) server on port \$(WEB_PORT)..."
	@PID=\$\$(lsof -i :\$(WEB_PORT) -sTCP:LISTEN -t -a -c \$(SERVER_NAME)); \\
	if [ -n "\$\$PID" ]; then \\
		echo "🛑 Found \$(SERVER_NAME) (PID: \$\$PID), stopping it..."; \\
		kill \$\$PID; \\
	else \\
		echo "✅ No \$(SERVER_NAME) server running on port \$(WEB_PORT)."; \\
	fi

# -------- Set release tag to build docker on github --------
# only use this, if you do not use release-please

.PHONY: release-tag
release-tag:
	@echo "🔍 Lese Version aus Cargo.toml..."
	@VERSION=\$\$(grep '^version =' Cargo.toml | sed -E 's/version = "(.*)"/\1/') && \\
	TAG="v\$\$VERSION" && \\
	echo "🏷  Erzeuge Git-Tag: \$\$TAG" && \\
	if git rev-parse "\$\$TAG" >/dev/null 2>&1; then \\
		echo "❌ Tag '\$\$TAG' existiert bereits. Abbruch."; \\
		exit 1; \\
	fi && \\
	git tag "\$\$TAG" && \\
	git push origin "\$\$TAG" && \\
	echo "✅ Git-Tag '\$\$TAG' erfolgreich erstellt und gepusht."
EOF

echo "15. Kopiere GitHub Workflows ins Projektverzeichnis..."
cp -r "$(dirname "$0")/../github" ".github"

echo "16. Dockerfile schreiben"
cat << EOF >  Dockerfile
# ---------- Stage 1: Build ----------
FROM rust:1.88-bookworm AS builder

# Install system dependencies
RUN apt-get update -y && apt-get install -y --no-install-recommends \
  clang \
  npm \
  wget \
  ca-certificates \
  && apt-get clean -y && rm -rf /var/lib/apt/lists/*

ENV CARGO_TERM_COLOR=always

# Install cargo-binstall, which makes it easier to install other
# cargo extensions like cargo-leptos
RUN wget https://github.com/cargo-bins/cargo-binstall/releases/latest/download/cargo-binstall-x86_64-unknown-linux-musl.tgz
RUN tar -xvf cargo-binstall-x86_64-unknown-linux-musl.tgz
RUN cp cargo-binstall /usr/local/cargo/bin

# get github token from publish.yml and install cargo-leptos
RUN --mount=type=secret,id=github_token \
  GITHUB_TOKEN=\$(cat /run/secrets/github_token) \
  cargo binstall cargo-leptos -y


# Add the WASM target
RUN rustup target add wasm32-unknown-unknown

# Set up workdir and copy source
WORKDIR /app
COPY . .

# Install frontend dependencies (for Tailwind, daisyUI, etc.)
# Assumes package.json/package-lock.json in project root
RUN npm ci

# Build the Leptos app (WASM + SSR) in release mode
RUN cargo leptos build --release

# ---------- Stage 2: Runtime ----------
FROM debian:bookworm-slim AS runtime

# Install runtime dependencies (for OpenSSL etc.)
RUN apt-get update -y && apt-get install -y --no-install-recommends \
  openssl ca-certificates \
  && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy runtime files from build container
COPY --from=builder /app/target/release/$PROJECT_NAME /app/
COPY --from=builder /app/target/site /app/site
#COPY --from=builder /app/Cargo.toml /app/

# Set Leptos runtime environment variables (can be overridden!)
ENV RUST_LOG="info"
ENV LEPTOS_ENV="PROD"
ENV LEPTOS_SITE_ADDR="0.0.0.0:8080"
ENV LEPTOS_SITE_ROOT="site"
ENV LEPTOS_OUTPUT_NAME="$PROJECT_NAME"

# Expose SSR port
EXPOSE 8080

# Start the Leptos SSR server
CMD ["/app/$PROJECT_NAME"]
EOF

echo "17. Projektname im publish.yml Workflow anpassen"
sed -i "s|SET_APP_NAME_HERE|$PROJECT_NAME|" .github/workflows/publish.yml

echo "✅ Setup abgeschlossen für Projekt: $PROJECT_NAME"
echo "➡️ Passe jetzt oder später das README.md für $PROJECT_NAME manuell an."
echo "Verwende den 'github Project Repo' Guide, um für $PROJECT_NAME ein github Repository zu erstellen."
