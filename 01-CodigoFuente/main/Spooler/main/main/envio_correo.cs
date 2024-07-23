using Microsoft.Extensions.Configuration;
using System.Net;
using System.Net.Mail;
using System.Reflection;

namespace serverreports
{
    internal class envio_correo
    {
        //string [] mail_grupo_error = ["desarrollo_web@logis.com.mx"];
        string[] mail_grupo_error = ["raulrgg@logis.com.mx"];
        Utilerias util = new Utilerias();

        private string email_usuario()
        {
            string correo_p;
            var configuration = new ConfigurationBuilder()
                                              .AddUserSecrets(Assembly.GetExecutingAssembly())
                                              .Build();
            correo_p = configuration["us_mail"] + "|" + configuration["pwd_mail"];
            // toma el valor de app.config
            //correo_p = ConfigurationManager.AppSettings["us_mail"]+ "|"+ ConfigurationManager.AppSettings["pwd_mail"];
            return correo_p;
        }

        public void msg_error(string rep, string? codigo = "NA", string? msg = "NA")
        {
            string mensaje = "Hola,  \n"
            + "Ocurrió un error al intentar generar este reporte.\n"
            + "Consulta ejecutada:  \n"
            + codigo + " \n"
            + msg + " \n"
            + " \n"
            + " \n\n" + " Saludos."
            + " \n\n" + "Logis Reports Server.";
            send_mail("Report: < Logis " + rep + " > Error", [], mensaje);
        }

        public string send_mail(string asunto, string[] contact, string mensaje, string[]? arh = null, string?[] cc = null)
        {
            string[] dat_mail = new string[1];
            dat_mail = email_usuario().Split("|");
            //Console.WriteLine(dat_mail[0]);
            //Console.WriteLine(dat_mail[1]);
            Console.WriteLine("\t\t\tEnviar Correo Electronico");
            using (MailMessage correo = new MailMessage())
            {
                correo.From = new MailAddress(dat_mail[0]);
                correo.Subject = asunto;
                correo.IsBodyHtml = true;
                correo.Body = mensaje;
                
                if (contact.Length > 0)
                    for (int i = 0; i < contact.Length; i++)
                        correo.To.Add(contact[i]);
                else
                    for (int i = 0; i < mail_grupo_error.Length; i++)
                        correo.To.Add(mail_grupo_error[i]);               
                if (cc != null)
                {
                    for (int i = 0; i < cc.Length; i++) 
                    {
                        correo.CC.Add(cc[i]);
                    }
                        //MailAddress ccm = new MailAddress(cc);
                    //correo.To.Add(contact[i]);

                    //MailAddress ccm = new MailAddress(cc[i]);
                    //correo.CC.Add(cc[i]);
                }
                
                //using (SmtpClient servidor = new SmtpClient("smtp.gmail.com", 587)) 
                using (SmtpClient servidor = new SmtpClient("smtp.office365.com", 587))
                {
                    servidor.EnableSsl = true;
                    servidor.Credentials = new System.Net.NetworkCredential(dat_mail[0], dat_mail[1]);
                    if (arh != null)
                    {
                        System.Net.Mail.Attachment attachment;
                        for (int i = 0; i < arh.Length; i++)
                        {
                            attachment = new System.Net.Mail.Attachment(arh[i]);
                            correo.Attachments.Add(attachment);
                        }
                    }
                    try
                    {
                        servidor.Send(correo);
                        correo.Attachments.Dispose();
                        Console.WriteLine("\t\tCorreo enviado de manera exitosa");
                        correo.Dispose();
                        return "OK";
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine(ex.Message);
                        return (ex.Message);
                    }
                }
            }
        }

