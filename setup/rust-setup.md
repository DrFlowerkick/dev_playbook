# 🦀 Rust Setup & Tooling Notes

Hier findest du eine Sammlung nützlicher Setup- und Tooling-Hinweise für Rust-Entwicklung, insbesondere auf Windows, Linux, für WebAssembly und allgemeine Projektpflege.

---

## 🛠 Rust Setup

### 🔹 Windows

Download: [rustup-init.exe](https://www.rust-lang.org/tools/install)

### 🔹 Linux (allgemein)

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

### 🔹 Arch Linux

```bash
sudo pacman -S rustup
```

---

## ⚙️ Linker-Konfiguration

Die Linker Konfiguration kann entweder global oder projektweise konfiguriert werden.
Die Empfehlung ist "entweder ... oder". Beide Varianten sollten nicht gemischt werden.
Meine Empfehlung ist lokal je Projekt.

### Globale Konfigiuration

`~/.cargo/config.toml`

```toml
# Windows
[target.x86_64-pc-windows-msvc]
rustflags = ["-C", "link-arg=-fuse-ld=lld"]

[target.x86_64-pc-windows-gnu]
rustflags = ["-C", "link-arg=-fuse-ld=lld"]

# Linux (Arch z. B.)
[target.x86_64-unknown-linux-gnu]
rustflags = ["-C", "linker=clang", "-C", "link-arg=-fuse-ld=lld"]
```

### Lokale Konfiguration im Projektordner

`.cargo/config.toml`

```toml
# Windows
[target.x86_64-pc-windows-msvc]
rustflags = ["-C", "link-arg=-fuse-ld=lld"]

[target.x86_64-pc-windows-gnu]
rustflags = ["-C", "link-arg=-fuse-ld=lld"]

# Linux (Arch z. B.)
[target.x86_64-unknown-linux-gnu]
linker = "clang"
rustflags = ["-C", "link-arg=-fuse-ld=lld"]
```

### 📦 Abhängigkeiten für Linux

```bash
sudo pacman -S lld clang
```

---

## 🔄 Rust Updaten

```bash
rustup self update
rustup update
```

---

## 🔧 Nützliche Rust-Tools

### 🔁 cargo-watch

```bash
cargo install cargo-watch
cargo watch -x check -x test -x run
```

### 📊 Code Coverage

```bash
cargo install cargo-tarpaulin
cargo tarpaulin --ignore-tests
```

### 🧹 Linting

```bash
rustup component add clippy
cargo clippy
```

### 🎨 Formatierung

```bash
rustup component add rustfmt
cargo fmt             # Formatieren
cargo fmt -- --check  # Nur prüfen
```

### 🔐 Sicherheitsanalyse

```bash
cargo install cargo-audit
cargo audit
```

---

## 📦 Dependency-Management

### 🔄 Pakete aktualisieren

```bash
cargo update
cargo test
```

### ⬆️ Alle Abhängigkeiten upgraden

```bash
cargo install cargo-edit
cargo upgrade
cargo test
```

### 🔍 Veraltete Pakete finden

```bash
cargo install -f cargo-outdated
cargo outdated
```

### 🧼 Aufräumen

```bash
cargo clean
```

---

## 📦 Erweiterungen & Visualisierung

### 🛠 Erweiterungen als Binärpakete

```bash
cargo install cargo-binstall
cargo binstall <paketname>
```

### 🌲 Abhängigkeitsbaum anzeigen

```bash
cargo install cargo-tree
cargo tree
```

### 📖 Logs im bunyan-Format lesen

```bash
cargo install bunyan
```

---

## 🌙 Nightly-Tools

```bash
rustup toolchain install nightly --allow-downgrade
```

### 🔎 Macros expandieren

```bash
cargo install cargo-expand
cargo +nightly expand
```

### 🧪 Unbenutzte Dependencies entfernen

```bash
cargo install cargo-udeps
cargo +nightly udeps
```

---

## 🧪 Fuzzing (benötigt Nightly)

```bash
cargo install -f cargo-fuzzing
cargo fuzz init
cargo fuzz list
```

---

## 🌐 WebAssembly & Leptos

```bash
cargo install -f wasm-pack
rustup target add wasm32-unknown-unknown
```

Leptos bietet sehr viele [Beispiele](https://github.com/leptos-rs/leptos/tree/main/examples), die man
sich unbedingt anschauen sollte, wenn man bestimmte Feature nutzen möchte.

### 🔧 Trunk

```bash
cargo install trunk
```

### Server Side Rendering (SSR) mit cargo-leptos

```bash
cargo install --locked cargo-leptos
```

### Fehlerbehandlung

```bash
cargo add console_error_panic_hook
```

Dann in `fn main()` ergänzen:

```rust
console_error_panic_hook::set_once();
```

### 🧽 Formatierung für Leptos-Macros

```bash
cargo install leptosfmt
```

---

## 🐳 Cross Compilation (inkl. wasm)

```bash
cargo install -f cross
```

---
