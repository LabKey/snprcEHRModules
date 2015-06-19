SELECT id, obs_date, category, CAST(observation AS VARCHAR(3)) 
FROM (SELECT id, obs_date,
	CAST(water AS VARCHAR(3) ) AS water, CAST(feed  AS VARCHAR(3) ) AS feed,
	CAST(sa_none AS VARCHAR(3) ) AS sa_none,  CAST(sa_bloody AS VARCHAR(3)) AS sa_bloody,
	CAST(sa_dry AS VARCHAR(3) ) AS sa_dry, CAST(sa_loose AS VARCHAR(3) ) AS sa_loose,
	CAST(sa_normal AS VARCHAR(3) ) AS sa_normal, CAST(sa_other AS VARCHAR(3) ) AS sa_other,
	CAST(sa_pellet AS VARCHAR(3) ) AS sa_pellet,
	CAST(sa_soft AS VARCHAR(3) ) AS sa_soft, CAST(sa_unknown AS VARCHAR(3) ) AS sa_unknown, 
	CAST(sa_watery  AS VARCHAR(3) ) AS sa_watery, 
	CAST(housing_status AS VARCHAR(3)) AS housing_status
 FROM observations WHERE housing_status IS NOT NULL) --WHERE id = ' 15149')
AS result 
UNPIVOT
(
  observation FOR category   IN (water, feed , sa_none, sa_bloody, sa_dry, sa_loose,
	sa_normal, sa_other, sa_pellet, sa_soft, sa_unknown, sa_watery, housing_status)
	)
	AS Unpvt