using DocumentFormat.OpenXml.Bibliography;
using DocumentFormat.OpenXml.Drawing.Diagrams;
using DocumentFormat.OpenXml.Presentation;
using DocumentFormat.OpenXml.Spreadsheet;
using DocumentFormat.OpenXml.Wordprocessing;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Linq;
using System.Linq.Expressions;
using System.Reflection;
using System.Security.Policy;
using System.Text;
using System.Threading.Tasks;

namespace serverreports
{
    internal class dist_transfer_ftp_mod
    {
        private DM obj_dm = new DM();
        private Utilerias obj_utilerias = new Utilerias();
        private DataTable dt_conf_sftp_cliente = new DataTable();
        private DataTable dt_conf_sftp_espejo = new DataTable();
        private DataTable dt_evid_transmitir = new DataTable();
        private DataTable dt_rpt_evid_transm = new DataTable();
        private DataSet ds_rpt_evid_transm;
        private envio_correo obj_envio_correo = new envio_correo();
        private ArrayList arrayArchivosCorrectosCliente = new ArrayList();
        private ArrayList arrayArchivosCorrectosEspejo = new ArrayList();
        private ArrayList arrayArchivosIncorrectosCliente = new ArrayList();
        private ArrayList arrayArchivosIncorrectosEspejo = new ArrayList();
        private Excel xls = new Excel();


        private envio_sftp? obj_envio_sftp_cliente;
        private envio_sftp? obj_envio_sftp_espejo;
        private string[,]? par_st;
        private DateTime fecha1;
        private DateTime fecha2;


        private long? my_id_cron;
        private string? my_cliente;
        private string? my_carpeta_espejo;
        private string? my_fecha_1;
        private string? my_fecha_2;
        private string? rpt_evid_transmit;
        string[,]? my_pargral;
        private int my_vs;
        private bool? transmite_cliente = false;
        private bool? transmite_espejo = false;
        private bool? transmite_solo_espejo = false;
        private string? msg_proceso;
        private string? rpt_espejo_ruta_generacion;
        private string? rpt_cliente_ruta_generacion;
        private string? fechaConsultaRPT_1;
        private string? fechaConsultaRPT_2;

        private string? asunto_mail_exito_cliente;
        private string? asunto_mail_error_cliente;
        private string? asunto_mail_exito_espejo;
        private string? asunto_mail_error_espejo;

        private string[]? contmail_exito_cliente;
        private string[]? EmailCC_exito_cliente;
        private string[]? EmailBCC_exito_cliente;
        private string[]? contmail_error_cliente;
        private string[]? EmailCC_error_cliente;
        private string[]? EmailBCC_error_cliente;

        private string[]? contmail_exito_espejo;
        private string[]? EmailCC_exito_espejo;
        private string[]? EmailBCC_exito_espejo;
        private string[]? contmail_error_espejo;
        private string[]? EmailCC_error_espejo;
        private string[]? EmailBCC_error_espejo;

        private string ruta_log_cliente;
        private string ruta_log_espejo;


        (string? codigo, string? msg, string? sql, DataTable? tb) my_datos_sp;

        public string dist_ftp_transfer(long id_cron, String cliente, string carpeta_espejo, String fecha_1, String fecha_2, string[,] pargral, DataTable dtNotif, int vs)
        {

            try
            {
                //Inicializacion de variables...
                ftn_init_var(id_cron, cliente, carpeta_espejo, fecha_1, fecha_2, pargral, dtNotif, vs);

                // (1) *** Se validan credenciales registradas en base de datos y se realiza la prueba de conexión al repositorio cliente y espejo.
                sub_valida_conexion_repositorio();

                // (2) *** Se consultan las evidencias a enviar por el periodo de fecha específico, si no hay evidencias por enviar se notifica sin evidencias.
                sub_consulta_archivos();

                // (3) *** Si se encontraron evidencias por enviar, se conectará a cada repositorio (cliente / espejo) y las transmitirá, una vez transmitido todo, se notificará el resumen de lo enviado.
                sub_transmite_archivos();

            }
            catch (Exception ex)
            {
                obj_utilerias.EscribirLog(ruta_log_cliente, "Cliente:" + my_cliente + " - [ERROR]. Hubo una excepción en la ejecución del proceso a causa del siguiente error: \n" + ex.ToString());
                obj_utilerias.EscribirLog(ruta_log_espejo, "Cliente:" + my_cliente + " - [ERROR]. Hubo una excepción en la ejecución del proceso a causa del siguiente error: \n" + ex.ToString());
                Console.WriteLine(ex.ToString());
            }
            finally
            {
                if (dt_conf_sftp_cliente != null)
                {
                    dt_conf_sftp_cliente.Dispose();
                    GC.SuppressFinalize(dt_conf_sftp_cliente);
                }
                if (dt_conf_sftp_espejo != null)
                {
                    dt_conf_sftp_espejo.Dispose();
                    GC.SuppressFinalize(dt_conf_sftp_espejo);
                }
                if (dt_evid_transmitir != null)
                {
                    dt_evid_transmitir.Dispose();
                    GC.SuppressFinalize(dt_evid_transmitir);
                }

                if (File.Exists(rpt_espejo_ruta_generacion))
                {
                    File.Delete(rpt_espejo_ruta_generacion);
                }

                if (File.Exists(rpt_cliente_ruta_generacion))
                {
                    File.Delete(rpt_cliente_ruta_generacion);
                }


                obj_utilerias.EscribirLog(ruta_log_cliente, "Cliente:" + my_cliente + " - :::::::::::::::::::::::::::::::::::::::::::::::::::::: Finaliza proceso ::::::::::::::::::::::::::::::::::::::::::::::::::::::");
                obj_utilerias.EscribirLog(ruta_log_espejo, "Cliente:" + my_cliente + " - :::::::::::::::::::::::::::::::::::::::::::::::::::::: Finaliza proceso ::::::::::::::::::::::::::::::::::::::::::::::::::::::");
            }

            return "";
        }

