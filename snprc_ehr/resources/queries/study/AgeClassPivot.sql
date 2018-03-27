SELECT label,
  "M::ageRange" as M,
  "F::ageRange" as F,
  "U::ageRange" as U,
  species as species_code
FROM
  (
    SELECT label,
      gender,
      group_concat(ageRange) as ageRange,
      ageclass,
      species

    FROM study.AgeClassesRanges

    GROUP BY Label, gender, ageClass, species

    PIVOT ageRange BY gender IN ('M', 'F', 'U') ) age