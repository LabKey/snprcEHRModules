SELECT p.protocol AS Iacuc,
       p.protocol + ' - ' +  RTRIM(p.inves)+ ' -' + RTRIM(p.title) AS DisplayValue,
       RIGHT(p.protocol, 2) AS Species,
       p.approve AS ApprovalDate,
       p.enddate AS EndDate,
       p.maxAnimals AS MaxAnimals
FROM ehr.protocol AS p