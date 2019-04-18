SELECT
    m.Id AS Id,
    'A001: ' + m.A001Status + ' B003: ' + m.B003Status + ' B008: '  +  m.B008Status + ' B017: ' +  m.B017Status as mhcSummary,
    lsid,
    qcstate.publicData as publicData


FROM study.mhcStatus m