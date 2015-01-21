SELECT
  a.demographics.id As Animal,
  a.demographics.gender As Gender,
  cl.ageclass,
  h.room,
  hr.roommateId.id As Roommate,
  rd.gender As "Roommate Gender"

FROM study.Animal a

LEFT JOIN ehr_lookups.ageclass cl
ON (a.ageclass.ageclass=cl.ageclass)

LEFT JOIN study.housing h
ON (a.id=h.id)

LEFT JOIN study.housingRoommates hr
ON (a.id=hr.id)

LEFT JOIN study.demographics rd
ON (rd.id=hr.roommateId.id)