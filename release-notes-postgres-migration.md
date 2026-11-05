---
title: SNPRC EHR Postgres Migration - Release Notes
date: 2026-11-05
---

# SNPRC EHR Postgres Migration - Release Notes

The 26.3 release has been updated to run on PostgreSQL while keeping SQL Server fully supported through the final SQL Server support release. All five SNPRC modules now declare `mssql, pgsql` support. [snprcEHRModules #888](https://github.com/LabKey/snprcEHRModules/pull/888) added PostgreSQL schema scripts for `snprc_ehr`, `snprc_genetics`, and `snprc_r24`; [snprcEHRModules #947](https://github.com/LabKey/snprcEHRModules/pull/947) did the same for `snprc_scheduler`; and `snd` was migrated in [ehrModules #1112](https://github.com/LabKey/ehrModules/pull/1112) before moving into this repository ([snprcEHRModules #921](https://github.com/LabKey/snprcEHRModules/pull/921)). The query and reporting work is split across two PRs. [snprcEHRModules #955](https://github.com/LabKey/snprcEHRModules/pull/955) (merged) declares PostgreSQL support for `snprc_ehr` and `snprc_genetics`, fixes SQL syntax that only worked on SQL Server, and lets `SNPRC_EHRTest` run on PostgreSQL. [snprcEHRModules #990](https://github.com/LabKey/snprcEHRModules/pull/990) (in review) addresses collation and the remaining behavioral differences, reconciling results query by query against the SQL Server source, and registers the migration-time data normalization. Four companion framework PRs supply support that these depend on; they are listed at the end for reference.

## Related Support Tickets

- [Issue 55242](https://www.labkey.org/SNPRC/Support%20Tickets/issues-details.view?issueId=55242)
- [Issue 55241](https://www.labkey.org/SNPRC/Support%20Tickets/issues-details.view?issueId=55241)
- [Issue 55179](https://www.labkey.org/SNPRC/Support%20Tickets/issues-details.view?issueId=55179)

## Impact Statement

The rollout happens in two phases. First, SNPRC deploys 26.3, which includes the PRs in these notes, while continuing to run on SQL Server. Later, SNPRC and LabKey will coordinate the database migration to Postgres using LabKey's migration workflow. A few reports change immediately on SQL Server, since these PRs fix latent bugs and canonicalize values that SQL Server previously merged silently. The Postgres migration then applies further normalization to stored data.

### Why the SQL had to change

SQL Server and Postgres are similar enough that many reports look portable at first glance, but they differ in several places that matter for SNPRC's EHR queries:

1. **Collation: case and whitespace sensitivity.** SQL Server compares text case- and trailing-whitespace-insensitively; Postgres compares exactly. SNPRC source data carries many variants that SQL Server was collapsing without anyone noticing: animal IDs such as `4x0133` and `4X0133` (132 animals have records under both spellings), lab test names such as `ALBUMIN` and `Albumin`, service names, haplotypes, admit complaints, and lookup set names. On Postgres these split into separate rows at `GROUP BY`, `DISTINCT`, `UNION` and `PIVOT` time, and string filters stop matching. These PRs canonicalize each affected site in the query (typically `UPPER(LTRIM(RTRIM(...)))`), or normalize the stored value once at migration time where that repairs more consumers at once.
2. **Implicit type coercion.** SQL Server often compares unlike types by silently converting one side; Postgres usually rejects the comparison. These PRs add explicit casts in UNIONs, joins and comparisons (including the HL7 `ServiceId`/`PROCEDURE_ID` pivot joins), replace bit-style `= 0` with boolean literals, and read clinical-history timestamps as timestamps rather than parsing the driver's string rendering.
3. **SQL syntax and function differences.** SQL Server uses `+` for string concatenation and `charindex`/`len`; these were replaced with the portable `||` and `LOCATE`/`LENGTH`. `isnumeric()` and `right()` were made available on Postgres in the platform, and `isnumeric()` now returns 1/0 on both databases.
4. **Same function, different semantics.** `timestampdiff('SQL_TSI_DAY', ...)` counts calendar-date crossings on SQL Server but elapsed 24-hour periods on Postgres; day counts now use the LabKey SQL `age_in_days` function, which counts calendar days on both. `week()` is a driver passthrough that yields US numbering on SQL Server and ISO 8601 on Postgres; SNPRC's date-range lookups now call `weekus()` to keep US numbering on both.
5. **Quoted identifiers are case-sensitive on Postgres.** A quoted pivot column reference whose casing did not match its subquery alias silently returned NULLs on Postgres.
6. **Stricter query validation.** Four PIVOT queries that read their column list dynamically from `BaboonColonyGroups` failed LabKey query validation against an empty lookup table; they now use a literal list.
7. **Floating-point rounding.** SQL Server's `ROUND` on a `float` and Postgres's `ROUND` on `NUMERIC` can disagree on x.xx5 boundaries (see *Known differences* below).

### After the software update, still on SQL Server

The following changes are observable on SQL Server the moment the build is deployed, before any database migration runs.

1. **T. cruzi summary counts change.** `ReportTcruziSummaryAll` now deduplicates on the lab test ID rather than the test name. `labwork_panels` holds test 850 as `T. CRUZI AB` and test 965 as `T. Cruzi AB`, two codes distinguishable only by capitalization, which SQL Server was merging. In the reconciliation data, animal 28215 goes from 5 to 6 and the total from 257 to 258. **Open question for SNPRC:** this assumes 850 and 965 are genuinely different assays; confirm or advise if they should be merged.
2. **Culture pivot panel and test names are no longer swapped.** The two UNION branches of `culturePivotInner` listed their columns in opposite order, so panel and test name were transposed for every HL7-sourced row. This is a pre-existing bug that the comparison exposed; it is fixed on both databases.
3. **Lab pivot column names are canonicalized.** The hematology, chemistry, misc, culture, and surveillance pivots now take test names from a new `snprc_ehr.labworkPanelTestNames` query that merges spellings differing only in case or spaces. Column headers may show a different spelling of the same test than before. This join makes these pivots slower (about 30% on `hematologyPivot`); cleaning up the source test names in `labwork_panels` would remove the need for it.
4. **Some reports display animal IDs in uppercase.** `MhcDataPivot`, `BehaviorAbnormalSummary`, `proceduresPerYear`, and `ReportTcruziSummaryAll` group on the uppercased, trimmed ID. Row counts on SQL Server are not expected to change, but IDs entered in lowercase now display uppercase in these reports.
5. **`MhcDataPivot` reports the latest modified time per row.** It previously grouped on a minute-precision string rendering of `modified`; it now groups without `modified` and shows its maximum as a full timestamp. Rows that differed only by modification time collapse into one.
6. **TB and physical-exam status shows `Okay` instead of `OKAY` for infants.** One branch of `demographicsMostRecentTBDate` and `demographicsMostRecentPhysicalDate` returned `OKAY` while every other branch returned `Okay`. On SQL Server the two compare equal, so the overdue reports are unchanged; only the displayed value changes. (On Postgres the typo put 30 infant baboons on the overdue report.)
7. **Admit complaint list is trimmed and deduplicated.** `AdmitComplaintList` merges complaints that differ only in case or surrounding whitespace.
8. **"Enter Data" link on the SNPRC EHR begin page now goes to `ehr-enterData.view`.**
9. **Deleting a folder now removes its scheduler data.** The scheduler container listener now deletes Timeline tables on container removal and runs the cleanup in a single transaction.
10. **Adding a new colony group requires a query change.** The four colony-group PIVOT queries now list the groups literally instead of reading `BaboonColonyGroups`. **Action item:** if SNPRC adds a row to `BaboonColonyGroups`, those queries must be updated for the new group to appear.
11. **No intended change:** day-count logic now uses `age_in_days`, and `validateFinalWeights` is an SNPRC override using it; both follow SQL Server's calendar-day semantics. The date-range lookups' `weekus()` matches what SQL Server already returned. Migration handlers are registered but inert until `migrateSchemas`.

### After migrating to Postgres

The following describes reporting-relevant behavior at and after `migrateSchemas`.

1. **Reports converge with the post-update SQL Server output.** That is the goal of these PRs: same row counts and same values on Postgres as on the updated SQL Server build, not necessarily the old pre-update output. Results were reconciled query by query against the SQL Server source.
2. **GUID-shaped identifiers are canonicalized to lowercase, not remapped.** The SQL Server JDBC driver reports SNPRC's `ENTITYID` columns as `VARCHAR`, so the standard lowercasing does not apply to them. SNPRC registers `objectid`, `object_id`, `obr_object_id`, `servicetestid`, `taskid`, `requestid`, `parentid`, and `container` for lowercasing in the `snprc_ehr`, study dataset, `ehr`, and `ehr_lookups` schemas, so foreign keys between them still match. **Action item for admins:** saved URLs or external integrations that depend on exact uppercase GUID strings should be regenerated or normalized to lowercase. The GUID identity is preserved; only casing changes.
3. **Lookup values are normalized to their canonical case.** `ehr_lookups.lookups.set_name` is rewritten to the matching `lookup_sets` name in the same folder, so the per-set lookup queries (for example `ehr_lookups.AccessionCode`) do not return zero rows. `labwork_services.Dataset` is rewritten to the matching `labwork_types.ServiceType`, so its foreign key holds on Postgres. Values with no match are kept as-is.
4. **Source data still carries case variants.** The migration does not rewrite animal IDs, test names, or other free-text values. The reports listed above canonicalize them, but any other query, saved filter, custom report, or external tool that relied on SQL Server merging `4x0133` and `4X0133` (or `Alive` and `alive`) will treat them as distinct on Postgres. **Action item for SNPRC:** check local or database-only saved filters, custom reports, and dataset views that compare text literals, and consider normalizing the source data (the 132 animals with mixed-case IDs in particular).

### Known differences

- **Average weight on x.xx5 boundaries.** `demographicsMostRecentWeight` rounds the average weight as a `double`, so a value exactly on an x.xx5 boundary can differ by 0.01 kg between the databases: 0.415 shows as 0.41 on SQL Server and 0.42 on Postgres.

## Technical Change Summary

The impact sections above are the authoritative description of expected user-visible behavior. The implementation work in #955 and #990 falls into these groups:

- **Module PostgreSQL enablement.** PostgreSQL schema scripts came earlier (#888, #947, ehrModules #1112). [#955](https://github.com/LabKey/snprcEHRModules/pull/955) declares `mssql, pgsql` support in `snprc_ehr` and `snprc_genetics` and lets `SNPRC_EHRTest` run outside the SQL Server-only path, and [#990](https://github.com/LabKey/snprcEHRModules/pull/990) finishes the PostgreSQL bootstrap script (`HL7_IMPORT_LOG.TID` becomes a `BIGINT` identity).
- **SQL portability fixes.** String concatenation, `LOCATE`/`LENGTH`, explicit casts in UNIONs and joins, boolean literals, `FLOOR` instead of `truncate`, literal PIVOT column lists, corrected Tcruzi view column references, and case-insensitive `objectid=` extraction from audit record maps in the SND and weight deleted-source queries.
- **Collation fixes.** About 25 SNPRC queries canonicalize case and whitespace at the point where SQL Server's collation used to merge variants, plus the shared `labworkPanelTestNames` query for the lab pivots. `R24WeightsDeletedSrc` and `DemographicsHL7DeleteSource` returned zero rows on Postgres because of dataset-name casing and are fixed.
- **Migration-time normalization.** `SNPRC_EHRModule` registers migration handlers that lowercase GUID columns and map `set_name` and `labwork_services.Dataset` to their canonical case.
- **Dialect semantics.** `age_in_days` replaces `timestampdiff` day counts, and SNPRC overrides `ehr_lookups.dateRange`, `ehr_lookups.next30Days`, `ldk.dateRange`, and `study.validateFinalWeights` so other centers' Postgres values do not move.
- **Other fixes the comparison exposed.** `culturePivotInner` column order, `colonyUsageQuery` gender pivot and alias casing, a boolean `visible` filter in `AnimalsHierarchyController`, and transactional scheduler container cleanup.
- **Tests.** Shared setup extracted into `SnprcSetupHelper`; `SNPRC_EHRTest` and `SNPRC_schedulerTest` updated for PostgreSQL; sample-data `Status` values normalized to `Alive`.

## Reference: Companion PRs

These framework PRs ship alongside the SNPRC PRs and supply infrastructure they depend on. They contain no SNPRC code.

- [platform #7798](https://github.com/LabKey/platform/pull/7798): portable LabKey SQL `isnumeric()`, and `right()` available on PostgreSQL.
- [premiumModules #639](https://github.com/LabKey/premiumModules/pull/639): SQL Server side of the `isnumeric()` change.
- [platform #7993](https://github.com/LabKey/platform/pull/7993): adds `weekus()`/`weekiso()`, makes `isnumeric()` return 1/0 on both databases, and fixes how PIVOT values are emitted in generated SQL.
- [premiumModules #745](https://github.com/LabKey/premiumModules/pull/745): SQL Server implementations of `weekus()` and `weekiso()`.
- [platform #7547](https://github.com/LabKey/platform/pull/7547): adds `age_in_days` and the schema-contributor registration interface used by the SNPRC migration handlers.
