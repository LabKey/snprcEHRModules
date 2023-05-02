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

export const updateTableRow = async (schemaName: string, queryName: string, row: any, updatedRow?: any[]) => {
    let rows = [];
    updatedRow.map(column => {
        row[column[0]] = column[1];
    });
    rows.push(row);
    return new Promise((resolve, reject) => {
        Query.updateRows({
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

export const deleteTableRow = async (schemaName: string, queryName: string, row: any) => {
    let rows = [];
    rows.push(row);
    return new Promise((resolve, reject) => {
        Query.deleteRows({
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

export const getTableRow = async (schemaName: string, queryName: string, rowIdName: string, id: number, parentId?: number) => {
    let columns = [];
    if (parentId) {
        columns.push('lookupId', 'LookupSetId', 'value', 'displayable', 'sortOrder');
    } else {
        columns.push('lookupSetId', 'description', 'label', 'setName');
    }
    const filterArray: IFilter[] = [Filter.create(rowIdName, id, Filter.Types.EQUALS)];

    return new Promise((resolve, reject) => {
        return Query.selectRows({
            columns,
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