This folder will eventually hold the XML describing the SQLServer tables to sync.  For the first phase,
we will need to create database views that select the appropriate data and transform it as needed for
the EHR datasets.  Examples of the ONPRC ETL SQL scripts (which are analogous to what a view might use),
can be found in SVN under /server/customModules/onprc_ehr/resources/etl.  There are a handful in this folder
and many more in the /deprecated subfolder.