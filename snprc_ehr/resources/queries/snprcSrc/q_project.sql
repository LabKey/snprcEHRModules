SELECT
  --TODO: make a numeric PK?
  --null as project,

  working_iacuc AS name,
  annual_review_date AS lastAnnualReview,
  termination_date AS enddate
FROM dbo.arc_master a