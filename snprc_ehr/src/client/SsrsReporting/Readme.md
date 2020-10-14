## External reports are configured in the snprc_ehr.ExternalReports table using the format below.

- Id - identity field
- SortOrder - Optional integer value used to order report rows
- Label - display value in the report list
- Report - the SSRS path to the report and any optional hardcoded parameters e.g. *'CenterReports/IACUC/3YrRollover&Mode=1',*
- Description - report description
- Parameters - optional parameters 
```
    // parm format is: name, type, label, value
    // Each parm gets its own object
    // Example: 'TargetID:string:Target ID:31415, ...' = [{name: 'TargetId', type: 'string', label: 'Target ID', value: '31415' }, ...]
```    
- rsParameters - optional URL access parameters e.g., *'&rs:Command=Render'* 
[URL access parameter reference](https://docs.microsoft.com/en-us/sql/reporting-services/url-access-parameter-reference?view=sql-server-ver15)

## Source SSRS Server Configuration
The SSRSServerURL property is used to configure the reporting server viewer baseURL. To set its value use the *Folder>Management>Module Properties* UI.  
For example: `http://servername/ReportServer/Pages/ReportViewer.aspx?`

## Example table insert statement

```
	INSERT INTO snprc_ehr.ExternalReports
    (
        SortOrder, 
		Label,
        Report,
        Description,
        Parameters,
        rsParameters,
        Created,
        Modified,
        CreatedBy,
        ModifiedBy
    )
    VALUES
    (	7,
        N'IACUC 3yr Rollover (Standard)',       -- Label - nvarchar(64)
        N'CenterReports/IACUC/3YrRollover&Mode=1',       -- Value - nvarchar(400)
        N'Target Date is used to determine 3yr period.',       -- Description - nvarchar(4000)
        N'IACUC:string:IACUC, TargetDate:Date:Target Date',       -- Parameters - nvarchar(4000)
        N'&rc:Parameters=Collapsed',       -- rsParameters - nvarchar(4000)
        GETDATE(), -- Created - datetime
        GETDATE(), -- Modified - datetime
        (SELECT userId FROM core.Principals WHERE name LIKE '%thawkins%') ,      -- CreatedBy - USERID
        (SELECT userId FROM core.Principals WHERE name LIKE '%thawkins%')       -- ModifiedBy - USERID
    )
```