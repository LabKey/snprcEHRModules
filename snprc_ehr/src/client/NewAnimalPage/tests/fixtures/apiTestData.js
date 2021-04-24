/* eslint-disable camelcase */

export const CurrentSpeciesLookup = {
    schemaName: ['snprc_ehr'],
    queryName: 'CurrentSpeciesLookup',
    rows: [{
        data: {
            SpeciesCode: {
                value: 'CTJ'
            },
            DisplayColumn: {
                value: 'CTJ (CJ) - Callithrix spp./Marmoset'
            },
            arcSpeciesCode: {
                value: 'CJ',
                url: '/labkey/query/SNPRC/detailsQueryRow.view?schemaName=ehr_lookups&query.queryName=species_codes&code=CJ'
            }
        }
    }, {
        data: {
            SpeciesCode: {
                value: 'MML'
            },
            DisplayColumn: {
                value: 'MML (MM) - Macaca mulatta/Rhesus'
            },
            arcSpeciesCode: {
                value: 'MM',
                url: '/labkey/query/SNPRC/detailsQueryRow.view?schemaName=ehr_lookups&query.queryName=species_codes&code=MM'
            }
        }
    }, {
        data: {
            SpeciesCode: {
                value: 'PCA'
            },
            DisplayColumn: {
                value: 'PCA (PC) - Papio hamadryas anubis/Baboon'
            },
            arcSpeciesCode: {
                value: 'PC',
                url: '/labkey/query/SNPRC/detailsQueryRow.view?schemaName=ehr_lookups&query.queryName=species_codes&code=PC'
            }
        }
    }],
    rowCount: 3
}

