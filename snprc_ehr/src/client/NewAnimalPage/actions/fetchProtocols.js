import { request } from '../../utils/actions';

const parse = rows => {
    return rows.map(({ data }, key) => {
        return { id: key, value: data.Iacuc.value, label: data.DisplayValue.value, species: data.Species.value, maxAnimals: data.MaxAnimals.value }
    })
}

const fetchProtocols = (species) => {
    return new Promise((resolve, reject) => {
        request({
            schemaName: 'ehr',
            queryName: 'ProtocolLookup',
            columns: ['Iacuc', 'DisplayValue', 'Species', 'MaxAnimals'],
            filterArray: [
                LABKEY.Filter.create('Species', species, LABKEY.Filter.Types.EQUAL),
                LABKEY.Filter.create('EndDate', null, LABKEY.Filter.Types.MISSING)
            ],
            sort: "Iacuc"
        }).then(({ rows }) => {
                const parsedRows = parse(rows)
                resolve(parsedRows);
        }).catch((error) => {
            console.log('error', error);
            reject(error);
        })
    });
}
export default fetchProtocols;