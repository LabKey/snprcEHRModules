export default {
    accountList: [{id: 1,value: "0063-010-99", label: "0063-010-99 - TEST Blah, Combination therapy for Blah"},
        {id: 0,value: "0060-014-00",label: "0060-014-99 - TEST PC, Natural resistance of baboon cells to Blah infection"}],
    colonyList: [{ category: 0, id: 0, label: "test Colony 1", species: "PC",  value: 1 },
        { category: 0, id: 1, label: "test Colony 2", species: "PC",  value: 2 }],
    iacucList: [{ id: 0, label: "111PC - Test", maxAnimals: 0, species: "PC", value: "111PC" },
        { id: 1, label: "222PC - Test", maxAnimals: 0, species: "PC", value: "222PC" }],
    pedigreeList: [{ category: 2, id: 0, label: "Baboon 1",  species: "PC", value: 31 },
        { category: 2, id: 1, label: "Baboon 2",  species: "PC", value: 32 }],
    institutionList: [{ id: 0, value: 1, label: "TxBiomed - Texas Biomedical Research Institute" },
        { id: 1, value: 2, label: "Mexico Biomed- Mexico Biomedical Research Institute" }],
    acquisitionTypeList: [{id: 0, value: "1",label: "1 - Colony-born, Vaginal delivery (at TBRI)", Category: "Birth", SortOrder: 1},
        {id: 1, value: "2",label: "2 - Hatched, Colony hatched", Category: "Birth", SortOrder: 2}],
    dietList: [{id: 0, value: "S-00001",label: "Regular chow", species: null},
        {id: 1, value: "S-00002",label: "Corn feed", species: null}],
    locationList: [{id: 0,value: "1.01", label: "1.01", arcSpeciesCode: "PC", maxCages: 42},
        {id: 1,value: "1.02", label: "1.02", arcSpeciesCode: "PC", maxCages: 43}],
    potentialDamList: [{id: 0, value: "12924", label: "12924", ArcSpeciesCode: "PC", Age: 24.7},
        {id: 1, value: "12925", label: "12925", ArcSpeciesCode: "PC", Age: 21.8}],
    potentialSireList: [{id: 0, value: "14022", label: "14022", ArcSpeciesCode: "PC", Age: 22.8},
        {id: 1, value: "14023", label: "14023", ArcSpeciesCode: "PC", Age: 19.8}],
    speciesList: [{id: 10, value: "PCA", label: "PCA (PC) - Papio hamadryas anubis/Baboon", arcSpeciesCode: "PC"},
        {id: 11, value: "MML", label: "MML (MM) - Macaca mulatta/Rhesus", arcSpeciesCode: "MM"}],
    bdStatusList: [{id: 0, value: 0,label: "Day/Month/Year OK" },
        {id: 1, value: 1, label: "Month/Year OK"}]
}