export const AccountLookup = {
    schemaName: ['snprc_ehr'],
    queryName: 'AccountLookup',
    rows: [{
        data: {
            Account: {
                value: '0060-014-00'
            },
            DisplayValue: {
                value: '0060-014-00 - Giavedoni 1497PC, Natural resistance of baboon cells to SIV infection'
            }
        }
    }, {
        data: {
            Account: {
                value: '0063-010-50'
            },
            DisplayValue: {
                value: '0063-010-50 - Lanford 1295PT, Combination therapy for HCV'
            }
        }
    }, {
        data: {
            Account: {
                value: '0063-010-51'
            },
            DisplayValue: {
                value: '0063-010-51 - Tardif 1243SM, Tamarin Breeding and Production Colony, Lanford animals'
            }
        }
    }],
    rowCount: 3
}
export const validInstitutions = {
    schemaName: ['snprc_ehr'],
    queryName: 'validInstitutions',
    rows: [{
        data: {
            short_name: {
                value: 'TxBiomed'
            },
            institution_name: {
                value: 'Texas Biomedical Research Institute',
                url: '/labkey/query/SNPRC/detailsQueryRow.view?schemaName=snprc_ehr&query.queryName=validInstitutions&institution_id=1'
            },
            institution_id: {
                value: 1
            }
        }
    }, {
        data: {
            short_name: {
                value: 'NHLBI'
            },
            institution_name: {
                value: 'National Heart, Lung, Blood Institute',
                url: '/labkey/query/SNPRC/detailsQueryRow.view?schemaName=snprc_ehr&query.queryName=validInstitutions&institution_id=2'
            },
            institution_id: {
                value: 2
            }
        }
    }, {
        data: {
            short_name: {
                value: 'ISIS'
            },
            institution_name: {
                value: 'International Species Information System',
                url: '/labkey/query/SNPRC/detailsQueryRow.view?schemaName=snprc_ehr&query.queryName=validInstitutions&institution_id=3'
            },
            institution_id: {
                value: 3
            }
        }
    }],
    rowCount: 3
}
export const ValidDiet = {
    schemaName: ['snprc_ehr'],
    queryName: 'ValidDiet',
    rows: [{
        data: {
            Diet: {
                value: 'AQUA',
                url: '/labkey/query/SNPRC/detailsQueryRow.view?schemaName=snprc_ehr&query.queryName=ValidDiet&Diet=AQUA&StartDate=1991-09-17%2000%3A00%3A00.0'
            },
            ARCSpeciesCode: {
                value: null
            },
            DietCode: {
                value: 3
            }
        }
    }, {
        data: {
            Diet: {
                value: 'AQUA/GREEN',
                url: '/labkey/query/SNPRC/detailsQueryRow.view?schemaName=snprc_ehr&query.queryName=ValidDiet&Diet=AQUA/GREEN&StartDate=2013-05-14%2000%3A00%3A00.0'
            },
            ARCSpeciesCode: {
                value: null
            },
            DietCode: {
                value: 4
            }
        }
    }, {
        data: {
            Diet: {
                value: 'BLACK',
                url: '/labkey/query/SNPRC/detailsQueryRow.view?schemaName=snprc_ehr&query.queryName=ValidDiet&Diet=BLACK&StartDate=1991-11-01%2000%3A00%3A00.0'
            },
            ARCSpeciesCode: {
                value: null
            },
            DietCode: {
                value: 5
            }
        }
    }],
    rowCount: 3
}
export const AcquisitionTypesLookup = {
    schemaName: ['ehr_lookups'],
    queryName: 'AcquisitionTypesLookup',
    rows: [{
        data: {
            AcqCode: {
                value: '1'
            },
            Category: {
                value: 'Birth'
            },
            DisplayValue: {
                value: '1 - Colony-born, Vaginal delivery (at TBRI)'
            },
            SortOrder: {
                value: 1
            }
        }
    }, {
        data: {
            AcqCode: {
                value: '2'
            },
            Category: {
                value: 'Birth'
            },
            DisplayValue: {
                value: '2 - Colony-born, Cesarean delivery (at TBRI)'
            },
            SortOrder: {
                value: 2
            }
        }
    }, {
        data: {
            AcqCode: {
                value: '3'
            },
            Category: {
                value: 'Birth'
            },
            DisplayValue: {
                value: '3 - Stillbirth/Abortion'
            },
            SortOrder: {
                value: 3
            }
        }
    }],
    rowCount: 3
}
export const PotentialDams = {
    schemaName: ['study'],
    queryName: 'PotentialDams',
    rows: [{
        data: {
            Dam: {
                value: '12924',
                url: '/labkey/ehr/SNPRC/participantView.view?participantId=12924'
            },
            ArcSpeciesCode: {
                value: 'PC',
                url: '/labkey/query/SNPRC/detailsQueryRow.view?schemaName=ehr_lookups&query.queryName=species_codes&code=PC'
            },
            Age: {
                value: 24.7
            }
        }
    }, {
        data: {
            Dam: {
                value: '16006',
                url: '/labkey/ehr/SNPRC/participantView.view?participantId=16006'
            },
            ArcSpeciesCode: {
                value: 'PC',
                url: '/labkey/query/SNPRC/detailsQueryRow.view?schemaName=ehr_lookups&query.queryName=species_codes&code=PC'
            },
            Age: {
                value: 20.3
            }
        }
    }, {
        data: {
            Dam: {
                value: '16243',
                url: '/labkey/ehr/SNPRC/participantView.view?participantId=16243'
            },
            ArcSpeciesCode: {
                value: 'PC',
                url: '/labkey/query/SNPRC/detailsQueryRow.view?schemaName=ehr_lookups&query.queryName=species_codes&code=PC'
            },
            Age: {
                value: 19.8
            }
        }
    }],
    rowCount: 3
}
export const PotentialSires = {
    schemaName: ['study'],
    queryName: 'PotentialSires',
    rows: [{
        data: {
            ArcSpeciesCode: {
                value: 'PC',
                url: '/labkey/query/SNPRC/detailsQueryRow.view?schemaName=ehr_lookups&query.queryName=species_codes&code=PC'
            },
            Sire: {
                value: '14022',
                url: '/labkey/ehr/SNPRC/participantView.view?participantId=14022'
            },
            Age: {
                value: 22.8
            }
        }
    }, {
        data: {
            ArcSpeciesCode: {
                value: 'PC',
                url: '/labkey/query/SNPRC/detailsQueryRow.view?schemaName=ehr_lookups&query.queryName=species_codes&code=PC'
            },
            Sire: {
                value: '15009',
                url: '/labkey/ehr/SNPRC/participantView.view?participantId=15009'
            },
            Age: {
                value: 21.5
            }
        }
    }, {
        data: {
            ArcSpeciesCode: {
                value: 'PC',
                url: '/labkey/query/SNPRC/detailsQueryRow.view?schemaName=ehr_lookups&query.queryName=species_codes&code=PC'
            },
            Sire: {
                value: '15945',
                url: '/labkey/ehr/SNPRC/participantView.view?participantId=15945'
            },
            Age: {
                value: 20.4
            }
        }
    }],
    rowCount: 3
}
export const ActiveLocationsAll = {
    schemaName: ['snprc_ehr'],
    queryName: 'ActiveLocationsAll',
    rows: [{
        data: {
            species: {
                value: 'PC',
                url: '/labkey/query/SNPRC/detailsQueryRow.view?schemaName=ehr_lookups&query.queryName=species_codes&code=PC'
            },
            maxCages: {
                value: null
            },
            room: {
                value: '1.01'
            },
            rowId: {
                value: 4201
            },
            description: {
                value: 'Test location 1'
            }
        }
    }, {
        data: {
            species: {
                value: 'PC',
                url: '/labkey/query/SNPRC/detailsQueryRow.view?schemaName=ehr_lookups&query.queryName=species_codes&code=PC'
            },
            maxCages: {
                value: 12
            },
            room: {
                value: '2.00'
            },
            rowId: {
                value: 4202
            },
            description: {
                value: 'Test location 2'
            }
        }
    }, {
        data: {
            species: {
                value: 'PC',
                url: '/labkey/query/SNPRC/detailsQueryRow.view?schemaName=ehr_lookups&query.queryName=species_codes&code=PC'
            },
            maxCages: {
                value: 15
            },
            room: {
                value: '6.06'
            },
            rowId: {
                value: 4203
            },
            description: {
                value: 'Test location 3'
            }
        }
    }],
    rowCount: 3
}
export const colonyGroups = {
    schemaName: ['snprc_ehr'],
    queryName: 'colonyGroups',
    rows: [{
        data: {
            Category: {
                value: 7,
                displayValue: 'Baboon colonies',
                url: '/labkey/query/SNPRC/detailsQueryRow.view?schemaName=snprc_ehr&query.queryName=animal_group_categories&category_code=7'
            },
            Code: {
                value: 214
            },
            Species: {
                value: 'PC',
                url: '/labkey/query/SNPRC/detailsQueryRow.view?schemaName=ehr_lookups&query.queryName=species_codes&code=PC'
            },
            Name: {
                value: 'pc_Conv'
            }
        }
    }, {
        data: {
            Category: {
                value: 7,
                displayValue: 'Baboon colonies',
                url: '/labkey/query/SNPRC/detailsQueryRow.view?schemaName=snprc_ehr&query.queryName=animal_group_categories&category_code=7'
            },
            Code: {
                value: 213
            },
            Species: {
                value: 'PC',
                url: '/labkey/query/SNPRC/detailsQueryRow.view?schemaName=ehr_lookups&query.queryName=species_codes&code=PC'
            },
            Name: {
                value: 'pc_SPF'
            }
        }
    }, {
        data: {
            Category: {
                value: 42,
                displayValue: 'Baboon Colonies',
                url: '/labkey/query/SNPRC/detailsQueryRow.view?schemaName=snprc_ehr&query.queryName=animal_group_categories&category_code=42'
            },
            Code: {
                value: 215
            },
            Species: {
                value: 'PC',
                url: '/labkey/query/SNPRC/detailsQueryRow.view?schemaName=ehr_lookups&query.queryName=species_codes&code=PC'
            },
            Name: {
                value: 'pc_Whatever'
            }
        }
    }],
    rowCount: 3
}
export const ProtocolLookup = {
    schemaName: ['ehr'],
    queryName: 'ProtocolLookup',
    rows: [{
        data: {
            DisplayValue: {
                value: '1134PC - Nathanielsz, P. -Maternal Nutrient Restriction:  Placental and Fetal Brain and Kidney Outcomes'
            },
            MaxAnimals: {
                value: 0
            },
            Iacuc: {
                value: '1134PC'
            },
            Species: {
                value: 'PC'
            }
        }
    }, {
        data: {
            DisplayValue: {
                value: '1272PC - Chen, Christopher -Baboon Model of Liver Cancer'
            },
            MaxAnimals: {
                value: 8
            },
            Iacuc: {
                value: '1272PC'
            },
            Species: {
                value: 'PC'
            }
        }
    }, {
        data: {
            DisplayValue: {
                value: '1497PC - Giavedoni, L. -Natural Resistance of baboon cells to SIV infection'
            },
            MaxAnimals: {
                value: 60
            },
            Iacuc: {
                value: '1497PC'
            },
            Species: {
                value: 'PC'
            }
        }
    }],
    rowCount: 3
}
export const pedigreeGroups = {
    schemaName: ['snprc_ehr'],
    queryName: 'pedigreeGroups',
    rows: [{
        data: {
            Category: {
                value: 2,
                displayValue: 'Baboon pedigrees',
                url: '/labkey/query/SNPRC/detailsQueryRow.view?schemaName=snprc_ehr&query.queryName=animal_group_categories&category_code=2'
            },
            Code: {
                value: 31
            },
            Species: {
                value: 'PC',
                url: '/labkey/query/SNPRC/detailsQueryRow.view?schemaName=ehr_lookups&query.queryName=species_codes&code=PC'
            },
            Name: {
                value: 'baboon1'
            }
        }
    }, {
        data: {
            Category: {
                value: 2,
                displayValue: 'Baboon pedigrees',
                url: '/labkey/query/SNPRC/detailsQueryRow.view?schemaName=snprc_ehr&query.queryName=animal_group_categories&category_code=2'
            },
            Code: {
                value: 32
            },
            Species: {
                value: 'PC',
                url: '/labkey/query/SNPRC/detailsQueryRow.view?schemaName=ehr_lookups&query.queryName=species_codes&code=PC'
            },
            Name: {
                value: 'baboon2'
            }
        }
    }, {
        data: {
            Category: {
                value: 2,
                displayValue: 'Baboon pedigrees',
                url: '/labkey/query/SNPRC/detailsQueryRow.view?schemaName=snprc_ehr&query.queryName=animal_group_categories&category_code=2'
            },
            Code: {
                value: 33
            },
            Species: {
                value: 'PC',
                url: '/labkey/query/SNPRC/detailsQueryRow.view?schemaName=ehr_lookups&query.queryName=species_codes&code=PC'
            },
            Name: {
                value: 'baboon3'
            }
        }
    }],
    rowCount: 3
}

