SELECT
  age.label,
  age.species,
  age.ageclass,
  age."min",
  age."max",
  age.gender

FROM ehr_lookups.ageclass AS age
where gender is not null

union

SELECT
  age.label,
  age.species,
  age.ageclass,
  age."min",
  age."max",
  case when age.gender is null then 'M' end as gender

FROM ehr_lookups.ageclass AS age
where gender is null

union

SELECT
  age.label,
  age.species,
  age.ageclass,
  age."min",
  age."max",
  case when age.gender is null then 'F' end as gender

FROM ehr_lookups.ageclass AS age
where gender is null

union

SELECT
  age.label,
  age.species,
  age.ageclass,
  age."min",
  age."max",
  case when age.gender is null then 'U' end as gender

FROM ehr_lookups.ageclass AS age
where gender is null