        public void sub_valida_conexion_repositorio()
        {
            string error;
            // SP consulta configuracion Cliente...
            par_st = new string[6, 4];

            par_st[0, 0] = "i";
            par_st[0, 1] = "i";
            par_st[0, 2] = "p_Tipo_Envio ";
            par_st[0, 3] = "1";


            par_st[1, 0] = "i";
            par_st[1, 1] = "i";
            par_st[1, 2] = "p_Num_Cliente";
            par_st[1, 3] = my_cliente;


            par_st[2, 0] = "i";
            par_st[2, 1] = "i";
            par_st[2, 2] = "p_Es_Espejo";
            par_st[2, 3] = "0";

            par_st[3, 0] = "o";
            par_st[3, 1] = "c";
            par_st[3, 2] = "p_Cur_SFTP_Accesos_Cli";

            par_st[4, 0] = "o";
            par_st[4, 1] = "v";
            par_st[4, 2] = "p_Mensaje";
            par_st[4, 3] = "msg";

            par_st[5, 0] = "o";
            par_st[5, 1] = "i";
            par_st[5, 2] = "p_Codigo_Error";
            par_st[5, 3] = "cod";

            my_datos_sp.sql = "SC_RS_DIST.SPG_ENVIO_EVIDENCIAS_SFTP.P_DAT_SFTP_ACCESOS_CLI";

            my_datos_sp = obj_dm.datos_sp([my_datos_sp.sql], par_st, 3, my_vs);
            dt_conf_sftp_cliente = my_datos_sp.tb;

            //En caso de error...
            if (my_datos_sp.codigo != "1" || dt_conf_sftp_cliente.Rows.Count <= 0)
            {
                msg_proceso = "Buen día, \n\nNo se encontró registro de la configuración de conexión al repositorio SFTP del Cliente " + my_cliente + "." + "\n\n" + "Saludos, \n" + "Server Reports.";
                obj_envio_correo.send_mail(asunto_mail_error_cliente, contmail_error_cliente, msg_proceso, [], EmailCC_error_cliente, false, EmailBCC_error_cliente);
                obj_utilerias.EscribirLog(ruta_log_cliente, "Cliente:" + my_cliente + " - [Error]. No se encontró registro de la configuración de conexión al repositorio SFTP del Cliente.");
                transmite_cliente = false;
            }
            else
            {
                transmite_cliente = true;
            }


            // SP consulta configuracion Espejo...
            par_st = new string[6, 4];

            par_st[0, 0] = "i";
            par_st[0, 1] = "i";
            par_st[0, 2] = "p_Tipo_Envio";
            par_st[0, 3] = "2";

            par_st[1, 0] = "i";
            par_st[1, 1] = "i";
            par_st[1, 2] = "p_Num_Cliente";
            par_st[1, 3] = my_cliente;

            par_st[2, 0] = "i";
            par_st[2, 1] = "i";
            par_st[2, 2] = "p_Es_Espejo";
            par_st[2, 3] = "1";

            par_st[3, 0] = "o";
            par_st[3, 1] = "c";
            par_st[3, 2] = "p_Cur_SFTP_Accesos_Cli";

            par_st[4, 0] = "o";
            par_st[4, 1] = "v";
            par_st[4, 2] = "p_Mensaje";
            par_st[4, 3] = "msg";

            par_st[5, 0] = "o";
            par_st[5, 1] = "i";
            par_st[5, 2] = "p_Codigo_Error";
            par_st[5, 3] = "cod";

            my_datos_sp.sql = "SC_RS_DIST.SPG_ENVIO_EVIDENCIAS_SFTP.P_DAT_SFTP_ACCESOS_CLI";

            my_datos_sp = obj_dm.datos_sp([my_datos_sp.sql], par_st, 3, my_vs);
            dt_conf_sftp_espejo = my_datos_sp.tb;

            //En caso de error...
            if (my_datos_sp.codigo != "1" || dt_conf_sftp_espejo.Rows.Count <= 0)
            {
                msg_proceso = "Buen día, \n\nNo se encontró registro de la configuración de conexión al repositorio SFTP Espejo para el cliente " + my_cliente + "." + "\n\n" + "Saludos, \n" + "Server Reports.";
                obj_envio_correo.send_mail(asunto_mail_error_espejo, contmail_error_espejo, msg_proceso, [], EmailCC_error_espejo, false, EmailBCC_error_espejo);
                obj_utilerias.EscribirLog(ruta_log_espejo, "Cliente:" + my_cliente + " - [ERROR]. No se encontró registro de la configuración de conexión al repositorio SFTP Espejo para el cliente.");
                transmite_espejo = false;
            }
            else
            {
                transmite_espejo = true;
            }

            //Prueba de Conexion a Repositorio Cliente...
            if (transmite_cliente == true)
            {
                obj_envio_sftp_cliente = new envio_sftp(obj_utilerias.nvl("" + dt_conf_sftp_cliente.Rows[0]["HOST"]), Convert.ToInt16(dt_conf_sftp_cliente.Rows[0]["PUERTO"]), obj_utilerias.nvl("" + dt_conf_sftp_cliente.Rows[0]["USUARIO"]), obj_utilerias.nvl("" + dt_conf_sftp_cliente.Rows[0]["PASSWORD"]));

                if (obj_envio_sftp_cliente.sftp_conexion(out error) != false)
                {
                    obj_utilerias.EscribirLog(ruta_log_cliente, "Cliente:" + my_cliente + " - [EXITO]. Conectado al repositorio cliente con IP: " + dt_conf_sftp_cliente.Rows[0]["HOST"] + "");
                    transmite_cliente = true;
                }
                else
                {
                    msg_proceso = "Buen día, \n\nSe intento establecer una conexión al repositorio SFTP del cliente " + my_cliente + ", pero no se obtuvo éxito: \n" + error + "\n\n" + "Saludos, \n" + "Server Reports.";
                    obj_envio_correo.send_mail(asunto_mail_error_cliente, contmail_error_cliente, msg_proceso, [], EmailCC_error_cliente, false, EmailBCC_error_cliente);
                    obj_utilerias.EscribirLog(ruta_log_cliente, "Cliente:" + my_cliente + " - [ERROR]. Se intento establecer una conexión al repositorio SFTP espejo con IP:" + dt_conf_sftp_cliente.Rows[0]["HOST"] + ", pero no se obtuvo éxito: \n" + error);
                    transmite_cliente = false;
                }
                obj_envio_sftp_cliente.sftp_desconexion();
            }

            //Prueba de Conexion a Repositorio Espejo...
            if (transmite_espejo == true)
            {
                obj_envio_sftp_espejo = new envio_sftp(obj_utilerias.nvl("" + dt_conf_sftp_espejo.Rows[0]["HOST"]), Convert.ToInt16(dt_conf_sftp_espejo.Rows[0]["PUERTO"]), obj_utilerias.nvl("" + dt_conf_sftp_espejo.Rows[0]["USUARIO"]), obj_utilerias.nvl("" + dt_conf_sftp_espejo.Rows[0]["PASSWORD"]));
                if (obj_envio_sftp_espejo.sftp_conexion(out error) != false)
                {
                    obj_utilerias.EscribirLog(ruta_log_espejo, "Cliente:" + my_cliente + " - [EXITO]. Conectado al repositorio espejo con IP: " + dt_conf_sftp_espejo.Rows[0]["HOST"] + "");
                    transmite_espejo = true;
                }
                else
                {
                    msg_proceso = "Buen día, \n\nSe intento establecer una conexión al repositorio SFTP espejo, pero no se obtuvo éxito: \n" + error + "\n\n" + "Saludos, \n" + "Server Reports.";
                    obj_envio_correo.send_mail(asunto_mail_error_espejo, contmail_error_espejo, msg_proceso, [], EmailCC_error_espejo, false, EmailBCC_error_espejo);
                    obj_utilerias.EscribirLog(ruta_log_espejo, "Cliente:" + my_cliente + " - [ERROR]. Se intento establecer una conexión al repositorio SFTP espejo con IP: " + dt_conf_sftp_espejo.Rows[0]["HOST"] + ", pero no se obtuvo éxito: \n" + error);
                    transmite_espejo = false;
                }
                obj_envio_sftp_espejo.sftp_desconexion();
            }
        }
        public void sub_consulta_archivos()
        {
            //DEBBUG:
            //my_fecha_1 = "01/01/2024";
            //my_fecha_2 = "02/01/2024";

            // SP consulta evidencias del periodo...
            //...
            if (transmite_cliente == true || transmite_espejo == true)
            {
                par_st = new string[6, 4];

                par_st[0, 0] = "i";
                par_st[0, 1] = "i";
                par_st[0, 2] = "p_Num_Cliente";
                par_st[0, 3] = my_cliente;

                par_st[1, 0] = "i";
                par_st[1, 1] = "v";
                par_st[1, 2] = "p_Fecha_Inicio";
                par_st[1, 3] = my_fecha_1;

                par_st[2, 0] = "i";
                par_st[2, 1] = "v";
                par_st[2, 2] = "p_Fecha_Fin";
                par_st[2, 3] = my_fecha_2;

                par_st[3, 0] = "o";
                par_st[3, 1] = "c";
                par_st[3, 2] = "p_Cur_Evidencias";

                par_st[4, 0] = "o";
                par_st[4, 1] = "v";
                par_st[4, 2] = "p_Mensaje";
                par_st[4, 3] = "msg";

                par_st[5, 0] = "o";
                par_st[5, 1] = "i";
                par_st[5, 2] = "p_Codigo_Error";
                par_st[5, 3] = "cod";

                my_datos_sp.sql = "SC_RS_DIST.SPG_ENVIO_EVIDENCIAS_SFTP.P_DAT_EVIDENCIAS_CLIENTE";
                my_datos_sp = obj_dm.datos_sp([my_datos_sp.sql], par_st, 3, my_vs);


                //dt_evid_transmitir = my_datos_sp.tb;

                //DEBBUGG:
                //LlenarDataTablepPrueba(dt_evid_transmitir);

                if (dt_evid_transmitir.Rows.Count <= 0)
                {
                    //Cuando no se encuentren evidencias a transmitir se notifica... 

                    //Cliente:
                    msg_proceso = "Buen día, \n\nNo se encontraron archivos a transmitir al repositorio SFTP del cliente " + my_cliente + ".\n\n" + "Fecha de busqueda: Del " + my_fecha_1 + " al " + my_fecha_2 + "\n\n" + "Saludos, \n" + "Server Reports.";
                    obj_envio_correo.send_mail(asunto_mail_exito_cliente, contmail_exito_cliente, msg_proceso, [], EmailCC_exito_cliente, false, EmailBCC_exito_cliente);

                    //Espejo:
                    msg_proceso = "Buen día, \n\nNo se encontraron archivos a transmitir al repositorio SFTP Espejo del cliente " + my_cliente + ".\n\n" + "Fecha de busqueda: Del " + my_fecha_1 + " al " + my_fecha_2 + "\n\n" + "Saludos, \n" + "Server Reports.";
                    obj_envio_correo.send_mail(asunto_mail_exito_espejo, contmail_exito_espejo, msg_proceso, [], EmailCC_exito_espejo, false, EmailBCC_exito_espejo);
                }
            }
        }
        public void sub_transmite_archivos()
        {
            string error_transmision;
            if (dt_evid_transmitir.Rows.Count > 0)
            {
                //Cuando si se encuentren evidencias transmitimos a cada repositorio...

                obj_envio_sftp_cliente = new envio_sftp(obj_utilerias.nvl("" + dt_conf_sftp_cliente.Rows[0]["HOST"]), Convert.ToInt16(dt_conf_sftp_cliente.Rows[0]["PUERTO"]), obj_utilerias.nvl("" + dt_conf_sftp_cliente.Rows[0]["USUARIO"]), obj_utilerias.nvl("" + dt_conf_sftp_cliente.Rows[0]["PASSWORD"]));
                obj_envio_sftp_espejo = new envio_sftp(obj_utilerias.nvl("" + dt_conf_sftp_espejo.Rows[0]["HOST"]), Convert.ToInt16(dt_conf_sftp_espejo.Rows[0]["PUERTO"]), obj_utilerias.nvl("" + dt_conf_sftp_espejo.Rows[0]["USUARIO"]), obj_utilerias.nvl("" + dt_conf_sftp_espejo.Rows[0]["PASSWORD"]));


                for (int i = 0; i < dt_evid_transmitir.Rows.Count; i++)
                {
                    //Espejo:
                    if (transmite_espejo == true)
                    {
                        if (obj_envio_sftp_espejo.sftp_transmitir_archivo("" + dt_evid_transmitir.Rows[i]["RUTA_ORIGEN"] + dt_evid_transmitir.Rows[i]["NOMBRE_ORIGEN"], "" + dt_evid_transmitir.Rows[i]["RUTA_DESTINO_ESPEJO"], "" + dt_evid_transmitir.Rows[i]["NOMBRE_DESTINO"], true, out error_transmision) == true)
                        {
                            arrayArchivosCorrectosEspejo.Add("" + dt_evid_transmitir.Rows[i]["RUTA_DESTINO_ESPEJO"] + dt_evid_transmitir.Rows[i]["NOMBRE_DESTINO"]);
                            ftn_registra_status_bita("" + dt_evid_transmitir.Rows[i]["ID_ARCHIVO"], "", "1", "Transmitido al repositorio espejo.");
                            obj_utilerias.EscribirLog(ruta_log_espejo, "Cliente:" + my_cliente + " - [EXITO]. Archivo" + "" + dt_evid_transmitir.Rows[i]["RUTA_DESTINO_ESPEJO"] + dt_evid_transmitir.Rows[i]["NOMBRE_DESTINO"] + " transmitido al repositorio espejo.");
                        }
                        else
                        {
                            arrayArchivosIncorrectosEspejo.Add("" + dt_evid_transmitir.Rows[i]["RUTA_DESTINO_ESPEJO"] + dt_evid_transmitir.Rows[i]["NOMBRE_DESTINO"] + " --> ERROR: " + error_transmision);
                            ftn_registra_status_bita("" + dt_evid_transmitir.Rows[i]["ID_ARCHIVO"], "", "2", "Error al intentar transmitir al repositorio espejo: " + error_transmision);
                            obj_utilerias.EscribirLog(ruta_log_espejo, "Cliente:" + my_cliente + " - [ERROR]. Archivo" + "" + dt_evid_transmitir.Rows[i]["RUTA_DESTINO_ESPEJO"] + dt_evid_transmitir.Rows[i]["NOMBRE_DESTINO"] + " NO transmitido al repositorio espejo a causa del siguiente error: \n" + error_transmision);
                        }
                    }

                    //Cliente:
                    if (transmite_cliente == true)
                    {
                        if (obj_envio_sftp_cliente.sftp_transmitir_archivo("" + dt_evid_transmitir.Rows[i]["RUTA_ORIGEN"] + dt_evid_transmitir.Rows[i]["NOMBRE_ORIGEN"], "" + dt_evid_transmitir.Rows[i]["RUTA_DESTINO_CLIENTE"], "" + dt_evid_transmitir.Rows[i]["NOMBRE_DESTINO"], true, out error_transmision) == true)
                        {
                            arrayArchivosCorrectosCliente.Add("" + dt_evid_transmitir.Rows[i]["RUTA_DESTINO_CLIENTE"] + dt_evid_transmitir.Rows[i]["NOMBRE_DESTINO"]);
                            ftn_registra_status_bita("" + dt_evid_transmitir.Rows[i]["ID_ARCHIVO"], "1", "", "Transmitido al repositorio cliente.");
                            obj_utilerias.EscribirLog(ruta_log_cliente, "Cliente:" + my_cliente + " - [EXITO]. Archivo " + "" + dt_evid_transmitir.Rows[i]["RUTA_DESTINO_CLIENTE"] + dt_evid_transmitir.Rows[i]["NOMBRE_DESTINO"] + "transmitido al repositorio cliente");
                        }
                        else
                        {
                            arrayArchivosIncorrectosCliente.Add("" + dt_evid_transmitir.Rows[i]["RUTA_DESTINO_CLIENTE"] + dt_evid_transmitir.Rows[i]["NOMBRE_DESTINO"] + " --> ERROR: " + error_transmision);
                            ftn_registra_status_bita("" + dt_evid_transmitir.Rows[i]["ID_ARCHIVO"], "2", "", "Error al intentar transmitir al repositorio cliente: " + error_transmision);
                            obj_utilerias.EscribirLog(ruta_log_cliente, "Cliente:" + my_cliente + " - [ERROR]. Archivo " + "" + dt_evid_transmitir.Rows[i]["RUTA_DESTINO_CLIENTE"] + dt_evid_transmitir.Rows[i]["NOMBRE_DESTINO"] + " NO transmitido al repositorio cliente a causa del siguiente error: \n" + error_transmision);
                        }
                    }
                }

                obj_envio_sftp_cliente.sftp_liberar_recursos();
                obj_utilerias.EscribirLog(ruta_log_cliente, "Cliente:" + my_cliente + " - [EXITO]. Desconectado del repositorio cliente con IP: " + dt_conf_sftp_cliente.Rows[0]["HOST"] + "");
                obj_envio_sftp_espejo.sftp_liberar_recursos();
                obj_utilerias.EscribirLog(ruta_log_espejo, "Cliente:" + my_cliente + " - [EXITO]. Desconectado del repositorio espejo con IP: " + dt_conf_sftp_espejo.Rows[0]["HOST"] + "");
            }

            // Genera y Transmite archivo xlsx de evidencias enviadas al día...
            var configuration = new ConfigurationBuilder()
                          .AddUserSecrets(Assembly.GetExecutingAssembly())
                             .Build();

            fechaConsultaRPT_1 = DateTime.Now.ToString("dd/MM/yyyy");
            fechaConsultaRPT_2 = DateTime.Now.ToString("dd/MM/yyyy");

            //DEBBUGG:
            //fechaConsultaRPT_1 = "14/07/2025";
            //fechaConsultaRPT_2 = "14/07/2025";

            //Espejo:
            rpt_espejo_ruta_generacion = ftn_genera_reporte_evidencias(fechaConsultaRPT_1, fechaConsultaRPT_2, "E");

            //Cliente:
            if (configuration["gen_rpt_evid_cli"].Equals("1"))
            {
                rpt_cliente_ruta_generacion = ftn_genera_reporte_evidencias(fechaConsultaRPT_1, fechaConsultaRPT_2, "C");
            }



            if (rpt_espejo_ruta_generacion != "")
            {
                //Espejo:
                obj_envio_sftp_espejo = new envio_sftp(obj_utilerias.nvl("" + dt_conf_sftp_espejo.Rows[0]["HOST"]), Convert.ToInt16(dt_conf_sftp_espejo.Rows[0]["PUERTO"]), obj_utilerias.nvl("" + dt_conf_sftp_espejo.Rows[0]["USUARIO"]), obj_utilerias.nvl("" + dt_conf_sftp_espejo.Rows[0]["PASSWORD"]));
                if (obj_envio_sftp_espejo.sftp_transmitir_archivo(rpt_espejo_ruta_generacion, "" + dt_conf_sftp_espejo.Rows[0]["CARPETA_REMOTA"] + "/Reportes/", Path.GetFileName(rpt_espejo_ruta_generacion), true, out error_transmision) == true)
                {
                    obj_utilerias.EscribirLog(ruta_log_espejo, "Cliente:" + my_cliente + " - [EXITO]. Conectado al repositorio espejo con IP: " + dt_conf_sftp_espejo.Rows[0]["HOST"] + "");
                    obj_utilerias.EscribirLog(ruta_log_espejo, "Cliente:" + my_cliente + " - [EXITO]. Archivo" + "" + dt_conf_sftp_espejo.Rows[0]["CARPETA_REMOTA"] + "/Reportes/" + Path.GetFileName(rpt_espejo_ruta_generacion) + " transmitido al repositorio espejo.");
                    obj_utilerias.EscribirLog(ruta_log_espejo, "Cliente:" + my_cliente + " - [EXITO]. Desconectado del repositorio espejo con IP: " + dt_conf_sftp_espejo.Rows[0]["HOST"] + "");
                    arrayArchivosCorrectosEspejo.Add("" + dt_conf_sftp_espejo.Rows[0]["CARPETA_REMOTA"] + "/Reportes/" + Path.GetFileName(rpt_espejo_ruta_generacion));
                    if (File.Exists(rpt_espejo_ruta_generacion))
                    {
                        File.Delete(rpt_espejo_ruta_generacion);
                    }
                }
                else
                {
                    obj_utilerias.EscribirLog(ruta_log_espejo, "Cliente:" + my_cliente + " - [ERROR]. Archivo" + "" + dt_conf_sftp_espejo.Rows[0]["CARPETA_REMOTA"] + "/Reportes/" + Path.GetFileName(rpt_espejo_ruta_generacion) + " NO transmitido al repositorio espejo a causa del siguiente error: \n" + error_transmision);
                    arrayArchivosIncorrectosEspejo.Add("" + dt_conf_sftp_espejo.Rows[0]["CARPETA_REMOTA"] + "/Reportes/" + Path.GetFileName(rpt_espejo_ruta_generacion) + " --> ERROR: " + error_transmision);
                }
            }

            if (configuration["gen_rpt_evid_cli"].Equals("1"))
            {
                if (rpt_cliente_ruta_generacion != "")
                {
                    //Cliente:
                    obj_envio_sftp_cliente = new envio_sftp(obj_utilerias.nvl("" + dt_conf_sftp_cliente.Rows[0]["HOST"]), Convert.ToInt16(dt_conf_sftp_cliente.Rows[0]["PUERTO"]), obj_utilerias.nvl("" + dt_conf_sftp_cliente.Rows[0]["USUARIO"]), obj_utilerias.nvl("" + dt_conf_sftp_cliente.Rows[0]["PASSWORD"]));
                    if (obj_envio_sftp_cliente.sftp_transmitir_archivo(rpt_cliente_ruta_generacion, "" + dt_conf_sftp_cliente.Rows[0]["CARPETA_REMOTA"] + "Reportes/", Path.GetFileName(rpt_cliente_ruta_generacion), true, out error_transmision) == true)
                    {
                        obj_utilerias.EscribirLog(ruta_log_cliente, "Cliente:" + my_cliente + " - [EXITO]. Conectado al repositorio cliente con IP: " + dt_conf_sftp_cliente.Rows[0]["HOST"] + "");
                        obj_utilerias.EscribirLog(ruta_log_cliente, "Cliente:" + my_cliente + " - [EXITO]. Archivo" + "" + dt_conf_sftp_cliente.Rows[0]["CARPETA_REMOTA"] + "Reportes/" + Path.GetFileName(rpt_cliente_ruta_generacion) + " transmitido al repositorio cliente.");
                        obj_utilerias.EscribirLog(ruta_log_cliente, "Cliente:" + my_cliente + " - [EXITO]. Desconectado del repositorio cliente con IP: " + dt_conf_sftp_cliente.Rows[0]["HOST"] + "");
                        arrayArchivosCorrectosCliente.Add("" + dt_conf_sftp_cliente.Rows[0]["CARPETA_REMOTA"] + "Reportes/" + Path.GetFileName(rpt_cliente_ruta_generacion));
                        if (File.Exists(rpt_cliente_ruta_generacion))
                        {
                            File.Delete(rpt_cliente_ruta_generacion);
                        }
                    }
                    else
                    {
                        obj_utilerias.EscribirLog(ruta_log_cliente, "Cliente:" + my_cliente + " - [ERROR]. Archivo" + "" + dt_conf_sftp_cliente.Rows[0]["CARPETA_REMOTA"] + "Reportes/" + Path.GetFileName(rpt_cliente_ruta_generacion) + " NO transmitido al repositorio cliente a causa del siguiente error: \n" + error_transmision);
                        arrayArchivosIncorrectosCliente.Add("" + dt_conf_sftp_cliente.Rows[0]["CARPETA_REMOTA"] + "Reportes/" + Path.GetFileName(rpt_cliente_ruta_generacion) + " --> ERROR: " + error_transmision);
                    }
                }
            }

            //Cliente:
            ftn_notifica_envios(arrayArchivosCorrectosCliente, arrayArchivosIncorrectosCliente, false);

            //Espejo:
            ftn_notifica_envios(arrayArchivosCorrectosEspejo, arrayArchivosIncorrectosEspejo, true);
        }
        private string ftn_init_var(long id_cron, String cliente, string carpeta_espejo, String fecha_1, String fecha_2, string[,] pargral, DataTable dtNotif, int vs)
        {

            // *** Inicializa variables locales...
            my_id_cron = id_cron;
            my_cliente = cliente;
            my_carpeta_espejo = carpeta_espejo;
            //Formateo de fechas a DD/MM/YYYY/:
            fecha1 = DateTime.ParseExact(fecha_1, "MM/dd/yyyy", CultureInfo.InvariantCulture);
            fecha2 = DateTime.ParseExact(fecha_2, "MM/dd/yyyy", CultureInfo.InvariantCulture);
            my_fecha_1 = fecha1.ToString("dd/MM/yyyy");
            my_fecha_2 = fecha2.ToString("dd/MM/yyyy");
            my_pargral = pargral;
            my_vs = vs;
            rpt_espejo_ruta_generacion = "";
            rpt_cliente_ruta_generacion = "";


            var configuration = new ConfigurationBuilder()
                          .AddUserSecrets(Assembly.GetExecutingAssembly())
                             .Build();
            if (configuration["ruta_log_evid_sftp"] != "")
            {
                if (!Directory.Exists(configuration["ruta_log_evid_sftp"]))
                {
                    Directory.CreateDirectory(configuration["ruta_log_evid_sftp"]);
                }
                ruta_log_cliente = configuration["ruta_log_evid_sftp"] + "\\Log_SFTP_CLIENTE_" + DateTime.Now.ToString("dd-MM-yyyy") + ".txt";
                ruta_log_espejo = configuration["ruta_log_evid_sftp"] + "\\Log_SFTP_ESPEJO_" + DateTime.Now.ToString("dd-MM-yyyy") + ".txt";
            }
            else
            {
                ruta_log_cliente = "Log_SFTP_CLIENTE_" + DateTime.Now.ToString("dd-MM-yyyy") + ".txt";
                ruta_log_espejo = "Log_SFTP_ESPEJO_" + DateTime.Now.ToString("dd-MM-yyyy") + ".txt";
            }



            if (dtNotif.Rows.Count > 0)
            {
                string? asunto;
                string? tipo_not;
                string? id_not;

                for (int i = 0; i < dtNotif.Rows.Count; i++)
                {
                    asunto = dtNotif.Rows[i]["ASUNTO"].ToString();
                    tipo_not = dtNotif.Rows[i]["ID_TIPO_NOTIFICACION"].ToString();
                    id_not = dtNotif.Rows[i]["ID_NOTIFICACION"].ToString();

                    //Asuntos y contactos  Cliente:
                    if (tipo_not.Equals("5"))
                    {
                        asunto_mail_exito_cliente = asunto;
                        (contmail_exito_cliente, EmailCC_exito_cliente, EmailBCC_exito_cliente) = obj_utilerias.getDestinaratios(id_not);
                    }
                    if (tipo_not.Equals("6"))
                    {
                        asunto_mail_error_cliente = asunto;
                        (contmail_error_cliente, EmailCC_error_cliente, EmailBCC_error_cliente) = obj_utilerias.getDestinaratios(id_not);
                    }

                    //Asuntos y contactos  Espejo:
                    if (tipo_not.Equals("3"))
                    {
                        asunto_mail_exito_espejo = asunto;
                        (contmail_exito_espejo, EmailCC_exito_espejo, EmailBCC_exito_espejo) = obj_utilerias.getDestinaratios(id_not);
                    }
                    if (tipo_not.Equals("4"))
                    {
                        asunto_mail_error_espejo = asunto;
                        (contmail_error_espejo, EmailCC_error_espejo, EmailBCC_error_espejo) = obj_utilerias.getDestinaratios(id_not);
                    }
                }
            }


            obj_utilerias.EscribirLog(ruta_log_cliente, "Cliente:" + my_cliente + " - :::::::::::::::::::::::::::::::::::::::::::::::::::::: Inicialización de proceso ::::::::::::::::::::::::::::::::::::::::::::::::::::::");
            obj_utilerias.EscribirLog(ruta_log_espejo, "Cliente:" + my_cliente + " - :::::::::::::::::::::::::::::::::::::::::::::::::::::: Inicialización de proceso ::::::::::::::::::::::::::::::::::::::::::::::::::::::");


            return "";
        }
        private string ftn_notifica_envios(ArrayList archivos_correctos, ArrayList archivos_incorrectos, bool es_espejo = false)
        {
            string msg_proceso;
            int count;

            msg_proceso = "";
            count = 0;


            if (es_espejo == false)
            {
                if (archivos_correctos.Count > 0 || archivos_incorrectos.Count > 0)
                {
                    msg_proceso = "Buen día, \n\n";
                    if (archivos_correctos.Count > 0)
                    {
                        if (archivos_correctos.Count == 1)
                        {
                            msg_proceso = msg_proceso + "Se transmitio el siguiente archivo al repositorio SFTP del cliente. \n";
                        }
                        else if (archivos_correctos.Count > 1)
                        {
                            msg_proceso = msg_proceso + "Se transmitieron los siguientes " + archivos_correctos.Count + " archivos al repositorio SFTP del cliente. \n";
                        }

                        msg_proceso = msg_proceso + "Fecha de busqueda: Del " + my_fecha_1 + " al " + my_fecha_2 + "\n";
                        msg_proceso = msg_proceso + "Cliente: " + my_cliente + "\n\n";

                        count = 1;
                        for (int j = 0; j < archivos_correctos.Count; j++)
                        {
                            msg_proceso = msg_proceso + "(" + count + ") " + archivos_correctos[j].ToString().Replace("//", "/") + "\n";
                            count = count + 1;
                        }
                        count = 0;
                        msg_proceso = msg_proceso + "\n\n";
                    }

                    if (archivos_incorrectos.Count > 0)
                    {
                        if (archivos_incorrectos.Count == 1)
                        {
                            msg_proceso = msg_proceso + "El siguiente archivo no se envio al repositorio SFTP del cliente. ¡Favor de verificar el error!.\n";
                        }
                        else if (archivos_incorrectos.Count > 1)
                        {
                            msg_proceso = msg_proceso + "Los siguientes " + archivos_incorrectos.Count + " archivos NO se enviaron al repositorio SFTP del cliente. ¡Favor de verificar los errores!. \n";
                        }

                        msg_proceso = msg_proceso + "Fecha de busqueda: Del " + my_fecha_1 + " al " + my_fecha_2 + "\n";
                        msg_proceso = msg_proceso + "Cliente: " + my_cliente + "\n\n";

                        count = 1;
                        for (int j = 0; j < archivos_incorrectos.Count; j++)
                        {
                            msg_proceso = msg_proceso + "(" + count + ") " + archivos_incorrectos[j].ToString().Replace("//", "/") + "\n";
                            count = count + 1;
                        }
                        count = 0;

                    }

                    msg_proceso = msg_proceso + "\n\nSaludos, \n" + "Server Reports.";

                    return obj_envio_correo.send_mail(asunto_mail_exito_cliente, contmail_exito_cliente, msg_proceso, [], EmailCC_exito_cliente, false, EmailBCC_exito_cliente);
                }
            }
            else
            {
                if (archivos_correctos.Count > 0 || archivos_incorrectos.Count > 0)
                {
                    msg_proceso = "Buen día, \n\n";
                    if (archivos_correctos.Count > 0)
                    {
                        if (archivos_correctos.Count == 1)
                        {
                            msg_proceso = msg_proceso + "Se transmitio el siguiente archivo al repositorio SFTP espejo. \n";
                        }
                        else if (archivos_correctos.Count > 1)
                        {
                            msg_proceso = msg_proceso + "Se transmitieron los siguientes " + archivos_correctos.Count + " archivos al repositorio SFTP espejo. \n";
                        }

                        msg_proceso = msg_proceso + "Fecha de busqueda: Del " + my_fecha_1 + " al " + my_fecha_2 + "\n";
                        msg_proceso = msg_proceso + "Cliente: " + my_cliente + "\n\n";

                        count = 1;
                        for (int j = 0; j < archivos_correctos.Count; j++)
                        {
                            msg_proceso = msg_proceso + "(" + count + ") " + archivos_correctos[j].ToString().Replace("//", "/") + "\n";
                            count = count + 1;
                        }
                        count = 0;
                        msg_proceso = msg_proceso + "\n\n";
                    }

                    if (archivos_incorrectos.Count > 0)
                    {
                        if (archivos_incorrectos.Count == 1)
                        {
                            msg_proceso = msg_proceso + "El siguiente archivo no se envio al repositorio SFTP espejo. ¡Favor de verificar el error!. \n";
                        }
                        else if (archivos_incorrectos.Count > 1)
                        {
                            msg_proceso = msg_proceso + "Los siguientes " + archivos_incorrectos.Count + " archivos no se enviaron al repositorio SFTP espejo. ¡Favor de verificar los errores!. \n";
                        }

                        msg_proceso = msg_proceso + "Fecha de busqueda: Del " + my_fecha_1 + " al " + my_fecha_2 + "\n";
                        msg_proceso = msg_proceso + "Cliente: " + my_cliente + "\n\n";

                        count = 1;
                        for (int j = 0; j < archivos_incorrectos.Count; j++)
                        {
                            msg_proceso = msg_proceso + "(" + count + ") " + archivos_incorrectos[j].ToString().Replace("//", "/") + "\n";
                            count = count + 1;
                        }
                        count = 0;
                    }

                    //if (transmite_solo_espejo == true)
                    //{
                    //    msg_proceso = msg_proceso + "\n\n¡NOTA: PARA ESTE CLIENTE AUN NO SE HA CONFIGURADO UN REPOSITORIO SFTP EXTERNO, SOLO SE TRANSMITE AL ESPEJO!";
                    //}

                    msg_proceso = msg_proceso + "\n\nSaludos, \n" + "Server Reports.";

                    return obj_envio_correo.send_mail(asunto_mail_exito_espejo, contmail_exito_cliente, msg_proceso, [], EmailCC_exito_cliente, false, EmailBCC_exito_cliente);
                }
            }
            return "";
        }
        private bool ftn_registra_status_bita(string id_archivo, string status_cliente, string status_espejo, string observaciones)
        {
            string observaciones_limitado = observaciones.Length > 1999 ? observaciones.Substring(0, 1999) : observaciones;

            par_st = new string[6, 4];
            par_st[0, 0] = "i";
            par_st[0, 1] = "i";
            par_st[0, 2] = "p_Id_Archivo";
            par_st[0, 3] = id_archivo;

            par_st[1, 0] = "i";
            par_st[1, 1] = "i";
            par_st[1, 2] = "p_Estatus_Cliente";
            //par_st[1, 3] = status_cliente;
            if (status_cliente != "")
            {
                par_st[1, 3] = status_cliente;
            }
            else
            {
                par_st[1, 3] = null;
            }

            par_st[2, 0] = "i";
            par_st[2, 1] = "i";
            par_st[2, 2] = "p_Estatus_Espejo";
            // par_st[2, 3] = status_espejo;
            if (status_espejo != "")
            {
                par_st[2, 3] = status_espejo;
            }
            else
            {
                par_st[2, 3] = null;
            }

            par_st[3, 0] = "i";
            par_st[3, 1] = "v";
            par_st[3, 2] = "p_Observaciones";
            par_st[3, 3] = observaciones_limitado;

            par_st[4, 0] = "o";
            par_st[4, 1] = "v";
            par_st[4, 2] = "p_Mensaje";
            par_st[4, 3] = "msg";

            par_st[5, 0] = "o";
            par_st[5, 1] = "i";
            par_st[5, 2] = "p_Codigo_Error";
            par_st[5, 3] = "cod";

            my_datos_sp.sql = "SC_RS_DIST.SPG_ENVIO_EVIDENCIAS_SFTP.P_INS_STATUS_BITA_EES_ARCHIVOS";

            my_datos_sp = obj_dm.datos_sp([my_datos_sp.sql], par_st, 3, my_vs);

            return false;
        }
        private string ftn_genera_reporte_evidencias(string fecha_consulta_rpt_1, string fecha_consulta_rpt_2, string tipo_status)
        {

            //DEBBUGG:
            //fecha_consulta_rpt_1 = "10/07/2025";
            //fecha_consulta_rpt_2 = "10/07/2025";

            try
            {
                string? ruta_reporte;
                ruta_reporte = "";

                par_st = new string[7, 4];

                par_st[0, 0] = "i";
                par_st[0, 1] = "i";
                par_st[0, 2] = "p_Num_Cliente";
                par_st[0, 3] = my_cliente;

                par_st[1, 0] = "i";
                par_st[1, 1] = "v";
                par_st[1, 2] = "p_Fecha_Inicio";
                par_st[1, 3] = fecha_consulta_rpt_1;

                par_st[2, 0] = "i";
                par_st[2, 1] = "v";
                par_st[2, 2] = "p_Fecha_Fin";
                par_st[2, 3] = fecha_consulta_rpt_2;

                par_st[3, 0] = "i";
                par_st[3, 1] = "v";
                par_st[3, 2] = "p_Tipo_Estatus";
                par_st[3, 3] = tipo_status;

                par_st[4, 0] = "o";
                par_st[4, 1] = "c";
                par_st[4, 2] = "p_Cur_Evidencias_Trans";
                par_st[4, 3] = null;

                par_st[5, 0] = "o";
                par_st[5, 1] = "v";
                par_st[5, 2] = "p_Mensaje";
                par_st[5, 3] = "msg";

                par_st[6, 0] = "o";
                par_st[6, 1] = "i";
                par_st[6, 2] = "p_Codigo_Error";
                par_st[6, 3] = "cod";

                my_datos_sp.sql = "SC_RS_DIST.SPG_ENVIO_EVIDENCIAS_SFTP.P_DAT_EVIDENCIAS_TRANSMITIDAS";
                my_datos_sp = obj_dm.datos_sp([my_datos_sp.sql], par_st, 3, my_vs);
                rpt_evid_transmit = DateTime.Now.ToString("yyyy-MM-dd") + "_" + my_cliente;
                dt_rpt_evid_transm = my_datos_sp.tb.Copy();

                if (my_datos_sp.codigo == "1" && dt_rpt_evid_transm.Rows.Count > 0)
                {
                    dt_rpt_evid_transm.TableName = "Evidencias";

                    ds_rpt_evid_transm = new DataSet(rpt_evid_transmit);
                    ds_rpt_evid_transm.Tables.Add(dt_rpt_evid_transm);

                    if (tipo_status == "E")
                    {
                        ruta_reporte = Path.Combine(Path.GetTempPath(), "rpt_espejo\\"); ;
                    }
                    else if (tipo_status == "C")

                    {
                        ruta_reporte = Path.Combine(Path.GetTempPath(), "rpt_cliente\\");
                    }

                    if (!Directory.Exists(ruta_reporte))
                    {
                        Directory.CreateDirectory(ruta_reporte);
                    }


                    rpt_evid_transmit = xls.CreateExcel_file(ds_rpt_evid_transm, null, rpt_evid_transmit, ruta_reporte);
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("Error al intentar generar el reporte de evidencias transmitidas: " + ex.ToString());
            }
            finally
            {
                if (dt_rpt_evid_transm != null)
                {
                    dt_rpt_evid_transm.Dispose();
                    GC.SuppressFinalize(dt_rpt_evid_transm);
                }
                if (ds_rpt_evid_transm != null)
                {
                    ds_rpt_evid_transm.Dispose();
                    GC.SuppressFinalize(ds_rpt_evid_transm);
                }

                if (rpt_evid_transmit != "")
                {
                    Console.WriteLine("El reporte de evidencias transmitidas fue generado exitosamente: " + rpt_evid_transmit);
                }

            }


            return rpt_evid_transmit;
        }



        private static void LlenarDataTablepPrueba(DataTable dataTable)
        {
            // Validar si las columnas no están definidas
            if (dataTable.Columns.Count == 0)
            {
                dataTable.Columns.Add("ID_ARCHIVO", typeof(int));
                dataTable.Columns.Add("ID_CLIENTE", typeof(int));
                dataTable.Columns.Add("RUTA_ORIGEN", typeof(string));
                dataTable.Columns.Add("RUTA_DESTINO_CLIENTE", typeof(string));
                dataTable.Columns.Add("RUTA_DESTINO_ESPEJO", typeof(string));
                dataTable.Columns.Add("NOMBRE_ORIGEN", typeof(string));
                dataTable.Columns.Add("NOMBRE_DESTINO", typeof(string));
                dataTable.Columns.Add("ID_STATUS_ENVIO_CLIENTE", typeof(string));
                dataTable.Columns.Add("ID_STATUS_ENVIO_ESPEJO", typeof(string));
                dataTable.Columns.Add("OBSERVACIONES", typeof(string));

            }

            // Llenar con datos de prueba
            dataTable.Rows.Add(6563, 22573, "D:\\TMP\\evidencias_test\\", "/logis/evidencias/22573/2023/12/", "/evidencia/Publica/Evidencias/Helvex/22573/2023/12/", "PRUEBA_DE_CARGA_SFTP_TEST_1.pdf", "9151896.pdf", "0", "0", "");
            dataTable.Rows.Add(6572, 22573, "D:\\TMP\\evidencias_test\\", "/logis/evidencias/22573/2024/01/", "/evidencia/Publica/Evidencias/Helvex/22573/2024/01/", "PRUEBA_DE_CARGA_SFTP_TEST_1 - copia.pdf", "9151947.pdf", "0", "0", "");
            dataTable.Rows.Add(6569, 22573, "D:\\TMP\\evidencias_test\\", "/logis/evidencias/22573/2023/12/", "/evidencia/Publica/Evidencias/Helvex/22573/2023/12/", "PRUEBA_DE_CARGA_SFTP_TEST_1 - copiaaaa.pdf", "9152187.pdf", "0", "0", "");
        }

    }
}
