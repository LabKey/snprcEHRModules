package org.labkey.snprc_ehr.notification;

import org.apache.commons.lang3.StringUtils;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;
import org.labkey.api.data.Container;
import org.labkey.api.data.PropertyManager;
import org.labkey.api.data.PropertyStore;

import java.net.MalformedURLException;
import java.net.URL;

/**
 * Manages storing and retrieving properties needed to invoke SSRS reports
 * Created by Josh on 8/12/2016.
 */
public class SSRSConfigManager
{
    private static final SSRSConfigManager INSTANCE = new SSRSConfigManager();

    public static final String SSRS_PROPERTY_CATEGORY = SSRSConfigManager.class.getName();

    public static final String SSRS_USER_NAME_PROPERTY = "username";
    public static final String SSRS_PASSWORD_PROPERTY = "password";
    public static final String SSRS_BASE_URL = "baseURL";

    private SSRSConfigManager() {}

    @NotNull
    public static SSRSConfigManager getInstance()
    {
        return INSTANCE;
    }

    @NotNull
    private PropertyManager.PropertyMap getStore(@NotNull Container c)
    {
        PropertyStore store = PropertyManager.getEncryptedStore();
        return store.getProperties(c, SSRS_PROPERTY_CATEGORY);
    }

    @Nullable
    public String getUser(@NotNull Container c)
    {
        return getStore(c).get(SSRS_USER_NAME_PROPERTY);
    }

    @Nullable
    public String getPassword(@NotNull Container c)
    {
        return getStore(c).get(SSRS_PASSWORD_PROPERTY);
    }

    @Nullable
    public String getBaseURL(@NotNull Container c)
    {
        return getStore(c).get(SSRS_BASE_URL);
    }

    public void setProperties(@NotNull Container c, @Nullable String user, @Nullable String password, @Nullable String baseURL) throws MalformedURLException
    {
        user = StringUtils.trimToNull(user);
        password = StringUtils.trimToNull(password);
        baseURL = StringUtils.trimToNull(baseURL);

        new URL(baseURL);

        PropertyStore store = PropertyManager.getEncryptedStore();
        PropertyManager.PropertyMap map = store.getWritableProperties(c, SSRS_PROPERTY_CATEGORY, true);
        map.put(SSRS_USER_NAME_PROPERTY, user);
        map.put(SSRS_PASSWORD_PROPERTY, password);
        map.put(SSRS_BASE_URL, baseURL);
        map.save();
    }
}
