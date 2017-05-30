SELECT pc.id,
  pc.date,
  pc.AccessionCode,
  pc.AccessionNumber,
  pd.morphology,
  pd.organ,
  pd.etiology_code
FROM PathologyCases as pc
  LEFT JOIN PathologyDiagnoses as pd on pc.AccessionNumber = pd.AccessionNumber
where pc.qcstate.publicdata = true