export const valid_bd_status = {
    schemaName: ['snprc_ehr'],
    queryName: 'valid_bd_status',
    rows: [{
        data: {
            description: {
                url: '/labkey/query/SNPRC/detailsQueryRow.view?schemaName=snprc_ehr&query.queryName=valid_bd_status&value=0',
                value: 'Day/Month/Year OK'
            },
            value: {
                value: 0
            }
        }
    }, {
        data: {
            description: {
                url: '/labkey/query/SNPRC/detailsQueryRow.view?schemaName=snprc_ehr&query.queryName=valid_bd_status&value=1',
                value: 'Month/Year OK'
            },
            value: {
                value: 1
            }
        }
    }, {
        data: {
            description: {
                url: '/labkey/query/SNPRC/detailsQueryRow.view?schemaName=snprc_ehr&query.queryName=valid_bd_status&value=2',
                value: 'Year OK'
            },
            value: {
                value: 2
            }
        }
    }],
    rowCount: 3
}

export const sourceLocations = {
        schemaName: ['ehr_lookups'],
        queryName: 'sourceLocations',
            rows: [{
                data: {
                  SourceState: {
                    value: 'LA'
                  },
                  SourceCountry: {
                    value: 'USA'
                  },
                  code: {
                    value: 1001.00
                  },
                  meaning: {
                    value: 'New Iberia Research Center U of LA at Lafayette'
                  },
                  description: {
                    value: null
                  },
                  SourceCity: {
                    value: 'Lafayette'
                  },
                  rowid: {
                    value: 1593
                  }
                }
              }, {
                data: {
                  SourceState: {
                    value: 'LA'
                  },
                  SourceCountry: {
                    value: 'USA'
                  },
                  code: {
                    value: 1009.00
                  },
                  meaning: {
                    value: 'Chimp Haven'
                  },
                  description: {
                    value: null
                  },
                  SourceCity: {
                    value: 'Keithville'
                  },
                  rowid: {
                    value: 1601
                  }
                }
              }, {
                data: {
                  SourceState: {
                    value: 'WA'
                  },
                  SourceCountry: {
                    value: 'USA'
                  },
                  code: {
                    value: 1010.00
                  },
                  meaning: {
                    value: 'SNBL USA Ltd.'
                  },
                  description: {
                    value: '6605 Merrill Creek Pkwy'
                  },
                  SourceCity: {
                    value: 'Everett'
                  },
                  rowid: {
                    value: 1602
                  }
                }
        }],
        rowCount: 3
}