        public string send_error_mail1(string asunto, string[] contact, string mensaje)
        {
            string[] dat_mail = new string[1];
            dat_mail = email_usuario().Split("|");
            //Console.WriteLine(dat_mail[0]);
            //Console.WriteLine(dat_mail[1]);
            Console.WriteLine("\t\t\tEnviar Correo Electronico");
            MailMessage correo = new MailMessage("prueba@gmail.com", "raulrgg@logis.com.mx", asunto, mensaje);
            if (contact.Length > 0)
                for (int i = 0; i < contact.Length; i++)
                    correo.To.Add(contact[i]);
            else
                for (int i = 0; i < mail_grupo_error.Length; i++)
                    correo.To.Add(mail_grupo_error[i]);
            SmtpClient servidor = new SmtpClient("smtp.gmail.com", 587);
            NetworkCredential credenciales = new NetworkCredential(dat_mail[0], dat_mail[1]);
            servidor.Credentials = credenciales;
            servidor.EnableSsl = true;
            //– 465 y 578
            try
            {
                //  servidor.Send(correo);
                correo.Attachments.Dispose();
                correo.Dispose();
                return "OK";
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                return (ex.Message);
            }

        }


        public string display_mail(string servidor, string warning_message, string nombre_reporte, string[,] tab_archivos, int days_deleted, string? adittional_info = "")
        {
            int Zip = 0;
            int Pdf = 0;
            int Excel = 0;
            string display_mail = "<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n"
            + "<html>\n"
            + "<head>\n"
            + "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=ISO-8859-1\">\n"
            + "<title>Logis Report Server</title>\n"
            + "<STYLE TYPE=\"text/css\">\n"
            + ".link:active {color:\"#0000FF\"}\n"
            + ".link:link {color:\"#0000FF\"}\n"
            + ".link:hover {color:\"#0000FF\"}\n"
            + ".link:visited {color:\"#0000FF\"}\n"

            + "</STYLE>\n"
            + "</head>\n"
            + "<body>\n"
            + "\n"
            + "<center>\n"
            + "<TABLE WIDTH=\"500\" CELLSPACING=\"0\" CELLPADDING=\"0\" BORDER=\"1\" bgcolor=\"#ffffff\">\n"
                + "<tr><td>\n"
            + "<TABLE WIDTH=\"500\" CELLSPACING=\"0\" CELLPADDING=\"0\" BORDER=\"0\" bgcolor=\"#336699\">\n"
                  + "<tr>\n"
            + "<td align=\"left\"><a href=\"" + servidor + "/\"><img src=\"" + servidor + "/images/pixel.gif\" width=\"1\" height=\"45\" border=\"0\" alt=\"\"><img src=\"LetrasLogis.gif\" border=\"0\" alt=\"logo logis\"></a></td>\n"
            + "<td align=\"left\"><a href=\"" + servidor + "/\"><IMG SRC=\"" + servidor + "/images/pixel.gif\" WIDTH=\"1\" HEIGHT=\"45\" border=\"0\" alt=\"\"><img src=\"" + servidor + "/images/LetrasLogis.gif\" border=\"0\" alt=\"logo logis\"></a></td>\n"
            + "</tr>\n"
            + "</table>\n"
            + "<TABLE WIDTH=\"500\" CELLSPACING=\"0\" CELLPADDING=\"0\" BORDER=\"0\" bgcolor=\"#ffffff\">\n"
            + "<tr>\n"
            + "    <td align=\"left\"><IMG SRC=\"" + servidor + "/images/pixel.gif\" WIDTH=\"1\" HEIGHT=\"5\" alt=\"\"></td>\n"
            + "</tr>\n"
            + "</table>\n"
            + "<TABLE WIDTH=\"500\" CELLSPACING=\"0\" CELLPADDING=\"3\" BORDER=\"0\" bgcolor=\"#ffffff\">\n";
            if (warning_message != "")
            {
                display_mail = display_mail + "<tr bgcolor=\"#C69633\">\n"
                + "    <td height=\"25\"  align=\"left\" valign=bottom><IMG SRC=\"" + servidor + "/images/pixel.gif\" WIDTH=\"20\" HEIGHT=\"1\" alt=\"\"><FONT FACE=\"Arial,Helvetica\" SIZE=\"3\" COLOR=\"red\"><B>Comment :</B></FONT></td>\n"
                + "</tr>\n"
                + "<tr>\n"
                + "    <td><IMG SRC=\"" + servidor + "/images/pixel.gif\" WIDTH=\"1\" HEIGHT=\"5\" alt=\"\"></td>\n"
                + "</tr>\n"
                + "<tr>\n"
                + "    <td align=\"left\">\n"
                + "    <FONT SIZE=\"2\" FACE=\"Arial,Helvetica\" COLOR=\"#000000\">\n"
                + warning_message + "\n"
                + "    </FONT>\n"
                + "    </td>\n"
                + "</tr>\n"
                + "<tr>\n"
                + "    <td><IMG SRC=\"" + servidor + "/images/pixel.gif\" WIDTH=\"1\" HEIGHT=\"30\" alt=\"\"></td>\n"
                + "</tr>\n";
            }
            display_mail = display_mail + "<tr bgcolor=\"#C69633\">\n"
            + "    <td height=\"25\"  align=\"left\" valign=bottom><IMG SRC=\"" + servidor + "/images/pixel.gif\" WIDTH=\"20\" HEIGHT=\"1\" alt=\"\"><FONT FACE=\"Arial,Helvetica\" SIZE=\"3\" COLOR=\"#FFFFFF\"><B>Logis Report Server :</B></FONT></td>\n"
            + "</tr>\n"
            + "<tr>\n"
            + "    <td>\n"
            + "    <FONT SIZE=\"2\" FACE=\"Arial,Helvetica\" COLOR=\"#000000\">\n"
            + "    <IMG SRC=\"" + servidor + "/images/pixel.gif\" WIDTH=\"1\" HEIGHT=\"5\" alt=\"\">\n"
            + "    <br>\n"
            + "    <IMG SRC=\"" + servidor + "/images/pixel.gif\" WIDTH=\"20\" HEIGHT=\"20\" alt=\"\"><IMG SRC=\"" + servidor + "/images/pointeurgris.gif\" alt=\"\">&nbsp;<B>Report Name :</B> " + tab_archivos[1, 0] + "\n"
            + "    <br>\n"
            + "    <IMG SRC=\"" + servidor + "/images/pixel.gif\" WIDTH=\"20\" HEIGHT=\"20\" alt=\"\"><IMG SRC=\"" + servidor + "/images/pointeurgris.gif\" alt=\"\">&nbsp;<B>Date :</B> " + DateTime.Now.ToString("dd/MM/yyyy H: mm") + "\n"
            + "    <br>\n";
            // for (int i = 0; i < tab_archivos.Length - 5; i++)
            for (int i = 0; i < tab_archivos.Rank-1; i++)

            {
                display_mail = display_mail + "    <IMG SRC=\"" + servidor + " /images/pixel.gif\" WIDTH =\"20\" HEIGHT =\"20\" alt =\"\" ><IMG SRC=\"" + servidor + " /images/pointeurgris.gif\" alt =\"\" > &nbsp;<B>Reporte :</B> " + tab_archivos[1, 0] + "\n"
                                               + " <br>\n";
                string arch23 = tab_archivos[0, i];
                if (arch23 != "" && arch23 != null)
                {
                    string img = "";
                    string cve = tab_archivos[3, i].Substring(tab_archivos[3, i].Length - 8, 8);
                    string ext = tab_archivos[0, i].Substring(tab_archivos[0, i].IndexOf(".") + 1, tab_archivos[0, i].Length - (tab_archivos[0, i].IndexOf(".") + 1));
                    string ext1 = tab_archivos[4, i];
                    string ext2 = tab_archivos[2, i];
                    string ext5 = tab_archivos[5, i];
                    int ex5 = ext2.IndexOf("MB");
                    if ((util.nvl(ext1) != "1") || (ext2.IndexOf("MB") <= 0))
                    {
                        display_mail = display_mail + "    <IMG SRC=\"" + servidor + " /images/pixel.gif\" WIDTH =\"40\" HEIGHT =\"1\" alt =\"\" > " + "\n"
                                                    + "    <a href=\"" + servidor + " /download.asp?id=" + cve + "\" > " + "\n";

                        switch (ext)
                        {
                            case "xlsx":
                                Excel = 1;
                                img = "excel.gif Excel";
                                //        display_mail = display_mail + "    <IMG SRC=\"" + servidor + " /images/excel.gif\" align =\"bottom\" alt =\"excel\" border =\"0\" ></a>" + "\n"
                                //                                     + "    &nbsp;- <a href=\"" + servidor + " /download.asp?id=" + cve + "\" class=\"link\" > Excel</a> (" + tab_archivos[2, i] + ")" + "\n";
                                break;
                            case "csv":
                                img = "excel.gif Excel";
                                //       display_mail = display_mail + "    <IMG SRC=\"" + servidor + " /images/excel.gif\" align =\"bottom\" alt =\"excel\" border =\"0\" ></a>" + "\n"
                                //             + "    &nbsp;- <a href=\"" + servidor + " /download.asp?id=" + cve + "\" class=\"link\" > Excel</a> (" + tab_archivos[2, i] + ")" + "\n";
                                break;
                            case "pdf":
                                img = "pdf.gif pdf";
                                Pdf = 1;
                                //       display_mail = display_mail + "    <IMG SRC=\"" + servidor + " /images/pdf.gif\" align =\"bottom\" alt =\"excel\" border =\"0\" ></a>" + "\n"
                                //             + "    &nbsp;- <a href=\"" + servidor + " /download.asp?id=" + cve + "\" class=\"link\" > pdf</a> (" + tab_archivos[2, i] + ")" + "\n";
                                break;
                            case "txt":
                                img = "notepad.gif txt";
                                //       display_mail = display_mail + "    <IMG SRC=\"" + servidor + " /images/notepad.gif\" align =\"bottom\" alt =\"excel\" border =\"0\" ></a>" + "\n"
                                //            + "    &nbsp;- <a href=\"" + servidor + " /download.asp?id=" + cve + "\" class=\"link\" > txt</a> (" + tab_archivos[2, i] + ")" + "\n";
                                break;
                            case "xml":
                                img = "xml3.png xml";
                                //       display_mail = display_mail + "    <IMG SRC=\"" + servidor + " /images/xml3.png\" align =\"bottom\" alt =\"excel\" border =\"0\" ></a>" + "\n"
                                //            + "    &nbsp;- <a href=\"" + servidor + " /download.asp?id=" + cve + "\" class=\"link\" > xml</a> (" + tab_archivos[2, i] + ")" + "\n";
                                break;
                            case "zip":
                                img = "winzip2.gif zip";
                                Zip = 1;
                                //       display_mail = display_mail + "    <IMG SRC=\"" + servidor + " /images/winzip2.gif\" align =\"bottom\" alt =\"excel\" border =\"0\" ></a>" + "\n"
                                //            + "    &nbsp;- <a href=\"" + servidor + " /download.asp?id=" + cve + "\" class=\"link\" > zip</a> (" + tab_archivos[2, i] + ")" + "\n";
                                break;
                            default:
                                img = "";
                                break;
                        }


                    }
                    string[] par1 = img.Split(" ");
                    if (par1.Length > 1)
                        display_mail = display_mail + "    <IMG SRC=\"" + servidor + " /images/" + par1[0] + "\" align =\"bottom\" alt =\"" + par1[1] + "\" border =\"0\" ></a>" + "\n"
                             //+ "    &nbsp;- <a href=\"" + servidor + " /download.asp?id=" + cve + "\" class=\"link\" > " + par1[1] + "</a> (" + tab_archivos[2, i] + ")" + "\n";
                             + "    &nbsp;- <a href=\"" + servidor + " /download.asp?id=" + cve + "\" class=\"link\" > " + par1[1] + "</a> (" + ext2 + ")" + "\n";
                    else
                        //display_mail = display_mail + "    <a href=\"" + servidor + " /download.asp?id=" + cve + "\" class=\"link\" > download</a> (" + tab_archivos[2, i] + ")" + "\n";
                        display_mail = display_mail + "    <a href=\"" + servidor + " /download.asp?id=" + cve + "\" class=\"link\" > download</a> (" + ext2 + ")" + "\n";

                    if ((util.nvl(ext1)) == "1")
                    {
                        Zip = 1;
                        display_mail = display_mail + "    <IMG SRC=\"" + servidor + " /images/pixel.gif\" WIDTH =\"40\" HEIGHT =\"1\" alt =\"\" > " + "\n"
                          + "  <a href=\"" + servidor + " /download.asp?id=" + cve + "&zip=1" + "\" > " + "\n"
                          + "  <IMG SRC=\"" + servidor + " /images/winzip2.gif\" align =\"bottom\" alt =\"zip\" border =\"0\" ></a>" + "\n"
                          + "   &nbsp;- <a href=\"" + servidor + " /download.asp?id=" + cve + "&zip=1" + "\" class=\"link\" > Zip</a> (" + ext5 + ")" + "\n";
                    }
                    display_mail = display_mail + "    <br><IMG SRC=\"" + servidor + "/images/pixel.gif\" WIDTH=\"40\" HEIGHT=\"10\" alt=\"\"><IMG SRC=\"" + servidor + "/images/pointeurgris.gif\" alt=\"\">&nbsp;Direct Link :" + "\n"
                                  + "    <br>" + "\n";
                    if ((util.nvl(ext1) != "1") || (ext2.IndexOf("MB") == 0))
                        //if ((util.nvl(tab_archivos[4, i]) != "1") || (tab_archivos[2, i].IndexOf("MB") == 0))
                        display_mail = display_mail + "    <IMG SRC=\"" + servidor + "/images/pixel.gif\" WIDTH=\"40\" HEIGHT=\"1\" alt=\"\"><a href=\"" + servidor + "/download.asp?id=" + cve + "\">" + servidor + "/download.asp?id=" + cve + "</a>" + "\n";
                    else
                        display_mail = display_mail + "    <IMG SRC=\"" + servidor + " /images/pixel.gif\" WIDTH =\"40\" HEIGHT =\"1\" alt =\"\" ><a href=\"" + servidor + " /download.asp?id=" + cve + "&zip=1\" > " + servidor + "/download.asp?id=" + cve + "&zip=1</a>" + "\n";
                    display_mail = display_mail + "    <br><br>" + "\n";

                }
                else
                    display_mail = display_mail + "    <IMG SRC=\"" + servidor + " /images/pixel.gif\" WIDTH =\"40\" HEIGHT =\"1\" alt =\"\" > No Reports.";
            }
            display_mail = display_mail + "    </FONT></td>\n"
            + "</tr>" + "\n"
             + "<tr>" + "\n"
             + "    <td align=\"left\" > " + "\n"
             + "    <FONT SIZE=\"2\" FACE =\"Arial,Helvetica\" COLOR =\"#000000\" > " + "\n";
            if (adittional_info != "")
            {
                display_mail = display_mail + "<p>" + "\n"
              + adittional_info.Replace("\n", "<br>") + "\n"
              + "</p>" + "\n";
            }
            display_mail = display_mail + "    <IMG SRC=\"" + servidor + " /images/pixel.gif\" WIDTH =\"20\" HEIGHT =\"30\" alt =\"\" > This report will be automatically deleted in " + days_deleted + " days.\n"
                + "    <BR>\n"
                 + "    <IMG SRC=\"" + servidor + " /images/pixel.gif\" WIDTH =\"20\" HEIGHT =\"20\" alt =\"\" > Regards\n"
                 + "    <BR>\n"
                 + "    <IMG SRC=\"" + servidor + " /images/pixel.gif\" WIDTH =\"20\" HEIGHT =\"20\" alt =\"\" ><b>Logis Reports Server.</b>\n"
                 + "    </FONT>\n"
                 + "    </td>\n"
                 + "</tr>\n"
                 + "<tr>\n"
                 + "    <td><IMG SRC=\"" + servidor + " /images/pixel.gif\" WIDTH =\"1\" HEIGHT =\"30\" alt =\"\" ></td>\n"
                 + "</tr>\n"
                 + "<tr bgcolor=\"#C69633\" >\n"
                 + "    <td height=\"25\" align =\"left\" valign =bottom><IMG SRC=\"" + servidor + " /images/pixel.gif\" WIDTH =\"20\" HEIGHT =\"1\" alt =\"\" ><FONT FACE=\"Arial,Helvetica\" SIZE =\"3\" COLOR =\"#ffffff\" ><B>Help :</B></FONT></td>\n"
                 + "</tr>\n"
                 + "<tr>\n"
                 + "    <td><IMG SRC=\"" + servidor + " /images/pixel.gif\" WIDTH =\"1\" HEIGHT =\"5\" alt =\"\" ></td>\n"
                 + "</tr>\n"
                 + "<tr>\n"
                 + "    <td align=\"left\" >\n";

            if (Excel == 1)
            {
                display_mail = display_mail + "    <FONT SIZE=\"2\" FACE =\"Arial,Helvetica\" COLOR =\"#000000\" >\n"
                + "    <IMG SRC=\"" + servidor + " /images/pixel.gif\" WIDTH =\"5\" HEIGHT =\"1\" alt =\"\" >\n"
                + "    <IMG SRC=\"" + servidor + "/images/excel.gif\" align =\"bottom\" alt =\"\" > &nbsp;- <b>Excel</b> : you will need office 2000 (and superior) or <a href=\"http://office.microsoft.com/downloads/2000/xlviewer.aspx\" class=\"link\" > XLViewer</a>.\n";
            }

            if (Pdf == 1)
            {
                display_mail = display_mail + "    <FONT SIZE=\"2\" FACE =\"Arial,Helvetica\" COLOR =\"#000000\" >\n"
                + "    <IMG SRC=\"" + servidor + " /images/pixel.gif\" WIDTH =\"5\" HEIGHT =\"1\" alt =\"\" >\n"
                + "    <IMG SRC=\"" + servidor + "/images/pdf.gif\" align =\"bottom\" alt =\"\" > &nbsp;- <b>Pdf</b> : this file can be viewed with <a href=\"http://www.adobe.com/products/acrobat/readstep2.html\" class=\"link\" > Acrobat Reader</a>.\n";
            }
            if (Zip == 1)
            {
                display_mail = display_mail + "    <br>\n"
                 + "    <IMG SRC=\"" + servidor + " /images/pixel.gif\" WIDTH =\"5\" HEIGHT =\"20\" align =\"bottom\" alt =\"\" >\n"
                 + "    <IMG SRC=\"" + servidor + " /images/winzip2.gif\" align =\"bottom\" alt =\"\" > &nbsp;- <b>Zip</b> : In order to reduce your download time, we compressed your report.\n"
                 + "    <br>To open it, you will need Winzip (<a href=\"http://www.winzip.com\" class=\"link\" > free trial</a>) or equivalent : 7-zip (<a href=\"http://www.7-zip.org\" class=\"link\" > free</a>).\n";
            }



            display_mail = display_mail + "    </FONT>\n"
         + "    </td>\n"
         + "</tr>\n"
         + "<tr>\n"
         + "    <td><IMG SRC=\"" + servidor + " /images/pixel.gif\" WIDTH =\"1\" HEIGHT =\"30\" alt =\"\" ></td>\n"
         + "</tr>\n"
         + "<tr><td>\n"
         + "<table width=\"100 %\" CELLSPACING =\"0\" CELLPADDING =\"0\" BORDER =\"0\" >\n"
         + "<tr>\n"
         + "    <td align=\"left\" ><hr>\n"
         + "    <FONT SIZE=\"2\" FACE =\"Arial,Helvetica\" COLOR =\"#000000\" > This is a message automatically generated, please contact\n"
         + "<a href=\"mailto:web-master@logis.com.mx\" class=\"link\" > web-master@logis.com.mx</a> for any question or to unsubscribe. </FONT></td>\n"
         //'+ "</tr>\n"
         //'+ "<tr>\n"
         + "    <td align=\"right\" >\n"
         + "        <p><img border=\"0\" src =\"http://www.w3.org/Icons/valid-html401\"  alt =\"Valid HTML 4.01!\" height =\"31\" width =\"88\" >\n"
         + "    </p>\n"
         + "    </td>\n"
         + "</tr>\n"
         + "</table>\n"
         + "</td></tr>\n"
         + "<tr bgcolor=\"#336699\" >\n"
         + "    <td><IMG SRC=\"" + servidor + " /images/pixel.gif\" WIDTH =\"1\" HEIGHT =\"15\" alt =\"\" ></td>\n"
         + "</tr>\n"
         + "</table>\n"
         + "\n"
         + "</td></tr>\n"
         + "</table>\n"
         + "</center>\n"
         + "</BODY>\n"
         + "</HTML>";


            return display_mail;
        }


    }
}
