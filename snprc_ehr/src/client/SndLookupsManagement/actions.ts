import { Filter, Query } from '@labkey/api';
import { IFilter } from '@labkey/api/dist/labkey/filter/Filter';

/**
 * Call the insertRows API on a table, and set the field values for lookupSets or lookups depending on if the parameters contain a parentId
 * @param schemaName
 * @param queryName
 * @param name
 * @param parentId
 */
export const createTableRow = async (schemaName: string, queryName: string, name: string, parentId?: number) => {
    let rows = [];
    if (parentId) {
        rows.push(
            {
                LookupSetId: parentId,
                Value: name,
                Displayable: true,
                SortOrder: 0
            });
    } else {
        rows.push({SetName: name});
    }
    return new Promise((resolve, reject) => {
        Query.insertRows({
            schemaName,
            queryName,
            rows,
            success: (data: any) => {
                resolve(data);
            },
            failure: (data) => {
                reject(data);
            }
        });
    });
};

/**
 * Call the updateRows API for a table with the row to be updated and the newly updated row as arguments
 * @param schemaName
 * @param queryName
 * @param row
 * @param updatedColumns
 */
export const updateTableRow = async (schemaName: string, queryName: string, row: any, updatedColumns?: any[]) => {
    updatedColumns.map(column => {
        row[column[0]] = column[1];
    });
    return new Promise((resolve, reject) => {
        Query.updateRows({
            schemaName,
            queryName,
            rows:[row],
            success: (data: any) => {
                resolve(data);
            },
            failure: (data) => {
                reject(data);
            }
        });
    });
};

/**
 * Call the deleteRows API on a table
 * @param schemaName
 * @param queryName
 * @param row
 */
export const deleteTableRow = async (schemaName: string, queryName: string, row: any) => {
    return new Promise((resolve, reject) => {
        Query.deleteRows({
            schemaName,
            queryName,
            rows:[row],
            success: (data: any) => {
                resolve(data);
            },
            failure: (data) => {
                reject(data);
            }
        });
    });
};

/**
 * Call the selectRows API on a table with the column and value to be filtered on and the columns to be displayed in the returned data
 * @param schemaName
 * @param queryName
 * @param filterColumn
 * @param filterValue
 * @param columns
 */
export const getTableRow = async (schemaName: string, queryName: string, filterColumn: string, filterValue: number, columns: string[]) => {
    const filterArray: IFilter[] = [Filter.create(filterColumn, filterValue, Filter.Types.EQUALS)];
    return new Promise((resolve, reject) => {
        return Query.selectRows({
            columns,
            schemaName,
            queryName,
            filterArray: filterArray,
            success: (data: any) => {
                resolve(data);},
            failure: (data) => {
                reject(data);
            }
        });
    });
}