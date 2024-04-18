import {ActionURL, getServerContext } from "@labkey/api";

export const fetchEvent = async (eventID: string | undefined): Promise<FetchAnimalEventResponse> => {
    const url = ActionURL.buildURL('snd', 'getEvent.api')
    const headers = {
        'Content-Type': 'application/json',
        accept: 'application/json',
        'X-LABKEY-CSRF': getServerContext().CSRF
    }

    const body = JSON.stringify({
        eventId: eventID,
        getTextNarrative: false,
        getRedactedNarrative: false,
        getHtmlNarrative: true,
        getRedactedHtmlNarrative: false,
    })

    return fetch(url, {
        headers,
        body,
        method: 'post',
        credentials: 'include',
    }).then(async response => {
        const data = await response.json()
        if (!data.success) {
            throw new Error(data.event.exception.message)
        }
        if(response.status === 200)
            return data.event
    })
}

export type FetchAnimalEventResponse = {
    date: string
    eventData: SuperPackageEventData[]
    eventId: number
    extraFields: Field[]
    htmlNarrative: string
    note: string
    projectIdRev: string
    qcState: QCState
    redactedHtmlNarrative: string
    subjectId: string
    textNarrative: string
}

type SuperPackageEventData = {
    attributes: []
    eventDataId: number
    extraFields: Field[]
    narrativeTemplate: string
    subPackages: SuperPackageEventData[]
    superPkgId: number
}

type Field = {
}

type QCState = 'Completed' | 'In Progress' | 'Review Required' | 'Rejected'

type ResponseError = {
    exception: string
}

export class ResponseHadErrorException extends Error {
    stackTrace: string[]

    constructor({ exception, exceptionClass, stackTrace }: ResponseWithError) {
        super(exception)
        this.name = exceptionClass
        this.stackTrace = stackTrace
    }
}

interface ResponseWithError {
    exception: string
    exceptionClass: string
    stackTrace: string[]
}