/*
 * Copyright (c) 2016-2018 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.labkey.snprc_ehr.notification;

import jakarta.activation.DataHandler;
import jakarta.activation.DataSource;
import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeBodyPart;
import jakarta.mail.internet.MimeMessage;
import jakarta.mail.internet.MimeMultipart;
import jakarta.mail.util.ByteArrayDataSource;
import org.apache.commons.codec.binary.Base64;
import org.apache.hc.client5.http.classic.methods.HttpGet;
import org.apache.hc.client5.http.impl.classic.CloseableHttpClient;
import org.apache.hc.client5.http.impl.classic.CloseableHttpResponse;
import org.apache.hc.client5.http.impl.classic.HttpClientBuilder;
import org.apache.hc.core5.http.Header;
import org.apache.hc.core5.http.HttpEntity;
import org.apache.hc.core5.http.HttpHeaders;
import org.apache.hc.core5.http.HttpStatus;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.poi.util.IOUtils;
import org.jetbrains.annotations.Nullable;
import org.labkey.api.data.Container;
import org.labkey.api.ldk.notification.Notification;
import org.labkey.api.module.ModuleLoader;
import org.labkey.api.security.SecurityManager;
import org.labkey.api.security.SecurityManager.TransformSession;
import org.labkey.api.security.User;
import org.labkey.api.util.DateUtil;
import org.labkey.api.util.FileUtil;
import org.labkey.api.util.MailHelper;
import org.labkey.api.util.UnexpectedException;
import org.labkey.snprc_ehr.SNPRC_EHRModule;

import java.io.IOException;
import java.io.InputStream;
import java.net.URI;
import java.net.URISyntaxException;
import java.nio.charset.Charset;

/**
 * Created by: jeckels
 * Date: 6/29/16
 */
public abstract class AbstractSSRSNotification implements Notification
{
    private final String _subject;
    private final String _textContent;
    private final Format _format;

    private static final Logger LOG = LogManager.getLogger(AbstractSSRSNotification.class);
    private final String _reportId;

    public enum Format
    {
        HTML5("html", "text/html"),
        PDF("pdf", "application/pdf"),
        XML("xml", "text/xml"),
        CSV("csv", "text/csv"),
        Excel("xlsx", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");

        private final String _extension;
        private final String _mimeType;

        Format(String extension, String mimeType)
        {
            _extension = extension;
            _mimeType = mimeType;
        }

        public String getExtension()
        {
            return _extension;
        }

        public String getMimeType()
        {
            return _mimeType;
        }
    }

    public AbstractSSRSNotification(String reportId, String subject, String textContent, Format format)
    {
        _reportId = reportId;
        _subject = subject;
        _textContent = textContent;
        _format = format;
    }

    @Override
    @Nullable
    public String getMessageBodyHTML(Container c, User u)
    {
        return _textContent;
    }

    @Nullable
    @Override
    public MimeMessage createMessage(Container c, User u)
    {
        String user = SSRSConfigManager.getInstance().getUser(c);
        String password = SSRSConfigManager.getInstance().getPassword(c);
        String baseURL = SSRSConfigManager.getInstance().getBaseURL(c);

        if (user == null || password == null || baseURL == null)
        {
            StringBuilder sb = new StringBuilder();
            if (user == null)
            {
                sb.append("No SSRS user configured, cannot request report\n");
            }
            if (password == null)
            {
                sb.append("No SSRS password configured, cannot request report\n");
            }
            if (baseURL == null)
            {
                sb.append("No SSRS URL configured, cannot request report\n");
            }
            LOG.error(sb.toString());
            return null;
        }

        if (!baseURL.endsWith("?"))
        {
            baseURL += "?";
        }

        String ssrsReportURL = baseURL + _reportId + "&rs:Command=Render&rs:Format=" + _format.toString();

        // Start a session that SSRS can use for its callback
        // We *should* create the transform session in a try-with-resources to ensure the API key gets invalidated.
        // However, if SSRS is handling the request asynchronously we might need to block, sleep, etc. so it's not
        // terminated too early
        TransformSession session = SecurityManager.createTransformSession(u);
        String ssrsSessionURL = ssrsReportURL + "&" + SecurityManager.TRANSFORM_SESSION_ID + "=" + session.getApiKey();

        try
        {
            URI uri = new URI(ssrsSessionURL);
            HttpGet request = new HttpGet (uri);

            String auth = user + ":" + password;
            byte[] encodedAuth = Base64.encodeBase64(auth.getBytes(Charset.forName("ISO-8859-1")));
            String authHeader = "Basic " + new String(encodedAuth, "ISO-8859-1");
            request.setHeader(HttpHeaders.AUTHORIZATION, authHeader);

            try (CloseableHttpClient client = HttpClientBuilder.create().build(); CloseableHttpResponse resp = client.execute(request))
            {
                if (null == resp)
                    throw new IOException("No response from SSRS server.");

                if (resp.getCode() != HttpStatus.SC_OK)
                    throw new IOException("Server response: " + resp.getCode());

                Header contentTypeHeader = resp.getFirstHeader("Content-Type");
                if (null == contentTypeHeader || !contentTypeHeader.getValue().equals(_format.getMimeType()))
                    throw new IOException("Content-Type not found or incorrect. Expecting '" + _format.getMimeType() + "' but was '" + (contentTypeHeader == null ? "null" : contentTypeHeader.getValue()) + "'.");

                HttpEntity entity = resp.getEntity();

                try (InputStream is = entity.getContent())
                {
                    byte[] data = IOUtils.toByteArray(is);

                    if (data.length == 0)
                        throw new IOException("Empty report received from SSRS, URL was " + ssrsReportURL);

                    // Text body part
                    MimeBodyPart textBodyPart = new MimeBodyPart();
                    textBodyPart.setText(getMessageBodyHTML(c, u), null, "html");

                    // PDF body part
                    DataSource dataSource = new ByteArrayDataSource(data, _format.getMimeType());
                    MimeBodyPart pdfBodyPart = new MimeBodyPart();
                    pdfBodyPart.setDataHandler(new DataHandler(dataSource));
                    pdfBodyPart.setFileName(FileUtil.makeFileNameWithTimestamp(_subject, _format.getExtension()));

                    // Mime multi part
                    MimeMultipart mimeMultipart = new MimeMultipart();
                    mimeMultipart.addBodyPart(textBodyPart);
                    mimeMultipart.addBodyPart(pdfBodyPart);

                    // Construct message
                    MailHelper.MultipartMessage message = MailHelper.createMultipartMessage();
                    message.setContent(mimeMultipart);
                    return message;
                }
                catch (MessagingException e)
                {
                    throw new UnexpectedException(e);
                }
            }
        }
        catch (URISyntaxException | IOException e)
        {
            throw new UnexpectedException(e);
        }
    }

    @Override
    public boolean isAvailable(Container c)
    {
        // Make available is SNPRC_EHR is enabled
        return c.getActiveModules().contains(ModuleLoader.getInstance().getModule(SNPRC_EHRModule.class));
    }

    @Override
    public String getEmailSubject(Container c)
    {
        return _subject + " " + DateUtil.formatDate(c);
    }
}
