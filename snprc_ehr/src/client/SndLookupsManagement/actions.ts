import { Query } from '@labkey/api';

export const createTableRow = (schemaName: string, queryName: string, name: string, parentId?: number) => {
    let rows = [];

    if (parentId) {
        rows.push(
            {LookupSetId: parentId},
            {Value: name},
            {Displayable: true});
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

export const updateTableRow = (schemaName: string, queryName: string, id: number, name: string, parentId?: number) => {
    let rows = [];

    if (parentId) {
        rows.push(
            {LookupSetId: parentId},
            {LookupId: id},
            {Value: name},
            {Displayable: true});
    } else {
        rows.push(
            {LookupSetId: id},
            {SetName: name});
    }

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

export const deleteTableRow = (schemaName: string, queryName: string, id: number, parentId?: number) => {
    let rows = [];
    if (parentId) {
        rows.push({LookupId: id});
        id = parentId;
    }
    rows.push({LookupSetId: id});
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

export const getTableRow = (schemaName: string, queryName: string, id: number, parentId?: number) => {
    let parameters: Array<{ [key: string]: any }> = [];
    let columns = [];
    if (parentId) {
        parameters.push({LookupId: id},
            {LookupSetId: parentId});
        columns.push('lookupSetId', 'lookupId', 'value', 'displayable', 'sortOrder');
    } else {
        parameters.push({LookupSetId: id});
        columns.push('lookupSetId', 'description', 'label', 'setName');
    }
    console.log(parameters);
    return new Promise((resolve, reject) => {
        return Query.selectRows({
            columns,
            schemaName,
            queryName,
            parameters,
            success: (data: any) => {
                resolve(data);
            },
            failure: (data) => {
                reject(data);
            }
        });
    });
};