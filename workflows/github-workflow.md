# Git Workflow: Geschützte Branches, `release-please` & Saubere Historie

Dieser Guide beschreibt einen sicheren und effektiven Git-Workflow für Projekte, die `main` und `development` als zentrale Branches nutzen, beide durch **Branch Protection Rules** (nur Pull Requests erlaubt) geschützt sind und `release-please` für die Versionsverwaltung und Changelog-Generierung verwendet wird.

Dieser Guide eignet sich für Projekte, die mit [`setup_leptos_project.sh`](../scripts/setup_leptos_project.sh) erstellt in mit [`github-project-repo.md`](../setup/github-project-repo.md) in `GitHub` eingerichtet wurden.

## Kernprinzipien

- **`main` ist der Hauptzweig:** Er dient mit `release-please` gleichzeitig als Release Branch.
- **`development` ist der Start Branch für Entwicklung:** Alle temporären Branches für Features und Fixes werden von `development` abgeleitet.
- **Temporäre Branches:** Alle Änderungen am Repository (neue Dateien, Dateien anpassen oder entfernen) durch Entwickler erfolgt über temporäre Branches, die zu löschen sind, wenn sie nicht mehr gebraucht werden.
- **Keine Squash-Merges von `development` nach `main`:** Dies ist entscheidend, um doppelte Einträge in Changelogs bei der Synchronisation zu vermeiden. Wir verwenden stattdessen **normale Merge-Commits**.
- **Feature-Branches aufräumen:** Die "Sauberkeit" der Commit-Historie wird auf den **Feature-Branches** selbst sichergestellt, bevor sie gemergt werden.
- **Pull Request-zentrierter Ansatz:** Alle Änderungen an den geschützten Branches (`main` und `development`) müssen über Pull Requests erfolgen.
- **Notwendige `GitHub` Workflows:** Alle notwendigen Workflows werden über [`setup_leptos_project.sh`](../scripts/setup_leptos_project.sh) bereit gestellt.

---

## Der Workflow in Schritten

### 1\. Feature-Branch erstellen und entwickeln

Starte die Entwicklung neuer Features oder Fixes auf einem dedizierten Feature-Branch.

```bash
# Sicherstellen, dass der lokale development Branch aktuell ist
git checkout development
git pull origin development

# Neuen Feature-Branch erstellen
git checkout -b feature/mein-super-feature
```

### 2\. Feature-Branch aufräumen (Interaktives Rebasen)

Bevor du deinen Feature-Branch zur Code-Review einreichst, bereinige seine Historie lokal. Dies macht deine Commits atomarer und aussagekräftiger.

```bash
# Interaktiven Rebase starten
git rebase -i development
```

- **Im geöffneten Editor:** Nutze Befehle wie `reword` (Commit-Nachricht bearbeiten), `squash` (mit vorherigem Commit zusammenfassen) oder `fixup` (mit vorherigem Commit zusammenfassen, Nachricht verwerfen), um deine Commits zu organisieren und zu verbessern. Speichere und schließe die Datei, damit Git den Rebase durchführen kann.

- **Pushe deinen bereinigten Branch:** Da du die Historie umgeschrieben hast, ist ein Force Push notwendig. Verwende immer `--force-with-lease`, um unbeabsichtigtes Überschreiben von Änderungen anderer zu vermeiden.

  ```bash
  git push origin feature/mein-super-feature --force-with-lease
  ```

### 3\. Feature-Branch in `development` mergen (via Pull Request)

Erstelle einen Pull Request (PR) von deinem Feature-Branch nach `development`.

- **PR erstellen:** Öffne einen PR von `feature/mein-super-feature` nach `development`.
- **Review & Checks:** Lasse den Code reviewen und stelle sicher, dass alle CI/CD-Checks erfolgreich sind.
- **Mergen:** Der Merge dieses PRs nach `development` sollte als **normaler Merge** erfolgen (nicht als Squash-Merge oder Rebase-Merge). Dies bewahrt die Commit-Historie deines Feature-Branches in `development`.

### 4\. `development` in `main` mergen (Release-Vorbereitung via Pull Request)

Sobald `development` alle für das nächste Release benötigten Features gesammelt hat, wird es in `main` integriert.

- **PR erstellen:** Erstelle einen Pull Request von `development` nach `main`.
- **Review & Checks:** Führe Code-Reviews und CI/CD-Checks durch.
- **Mergen:** Auch hier ist ein **normaler Merge** erforderlich. Dies ermöglicht es `release-please`, die einzelnen Feature-Commits auf `main` zu erkennen und das Changelog korrekt zu generieren.

### 5\. `release-please` wird aktiv und aktualisiert `main`

Nach dem Merge von `development` nach `main` wird `release-please` (typischerweise über GitHub Actions) ausgelöst.

- `release-please` analysiert die neuen Commits auf `main` (die ursprünglichen Feature-Commits von `development`).
- Es erstellt automatisch einen **neuen Pull Request** (z.B. "Release v1.2.3") auf `main`. Dieser PR enthält:
  - Den Version Bump in der Versionsdatei (z.B. `Cargo.toml`).
  - Das generierte Changelog.
  - Ggf. weitere Release-Artefakte.

### 6\. `release-please`-PR nach `main` mergen

Überprüfe den von `release-please` erstellten PR. In den meisten Fällen kann dieser PR direkt gemergt werden.

- **Mergen:** Führe einen **normalen Merge** für diesen `release-please`-PR nach `main` durch.
- `main` enthält nun die aktualisierte Version und das Changelog. Ein entsprechendes Release-Tag wird gesetzt.

### 7\. `main` in `development` zurücksynchronisieren (via Pull Request)

> 💡 **Hinweis:** Der `GitHub` Workflow [`sync_development_with_main.yml`](../github/workflows/sync_development_with_main.yml) führt die folgendes Schritte automatisch aus, sobald `release-please` nach dem merge des `Release PR` den `main` Branch mit einem Version tag markiert. Wenn beim merge Konflikte auftauchen, bricht der Workflow mit einer entsprechenden Fehlermeldung ab. Andernfalls endet er mit der Erstellung des Pull Request auf `development`.

Dies ist der letzte, aber entscheidende Schritt, um den `development`-Branch mit den durch `release-please` auf `main` eingeführten Versionsänderungen und dem Changelog zu aktualisieren.

- **Temporären Sync-Branch erstellen:**

  ```bash
  git checkout development
  git pull origin development # development auf den neuesten Stand bringen
  git checkout -b sync/main-to-development
  ```

- **`main` in den Sync-Branch mergen:**

  ```bash
  git merge main
  ```

  - **Konfliktlösung (falls nötig):** Sollten hierbei Konflikte auftreten (was selten sein sollte, da nur `release-please` `main` direkt ändert), löse diese wie gewohnt.

    ```bash
    git add .        # Gelöste Konflikte zum Staging-Bereich hinzufügen
    git commit       # Merge-Commit abschließen
    ```

- **Sync-Branch pushen:**

  ```bash
  git push origin sync/main-to-development
  ```

- **Pull Request erstellen:** Erstelle einen Pull Request von `sync/main-to-development` nach `development`.
- **Mergen:** Merge diesen PR nach `development` (wieder ein **normaler Merge**).

---
