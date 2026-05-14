# snd module history

**TL;DR:** the `snd` module's full commit history travels with it on every migration. **File-level** history and blame work everywhere — GitHub, IntelliJ, and any tool that follows renames (Sourcetree, GitKraken, Fork, GitLens, `git log --follow`, etc.). **Directory-level** history (`git log -- snd/` or GitHub's directory tree view) only shows commits since the most recent migration — for older directory-level browsing, open the corresponding repo from the table below.

## Why directory-level history is limited

Each migration changed the path of the module — first from a repo root into a subdirectory, then between subdirectories. Git's rename detection is per-file, not per-directory, so a directory-level log starts fresh at each move even though every individual file's history remains intact.

## Where prior history lives

| Repository                                                                                                       | History active          | Notes                                                                    |
|------------------------------------------------------------------------------------------------------------------|-------------------------|--------------------------------------------------------------------------|
| [LabKey/snd](https://github.com/LabKey/snd)                                                                      | until 2025-02-24        | Original standalone repo. Now archived.                                  |
| [LabKey/ehrModules/snd](https://github.com/LabKey/ehrModules/tree/fc811d93c1a99ee46e219508da17041a9bcfb2d4/snd)  | 2025-02-24 → 2026-05-05 | Rehomed via `LabKey/ehrModules` commit `76b86bc5` ("Rehome snd module"). |
| [LabKey/snprcEHRModules/snd](https://github.com/LabKey/snprcEHRModules/tree/develop/snd)                         | 2026-05-05 → present    | Current home. Rehomed from `LabKey/ehrModules`.                          |

## Browsing history

### File-level (works everywhere)

Any Git tool that follows renames will show full history back to the module's origin:

- **GitHub**: open any individual file, then click *History* or *Blame*. GitHub follows renames automatically across migrations.
- **IntelliJ**: right-click a file → *Git → Show History* (or *Annotate* for blame).
- **Other tools** (Sourcetree, GitKraken, Fork, GitLens, etc.): use the file's history or blame view — these tools follow renames by default.
- **CLI**: `git log --follow -- <path/to/file>`.

### Directory-level (use the table above)

There is no built-in equivalent to `--follow` for directories. To see directory-level history from before a migration, open the corresponding repo from the table above for the date range you care about and browse the module directory there.
