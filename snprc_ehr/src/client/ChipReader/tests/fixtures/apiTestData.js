/* eslint-disable camelcase */

export const animalIdData = {
    schemaName: "study",
    queryName: "sql",
    rows: [{
        data: {
            location: {
                value: "2.00-42"
            },
            Id: {
                "value": "12345",
                "url": "/labkey/ehr/SNPRC/participantView.view?participantId=12345"
            }
        }
    }],
    rowCount: 1
}

export const summaryData = 
    [
        {
            chipId: "1C45433F",
            animalId: {
                value: "12345",
                url: "/labkey/ehr/SNPRC/participantView.view?participantId=12345",
                location: "2.00-42",
                time: "2020-08-18T16:47:44.704Z"
            },
            temperature: "<25.0"
        },
        {
            chipId: "2C45433F",
            animalId: {
                value: "11111",
                url: "/labkey/ehr/SNPRC/participantView.view?participantId=11111",
                location: "2.00-42",
                time: "2020-08-18T16:48:53.150Z"
            },
            temperature: "26.2"
        },
        {
            chipId: "3C45433F",
            animalId: {
                value: "22222",
                url: "/labkey/ehr/SNPRC/participantView.view?participantId=22222",
                location: "2.00-42",
                time: "2020-08-18T16:49:56.729Z"
            },
            temperature: "26.3"
        }
    ]
 