# 📝 Commit-Guideline für Projekte mit `release-please`

Projekte, die mit dem Script [`setup_leptos_project.sh`](../scripts/setup_leptos_project.sh) erstellt werden, verwenden [Conventional Commits](https://www.conventionalcommits.org/) und sind mit [`release-please`](https://github.com/googleapis/release-please) konfiguriert, um automatische Releases und Changelogs zu erstellen.  

> 💡 **Hinweis:** Die VSC Erweiterung `Conventional Commits` ist besonders praktisch.

Bitte halte dich beim Committen an die folgende Struktur:

---

## ✅ Commit-Syntax

```bash
<type>[optional scope]: <kurze Beschreibung>

[optional ausführliche Beschreibung]
[optional BREAKING CHANGE: Beschreibung der Breaking Change]
```

### 🔹 Beispiele

```bash
feat: add user login form
fix: correct broken route resolution
chore: update Rust toolchain version
docs: add API usage section to README
refactor(auth): simplify token validation logic
```

---

## 🔖 Gültige `type` Tags

| Typ        | Beschreibung |
|------------|--------------|
| `feat`     | Neues Feature, das für Nutzer sichtbar ist (**löst Minor-Release aus**) |
| `fix`      | Fehlerbehebung, Bugfix (**löst Patch-Release aus**) |
| `docs`     | Änderungen an der Dokumentation |
| `style`    | Formatierung, keine Logik-Änderungen (z. B. Leerzeichen, Kommentare) |
| `refactor` | Code-Umstrukturierung ohne funktionale Änderungen |
| `perf`     | Performance-Verbesserungen ohne Verhaltensänderung |
| `test`     | Änderungen oder Ergänzungen von Tests |
| `build`    | Build-System oder Abhängigkeitsverwaltung |
| `ci`       | Continuous Integration Setup oder Änderungen |
| `chore`    | Wartungsaufgaben, z. B. Dependency-Updates, Cleanup |
| `revert`   | Rückgängig machen eines früheren Commits |

---

## 🚨 Breaking Changes

Wenn eine Änderung inkompatibel ist (z. B. eine öffentliche API wurde entfernt), kennzeichne sie mit einem `!` nach dem Typ oder mit `BREAKING CHANGE:` im Commit-Body.

### 🔹 Beispiel mit `!`

```bash
feat!: remove deprecated authentication system
```

### 🔹 Beispiel mit Beschreibung im Body

```bash
feat: remove deprecated authentication system

BREAKING CHANGE: The old /auth endpoint has been removed.
```

Ein Breaking Change führt zu einem **Major-Version-Bump** beim nächsten Release. Verwende dies auch, wenn du einen **Major-Version-Bump** erzeugen willst, auch wenn kein Breaking Change vorliegt (z.B. für Veröffentlichung von `v1.0.0`).

---

## 💡 Tipps zur Commit-Erstellung

- Schreibe Commit-Messages **im Imperativ** (z. B. „add“, nicht „added“ oder „adds“).
- Nutze bei Bedarf ein `scope`, um zu präzisieren, worauf sich der Commit bezieht:

  ```bash
  feat(login): add remember me checkbox
  ```

- Verwende `chore` nur für interne Aufgaben, die **nicht im Changelog erscheinen müssen** (z. B. `chore: update README formatting`).
- Für dokumentationsrelevante Änderungen, auch z. B. an einer `LICENSE`, verwende `docs`.

---

## 🔍 Release Pull Request

Du kannst zwar `release-please` auch per CLI nutzen, aber empfohlen ist die [`release-please-action`](https://github.com/googleapis/release-please-action) in einem GitHub Workflow, z.B. [`_release_please.yml`](../github/workflows/_release_please.yml). Sobald neue Commits nach `main` gepusht werden (entweder direkt oder per Pull Request, s.u.), wird der Workflow aktiv. Sollte noch kein sogenannter `Release PR`, also ein `Release Pull Request`, existieren, wird dieser erstellt. Wann immer neue Commits nach `main` erfolgen, werden diese analysiert und der `Release PR` entsprechend erweitert. Sobald die für einen Release gewünschten Commits alle erfolgt sind, ist der `Release PR` per `Squash Merge` (s.u.) nach `main` abzuschließen. Nach erfolgreichem merge wird der Commit mit einem Version Tag durch `release-please` versehen, was z.B. genutzt werden kann, um den [`Publish.yml`](../github/workflows/publish.yml) anzustoßen.

## 🚦 Nutze Squash Merge

Wenn du einen Pull Request von einem Feature Branch oder von dem [`Release PR`](#-release-pull-request) nach `main` ausführst, verwende dafür `Squash Merge`. Bei einem `Squash Merge` werden alle Commits in einen einzigen Commit übertragen. Dieser Commit wird dann durch den Pull Request nach `main` überführt. Dabei ist folgendes zu beachten:

- **Du hast nur einen einzigen Commit im Branch:** Dann wird `Squash Merge` diesen Commit inhaltlich komplett übernehmen. Summary und description sind identisch.
- **Du hast mehrere Commits im Branch:** Dann wird `Squash Merge` die summaries und descriptions der Commits in der description des Merge Commits übertragen. Achte dabei darauf, dass das Tag im summary des Merge Commits darüber entscheidet, ob dieser selbst mit ins `CHANGELOG.md` übertragen wird (z.B. bei `feat` oder `fix`) oder nicht (z.B. bei `chore`).

Ein Beispiel zu mehren Commits, wie sie ein `Squash Merge` erzeugt, findet man in der [`release-please` Dokumentation](https://github.com/googleapis/release-please#what-if-my-pr-contains-multiple-fixes-or-features), wobei die erste Zeile das summary darstellt.

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

> 💡 **Hinweis:** In GitHub wird bei einem `Squash Merge` vor jedem gesquashten Commit ein `*` gesetzt. Dies muss entfernt werden, damit das Parsen der Commits durch `release-please` korrekt funktioniert.

## 📚 Weitere Ressourcen

- 🌐 [Conventional Commits – Offizielle Spezifikation](https://www.conventionalcommits.org/en/v1.0.0/)
- 🚀 [release-please – GitHub Action](https://github.com/googleapis/release-please-action)
- 📦 [Beispiel für ein semantisch versioniertes Changelog](https://github.com/googleapis/release-please/blob/main/CHANGELOG.md)

---
