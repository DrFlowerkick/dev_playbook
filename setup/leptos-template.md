# Leptos Axum Template in VSC und github aufsetzen

Leptos bietet diverse Templates, um schnell ins Projekt einzusteigen. Im Folgenden wird das Axum Template verwendet und lokal für das Projekt vorbereitet. Anstatt die vielen händischen Schritte selber durchzuführen, verwende stattdessen das Script `setup_leptos_project.sh` im `scripts` Ordner.

Wenn du lokal deinen Projektordner aufgesetzt hast, geht es weiter mit der Einrichtung deines [Projekt Repository auf github](./github-project-repo.md).

## Inhaltsverzeichnis

- [Projekt erstellen](#projekt-erstellen)
- [npm aufsetzen](#npm-aufsetzen)
- [tailwindcss und daisyUI installieren](#tailwindcss-und-daisyui-installieren)
- [Playwright installieren und test script für e2e testing in docker einrichten](#playwright-installieren-und-test-script-für-e2e-testing-in-docker-einrichten)
- [Makefile](#makefile)
- [github workflows einrichten](#github-workflows-einrichten)
- [Projektspezifische cargo Konfiguration](#projektspezifische-cargo-konfiguration)
- [Nützliche Einstellungen für Visual Studio Code (VSC)](#nützliche-einstellungen-für-visual-studio-code-vsc)
- [Dockerfile](#dockerfile)

## Projekt erstellen

Falls noch nicht installiert:

```bash
cargo install cargo-leptos --locked
```

Danach

```bash
cargo leptos new --git https://github.com/leptos-rs/start-axum
```

um das Projekt zu erstellen.

## npm aufsetzen

Im Projektordner:

```bash
npm init -y
```

In `.gitignore` folgendes ergänzen:

```text
# Node.js - if required
node_modules/
```

## tailwindcss und daisyUI installieren

[TailwindCSS](https://tailwindcss.com) ist ein `utility-first CSS framework`. Hiermit lässt sich schnell und flexibel CSS Styling aufsetzen. [daisyUI](https://daisyui.com) setzt auf TailwindCSS auf.

Im Projektordner:

```bash
npm install -D tailwindcss @tailwindcss/cli daisyui@latest
```

Im Ordner `style` die Datei `input.css` mit folgendem Inhalt erstellen:

```css
@import "tailwindcss";

@plugin "daisyui" {
  themes: fantasy --default, business --prefersdark;
}
```

Die Themes `fantasy` (hell) und `business` (dunkel) können durch andere Themes ersetzt oder ergänzt werden. Mehr dazu siehe unter [daisyUI](https://daisyui.com/docs/themes/).

Damit leptos tailwindcss verwendet, muss die Zeile `style-file = "style/main.scss"` durch `tailwind-input-file = "style/input.css"` in `Cargo.toml` ersetzt werden. Die Datei `style/main.scss` kann gelöscht werden.

## Playwright installieren und test script für e2e testing in docker einrichten

Das Axum Template von leptos bietet im end2end Ordner bereits ein vorkonfiguriertes Setup für end2end Testing mit [Playwright](https://playwright.dev). Um dies zu nutzen, muss Playwright wie folgt installiert werden.

```bash
cd ./end2end
npm ci
```

Dies installiert die in der Datei `package-lock.json` vorgegeben Pakete mit der exakten Versionsnummer.

Damit Playwright die Webseiten in verschiedenen Browsern testet, müssen die entsprechenden Browser Engines installiert werden. Oder man verwendet das Allzweckwerkzeug docker (unter linux gerne auch podman). Lege dazu im Projekt die Datei `scripts/e2e-testing.sh` mit folgendem Inhalt an:

```bash
#!/usr/bin/env bash
set -e

# Determine container engine (docker or podman fallback)
ENGINE=${CONTAINER_ENGINE:-docker}

# Leptos environment
ENVIRONMENT=${LEPTOS_ENV:-DEV}

# Use same test directory regardless of CWD
TEST_DIR="$(pwd)"

# Playwright Docker image (used in DEV only)
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
  echo "🔍 Reporter: HTML, no interactive mode"

  # Run Playwright tests with HTML report only
  npx playwright test --reporter=html || {
    echo "❌ Playwright tests failed."
    exit 1
  }

  echo "✅ Playwright tests finished (CI)"
else
  echo "❗️Unknown LEPTOS_ENV value: $ENVIRONMENT"
  exit 1
fi
```

Mache die Datei ausführbar mit `chmod +x ./scripts/e2e-testing.sh`.

Dann setze in `Cargo.toml` die Variable `end2end-cmd` wie folgt:

```toml
end2end-cmd = "./scripts/e2e-testing.sh"
```

## Makefile

Mit dem Makefile werden praktische Kommandos einfach über `make command` angeboten. Folge den Anleitung unter [Makefile mut rust verwenden](./make.md).

## github workflows einrichten

Kopiere den Ordner `github` aus diesem Repo in deinen Projektordner und nenne den Ordner um nach `.github`. Damit werden die enthaltenen workflows mit dem nächsten commit automatisch aktiv.

### Funktionale workflows

Alle funktionalen Workflows starten mit einem `_`. Sie bieten eine gewisse Funktionalität, die von anderen workflows genutzt werden kann. Sie stellen somit wiederverwendbare workflows dar, die in verschiedenen Phasen des Entwicklungsprozesses verwendet werden können. So können bei komplexen Features, die selber Sub-Branches benötigen, eigene workflows aus den funktionalen Workflows zusammen gesetzt werden. Als Vorlage hierfür können die workflows von `main` und `development` verwendet werden.

### Branch workflows

Branch workflows definieren, was passieren soll, wenn mit dem branch interagiert wird. Sie werden gestartet, wenn

- ein push auf den Branch erfolgt (ohne postfix),
- ein pull request auf den Branch erfolgt (`_pr` postfix),
- oder nach einem bestimmten Zeitplan (`_scheduled` postfix).

### Code veröffentlichen mit `publish.yml`

Der Workflow `publish.yml` wird ausgelöst, wein ein `v*.*.*` git tag gesetzt wird. Der Workflow prüft, ob dieser getagte commit mit dem letzten commit auf `main` übereinstimmt. Wenn ja, dann erfolgt eine Veröffentlichung. Aktuell ist dies ein docker image auf dem github docker repository `ghcr.io`.

Mit dem workflow _release-please.yml wird solch ein `v*.*.*` tag automatisch gesetzt, wenn seit dem letzten Aufruf des Workflows commits erfolgt sind, die eine Änderung der Versionierung verursachen. Weitere Details dazu sie [release-please](../workflows/release-please.md).

## Projektspezifische cargo Konfiguration

legen im Projektordner eine Datei `.cargo/config.toml` mit dem folgenden Inhalt an:

```toml
[target.wasm32-unknown-unknown]
rustflags = [
   "--cfg",
   "getrandom_backend=\"wasm_js\"",
]

[target.x86_64-unknown-linux-gnu]
linker = "clang"
rustflags = ["-C", "link-arg=-fuse-ld=lld"]
```

Falls du das wasm target noch nicht installiert haben solltest, wäre das jetzt ein guter Zeitpunkt:

```bash
rustup target add wasm32-unknown-unknown
```

Den lld Linker Part nur anlegen, wenn du lld als Linker nutzen willst (s. [Rust Setup](rust-setup.md)).

## Nützliche Einstellungen für Visual Studio Code (VSC)

VSC bietet sehr viele nützliche Erweiterungen. Hier meine Top-Empfehlungen:

- radlc.vscode-tailwindcss
- ecmel.vscode-html-css
- davidanson.vscode-markdownlint
- esbenp.prettier-vscode
- github.vscode-github-actions
- github.vscode-pull-request-github
- jbro.vscode-default-keybindings
- mdickin.markdown-shortcuts
- ms-ceintl.vscode-language-pack-de
- ms-playwright.playwright
- rust-lang.rust-analyzer
- shd101wyy.markdown-preview-enhanced
- streetsidesoftware.code-spell-checker
- streetsidesoftware.code-spell-checker-german
- tamasfe.even-better-toml

Die meisten dieser Erweiterungen werden über `.vscode/settings.json` konfiguriert, wenn überhaupt. Einige Erweiterungen benötigen eigene Konfigurationsdateien.

### leptos ssr

```json
{
    "rust-analyzer.procMacro.ignored": {
        "leptos_macro": [
            // optional:
            // "component",
            "server"
        ]
    },
    // if code that is cfg-gated for the `ssr` feature is shown as inactive,
    // you may want to tell rust-analyzer to enable the `ssr` feature by default
    //
    // you can also use `rust-analyzer.cargo.allFeatures` to enable all features
    "rust-analyzer.cargo.features": ["ssr"],
}
```

### code-spell-checker

```json
{
  "cSpell.language": "en,de-de",
  "cSpell.dictionaries": ["en", "de-de"],
  "cSpell.enabled": true,
  "cSpell.words": [
    "axum",
    "bindgen",
    "browserlist",
    "browserquery",
    "buildx",
    "Buildx",
    "cdylib",
    "codegen",
    "daisyui",
    "drflowerkick",
    "dtolnay",
    "github",
    "GITHUB",
    "leptos",
    "leptosfmt",
    "linux",
    "prefersdark",
    "rlib",
    "rustc",
    "srcset",
    "stylesheet",
    "Swatinem",
    "taiki",
    "tailwindcss",
    "tokio"
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
  ],
}
```

### leptos-fmt und prettier automatische Formatierung

```json
{
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
  }
}
```

Falls die automatische Formatierung des Codes durch `prettier` stört, kann man das über eine Datei `.prettierignore` im Projektordner konfigurieren:

```text
#*.rs
target/
```

### CSS

```json
{
  "css.validate": false,
  "makefile.configureOnOpen": false,
  "tailwindCSS.includeLanguages": {
    "html": "html",
    "rust": "html"
  },
}
```

### Linting von Markdown

```yaml
# .markdownlint-cli2.yaml
config: .markdownlint.json
ignores:
  - "LICENSE"
```

## Dockerfile

Da Web-Apps üblicherweise über Docker Images verteilt und gehostet werden, brauchen wir im Projektroot ein `Dockerfile`:

```Dockerfile
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
  GITHUB_TOKEN=$(cat /run/secrets/github_token) \
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
COPY --from=builder /app/target/release/NAME_DEINER_APP /app/
COPY --from=builder /app/target/site /app/site
#COPY --from=builder /app/Cargo.toml /app/

# Set Leptos runtime environment variables (can be overridden!)
ENV RUST_LOG="info"
ENV LEPTOS_ENV="PROD"
ENV LEPTOS_SITE_ADDR="0.0.0.0:8080"
ENV LEPTOS_SITE_ROOT="site"
ENV LEPTOS_OUTPUT_NAME="NAME_DEINER_APP"

# Expose SSR port
EXPOSE 8080

# Start the Leptos SSR server
CMD ["/app/NAME_DEINER_APP"]

```

---
✅ Setup ist abgeschlossen
