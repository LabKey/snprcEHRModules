import { IFilter } from '@labkey/api/dist/labkey/filter/Filter';
import { Filter, Query } from '@labkey/api';

/**
 * Call the selectRows API on a table with the column and value to be filtered on and the columns to be displayed in the returned data
 * @param schemaName
 * @param queryName
 * @param filterColumn
 * @param filterValue
 * @param columns
 */
export const getTableRow = async (schemaName: string, queryName: string, filterColumn: string, filterValue: string, columns: string[]) => {
    const filterArray: IFilter[] = [Filter.create(filterColumn, filterValue, Filter.Types.EQUALS)];
    return new Promise((resolve, reject) => {
        return Query.selectRows({
            //columns,
            schemaName,
            queryName,
            filterArray: filterArray,
            success: (data: any) => {
                resolve(data);
            },
            failure: (data) => {
                reject(data);
            }
        });
    });
};