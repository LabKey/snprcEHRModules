import { Filter, Query } from '@labkey/api';
import { IFilter } from '@labkey/api/dist/labkey/filter/Filter';

export const createTableRow = async (schemaName: string, queryName: string, name: string, parentId?: number) => {
    let rows = [];
    if (parentId) {
        rows.push(
            {
                LookupSetId: parentId,
                Value: name,
                Displayable: true
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