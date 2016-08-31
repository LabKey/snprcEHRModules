-- working code to emulate acq_disp
-- 8/31/2016 Scott Rouse

SELECT
a.id as id, a.date as acq_date,a.AcquisitionType.value as acq_code, a.acquisitionType,
            d.date as disp_date, d.dispositionType.value as disp_code, d.dispositionType
FROM arrival a
	LEFT OUTER JOIN departure d
	on d.id = a.id and a.date < ifnull(d.date,curdate())

where a.date < ifnull(d.date,curdate())
  and   ( d.date = (select min(z.date) from departure z where z.id = d.id and z.date > a.date)
                 or
       d.date is NULL)