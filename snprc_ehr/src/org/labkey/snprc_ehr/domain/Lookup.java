package org.labkey.snprc_ehr.domain;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;
import org.json.JSONObject;
import org.labkey.api.data.Container;
import org.labkey.api.security.User;

import java.util.Date;

@Getter
@Setter
@AllArgsConstructor
public class Lookup
{
    private Integer lookupSetId;
    private String value;
    private Boolean displayable;
    private Integer sortOrder;
    private String container;
    private Integer createdBy;
    private Date created;
    private Integer modifiedBy;
    private Date modified;
    private String lsid;
    private Integer lookupId;
    private String objectId;

    public Lookup(Container c, User u, JSONObject json) throws RuntimeException {

    }
}
