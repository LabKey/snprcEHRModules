import { ActionURL, getServerContext } from '@labkey/api';

export const saveEvent = async (eventToSave: EventToSave): Promise<SaveEventResponse> => {
    const url = ActionURL.buildURL('snd', 'saveEvent.api').replace('.org//', '.org/')

    const response = await fetch(url, {
        method: 'POST',
        body: JSON.stringify(eventToSave),
        credentials: 'include',
        headers: {
            'Content-Type': 'application/json',
            accept: 'application/json',
            'X-LABKEY-CSRF': getServerContext().CSRF,
        },
    })

    const json = await response.json()

    if (response?.status === 500) {
        throw new LabkeyError(json)
    }

    if (response?.status !== 200) {
        // @todo, investigate if this is needed
        throw new LabkeyError(json)
    }

    if (!json.success) {
        throw new LabkeyError(json)
    }

    return json
}

export interface EventToSave {
    eventId?: number,
    date: string, // YYYY-MM-DDTHH:mm:ss
    projectIdRev: string
    subjectId: string,
    qcState: QCState,
    note?: string,
    extraFields?: PropertyDescriptor[],
    eventData: EventData[]
}

export interface SaveEventResponse {
    success: boolean
    event: Event
}

class LabkeyError extends Error {
    constructor({ exception, exceptionClass, stackTrace }) {
        const message = `
    ${exception}

    ${stackTrace.join('\n\t').toString()}
    `.trim()

        super(message)
        this.name = exceptionClass
        this.stack = stackTrace
    }
}

interface EventData {
    eventDataId?: number,
    exception?: Exception
    superPkgId: number,
    narrativeTemplate?: string,
    extraFields?: PropertyDescriptor[],
    attributes: Attribute[]
    subPackages: EventData[]
}

export interface Attribute {
    propertyId: number,
    propertyName?: string,
    value: string | number,
    propertyDescriptor?: PropertyDescriptor
    exception?: Exception
}


interface Exception {
    message: string,
    severity: string
}

type QCState = 'Completed' | 'Rejected' | 'Review Required' | 'In Progress'