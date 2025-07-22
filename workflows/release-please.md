# 📝 Commit-Guideline für Projekte mit `release-please`

Projekte, die mit dem Script [`setup_leptos_project.sh`](../scripts/setup_leptos_project.sh) erstellt werden, verwenden [Conventional Commits](https://www.conventionalcommits.org/) und sind mit [`release-please`](https://github.com/googleapis/release-please) konfiguriert, um automatische Releases und Changelogs zu erstellen.  
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

## 📚 Weitere Ressourcen

- 🌐 [Conventional Commits – Offizielle Spezifikation](https://www.conventionalcommits.org/en/v1.0.0/)
- 🚀 [release-please – GitHub Action](https://github.com/googleapis/release-please)
- 📦 [Beispiel für ein semantisch versioniertes Changelog](https://github.com/googleapis/release-please#release-pr)

---
