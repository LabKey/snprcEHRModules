select id,
      date,
      enddate,
	  code,

	  case when age_in_months(date, enddate) <= 12
	  then concat( cast(timestampdiff('SQL_TSI_DAY', date, COALESCE(enddate, curdate()) ) as varchar(4)) , ' days   ')
    else concat(concat(cast(age_in_years(date, COALESCE(enddate, curdate())) as varchar(3)), ' yrs ' ),
                 concat(cast(  (timestampdiff('SQL_TSI_DAY', date, COALESCE(enddate, curdate())) - age_in_years(date, COALESCE(enddate, curdate())) * 365)  as varchar (5)) , ' days') )
    end

		as duration

from study.diet