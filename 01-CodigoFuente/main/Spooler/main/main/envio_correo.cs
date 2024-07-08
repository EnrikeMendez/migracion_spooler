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
                correo.Dispose();
                return "OK";
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                return (ex.Message);
            }

        }


        public string display_mail1(string servidor, string nombre_reporte)
        {
            string display_mail = "<!DOCTYPE html PUBLIC \"\"-//W3C//DTD HTML 4.01 Transitional//EN\"\">\n"
            + "<html>\n"
            + "<head>\n"
            + "<meta http-equiv=\"\"Content-Type\"\" content=\"\"text/html; charset=ISO-8859-1\"\">\n"
            + "<title>Logis Report Server</title>\n"
            + "<STYLE TYPE=\"\"text/css\"\">\n"

            + ".link:active {color:\"\"#0000FF\"\"}\n"
            + ".link:link {color:\"\"#0000FF\"\"}\n"
            + ".link:hover {color:\"\"#0000FF\"\"}\n"
            + ".link:visited {color:\"\"#0000FF\"\"}\n"

            + "</STYLE>\n"
            + "</head>\n"
            + "<body>\n"
            + "\n"
            + "<center>\n"
            + "<TABLE WIDTH=\"\"500\"\" CELLSPACING=\"\"0\"\" CELLPADDING=\"\"0\"\" BORDER=\"\"1\"\" bgcolor=\"\"#ffffff\"\">\n"
            + "<tr><td>\n"
            + "<TABLE WIDTH=\"\"500\"\" CELLSPACING=\"\"0\"\" CELLPADDING=\"\"0\"\" BORDER=\"\"0\"\" bgcolor=\"\"#336699\"\">\n"
            + "<tr>\n"
            + "<td align=\"\"left\"\"><a href=\"\"" + servidor + "/\"\"><img src=\"\"" + servidor + "/images/pixel.gif\"\" width=\"\"1\"\" height=\"\"45\"\" border=\"\"0\"\" alt=\"\"\"\"><img src=\"\"LetrasLogis.gif\"\" border=\"\"0\"\" alt=\"\"logo logis\"\"></a></td>\n"
            + "<td align=\"\"left\"\"><a href=\"\"" + servidor + "/\"\"><IMG SRC=\"\"" + servidor + "/images/pixel.gif\"\" WIDTH=\"\"1\"\" HEIGHT=\"\"45\"\" border=\"\"0\"\" alt=\"\"\"\"><img src=\"\"" + servidor + "/images/LetrasLogis.gif\"\" border=\"\"0\"\" alt=\"\"logo logis\"\"></a></td>\n"
            + "</tr>\n"
            + "</table>\n"
            + "<TABLE WIDTH=\"\"500\"\" CELLSPACING=\"\"0\"\" CELLPADDING=\"\"0\"\" BORDER=\"\"0\"\" bgcolor=\"\"#ffffff\"\">\n"
            + "<tr>\n"
            + "    <td align=\"\"left\"\"><IMG SRC=\"\"" + servidor + "/images/pixel.gif\"\" WIDTH=\"\"1\"\" HEIGHT=\"\"5\"\" alt=\"\"\"\"></td>\n"
            + "</tr>\n"
            + "</table>\n"
            + "<TABLE WIDTH=\"\"500\"\" CELLSPACING=\"\"0\"\" CELLPADDING=\"\"3\"\" BORDER=\"\"0\"\" bgcolor=\"\"#ffffff\"\">\n";
            //If warning_message<> "" Then
            {
                display_mail = display_mail + "<tr bgcolor=\"\"#C69633\"\">\n"
                + "    <td height=\"\"25\"\"  align=\"\"left\"\" valign=bottom><IMG SRC=\"\"" + servidor + "/images/pixel.gif\"\" WIDTH=\"\"20\"\" HEIGHT=\"\"1\"\" alt=\"\"\"\"><FONT FACE=\"\"Arial,Helvetica\"\" SIZE=\"\"3\"\" COLOR=\"\"red\"\"><B>Comment :</B></FONT></td>\n"
                + "</tr>\n"
                + "<tr>\n"
                + "    <td><IMG SRC=\"\"" + servidor + "/images/pixel.gif\"\" WIDTH=\"\"1\"\" HEIGHT=\"\"5\"\" alt=\"\"\"\"></td>\n"
                + "</tr>\n"
                + "<tr>\n"
                + "    <td align=\"\"left\"\">\n"
                + "    <FONT SIZE=\"\"2\"\" FACE=\"\"Arial,Helvetica\"\" COLOR=\"\"#000000\"\">\n"
                //+ warning_message + "\n"
                + "    </FONT>\n"
                + "    </td>\n"
                + "</tr>\n"
                + "<tr>\n"
                + "    <td><IMG SRC=\"\"" + servidor + "/images/pixel.gif\"\" WIDTH=\"\"1\"\" HEIGHT=\"\"30\"\" alt=\"\"\"\"></td>\n"
                + "</tr>\n";
            }
            display_mail = display_mail + "<tr bgcolor=\"\"#C69633\"\">\n"
            + "    <td height=\"\"25\"\"  align=\"\"left\"\" valign=bottom><IMG SRC=\"\"" + servidor + "/images/pixel.gif\"\" WIDTH=\"\"20\"\" HEIGHT=\"\"1\"\" alt=\"\"\"\"><FONT FACE=\"\"Arial,Helvetica\"\" SIZE=\"\"3\"\" COLOR=\"\"#FFFFFF\"\"><B>Logis Report Server :</B></FONT></td>\n"
            + "</tr>\n"
            + "<tr>\n"
            + "    <td>\n"
            + "    <FONT SIZE=\"\"2\"\" FACE=\"\"Arial,Helvetica\"\" COLOR=\"\"#000000\"\">\n"
            + "    <IMG SRC=\"\"" + servidor + "/images/pixel.gif\"\" WIDTH=\"\"1\"\" HEIGHT=\"\"5\"\" alt=\"\"\"\">\n"
            + "    <br>\n"
            + "    <IMG SRC=\"\"" + servidor + "/images/pixel.gif\"\" WIDTH=\"\"20\"\" HEIGHT=\"\"20\"\" alt=\"\"\"\"><IMG SRC=\"\"" + servidor + "/images/pointeurgris.gif\"\" alt=\"\"\"\">&nbsp;<B>Report Name :</B> " + nombre_reporte + "\n"
            + "    <br>\n"
            + "    <IMG SRC=\"\"" + servidor + "/images/pixel.gif\"\" WIDTH=\"\"20\"\" HEIGHT=\"\"20\"\" alt=\"\"\"\"><IMG SRC=\"\"" + servidor + "/images/pointeurgris.gif\"\" alt=\"\"\"\">&nbsp;<B>Date :</B> " + DateTime.Now.ToString("dd/MM/yyyy H: mm") + "\n"
            + "    <br>\n";
            /*
  For i = 0 To UBound(tab_archivos, 2)
      display_mail = display_mail & "    <IMG SRC=""" & servidor & "/images/pixel.gif"" WIDTH=""20"" HEIGHT=""20"" alt=""""><IMG SRC=""" & servidor & "/images/pointeurgris.gif"" alt="""">&nbsp;<B>Reporte :</B> " & tab_archivos(1, i) & vbCrLf
      display_mail = display_mail & "    <br>" & vbCrLf
      If tab_archivos(0, i) <> "" Then
          If NVL_num(tab_archivos(4, i)) <> 1 Or InStr(tab_archivos(2, i), "MB") = 0 Then
              'si el nombre de archivo se queda en blanco es que no hay reporte.
              display_mail = display_mail & "    <IMG SRC=""" & servidor & "/images/pixel.gif"" WIDTH=""40"" HEIGHT=""1"" alt="""">" & vbCrLf
              display_mail = display_mail & "    <a href=""" & servidor & "/download.asp?id=" & Left(tab_archivos(3, i), 8) & """>" & vbCrLf

              'imagen del tipo de archivo
              Select Case Split(tab_archivos(0, i), ".")(UBound(Split(tab_archivos(0, i), ".")))
                  Case "xls"
                      Excel = True
                      display_mail = display_mail & "    <IMG SRC=""" & servidor & "/images/excel.gif"" align=""bottom"" alt=""excel"" border=""0""></a>" & vbCrLf
                      display_mail = display_mail & "    &nbsp;- <a href=""" & servidor & "/download.asp?id=" & Left(tab_archivos(3, i), 8) & """ class=""link"">Excel</a> (" & tab_archivos(2, i) & ")" & vbCrLf

                  Case "csv"
                      Excel = True
                      display_mail = display_mail & "    <IMG SRC=""" & servidor & "/images/excel.gif"" align=""bottom"" alt=""excel"" border=""0""></a>" & vbCrLf
                      display_mail = display_mail & "    &nbsp;- <a href=""" & servidor & "/download.asp?id=" & Left(tab_archivos(3, i), 8) & """ class=""link"">Csv</a> (" & tab_archivos(2, i) & ")" & vbCrLf

                  Case "pdf"
                      Pdf = True
                      display_mail = display_mail & "    <IMG SRC=""" & servidor & "/images/pdf.gif"" align=""bottom"" alt=""pdf"" border=""0""></a>" & vbCrLf
                      display_mail = display_mail & "    &nbsp;- <a href=""" & servidor & "/download.asp?id=" & Left(tab_archivos(3, i), 8) & """ class=""link"">pdf</a> (" & tab_archivos(2, i) & ")" & vbCrLf

                  Case "txt"
                      display_mail = display_mail & "    <IMG SRC=""" & servidor & "/images/notepad.gif"" align=""bottom"" alt=""txt"" border=""0""></a>" & vbCrLf
                      display_mail = display_mail & "    &nbsp;- <a href=""" & servidor & "/download.asp?id=" & Left(tab_archivos(3, i), 8) & """ class=""link"">txt</a> (" & tab_archivos(2, i) & ")" & vbCrLf

                  Case "xml"
                      display_mail = display_mail & "    <IMG SRC=""" & servidor & "/images/xml3.png"" align=""bottom"" alt=""xml"" border=""0""></a>" & vbCrLf
                      display_mail = display_mail & "    &nbsp;- <a href=""" & servidor & "/download.asp?id=" & Left(tab_archivos(3, i), 8) & """ class=""link"">xml</a> (" & tab_archivos(2, i) & ")" & vbCrLf

                  Case "zip"
                      display_mail = display_mail & "    <IMG SRC=""" & servidor & "/images/winzip2.gif"" align=""bottom"" alt=""zip"" border=""0""></a>" & vbCrLf
                      display_mail = display_mail & "    &nbsp;- <a href=""" & servidor & "/download.asp?id=" & Left(tab_archivos(3, i), 8) & """ class=""link"">zip</a> (" & tab_archivos(2, i) & ")" & vbCrLf


                  Case Else
                      display_mail = display_mail & "    <a href=""" & servidor & "/download.asp?id=" & Left(tab_archivos(3, i), 8) & """ class=""link"">download</a> (" & tab_archivos(2, i) & ")" & vbCrLf
              End Select
          End If

          If NVL_num(tab_archivos(4, i)) = 1 Then
              'desplegamos el link para el archivo Zip
              Zip = True
              display_mail = display_mail & "    <IMG SRC=""" & servidor & "/images/pixel.gif"" WIDTH=""40"" HEIGHT=""1"" alt="""">" & vbCrLf
              display_mail = display_mail & "    <a href=""" & servidor & "/download.asp?id=" & Left(tab_archivos(3, i), 8) & "&zip=1" & """>" & vbCrLf
              display_mail = display_mail & "    <IMG SRC=""" & servidor & "/images/winzip2.gif"" align=""bottom"" alt=""zip"" border=""0""></a>" & vbCrLf
              display_mail = display_mail & "    &nbsp;- <a href=""" & servidor & "/download.asp?id=" & Left(tab_archivos(3, i), 8) & "&zip=1" & """ class=""link"">Zip</a> (" & tab_archivos(5, i) & ")" & vbCrLf
      '        display_mail = display_mail & "    " & vbCrLf
          End If

          display_mail = display_mail & "    <br><IMG SRC=""" & servidor & "/images/pixel.gif"" WIDTH=""40"" HEIGHT=""10"" alt=""""><IMG SRC=""" & servidor & "/images/pointeurgris.gif"" alt="""">&nbsp;Direct Link :" & vbCrLf
          display_mail = display_mail & "    <br>" & vbCrLf

          If NVL_num(tab_archivos(4, i)) <> 1 Or InStr(tab_archivos(2, i), "MB") = 0 Then
              'solo se muestra el zip
              display_mail = display_mail & "    <IMG SRC=""" & servidor & "/images/pixel.gif"" WIDTH=""40"" HEIGHT=""1"" alt=""""><a href=""" & servidor & "/download.asp?id=" & Left(tab_archivos(3, i), 8) & """>" & servidor & "/download.asp?id=" & Left(tab_archivos(3, i), 8) & "</a>" & vbCrLf
          Else
              display_mail = display_mail & "    <IMG SRC=""" & servidor & "/images/pixel.gif"" WIDTH=""40"" HEIGHT=""1"" alt=""""><a href=""" & servidor & "/download.asp?id=" & Left(tab_archivos(3, i), 8) & "&zip=1"">" & servidor & "/download.asp?id=" & Left(tab_archivos(3, i), 8) & "&zip=1</a>" & vbCrLf
          End If
          display_mail = display_mail & "    <br><br>" & vbCrLf
      Else
          display_mail = display_mail & "    <IMG SRC=""" & servidor & "/images/pixel.gif"" WIDTH=""40"" HEIGHT=""1"" alt="""">No Reports."
      End If
  Next           


             */
            display_mail = display_mail + "    </FONT></td>\n"
            + "</tr>" + "\n"
             + "<tr>" + "\n"
             + "    <td align=\"\"left\"\" > " + "\n"
             + "    <FONT SIZE=\"\"2\"\" FACE =\"\"Arial,Helvetica\"\" COLOR =\"\"#000000\"\" > " + "\n";
            /*
             '<JEMV:
            If adittional_info <> "" Then
                display_mail = display_mail & "<p>"
                display_mail = display_mail & Replace(adittional_info, vbCrLf, "<br>")
                display_mail = display_mail & "</p>"
            End If
            ' JEMV>* 
             */
            //display_mail = display_mail + "    <IMG SRC=\"\"" + servidor + " /images/pixel.gif\"\" WIDTH =\"\"20\"\" HEIGHT =\"\"30\"\" alt =\"\"\"\" > This report will be automatically deleted in " + days_deleted + " days.\n"
            display_mail = display_mail + "    <IMG SRC=\"\"" + servidor + " /images/pixel.gif\"\" WIDTH =\"\"20\"\" HEIGHT =\"\"30\"\" alt =\"\"\"\" > This report will be automatically deleted in " + "7" + " days.\n"
                + "    <BR>\n"
                 + "    <IMG SRC=\"\"" + servidor + " /images/pixel.gif\"\" WIDTH =\"\"20\"\" HEIGHT =\"\"20\"\" alt =\"\"\"\" > Regards\n"
                 + "    <BR>\n"
                 + "    <IMG SRC=\"\"" + servidor + " /images/pixel.gif\"\" WIDTH =\"\"20\"\" HEIGHT =\"\"20\"\" alt =\"\"\"\" ><b>Logis Reports Server.</b>\n"
                 + "    </FONT>\n"
                 + "    </td>\n"
                 + "</tr>\n"
                 + "<tr>\n"
                 + "    <td><IMG SRC=\"\"" + servidor + " /images/pixel.gif\"\" WIDTH =\"\"1\"\" HEIGHT =\"\"30\"\" alt =\"\"\"\" ></td>\n"
                 + "</tr>\n"
                 + "<tr bgcolor=\"\"#C69633\"\" >\n"
                 + "    <td height=\"\"25\"\" align =\"\"left\"\" valign =bottom><IMG SRC=\"\"" + servidor + " /images/pixel.gif\"\" WIDTH =\"\"20\"\" HEIGHT =\"\"1\"\" alt =\"\"\"\" ><FONT FACE=\"\"Arial,Helvetica\"\" SIZE =\"\"3\"\" COLOR =\"\"#ffffff\"\" ><B>Help :</B></FONT></td>\n"
                 + "</tr>\n"
                 + "<tr>\n"
                 + "    <td><IMG SRC=\"\"" + servidor + " /images/pixel.gif\"\" WIDTH =\"\"1\"\" HEIGHT =\"\"5\"\" alt =\"\"\"\" ></td>\n"
                 + "</tr>\n"
                 + "<tr>\n"
                 + "    <td align=\"\"left\"\" >\n";
            /*
             * If Excel Then
               display_mail = display_mail & "    <FONT SIZE=""2"" FACE=""Arial,Helvetica"" COLOR=""#000000"">" & vbCrLf
               display_mail = display_mail & "    <IMG SRC=""" & servidor & "/images/pixel.gif"" WIDTH=""5"" HEIGHT=""1"" alt="""">" & vbCrLf
               display_mail = display_mail & "    <IMG SRC=""" & servidor & "/images/excel.gif"" align=""bottom"" alt="""">&nbsp;- <b>Excel</b> : you will need office 2000 (and superior) or <a href=""http://office.microsoft.com/downloads/2000/xlviewer.aspx"" class=""link"">XLViewer</a>." & vbCrLf
           End If
           If Pdf Then
               display_mail = display_mail & "    <FONT SIZE=""2"" FACE=""Arial,Helvetica"" COLOR=""#000000"">" & vbCrLf
               display_mail = display_mail & "    <IMG SRC=""" & servidor & "/images/pixel.gif"" WIDTH=""5"" HEIGHT=""1"" alt="""">" & vbCrLf
               display_mail = display_mail & "    <IMG SRC=""" & servidor & "/images/pdf.gif"" align=""bottom"" alt="""">&nbsp;- <b>Pdf</b> : this file can be viewed with <a href=""http://www.adobe.com/products/acrobat/readstep2.html"" class=""link"">Acrobat Reader</a>." & vbCrLf
           End If
           If Zip Then
               display_mail = display_mail & "    <br>" & vbCrLf
               display_mail = display_mail & "    <IMG SRC=""" & servidor & "/images/pixel.gif"" WIDTH=""5"" HEIGHT=""20"" align=""bottom"" alt="""">" & vbCrLf
               display_mail = display_mail & "    <IMG SRC=""" & servidor & "/images/winzip2.gif"" align=""bottom"" alt="""">&nbsp;- <b>Zip</b> : In order to reduce your download time, we compressed your report." & vbCrLf
               display_mail = display_mail & "    <br>To open it, you will need Winzip (<a href=""http://www.winzip.com"" class=""link"">free trial</a>) or equivalent : 7-zip (<a href=""http://www.7-zip.org"" class=""link"">free</a>)." & vbCrLf
           End If
             */

            display_mail = display_mail + "    </FONT>\n"
         + "    </td>\n"
         + "</tr>\n"
         + "<tr>\n"
         + "    <td><IMG SRC=\"\"" + servidor + " /images/pixel.gif\"\" WIDTH =\"\"1\"\" HEIGHT =\"\"30\"\" alt =\"\"\"\" ></td>\n"
         + "</tr>\n"
         + "<tr><td>\n"
         + "<table width=\"\"100 %\"\" CELLSPACING =\"\"0\"\" CELLPADDING =\"\"0\"\" BORDER =\"\"0\"\" >\n"
         + "<tr>\n"
         + "    <td align=\"\"left\"\" ><hr>\n"
         + "    <FONT SIZE=\"\"2\"\" FACE =\"\"Arial,Helvetica\"\" COLOR =\"\"#000000\"\" > This is a message automatically generated, please contact\n"
         + "<a href=\"\"mailto:web-master@logis.com.mx\"\" class=\"\"link\"\" > web-master@logis.com.mx</a> for any question or to unsubscribe. </FONT></td>\n"
         //'+ "</tr>\n"
         //'+ "<tr>\n"
         + "    <td align=\"\"right\"\" >\n"
         + "        <p><img border=\"\"0\"\" src =\"\"http://www.w3.org/Icons/valid-html401\"\"  alt =\"\"Valid HTML 4.01!\"\" height =\"\"31\"\" width =\"\"88\"\" >\n"
         + "    </p>\n"
         + "    </td>\n"
         + "</tr>\n"
         + "</table>\n"
         + "</td></tr>\n"
         + "<tr bgcolor=\"\"#336699\"\" >\n"
         + "    <td><IMG SRC=\"\"" + servidor + " /images/pixel.gif\"\" WIDTH =\"\"1\"\" HEIGHT =\"\"15\"\" alt =\"\"\"\" ></td>\n"
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
