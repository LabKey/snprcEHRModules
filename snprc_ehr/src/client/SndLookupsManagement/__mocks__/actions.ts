import { createRowApiData, getRowApiData } from '../__tests__/fixtures/testdata';

export const createTableRow = async (schemaName: string, queryName: string, name: string, parentId?: number) => {
    return new Promise(resolve => {
        resolve(createRowApiData);
    })
}

export const updateTableRow = async (schemaName: string, queryName: string, row: any, updatedColumns?: any[]) => {

}

export const deleteTableRow = async (schemaName: string, queryName: string, row: any) => {

}

export const getTableRow = async (schemaName: string, queryName: string, filterColumn: string, filterValue: number, columns: string[]) => {
    return new Promise(resolve => {
        resolve(getRowApiData);
    })
}

