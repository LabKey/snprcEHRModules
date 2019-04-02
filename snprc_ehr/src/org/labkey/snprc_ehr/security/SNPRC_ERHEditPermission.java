package org.labkey.snprc_ehr.security;

        import org.labkey.api.security.permissions.AbstractPermission;

/**
 * Created on 3/1/2019. tjh
 */
public class SNPRC_ERHEditPermission extends AbstractPermission
{
    public SNPRC_ERHEditPermission()
    {
        super("SNPRC_ERHEditPermission", "This is the base permission required to edit tables");
    }
}
