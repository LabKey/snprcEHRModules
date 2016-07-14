package org.labkey.snprc_ehr.notification;

import org.apache.commons.codec.binary.Base64;
import org.apache.http.HttpEntity;
import org.apache.http.HttpHeaders;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.HttpClientBuilder;
import org.labkey.api.data.Container;
import org.labkey.api.ldk.notification.Notification;
import org.labkey.api.module.ModuleLoader;
import org.labkey.api.security.SecurityManager;
import org.labkey.api.security.User;
import org.labkey.api.util.UnexpectedException;
import org.labkey.snprc_ehr.SNPRC_EHRModule;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.URI;
import java.net.URISyntaxException;
import java.nio.charset.Charset;

/**
 * Created by: jeckels
 * Date: 6/29/16
 */
public abstract class AbstractSSRSNotification implements Notification
{
    @Override
    public String getMessage(Container c, User u)
    {
        String DEFAULT_USER = "txbiomed\\reports_lkbase";
        String DEFAULT_PASS = "**************";

        // Start a session that SSRS can use for its callback
        String sessionId = SecurityManager.beginTransformSession(u);
        String ssrsURL = "https://kittyhawk.txbiomed.local/ReportServer/Pages/ReportViewer.aspx?%2fbeta%2fLabkey_xml%2flabkey_xml&rs:Command=Render&rs:Format=CSV&"
                + SecurityManager.TRANSFORM_SESSION_ID + "=" + sessionId;

        try
        {
            URI uri = new URI(ssrsURL);
            HttpGet request = new HttpGet (uri);

            String auth = DEFAULT_USER + ":" + DEFAULT_PASS;
            byte[] encodedAuth = Base64.encodeBase64(auth.getBytes(Charset.forName("ISO-8859-1")));
            String authHeader = "Basic " + new String(encodedAuth, "ISO-8859-1");
            request.setHeader(HttpHeaders.AUTHORIZATION, authHeader);

            HttpClient client = HttpClientBuilder.create().build();
            HttpResponse resp = client.execute(request);

            int statusCode = resp.getStatusLine().getStatusCode();

            HttpEntity entity = resp.getEntity();
            InputStream is = entity.getContent();
            StringBuilder sb = new StringBuilder();

            BufferedReader reader = new BufferedReader(new InputStreamReader(is, "ISO-8859-1"));
            String line = null;
            while ((line = reader.readLine()) != null)
            {
                sb.append(line);
                sb.append("\n");
            }
            String response = sb.toString();
            String bla = "bla";
        }
        catch (URISyntaxException | IOException e)
        {
            throw new UnexpectedException(e);
        }
        finally
        {
            // Ideally we'd kill the session right here. However, if SSRS is handling the request
            // asynchronously we might need to block, sleep, etc so it's not terminated too early
            SecurityManager.endTransformSession(sessionId);
        }

        // We don't want to send an email ourselves, let SSRS handle that
        return null;
    }

    @Override
    public boolean isAvailable(Container c)
    {
        // Make available is SNPRC_EHR is enabled
        return c.getActiveModules().contains(ModuleLoader.getInstance().getModule(SNPRC_EHRModule.class));
    }

    @Override
    public String getEmailSubject()
    {
        // Shouldn't actually be called
        return null;
    }
}