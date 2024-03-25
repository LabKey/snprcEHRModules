import React, { FC, memo, useRef, useState } from 'react';
import { OverlayTrigger, Popover } from 'react-bootstrap';
import { getTableRow } from '../actions';

interface Props {
    admitChargeId: string,
    eventId: string
}

export const AdmissionInfoPopover: FC<Props> = memo((props: Props) => {
    const {admitChargeId, eventId} = props;

    const [admissionInfo, setAdmissionInfo] = useState<JSX.Element[]>([]);

    let ref = useRef(null);

    const handlePopoverEnter = async () => {
        await getAdmitData(eventId, setAdmissionInfo);
    };

    const popover = (
        <Popover className={'charge-id-popover'} id={'charge-id-popover'}>
            <div>
                <h4><strong>Admission Information</strong></h4>
                {admissionInfo.map((d, i) => {
                    return <div key={i}>{d}</div>;
                })}
            </div>
        </Popover>
    );
    return (
        <OverlayTrigger
            ref={r => (ref = r)}
            container={ref.current}
            placement="left"
            overlay={popover}
            onEnter={handlePopoverEnter}
            shouldUpdatePosition={true}>
            <span>{admitChargeId}</span>
        </OverlayTrigger>
    );
});

const getAdmitData = async (admitEventId, handleSetAdmissionInfo) => {

    const info = (await getTableRow('snd', 'AdmitChargeIdProtocolInfo', 'EventId', admitEventId, []))['rows'][0];
    let display: JSX.Element[] = [];
    if (info['AdmitId'] != null) {
        display.push(<span><strong>Admit ID:</strong> <i>{info['AdmitId']}</i></span>,
            <span><strong>Diagnosis:</strong> <i>{info['Diagnosis']}</i></span>,
            <span><strong>Admitting complaint:</strong> <i>{info['AdmittingComplaint']}</i></span>,
            <span><strong>Admission date:</strong> <i>{info['AdmitDate'] === null ? 'Not recorded' : info['AdmitDate'].split(' ')[0]}</i></span>);

        if (info['ReleaseDate'] != null) {
            display.push(<span><strong>Release date:</strong> <i>{info['ReleaseDate'].split(' ')[0]}</i></span>);
        }
        if (info['Resolution'] != null) {
            display.push(<span><strong>Resolution:</strong> <i>{info['Resolution']}</i></span>);
        }
    } else {
        display.push(<span><strong>Charge ID:</strong> <i>{info['ChargeId']}</i></span>);
        if (info['Protocol'] != null) {
            display.push(<span><strong>IACUC #:</strong> <i>{info['Protocol']}</i></span>,
                <span><strong>IACUC Description:</strong> <i>{info['IacucDescription']}</i></span>,
                <span><strong>IACUC Assignment Date:</strong> <i>{(info['AssignmentDate'] === null ? 'Not found' : info['AssignmentDate'].split(' ')[0])}</i></span>,
                <span><strong>Supervising Vet:</strong> <i>{(info['Veterinarian'] === null ? 'Not recorded' : info['Veterinarian'])}</i></span>);
        } else {
            display.push(<span><strong>Description:</strong> <i>{info['Description']}</i></span>);
        }
    }
    handleSetAdmissionInfo(display);
};