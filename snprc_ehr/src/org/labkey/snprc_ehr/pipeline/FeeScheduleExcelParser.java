package org.labkey.snprc_ehr.pipeline;


import org.apache.commons.lang3.StringUtils;
import org.apache.poi.openxml4j.exceptions.InvalidFormatException;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.json.JSONObject;
import org.labkey.api.data.Container;
import org.labkey.api.data.DbSchema;
import org.labkey.api.data.DbSchemaType;
import org.labkey.api.data.DbScope;
import org.labkey.api.data.Table;
import org.labkey.api.data.TableInfo;
import org.labkey.api.pipeline.PipelineJobException;
import org.labkey.api.reader.ExcelFactory;
import org.labkey.api.security.User;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;


public class FeeScheduleExcelParser
{

    /**
     * Parses the FeeSchedule Excel spreadsheet files
     * User: thawkins
     * Date: December 27, 2017
     */
    private File _importFile;

    private boolean _parsed;
    private final String _feeScheduleSheetName = "Fee Schedule";
    private final int _numberOfSkipHeaderRows = 6;
    private Map<Integer, FeeScheduleDataRow> _feeScheduleMap = new LinkedHashMap<>();
    private List<String> _colNames = new ArrayList<>();
    private Container _container;
    private User _user;


    public FeeScheduleExcelParser()
    {
        _parsed = false;
    }

    public FeeScheduleExcelParser(Container c, User user, File importFile)
    {
        _importFile = importFile;
        _parsed = false;
        _container = c;
        _user = user;
    }

    public void parseFile() throws PipelineJobException
    {
        Map<String, Double> costValueMap = new LinkedHashMap<>();
        int rowIdx;
        Row row;
        String value;
        Double doubleValue;
        boolean hasData = false;

        // only parse the file once
        if (_parsed) return;

        try
        {
            Workbook workbook = ExcelFactory.create(_importFile);
            Sheet sheet = workbook.getSheet(_feeScheduleSheetName);
            if (sheet == null)
            {
                throw new PipelineJobException("Fee Schedule tab sheet not found in workbook.");
            }

            rowIdx = _numberOfSkipHeaderRows;

            if (rowIdx <= sheet.getLastRowNum())
            {
                // read column header row
                Row r = sheet.getRow(rowIdx);
                if (r != null)
                {
                    for (Cell cell : r)
                        _colNames.add(ExcelFactory.getCellStringValue(cell).trim());
                }
                // skip second header row
                rowIdx += 4;
            }
            else
            {
                throw new PipelineJobException("Couldn't read importFile column headers");
            }

            // parse data

            int j = sheet.getLastRowNum();

            for (int i = rowIdx; i < sheet.getLastRowNum(); i++)
            {
                hasData = true;
                row = sheet.getRow(i);

                if (row != null)
                {
                    FeeScheduleDataRow dataRow = new FeeScheduleDataRow();

                    for (int col = 0; col < row.getLastCellNum(); col++)
                    {
                        Cell cell = row.getCell(col);
                        if (cell == null)
                        {
                            continue;
                        }
                        if (_colNames.size() <= col)
                        {
                            //throw new PipelineJobException("Unable to find header for cell [" + i + " /" + col + "]");
                            continue;
                        }
                        String columnName = _colNames.get(col);

                        // get data values

                        if ("Species".equalsIgnoreCase(columnName))
                        {
                            value = ExcelFactory.getCellStringValue(cell).trim();
                            dataRow.setSpecies(StringUtils.trimToNull(value));
                        }
                        else if ("Description".equalsIgnoreCase(columnName))
                        {
                            value = ExcelFactory.getCellStringValue(cell).trim();
                            dataRow.setDescription(StringUtils.trimToNull(value));
                        }
                        else if ("Activity ID".equalsIgnoreCase(columnName))
                        {
                            if (ExcelFactory.isCellNumeric(cell))
                            {
                                doubleValue = cell.getNumericCellValue();
                                dataRow.setActivityId(doubleValue.intValue());
                            }
                            else
                            {
                                hasData = false;
                                break;  // skip this row if it doesn't have an activity Id
                            }
                        }
                        else
                        {
                            // get cost values for each year/activity
                            if (!columnName.isEmpty() && ExcelFactory.isCellNumeric(cell))
                            {
                                costValueMap.put(columnName, cell.getNumericCellValue());
                            }
                        }
                    } // end col loop

                    if (hasData)
                    {
                        dataRow.setCost(costValueMap);
                        dataRow.setFileName(_importFile.getName());
                        _feeScheduleMap.put(i, dataRow);
                    }
                }

            }   // end row loop

            _parsed = true;

        }   // end function


        catch (IOException e)
        {
            throw new PipelineJobException("Failed to read from data file " + _importFile.getName(), e);
        }
        catch (InvalidFormatException e)
        {
            throw new PipelineJobException("Failed to parse file as Excel: " + _importFile.getName(), e);
        }
    }


    public int loadTable() throws PipelineJobException
    {
        //TODO: need to handle existing data - add archive date?

        DbSchema schema = DbSchema.get("snprc_ehr", DbSchemaType.Module);
        TableInfo ti = schema.getTable("FeeSchedule");
        DbScope scope = schema.getScope();
        JSONObject o = new JSONObject();

        try (DbScope.Transaction trans = scope.ensureTransaction())
        {

            for (FeeScheduleDataRow fsi : _feeScheduleMap.values())
            {
                o.clear();

                if (fsi.getSpecies() == null) continue; // skip entry
                o.put("container", _container);
                o.put("ActivityId", fsi.getActivityId());
                o.put("Species", fsi.getSpecies());
                o.put("Description", fsi.getDescription());
                o.put("FileName", fsi.getFileName());
                o.put("Created", new Date());
                o.put("CreatedBy", _user);


                for (Map.Entry<String, Double> entry : fsi.getCost().entrySet())
                {
                    o.put("BudgetYear", entry.getKey());
                    o.put("Cost", entry.getValue());

                    // insert one row for each BudgetYear
                    Table.insert(_user, ti, o);
                }
            }


            trans.commit();
            return _feeScheduleMap.size();

        }
        catch (Exception e)
        {
            throw new PipelineJobException("Unable to insert into Fee Schedule table. Error: " + e.getMessage());
        }
    }

}
