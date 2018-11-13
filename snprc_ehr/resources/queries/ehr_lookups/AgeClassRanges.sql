SELECT
  age.label,
  age.species,
  age.ageclass,

  -- please excuse the ugly formatting - A sql server convert function would be helpful here!
  case when (age."max" is NULL and age.label = 'Senior') then
    (CAST(age."min" as VARCHAR(5) ) + case when (age."min"- truncate(age."min", 0) > 0)  then  '' else '.0 - ' end)
  ELSE
    (CAST(age."min" as VARCHAR(5)) +
     + case when (age."min"- truncate(age."min", 0) > 0)  then  ' - ' else '.0 - ' end

     + CAST(age."max" as varchar(5))
     + case when (age."max"- truncate(age."max", 0) > 0)  then  '' else '.0' end )
  END AS ageRange,

  age.gender

FROM ehr_lookups.AgeclassesAll AS age

