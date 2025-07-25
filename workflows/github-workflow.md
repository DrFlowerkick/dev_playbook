# GitHub Workflow Guide

Dieser Leitfaden beschreibt den Git-Workflow für dieses Projekt, einschließlich der Branch-Strategie, Commit-Regeln und dem Release-Prozess mithilfe von [`release-please`](./release-please.md).

---

## `main` Branch

Der `main` Branch dient gleichzeitig als **Release-Branch**. Alle Änderungen in `main` sollen **ausschließlich über Pull Requests** erfolgen.

Die erforderlichen GitHub Actions Workflows (inkl. `release-please`) werden automatisch durch das [`setup_leptos_project.sh`](../scripts/setup_leptos_project.sh) Script eingerichtet. Weitere Details findest du im [Leptos Template Setup Guide](../setup/leptos-template.md#github-workflows-einrichten).

---

## `development` Branch

Der `development` Branch dient als zentraler Integrationszweig für neue Features, Bugfixes und sonstige Änderungen, **bevor sie in `main` übernommen werden**. Auch hier gilt: **Keine Direkt-Pushes** – alle Änderungen sollen über Pull Requests erfolgen.

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
5. Pull Request mergen mit `Squash Mode`
6. Nach Merge des pull requests: temporären Branch löschen (er ist "verbraucht" bzw. ist wie ein abhacktes ToDo in einer ToDo Liste zu betrachten)

Das gilt auch für Änderungen außerhalb des Codes (z. B. Dokumentation, Formatierung etc.).

---

## Commits & Development Artefakte

Alle zu trackenden Änderungen – Code, Doku, Konfiguration etc. – gelten als **Development Artefakte**.  
Für **alle Commits** gilt: Verwende das in der [`release-please`](./release-please.md) Dokumentation beschriebene [Conventional Commits Format](https://www.conventionalcommits.org/), um automatische Versionierung und Changelogs sicherzustellen.

---

## 🔁 Git: `development` nach erfolgreichem PR auf den Stand von `main` bringen (mit Branch Protection)

### Ziel

Nach einem erfolgreichen Pull Request von `development` nach `main` soll `development` wieder auf den aktuellen Stand von `main` gebracht werden – **ohne doppelte Commits, ohne Force Push, vollständig PR-basiert**.

> ✅ Dieses Vorgehen ist kompatibel mit **Branch Protection Rules**, da es ausschließlich mit Pull Requests arbeitet und keine `--force`-Pushes verwendet.

---

### ✅ Voraussetzungen

- Der PR von `development` nach `main` wurde erfolgreich gemerged.
- Du arbeitest lokal mit einem Git-Klon des Repos.
- `origin` zeigt auf das zentrale Remote-Repository.
- Du hast Schreibrechte auf das Repo.
- Branch Protection für `development` ist aktiv (z. B. „Require pull request“, „Prevent force push“).

---

### 🧼 Schritt-für-Schritt Anleitung für manuelles Vorgehen

#### 1. Stelle sicher, dass du auf dem neuesten Stand bist

```bash
git fetch origin
```

#### 2. Wechsle in den Branch `development`

```bash
git checkout development
```

#### 3. Erstelle einen temporären Branch für das Rebase

```bash
git checkout -b dev-on-main
```

> Du arbeitest nun in einem isolierten Branch, der später per PR nach `development` zurückgeführt wird.

#### 4. Rebase `dev-on-main` auf `main`, mit `main` als Master

```bash
git rebase -X theirs --reapply-cherry-picks origin/main
```

> ✅ `-X theirs` sorgt dafür, dass bei eventuellen Konflikten die Version aus `main` verwendet wird (also „`main` gewinnt“).

#### 5. Push den temporären Branch zum Remote

```bash
git push origin dev-on-main
```

---

#### 📬 6. Erstelle einen Pull Request: `dev-on-main` → `development`

- Titel z. B.: `Sync development with main after release`
- Optionale Reviewer zuweisen
- PR wie gewohnt durch CI/Checks laufen lassen

---

### 🔁 Halb-Automatisiertes Vorgehen: Synchronisation über GitHub Workflow

Statt dem beschrieben Vorgehen kannst du die Synchronisation von `development` mit `main` einfach über den **manuell auslösbaren GitHub Actions Workflow** [`sync_development_with_main.yml`](../github/workflows/sync_development_with_main.yml) durchführen.

### ✅ Ergebnis nach dem Merge

- `development` ist **vollständig und sauber synchronisiert mit `main`**
- Alle Konflikte wurden automatisch mit `main` als Master aufgelöst
- Keine Force Pushes
- Kompatibel mit geschütztem Branch

---

### 🧹 Optional: Aufräumen nach dem Merge

#### Lokalen Branch löschen

```bash
git branch -d dev-on-main
```

#### Remote-Branch löschen

```bash
git push origin --delete dev-on-main
```

Alternativ: Aktiviere in den Repository-Einstellungen:

> ✅ „Automatically delete head branches after merge“

---

### 🧠 Warum dieses Vorgehen?

| Vorteil                                  | Beschreibung                                             |
|------------------------------------------|----------------------------------------------------------|
| ✅ Kein Force-Push nötig                 | Erlaubt bei aktivierter Branch Protection                |
| ✅ Klarer Workflow über Pull Requests    | PRs bleiben nachvollziehbar und reviewfähig             |
| ✅ Keine doppelten Commits oder Merge-Müll | Historie bleibt sauber und linear                       |
| ✅ Vollständig CI-/Review-kompatibel     | Passt zu GitHub Workflows und Reviewprozessen           |

---

### 📦 Cheatsheet

```bash
git fetch origin
git checkout development
git checkout -b dev-on-main
git rebase -X theirs origin/main
git push origin dev-on-main
# → dann PR von dev-on-main nach development erstellen
```

---

### 🧱 Empfehlung

Richte für `development` folgende Branch Protection Rules ein:

- ✅ Require pull request before merging
- ✅ Require status checks to pass
- ✅ Prevent force pushes
- ✅ Prevent branch deletion (optional)
- ✅ Automatically delete head branches (für dev-on-main etc.)

---


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
