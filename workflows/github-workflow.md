# GitHub Workflow Guide

Dieser Leitfaden beschreibt den Git-Workflow für dieses Projekt, einschließlich der Branch-Strategie, Commit-Regeln und dem Release-Prozess mithilfe von [`release-please`](./release-please.md).

---

## `main` Branch

Der `main` Branch dient gleichzeitig als **Release-Branch**. Alle Änderungen in `main` erfolgen **ausschließlich über Pull Requests**.

> 💡 Empfohlen: Schütze den `main` Branch mit einem [GitHub Branch Ruleset](../setup/github-project-repo.md#branch-protection-für-main-und-development-erstellen), um Direkt-Pushes zu verhindern.

Die erforderlichen GitHub Actions Workflows (inkl. `release-please`) werden automatisch durch das [`setup_leptos_project.sh`](../scripts/setup_leptos_project.sh) Script eingerichtet. Weitere Details findest du im [Leptos Template Setup Guide](../setup/leptos-template.md#github-workflows-einrichten).

---

## `development` Branch

Der `development` Branch dient als zentraler Integrationszweig für neue Features, Bugfixes und sonstige Änderungen, **bevor sie in `main` übernommen werden**. Auch hier gilt: **Keine Direkt-Pushes** – alle Änderungen erfolgen über Pull Requests.

> 💡 Empfehlung: Lege den `development` Branch beim Repository-Setup als Ableitung von `main` an. Siehe: [Repository aufsetzen](../setup/github-project-repo.md#branch-development-von-main-erstellen)

Die verwendeten Workflows sind ebenfalls im Setup-Script enthalten.

---

## Feature- und Bugfix-Branches

Für jedes neue Feature oder jeden Bugfix wird ein **temporärer Branch** auf Basis von `development` erstellt.

### Workflow

1. Branch von `development` aus erstellen
2. Änderungen vornehmen
3. Pull Request zurück nach `development`
4. Prüfen, ob alle github workflows erfolgreich durchgelaufen sind:
    - Wenn nein, gehe zurück zu 2.
    - Wenn ja, weiter zu 5.
5. Nach Merge: Branch löschen (wenn nicht mehr benötigt)

> 🧼 Um das Repository sauber zu halten, sollten temporäre Branches nach dem Merge gelöscht werden – spätestens dann, wenn klar ist, dass sie nicht mehr benötigt werden.

Das gilt auch für Änderungen außerhalb des Codes (z. B. Dokumentation, Formatierung etc.).

---

## Commits & Development Artefakte

Alle zu trackenden Änderungen – Code, Doku, Konfiguration etc. – gelten als **Development Artefakte**.  
Für **alle Commits** gilt: Verwende das in der [`release-please`](./release-please.md) Dokumentation beschriebene [Conventional Commits Format](https://www.conventionalcommits.org/), um automatische Versionierung und Changelogs sicherzustellen.

---

## Releases

Releases werden vollständig über [`release-please`](./release-please.md) automatisiert.  
Der zugehörige Workflow (`_release_please.yml`) wird automatisch eingerichtet.

### Release-Verhalten

- Sobald ein Pull Request in `main` gemerged wird:
- wird automatisch die Version in `Cargo.toml` erhöht
- ein neuer Changelog-Eintrag erzeugt
- ein Release erstellt

> 🛠️ Eine manuelle Anpassung der Versionsnummer ist **nicht nötig**.

---
