package org.labkey.snprc_ehr.domain;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

import java.util.Date;

@Getter
@Setter
@AllArgsConstructor
public class LookupSet
{
    private Integer _lookupSetId;
    private String _setName;
    private String _label;
    private String _description;
    private String _container;
    private Integer _createdBy;
    private Date _created;
    private Integer _modifiedBy;
    private Date _modified;
    private String _lsid;
    private String _objectId;
}
