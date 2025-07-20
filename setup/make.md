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
    cargo fmt && leptosfmt ./**/*.rs

# -------- Leptos clippy --------

.PHONY: clippy
fmt:
    cargo clippy

# -------- Leptos fmt + clippy --------

.PHONY: fmt-clippy
fmt:
    cargo fmt && leptosfmt ./**/*.rs && cargo clippy

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

# -------- Cleanup --------

.PHONY: clean
clean:
    cargo clean
```

`.PHONY` ist der name des Kommandos, dass man mit `make` aufruft, z.B.

* `make fmt`
* `make dev-example-project`
