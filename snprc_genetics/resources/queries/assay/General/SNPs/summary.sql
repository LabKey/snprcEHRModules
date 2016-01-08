SELECT
  d.subjectId,
  d.snp,
  group_concat(coalesce(CAST(d.value as varchar), 'ND'), '/') as alleles,
  count(*) as totalResults,
  d.run

FROM Data d
GROUP BY d.run, d.subjectId, d.snp