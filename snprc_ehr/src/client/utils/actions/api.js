export const request = ({ schemaName, queryName, viewName = '',sort = '', columns = [], filterArray = [] }) => {
    return new Promise((resolve, reject) => {
      const success = response => {
        resolve(response)
      }
      const failure = error => {
        reject(error)
      }
      LABKEY.Query.selectRows({
        requiredVersion: 19.2,
        schemaName,
        queryName,
        viewName,
        sort,
        columns,
        success,
        failure,
        filterArray
      })
    })
  }

