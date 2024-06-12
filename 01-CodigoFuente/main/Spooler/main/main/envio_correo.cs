using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Mail;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using DocumentFormat.OpenXml.Wordprocessing;
using Microsoft.Extensions.Configuration;
using System.Reflection;

namespace serverreports
{
    internal class envio_correo
    {
        //string [] mail_grupo_error = ["desarrollo_web@logis.com.mx"];
        string[] mail_grupo_error = ["joseemv@logis.com.mx", "raulrgg@logis.com.mx"];
        private string email_usuario()
        {
            var configuration = new ConfigurationBuilder()
                                              .AddUserSecrets(Assembly.GetExecutingAssembly())
                                              .Build();
            return configuration["us_mail"] + "|" + configuration["pwd_mail"];
        }

        public string send_error_mail(string asunto, string[] contact, string mensaje)
        {
            string[] dat_mail = new string[1];
            dat_mail = email_usuario().Split("|");
            //Console.WriteLine(dat_mail[0]);
            //Console.WriteLine(dat_mail[1]);
            Console.WriteLine("\t\t\tEnviar Correo Electronico");
            using (MailMessage correo = new MailMessage())
            {
                correo.From    = new MailAddress(dat_mail[0]);
                correo.Subject = asunto;
                correo.Body    = mensaje;
                if (contact.Length > 0)
                    for (int i = 0; i < contact.Length; i++)
                       correo.To.Add(contact[i]);
                else
                    for (int i = 0; i < mail_grupo_error.Length; i++)
                         correo.To.Add(mail_grupo_error[i]);

                using (SmtpClient servidor = new SmtpClient("smtp.gmail.com", 587)) 
                {
                    servidor.EnableSsl = true;
                    servidor.Credentials = new System.Net.NetworkCredential(dat_mail[0], dat_mail[1]);
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
            MailMessage correo = new MailMessage("rlgranados2@gmail.com", "raulrgg@logis.com.mx", asunto, mensaje);             
            if (contact.Length > 0)
                for (int i = 0; i < contact.Length; i++)
                    correo.To.Add(contact[i]);
            else
                for (int i = 0; i < mail_grupo_error.Length; i++)
                    correo.To.Add(mail_grupo_error[i]);            
            SmtpClient servidor = new SmtpClient("smtp.gmail.com", 587);
            //****NetworkCredential credenciales = new NetworkCredential("rlgranados2@gmail.com", "fvtv rtop otjx ggux");
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

    }
}
