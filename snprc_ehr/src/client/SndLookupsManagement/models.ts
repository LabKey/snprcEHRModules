export interface LookupSet {
    lookupSetId: number,
    setName: string,
    label: string,
    description: string,
    container: string,
    createdBy: number,
    created: Date,
    modifiedBy: number,
    modified: Date,
    lsid: string,
    objectId: string
}

export interface Lookup {
    lookupSetId: number,
    value: string,
    displayable: boolean,
    sortOrder: number,
    container: string,
    createdBy: number,
    created: Date,
    modifiedBy: number,
    modified: Date,
    lsid: string,
    lookupId: number,
    objectId: string
}