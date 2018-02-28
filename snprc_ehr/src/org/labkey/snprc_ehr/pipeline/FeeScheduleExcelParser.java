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
    private String _feeScheduleSheetName; // = "Capped Fee Schedule"; //"Actual Cost Fee Schedule";
    private final int _numberOfSkipHeaderRows = 2;
    private Map<Integer, FeeScheduleDataRow> _feeScheduleMap = new LinkedHashMap<>();
    private Map<Integer, String> _columnNameMap = new LinkedHashMap<>();
    private String _yearPublished;
    private Container _container;
    private User _user;
    private FeeScheduleImportForm _form;


    public FeeScheduleExcelParser()
    {
        _parsed = false;
    }

    public FeeScheduleExcelParser(File importFile)
    {
        _importFile = importFile;
        _parsed = false;
    }

    public FeeScheduleExcelParser(Container c, User user, File importFile, FeeScheduleImportForm form)
    {
        _importFile = importFile;
        _parsed = false;
        _container = c;
        _user = user;
        _form = form;
    }

    // returns a list of tabPageNames that **contain** fee schedules
    public List<String> getTabPageNames() throws PipelineJobException
    {

        List<String> tabPageNames = new ArrayList<>();
        Workbook workbook = null;
        Sheet sheet;
        Row r;
        String sheetName, cellValue;

        try
        {
            workbook = ExcelFactory.create(_importFile);
            for (int i = 0; i < workbook.getNumberOfSheets(); i++)
            {
                // identify worksheets (tab pages) with fee schedules
                sheetName = workbook.getSheetName(i);
                sheet = workbook.getSheet(sheetName);

                if (sheet == null || sheetName.equalsIgnoreCase("Fee Calculations"))
                {
                    // skip
                }
                else
                {
                    // get fee schedule header
                    r = sheet.getRow(0);
                    if (r != null)
                    {
                        cellValue = ExcelFactory.getCellStringValue(r.getCell(1)).trim(); // row 1, col b
                        if (cellValue.contains("Fee Schedule"))
                        {
                            // add sheet to list
                            tabPageNames.add(workbook.getSheetName(i));
                        }
                    }
                    else
                    {
                        //throw new PipelineJobException("Couldn't read sheet header.");
                    }
                }
            }
            if (tabPageNames.size() == 0)
            {
                throw new PipelineJobException("No Fee Schedule found in workbook.");
            }
            return tabPageNames;

        }
        catch (IOException | InvalidFormatException e)
        {
            throw new PipelineJobException("Failed to read from data file " + _importFile.getName(), e);
        }
        finally
        {
            try
            {
                if (workbook != null) workbook.close();
            }
            catch (IOException e)
            {
                throw new PipelineJobException("File IO error when closing: " + _importFile.getName(), e);
            }

        }
    }

    // Parses the Fee Schedule into
    public void parseFile() throws PipelineJobException
    {
        // tab page selected in jsp
        int rowIdx;
        String value;
        Double doubleValue;
        boolean hasData = false;
        Workbook workbook = null;
        Sheet sheet;

        // only parse the file once
        if (_parsed) return;

        try
        {
            _feeScheduleSheetName = _form.getTabPage();

            workbook = ExcelFactory.create(_importFile);
//            FileInputStream stream = new FileInputStream(_importFile);
//            workbook = new XSSFWorkbook(stream);
            sheet = workbook.getSheet(_feeScheduleSheetName);
            if (sheet == null)
            {
                throw new PipelineJobException("Fee Schedule tab sheet (" + _feeScheduleSheetName + ") not found in workbook.");
            }

            rowIdx = _numberOfSkipHeaderRows;

            if (rowIdx <= sheet.getLastRowNum())
            {
                Row r;
                String cellValue;

                // get year that the fee schedule was published
                r = sheet.getRow(rowIdx);
                if (r != null)
                {
                    String s = ExcelFactory.getCellStringValue(r.getCell(0)).trim();
                    String t[] = s.split(" ");
                    _yearPublished = t[1];
                }
                else
                {
                    throw new PipelineJobException("Couldn't read importFile year published.");
                }

                // read second header row - these are the column
                r = sheet.getRow(++rowIdx);
                if (r != null)
                {
                    for (Cell cell : r) {
                        // ignore the columns that contain the variance data (currently starting at column "N")
                        // They have duplicate column names so we can just ignore dups
                        cellValue = ExcelFactory.getCellStringValue(cell).trim();
                        if (!_columnNameMap.containsValue(cellValue)) {
                            _columnNameMap.put(cell.getColumnIndex(), cellValue);
                        }
                    }
                }

            }
            else
            {
                throw new PipelineJobException("Couldn't read importFile column headers");
            }

            // parse data

            int j = sheet.getLastRowNum();
            for (int i = rowIdx; i < j; i++)
            {
                Row row;
                hasData = true;
                row = sheet.getRow(i);

                if (row != null)
                {
                    FeeScheduleDataRow dataRow = new FeeScheduleDataRow();
                    Map<String, Double> costValueMap = new LinkedHashMap<String, Double>();

                    for (int col = 0; col < _columnNameMap.size(); col++) //row.getLastCellNum(); col++)
                    {
                        Cell cell = row.getCell(col);
                        if (cell == null)
                        {
                            continue;
                        }

                        String columnName = _columnNameMap.get(col);

                        // get data values

                        if ("Species".equalsIgnoreCase(columnName))
                        {
                            value = ExcelFactory.getCellStringValue(cell).trim();
                            dataRow.setSpecies(StringUtils.trimToNull(value));
                        }
                        else if ("Activity".equalsIgnoreCase(columnName))
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
                        dataRow.setStartingYear(Integer.parseInt(_yearPublished));
                        dataRow.setVersionLabel(_feeScheduleSheetName);
                        _feeScheduleMap.put(i, dataRow);
                    }
                }

            }   // end row loop

            _parsed = true;


        }   // end try

        catch (IOException e)
        {
            throw new PipelineJobException("Failed to read from data file " + _importFile.getName(), e);
        }
        catch (InvalidFormatException e)
        {
            throw new PipelineJobException("Failed to parse file as Excel: " + _importFile.getName(), e);
        }
        finally
        {
            try
            {
                if (workbook != null) workbook.close();
            }
            catch (IOException e)
            {
                throw new PipelineJobException("File IO error when closing: " + _importFile.getName(), e);
            }

        }
    }


    public int loadTable() throws PipelineJobException
    {
        if (!_parsed)
        {
            throw new PipelineJobException("File not parsed prior to calling loadTable().");
        }

        //TODO: need to handle existing data - add archive date?
        // delete existing rows, and add new entries?
        // update existing rows

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
                o.put("StartingYear", fsi.getStartingYear());
                o.put("VersionLabel", fsi.getVersionLabel());
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
