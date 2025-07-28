# Git Workflow: Geschützter `main` Branch, temporäre Feature & Fix Branches, `release-please` & Saubere Historie

Dieser Guide beschreibt einen sicheren und effektiven Git-Workflow für Projekte, bei dem nicht direkt im `main` gearbeitet wird, sondern Änderungen ins Repository über temporäre Feature & Fix Branches eingeführt werden. Um dies sicher zu stellen, wird der `main` durch **Branch Protection Rules** (u.a. nur Pull Requests erlaubt) geschützt. Zusätzlich wird `release-please` für die Versionsverwaltung und Changelog-Generierung verwendet. Dieser Workflow entspricht im Wesentlichen dem [GitHub-Flow](https://docs.github.com/de/get-started/using-github/github-flow) und dem [Git feature branch workflow](https://www.atlassian.com/git/tutorials/comparing-workflows/feature-branch-workflow). Für weiterführende Infos lese die verlinkten Guides.

Dieser Guide eignet sich für Projekte, die mit [`setup_leptos_project.sh`](../scripts/setup_leptos_project.sh) erstellt in mit [`github-project-repo.md`](../setup/github-project-repo.md) in `GitHub` eingerichtet wurden.

## Kernprinzipien

- **`main` ist der Hauptzweig:** Er dient mit `release-please` gleichzeitig als Release Branch.
- **Temporäre Branches:** Alle Änderungen am Repository (neue Dateien, Dateien anpassen oder entfernen) durch Entwickler erfolgt über temporäre Branches, die zu löschen sind, wenn sie nicht mehr gebraucht werden.
- **Feature-Branches aufräumen:** Die "Sauberkeit" der Commit-Historie wird auf den **Feature-Branches** selbst sichergestellt, bevor sie gemergt werden. Sie können nach `main` mit einem [`merge` Commit](https://docs.github.com/de/pull-requests/collaborating-with-pull-requests/incorporating-changes-from-a-pull-request/about-pull-request-merges#merge-your-commits) übertragen werden. Alternativ empfiehlt `release-please` die Verwendung von [`squashed` Commits(https://docs.github.com/de/pull-requests/collaborating-with-pull-requests/incorporating-changes-from-a-pull-request/about-pull-request-merges#squash-and-merge-your-commits)]. So lange vor dem Zusammenführen der Branches entweder durch "sauberes" Arbeiten oder durch nachträgliches Aufräumen mit `rebase` die "Sauberkeit" der Commit Historie sichergestellt wird, sind beide Ansätze in Ordnung.
- **Temporäre Branches:** Feature und Fix Branches sind temporär und werden nach dem Durchführen des Pull Requests wieder gelöscht. Sie werden nie wieder verwendet.
- **Pull Request-zentrierter Ansatz:** Alle Änderungen an `main` müssen über Pull Requests erfolgen. `main` wird explizit über ein entsprechendes **Branch Protection Ruleset** geschützt.
- **Notwendige `GitHub` Workflows:** Alle notwendigen Workflows werden über [`setup_leptos_project.sh`](../scripts/setup_leptos_project.sh) bereit gestellt.

---

## Der Workflow in Schritten

### 1\. Feature-Branch erstellen und entwickeln

Starte die Entwicklung neuer Features oder Fixes auf einem dedizierten Feature-Branch.

```bash
# Sicherstellen, dass der lokale main Branch aktuell ist
git checkout main
git pull origin main

# Neuen Feature-Branch erstellen
git checkout -b feature/mein-super-feature
```

### 2\. Feature-Branch aufräumen (Interaktives Rebasen)

Bevor du deinen Feature-Branch zur Code-Review einreichst, bereinige seine Historie lokal. Dies macht deine Commits atomarer und aussagekräftiger.

```bash
# Interaktiven Rebase starten
git rebase -i main
```

- **Im geöffneten Editor:** Nutze Befehle wie `reword` (Commit-Nachricht bearbeiten), `squash` (mit vorherigem Commit zusammenfassen) oder `fixup` (mit vorherigem Commit zusammenfassen, Nachricht verwerfen), um deine Commits zu organisieren und zu verbessern. Speichere und schließe die Datei, damit Git den Rebase durchführen kann.

- **Pushe deinen bereinigten Branch:** Da du die Historie umgeschrieben hast, ist ein Force Push nach Origin notwendig. Verwende immer `--force-with-lease`, um unbeabsichtigtes Überschreiben von Änderungen anderer zu vermeiden.

  ```bash
  git push origin feature/mein-super-feature --force-with-lease
  ```

Hier findest du [Informationen zu Git-Rebase](https://docs.github.com/de/get-started/using-git/about-git-rebase) auf GitHub.

### 3\. Feature-Branch in `main` mergen (Release-Vorbereitung via Pull Request)

Erstelle einen Pull Request (PR) von deinem Feature-Branch nach `main`.

- **PR erstellen:** Öffne einen PR von `feature/mein-super-feature` nach `main`.
- **Review & Checks:** Lasse den Code reviewen und stelle sicher, dass alle CI/CD-Checks erfolgreich sind.
- **Mergen:** Der Merge dieses PRs nach `main` sollte als **normaler Merge** (Commits bleiben einzeln erhalten) oder als **Squash-Merge** (Commits werden zu einem Commit zusammen gefasst) erfolgen (nicht Rebase-Merge).

> 💡 **Hinweis:** Vergiss nicht, den temporären Feature Branch nach dem merge lokal und auf Origin zu löschen.

#### Tipps zu Squash-Merge

Wenn `Squash Merge` verwendet wird, werden alle Commits aus dem Feature Branch in einen einzigen Commit "_gesquashed_". Dabei ist zu beachten, das weiterhin das [Conventional Commits](https://www.conventionalcommits.org/) Format eingehalten wird. Ein Beispiel dazu findet man in der [`release-please` Dokumentation](https://github.com/googleapis/release-please#what-if-my-pr-contains-multiple-fixes-or-features):

```text
feat: adds v4 UUID to crypto

This adds support for v4 UUIDs to the library.

fix(utils): unicode no longer throws exception
  PiperOrigin-RevId: 345559154
  BREAKING-CHANGE: encode method no longer throws.
  Source-Link: googleapis/googleapis@5e0dcb2

feat(utils): update encode to support unicode
  PiperOrigin-RevId: 345559182
  Source-Link: googleapis/googleapis@e5eef86
```

> 💡 **Hinweis:** In GitHub wird bei einem Squash Merge vor jedem gesquashten Commit Kommentar ein `*` gesetzt. Dies muss entfernt werden, damit das Parsen der Commits durch `release-please` korrekt funktioniert. Des Weiteren ist darauf zu achten, das der Pull Request selber auch mit einem `Conventional Commits` Tag versehen werden muss.

### 4\. `release-please` wird aktiv und aktualisiert `main`

Nach dem Merge nach `main` wird `release-please` (typischerweise über GitHub Actions) ausgelöst.

- `release-please` analysiert die neuen Commits auf `main` (die ursprünglichen Feature-Commits aus dem temporären Branch).
- Es erstellt automatisch einen **neuen Pull Request** (z.B. "Release v1.2.3") auf `main`. Dieser PR enthält:
  - Den Version Bump in der Versionsdatei (z.B. `Cargo.toml`).
  - Das generierte Changelog.
  - Ggf. weitere Release-Artefakte.

> 💡 **Hinweis:** Wenn `release-please` anders als erwartet arbeitet, können die entsprechenden Dateien lokal in dem temporären `release-please` Branche angepasst werden. Achte darauf, alle von `release-please` aktualisierten Dateien zu überprüfen. Danach den erstellten Release Pull Request entsprechend überarbeiten.

Der Commit Nachricht des Release Pull Requests sollte sicherheitshalber noch ein `chore:` vorweg gestellt werden, damit dieser in späteren `release-please` Durchläufen ignoriert wird.

### 5\. `release-please`-PR nach `main` mergen

Überprüfe den von `release-please` erstellten PR. In den meisten Fällen kann dieser PR direkt gemergt werden.

- **Mergen:** Führe einen **normalen Merge** für diesen `release-please`-PR nach `main` durch.
- `main` enthält nun die aktualisierte Version und das Changelog. Ein entsprechendes Release-Tag wird gesetzt.

### 6\. Publishing über Docker Image

Wenn deine App über ein Docker Image veröffentlicht werden soll, dann ist jetzt der Bau und die Veröffentlichung des Docker Images anzustoßen (typischerweise über GitHub Actions). Der Workflow [`publish.yml`](../github/workflows/publish.yml) reagiert aus das gesetzte Release-Tag und führt die folgenden Schritte aus:

- **Dockerfile** nutzen, um ein Docker Image zu erstellen.
- Taggen des Docker Image mit der Version und dem `latest` Tag.
- Veröffentlichen des Docker Image in der GitHub Docker Registry `ghcr.io`.

---
