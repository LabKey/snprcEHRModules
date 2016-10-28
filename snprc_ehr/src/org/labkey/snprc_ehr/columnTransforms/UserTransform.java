package org.labkey.snprc_ehr.columnTransforms;

import org.labkey.api.di.columnTransform.AbstractColumnTransform;
import org.labkey.api.security.SecurityManager;
import org.labkey.api.security.User;
import org.labkey.api.security.UserManager;
import org.labkey.api.security.ValidEmail;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by Marty on 10/26/2016.
 */
public class UserTransform extends AbstractColumnTransform
{
    private final String _emailDomain = "noreply-txbiomed.org";
    private Map<String, Integer> _userMap = new HashMap<>();

    public UserTransform()
    {
        super();
    }

    private ValidEmail createEmail(String user) throws ValidEmail.InvalidEmailException
    {
        return new ValidEmail(user + "@" + _emailDomain);
    }

    private Integer getUserByEmailPrefix(String user)
    {
        int index;
        Map<ValidEmail, User> emails = UserManager.getUserEmailMap();
        for (Map.Entry<ValidEmail, User> email : emails.entrySet())
        {
            index = email.getKey().getEmailAddress().indexOf("@");
            if(email.getKey().getEmailAddress().substring(0,index).equals(user))
            {
                return email.getValue().getUserId();
            }
        }

        return null;
    }

    @Override
    protected Object doTransform(Object inputValue)
    {
        if(null == inputValue)
            return null;

        // comparing with and making this an email name so case insensitive
        String input = inputValue.toString().toLowerCase();

        Integer userId = _userMap.get(input);

        if(null == userId)
        {
            userId = getUserByEmailPrefix(input);
        }

        if (null == userId)
        {
            try
            {
                ValidEmail email = createEmail(input);
                User user = SecurityManager.addUser(email, getContainerUser().getUser(), false).getUser();
                UserManager.setUserActive(getContainerUser().getUser(), user, false);
                userId = user.getUserId();
            }
            catch (ValidEmail.InvalidEmailException e)
            {
                throw new ColumnTransformException("Unable to create email address for user: " + input, e.getCause());
            }
            catch (SecurityManager.UserManagementException e)
            {
                throw new ColumnTransformException("Unable to add user:" + input, e.getCause());
            }
        }

        _userMap.put(input, userId);

        return userId;
    }
}
