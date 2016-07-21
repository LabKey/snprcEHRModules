package org.labkey.snprc_ehr.notification;

import org.apache.commons.codec.binary.Base64;
import org.apache.http.HttpEntity;
import org.apache.http.HttpHeaders;
import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.HttpClientBuilder;
import org.apache.poi.util.IOUtils;
import org.labkey.api.data.Container;
import org.labkey.api.ldk.notification.Notification;
import org.labkey.api.ldk.notification.NotificationService;
import org.labkey.api.module.ModuleLoader;
import org.labkey.api.security.SecurityManager;
import org.labkey.api.security.User;
import org.labkey.api.security.UserPrincipal;
import org.labkey.api.util.FileUtil;
import org.labkey.api.util.MailHelper;
import org.labkey.api.util.UnexpectedException;
import org.labkey.snprc_ehr.SNPRC_EHRModule;

import javax.activation.DataHandler;
import javax.activation.DataSource;
import javax.mail.Address;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeBodyPart;
import javax.mail.internet.MimeMultipart;
import javax.mail.util.ByteArrayDataSource;
import java.io.IOException;
import java.io.InputStream;
import java.net.URI;
import java.net.URISyntaxException;
import java.nio.charset.Charset;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Set;

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
        String TEXT_CONTENT = "Please see attached report.";
        String SUBJECT = "Daily Report";

        // Start a session that SSRS can use for its callback
        String sessionId = SecurityManager.beginTransformSession(u);
        String ssrsURL = "https://kittyhawk.txbiomed.local/ReportServer/Pages/ReportViewer.aspx?%2fbeta%2fLabkey_xml%2flabkey_xml&rs:Command=Render&rs:Format=CSV&"
                + SecurityManager.TRANSFORM_SESSION_ID + "=" + sessionId;
//        String ssrsURL = "http://www.labkey.com/wp-content/uploads/2016/06/2016-ASMS-Panorama-small-molecule-poster-v5.pdf";

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

            if( null == resp )
                throw new IOException("No response from SSRS server.");

            if( resp.getStatusLine().getStatusCode() != HttpStatus.SC_OK )
                throw new IOException("Server response: " + resp.getStatusLine().getStatusCode());

            if( null == resp.getFirstHeader("Content-Type") || !resp.getFirstHeader("Content-Type").getValue().equals("application/pdf"))
                throw new IOException("Content-Type not found or incorrect. Expecting application/pdf.");

            HttpEntity entity = resp.getEntity();

            try(InputStream is = entity.getContent())
            {
                byte[] data = IOUtils.toByteArray(is);

                if(data.length == 0)
                    throw new IOException("Empty report received.");

                // Text body part
                MimeBodyPart textBodyPart = new MimeBodyPart();
                textBodyPart.setText(TEXT_CONTENT);

                // PDF body part
                DataSource dataSource = new ByteArrayDataSource(data, "application/pdf");
                MimeBodyPart pdfBodyPart = new MimeBodyPart();
                pdfBodyPart.setDataHandler(new DataHandler(dataSource));
                pdfBodyPart.setFileName(FileUtil.makeFileNameWithTimestamp("DailyReport", "pdf"));

                // Mime multi part
                MimeMultipart mimeMultipart = new MimeMultipart();
                mimeMultipart.addBodyPart(textBodyPart);
                mimeMultipart.addBodyPart(pdfBodyPart);

                // Get recipients
                Set<UserPrincipal> recipients = NotificationService.get().getRecipients(this, c);
                Address[] addresses = new InternetAddress[recipients.size()];
                int iAdd = 0;
                for (UserPrincipal recipient : recipients)
                {
                    addresses[iAdd++] = new InternetAddress(recipient.getName());
                }

                // Email subject
                DateFormat format = new SimpleDateFormat("MM/dd/yyyy");
                String emailSubject = SUBJECT + " " + format.format(new Date());

                // Construct message
                MailHelper.ViewMessage message = MailHelper.createMessage();
                message.setFrom(NotificationService.get().getReturnEmail(c));
                message.setRecipients(Message.RecipientType.TO, addresses);
                message.setSubject(emailSubject);
                message.setContent(mimeMultipart);

                MailHelper.send(message, u, c);
            }
            catch (MessagingException e)
            {
                throw new UnexpectedException(e);
            }
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