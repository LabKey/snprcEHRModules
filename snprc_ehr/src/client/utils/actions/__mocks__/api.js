import { CurrentSpeciesLookup, AccountLookup, validInstitutions, ValidDiet, AcquisitionTypesLookup,
         PotentialDams, PotentialSires, ActiveLocationsAll, colonyGroups, ProtocolLookup, pedigreeGroups} from './apiTestData';

export const request = ({ schemaName, queryName, viewName = '',sort = '', columns = [], filterArray = [] }) => {
    //console.log(`loading list: ${queryName}`);
    return new Promise((resolve) => {
      switch (queryName) {
        case 'CurrentSpeciesLookup':
          resolve(CurrentSpeciesLookup);
          break;
        case 'AccountLookup':
          resolve(AccountLookup)
          break;
        case 'validInstitutions':
          resolve(validInstitutions);
          break;
        case 'ValidDiet':
          resolve(ValidDiet);
          break;
        case 'AcquisitionTypesLookup':
          resolve(AcquisitionTypesLookup);
          break;
        case 'PotentialDams':
          resolve(PotentialDams);
          break;
        case 'PotentialSires':
          resolve(PotentialSires);
          break;
        case 'ActiveLocationsAll':
          resolve(ActiveLocationsAll);
          break;
        case 'colonyGroups':
          resolve(colonyGroups);
          break;
        case 'ProtocolLookup':
          resolve(ProtocolLookup);
          break;
        case 'pedigreeGroups':
          resolve(pedigreeGroups);
          break;
      }
    })
  }

