-- b.Id, b.Haplotype, b.Ocid, b.DataFileSource are all canonicalized with UPPER(LTRIM(RTRIM(...))) because
-- the source has case/whitespace variants (e.g. animal IDs like 4x0133 vs 4X0133; haplotype/OCID casing).
-- SQL Server's case-insensitive collation collapsed these variants at GROUP BY / PIVOT time; Postgres is
-- case- and whitespace-sensitive and would otherwise split them into separate output rows / pivot columns.
--
-- b.modified is aggregated via MAX() rather than included in GROUP BY. SQL Server's default
-- cast(datetime as varchar) uses coarser precision (minute-level) than Postgres's cast (which preserves
-- microseconds), so identical-looking timestamps that collapsed to one string on SS stayed distinct on
-- PG and split into extra groups (+158 rows before this change). MAX(b.modified) keeps the latest
-- modification timestamp in the output for display without letting per-microsecond differences drive
-- grouping.
SELECT
    b.Id,
    cast(MAX(b.modified) as varchar) as modified,
    b.Haplotype,
    b.Ocid,
    b.DataFileSource,
    group_concat(b.MhcValue) as MhcValue


FROM (
         SELECT
             UPPER(LTRIM(RTRIM(b.Id))) as Id,
             UPPER(LTRIM(RTRIM(b.Haplotype))) as Haplotype,
             UPPER(LTRIM(RTRIM(b.Ocid))) as Ocid,
             b.MhcValue,
             UPPER(LTRIM(RTRIM(b.DataFileSource))) as DataFileSource,
             b.modified
         FROM snprc_ehr.MhcData as b
     ) as b

GROUP BY b.id, b.ocid, b.DataFileSource, b.haplotype

    PIVOT MhcValue BY Haplotype IN
(
    select distinct UPPER(LTRIM(RTRIM(Haplotype))) as Haplotype from snprc_ehr.MhcData order by UPPER(LTRIM(RTRIM(Haplotype)))
)