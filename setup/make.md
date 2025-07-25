# Makefile mit rust verwenden

Mit einem Makefile können wiederkehrende gebündelte Kommandos strukturiert im Projekt bereitgestellt werden.

## Beispiel Makefile mit leptos

```Makefile
# -------- variables --------

CARGO_LEPTOS=cargo leptos

# use this flags when developing for faster compile
DEV_RUSTFLAGS=RUSTFLAGS="--cfg erase_components"

# -------- Leptos fmt --------

.PHONY: fmt
fmt:
    leptosfmt ./**/*.rs && cargo fmt

# -------- Leptos clippy --------

.PHONY: clippy
clippy:
    cargo clippy

# -------- Leptos lint: fmt + clippy --------

.PHONY: lint
lint:
    leptosfmt ./**/*.rs && cargo fmt && cargo clippy

# -------- SSR example-project

.PHONY: dev-example-project
dev-example-project:
    $(DEV_RUSTFLAGS) $(CARGO_LEPTOS) watch

.PHONY: build-example-project
build-example-project:
    $(CARGO_LEPTOS) build --release

.PHONY: run-example-project
run-example-project:
    $(CARGO_LEPTOS) serve --release

# -------- Set release tag to build docker on github --------
# only use this, if you do not use release-please

.PHONY: release-tag
release-tag:
    @echo "🔍 Lese Version aus Cargo.toml..."
    @VERSION=$$(grep '^version =' Cargo.toml | sed -E 's/version = "(.*)"/\1/') && \
    TAG="v$$VERSION" && \
    echo "🏷  Erzeuge Git-Tag: $$TAG" && \
    if git rev-parse "$$TAG" >/dev/null 2>&1; then \
        echo "❌ Tag '$$TAG' existiert bereits. Abbruch."; \
        exit 1; \
    fi && \
    git tag "$$TAG" && \
    git push origin "$$TAG" && \
    echo "✅ Git-Tag '$$TAG' erfolgreich erstellt und gepusht."

# -------- Cleanup --------

.PHONY: clean
clean:
    cargo clean

# -------- check running webserver --------

.PHONY: webserver
webserver:
    @lsof -i :3000
```

`.PHONY` ist der name des Kommandos, dass man mit `make` aufruft, z.B.

* `make fmt`
* `make dev-example-project`

Wenn ein Fehler angezeigt wie `Makefile:12: *** Fehlender Trenner.  Schluss.`, dann leigt das daran, dass die einzeige durch 4 spaces und nicht einem echten tab dargestellt sind. Um dies zu ändern gehe in vsc auf das Makefile.

Dort siehst du etwas wie: `Spaces: 4 | UTF-8 | LF | Makefile`
Klicke auf "Spaces: 4"
Klicke auf "Convert Indentation to Tabs"
Danach: "Indent Using Tabs"
