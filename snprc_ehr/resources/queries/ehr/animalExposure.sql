SELECT DISTINCT
  a.demographics.id As Animal,
  a.demographics.gender As Gender,
  a.ageclass.ageclass As "AgeClass",
  h.room,
  hr.roommateId.id As Roommate,
  rd.demographics.gender As "Roommate Gender",
  rd.ageclass.ageclass As "Roommate Age Class"

FROM study.Animal a

LEFT JOIN study.housing h
ON (a.id=h.id)

LEFT JOIN study.housingRoommates hr
ON (a.id=hr.id)

LEFT JOIN study.Animal rd
ON (rd.id=hr.roommateId.id)
