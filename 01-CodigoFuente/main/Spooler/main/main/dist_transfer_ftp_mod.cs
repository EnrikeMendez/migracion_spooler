using DocumentFormat.OpenXml.Bibliography;
using DocumentFormat.OpenXml.Presentation;
using DocumentFormat.OpenXml.Wordprocessing;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Linq;
using System.Linq.Expressions;
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
        private envio_correo obj_envio_correo = new envio_correo();
        private ArrayList arrayArchivosCorrectosCliente = new ArrayList();
        private ArrayList arrayArchivosCorrectosEspejo = new ArrayList();
        private ArrayList arrayArchivosIncorrectosCliente = new ArrayList();
        private ArrayList arrayArchivosIncorrectosEspejo = new ArrayList();

        private envio_sftp? obj_envio_sftp_cliente;
        private envio_sftp? obj_envio_sftp_espejo;
        private string[,]? par_st;
        private DateTime fecha1;
        private DateTime fecha2;

        private long? my_id_cron;
        private string? my_cliente;
        private string? my_fecha_1;
        private string? my_fecha_2;
        string[,]? my_pargral;
        private int my_vs;
        private bool? transmite_cliente = false;
        private bool? transmite_espejo = false;
        private bool? transmite_solo_espejo = false;
        private string? msg_proceso;
        (string? codigo, string? msg, string? sql, DataTable? tb) my_datos_sp;

        public string dist_ftp_transfer(long id_cron, String cliente, String fecha_1, String fecha_2, string[,] pargral, int vs)
        {
            // *** Inicializa variables locales...
            my_id_cron = id_cron;
            my_cliente = cliente;
            //Formateo de fechas a DD/MM/YYYY/:
            fecha1 = DateTime.ParseExact(fecha_1, "MM/dd/yyyy", CultureInfo.InvariantCulture);
            fecha2 = DateTime.ParseExact(fecha_2, "MM/dd/yyyy", CultureInfo.InvariantCulture);
            my_fecha_1 = fecha1.ToString("dd/MM/yyyy");
            my_fecha_2 = fecha2.ToString("dd/MM/yyyy");
            my_pargral = pargral;
            my_vs = vs;

            // (1) *** Se validan credenciales registradas en base de datos y se realiza la prueba de conexión al repositorio cliente y espejo.
            sub_valida_conexion_repositorio();

            // (2) *** Se consultan las evidencias a enviar por el periodo de fecha específico, si no hay evidencias por enviar se notifica sin evidencias.
            sub_consulta_evidencias();

            // (3) *** Si se encontraron evidencias por enviar, se conectará a cada repositorio (cliente / espejo) y las transmitirá, una vez transmitido todo, se notificará el resumen de lo enviado.
            sub_transmite_evidencias();

            return "";
        }

        public void sub_valida_conexion_repositorio()
        {
            string error;
            // SP consulta configuracion Cliente...
            par_st = new string[6, 4];

            par_st[0, 0] = "i";
            par_st[0, 1] = "v";
            par_st[0, 2] = "p_Modalidad";
            par_st[0, 3] = "EVIDENCIAS_CLIENTES";


            par_st[1, 0] = "i";
            par_st[1, 1] = "v";
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

            my_datos_sp.sql = "SC_RS_DIST.SPG_RS_DIST_EVIDENCIAS_SFTP.P_DAT_SFTP_ACCESOS_CLI";

            my_datos_sp = obj_dm.datos_sp([my_datos_sp.sql], par_st, Convert.ToInt32(my_pargral[13, 1]), my_vs);
            dt_conf_sftp_cliente = my_datos_sp.tb;

            //En caso de error...
            if (my_datos_sp.codigo != "1" || dt_conf_sftp_cliente.Rows.Count <= 0)
            {
                msg_proceso = "Buen día, \n\nNo se encontró registro de la configuración de conexión al repositorio SFTP del Cliente " + my_cliente + "." + "\n\n" + "Saludos, \n" + "Server Reports.";
                obj_envio_correo.send_mail("[" + my_id_cron + "] - " + " [Error] " + "Envio de evidencias SFTP Cliente " + my_cliente, [my_pargral[0, 1]], msg_proceso, [], [], false);
                transmite_cliente = false;
            }
            else
            {
                transmite_cliente = true;
            }


            // SP consulta configuracion Espejo...
            par_st = new string[6, 4];

            par_st[0, 0] = "i";
            par_st[0, 1] = "v";
            par_st[0, 2] = "p_Modalidad";
            par_st[0, 3] = "SFTP_ESPEJO_EVID_CLI";

            par_st[1, 0] = "i";
            par_st[1, 1] = "v";
            par_st[1, 2] = "p_Num_Cliente";
            par_st[1, 3] = "";

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

            my_datos_sp.sql = "SC_RS_DIST.SPG_RS_DIST_EVIDENCIAS_SFTP.P_DAT_SFTP_ACCESOS_CLI";

            my_datos_sp = obj_dm.datos_sp([my_datos_sp.sql], par_st, Convert.ToInt32(my_pargral[13, 1]), my_vs);
            dt_conf_sftp_espejo = my_datos_sp.tb;

            //En caso de error...
            if (my_datos_sp.codigo != "1" || dt_conf_sftp_espejo.Rows.Count <= 0)
            {
                msg_proceso = "Buen día, \n\nNo se encontró registro de la configuración de conexión al repositorio SFTP Espejo para el cliente " + my_cliente + "." + "\n\n" + "Saludos, \n" + "Server Reports.";
                obj_envio_correo.send_mail("[" + my_id_cron + "] - " + " [Error] " + "Envio de evidencias SFTP *** Espejo *** " + my_cliente, [my_pargral[0, 1]], msg_proceso, [], [], false);
                transmite_espejo = false;
            }
            else
            {
                transmite_espejo = true;
            }

            //Valida si el cliente tiene configurado solo el repositorio espejo, para solo transmitir una sola vez...
            if (transmite_cliente == true && transmite_espejo == true)
            {
                if ("" + dt_conf_sftp_cliente.Rows[0]["FTP_DIRECCION"] == "" + dt_conf_sftp_espejo.Rows[0]["FTP_DIRECCION"])
                {
                    transmite_solo_espejo = true;
                    transmite_cliente = false;
                }
            }

            if (transmite_solo_espejo == true)
            {
                //Prueba de Conexion a Repositorio Espejo...
                obj_envio_sftp_espejo = new envio_sftp(obj_utilerias.nvl("" + dt_conf_sftp_espejo.Rows[0]["FTP_DIRECCION"]), 22, obj_utilerias.nvl("" + dt_conf_sftp_espejo.Rows[0]["FTP_LOGIN"]), obj_utilerias.nvl("" + dt_conf_sftp_espejo.Rows[0]["FTP_PWD"]));
                if (obj_envio_sftp_espejo.sftp_conexion(out error) != false)
                {
                    transmite_espejo = true;
                }
                else
                {
                    msg_proceso = "Buen día, \n\nSe intento establecer una conexión al repositorio SFTP espejo, pero no se obtuvo éxito: \n" + error + "\n\n" + "Saludos, \n" + "Server Reports.";
                    obj_envio_correo.send_mail("[" + my_id_cron + "] - " + " [Error] " + "Envio de evidencias SFTP *** Espejo *** " + my_cliente, [my_pargral[0, 1]], msg_proceso, [], [], false);
                    transmite_espejo = false;
                }
                obj_envio_sftp_espejo.sftp_desconexion();
            }
            else
            {
                //Prueba de Conexion a Repositorio Cliente...
                if (transmite_cliente == true)
                {
                    obj_envio_sftp_cliente = new envio_sftp(obj_utilerias.nvl("" + dt_conf_sftp_cliente.Rows[0]["FTP_DIRECCION"]), 22, obj_utilerias.nvl("" + dt_conf_sftp_cliente.Rows[0]["FTP_LOGIN"]), obj_utilerias.nvl("" + dt_conf_sftp_cliente.Rows[0]["FTP_PWD"]));

                    //¡PRUEBA LOCAL!:
                    //obj_envio_sftp_cliente = new envio_sftp("192.168.200.137", 22, "tester", "password");

                    if (obj_envio_sftp_cliente.sftp_conexion(out error) != false)
                    {
                        transmite_cliente = true;
                    }
                    else
                    {
                        msg_proceso = "Buen día, \n\nSe intento establecer una conexión al repositorio SFTP del cliente " + my_cliente + ", pero no se obtuvo éxito: \n" + error + "\n\n" + "Saludos, \n" + "Server Reports.";
                        obj_envio_correo.send_mail("[" + my_id_cron + "] - " + " [Error] " + "Envio de evidencias SFTP Cliente " + my_cliente, [my_pargral[0, 1]], msg_proceso, [], [], false);
                        transmite_cliente = false;
                    }
                    obj_envio_sftp_cliente.sftp_desconexion();
                }

                //Prueba de Conexion a Repositorio Espejo...
                if (transmite_espejo == true)
                {
                    obj_envio_sftp_espejo = new envio_sftp(obj_utilerias.nvl("" + dt_conf_sftp_espejo.Rows[0]["FTP_DIRECCION"]), 22, obj_utilerias.nvl("" + dt_conf_sftp_espejo.Rows[0]["FTP_LOGIN"]), obj_utilerias.nvl("" + dt_conf_sftp_espejo.Rows[0]["FTP_PWD"]));
                    if (obj_envio_sftp_espejo.sftp_conexion(out error) != false)
                    {
                        transmite_espejo = true;
                    }
                    else
                    {
                        msg_proceso = "Buen día, \n\nSe intento establecer una conexión al repositorio SFTP espejo, pero no se obtuvo éxito: \n" + error + "\n\n" + "Saludos, \n" + "Server Reports.";
                        obj_envio_correo.send_mail("[" + my_id_cron + "] - " + " [Error] " + "Envio de evidencias SFTP *** Espejo *** " + my_cliente, [my_pargral[0, 1]], msg_proceso, [], [], false);
                        transmite_espejo = false;
                    }
                    obj_envio_sftp_espejo.sftp_desconexion();
                }
            }
        }
        public void sub_consulta_evidencias()
        {
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

                my_datos_sp.sql = "SC_RS_DIST.SPG_RS_DIST_EVIDENCIAS_SFTP.P_DAT_EVIDENCIAS_CLIENTE";

                my_datos_sp = obj_dm.datos_sp([my_datos_sp.sql], par_st, Convert.ToInt32(my_pargral[13, 1]), my_vs);

                dt_evid_transmitir = my_datos_sp.tb;

                //¡PRUEBA LOCAL!:
                //LlenarDataTablepPrueba(dt_evid_transmitir);

                if (dt_evid_transmitir.Rows.Count <= 0)
                {
                    //Cuando no se encuentren evidencias a transmitir se notifica... 

                    if (transmite_solo_espejo == true)
                    {
                        //Repo Espejo:
                        msg_proceso = "Buen día, \n\nNo se encontraron evidencias a transmitir al repositorio SFTP Espejo del cliente " + my_cliente + ".\n\n" + "Fecha de busqueda: Del " + my_fecha_1 + " al " + my_fecha_2 + "\n\n" + "¡NOTA: PARA ESTE CLIENTE AUN NO SE HA CONFIGURADO UN REPOSITORIO SFTP EXTERNO, SOLO SE TRANSMITE AL ESPEJO!. \n\n\n" + "Saludos, \n" + "Server Reports.";
                        obj_envio_correo.send_mail("[" + my_id_cron + "] - " + " [Exito] " + "Envio de evidencias SFTP *** Espejo *** " + my_cliente, [my_pargral[0, 1]], msg_proceso, [], [], false);
                    }
                    else
                    {
                        //Repo Cliente:
                        msg_proceso = "Buen día, \n\nNo se encontraron evidencias a transmitir al repositorio SFTP del cliente " + my_cliente + ".\n\n" + "Fecha de busqueda: Del " + my_fecha_1 + " al " + my_fecha_2 + "\n\n" + "Saludos, \n" + "Server Reports.";
                        obj_envio_correo.send_mail("[" + my_id_cron + "] - " + " [Exito] " + "Envio de evidencias SFTP Cliente " + my_cliente, [my_pargral[0, 1]], msg_proceso, [], [], false);

                        //Repo Espejo:
                        msg_proceso = "Buen día, \n\nNo se encontraron evidencias a transmitir al repositorio SFTP Espejo del cliente " + my_cliente + ".\n\n" + "Fecha de busqueda: Del " + my_fecha_1 + " al " + my_fecha_2 + "\n\n" + "Saludos, \n" + "Server Reports.";
                        obj_envio_correo.send_mail("[" + my_id_cron + "] - " + " [Exito] " + "Envio de evidencias SFTP *** Espejo *** " + my_cliente, [my_pargral[0, 1]], msg_proceso, [], [], false);
                    }
                }
            }
        }
        public void sub_transmite_evidencias()
        {
            if (dt_evid_transmitir.Rows.Count > 0)
            {
                //Cuando si se encuentren evidencias transmitimos a cada repositorio...

                //¡PRUEBA ESPEJO!:
                //obj_envio_sftp_cliente = new envio_sftp("192.168.100.33", 22, "usr_rs_sftp_dist", "cBH6oGF8dr");
                if (transmite_solo_espejo == true)

                {
                    obj_envio_sftp_espejo = new envio_sftp(obj_utilerias.nvl("" + dt_conf_sftp_espejo.Rows[0]["FTP_DIRECCION"]), 22, obj_utilerias.nvl("" + dt_conf_sftp_espejo.Rows[0]["FTP_LOGIN"]), obj_utilerias.nvl("" + dt_conf_sftp_espejo.Rows[0]["FTP_PWD"]));
                }
                else
                {
                    obj_envio_sftp_cliente = new envio_sftp(obj_utilerias.nvl("" + dt_conf_sftp_cliente.Rows[0]["FTP_DIRECCION"]), 22, obj_utilerias.nvl("" + dt_conf_sftp_cliente.Rows[0]["FTP_LOGIN"]), obj_utilerias.nvl("" + dt_conf_sftp_cliente.Rows[0]["FTP_PWD"]));
                    obj_envio_sftp_espejo = new envio_sftp(obj_utilerias.nvl("" + dt_conf_sftp_espejo.Rows[0]["FTP_DIRECCION"]), 22, obj_utilerias.nvl("" + dt_conf_sftp_espejo.Rows[0]["FTP_LOGIN"]), obj_utilerias.nvl("" + dt_conf_sftp_espejo.Rows[0]["FTP_PWD"]));
                }

                bool bandera1;
                bool bandera2;
                string error_transmision;

                for (int i = 0; i < dt_evid_transmitir.Rows.Count; i++)
                {
                    bandera1 = false;
                    bandera2 = false;

                    if (transmite_solo_espejo == true)
                    {
                        if (obj_envio_sftp_espejo.sftp_transmitir_archivo("" + dt_evid_transmitir.Rows[i]["RUTA_ORIGEN"] + dt_evid_transmitir.Rows[i]["NOMBRE_ORIGEN"], "" + dt_evid_transmitir.Rows[i]["RUTA_DESTINO_ESPEJO"], "" + dt_evid_transmitir.Rows[i]["NOMBRE_DESTINO"], true, out error_transmision) == true)
                        {
                            arrayArchivosCorrectosEspejo.Add("" + dt_evid_transmitir.Rows[i]["RUTA_DESTINO_ESPEJO"] + dt_evid_transmitir.Rows[i]["NOMBRE_DESTINO"]);
                            ftn_registra_status_bita("" + dt_evid_transmitir.Rows[i]["ID_ARCHIVO"], "2", "Transmitido solo al repositorio espejo, aun no se configura repositorio cliente." + error_transmision);
                        }
                        else
                        {
                            arrayArchivosIncorrectosEspejo.Add("" + dt_evid_transmitir.Rows[i]["RUTA_DESTINO_ESPEJO"] + dt_evid_transmitir.Rows[i]["NOMBRE_DESTINO"] + " --> ERROR: " + error_transmision);
                            ftn_registra_status_bita("" + dt_evid_transmitir.Rows[i]["ID_ARCHIVO"], "3", "Error al intentar transmitir al repositorio espejo: " + error_transmision);
                        }
                    }
                    else
                    {

                        if (transmite_cliente == true)
                        {
                            if (obj_envio_sftp_cliente.sftp_transmitir_archivo("" + dt_evid_transmitir.Rows[i]["RUTA_ORIGEN"] + dt_evid_transmitir.Rows[i]["NOMBRE_ORIGEN"], "" + dt_evid_transmitir.Rows[i]["RUTA_DESTINO_CLIENTE"], "" + dt_evid_transmitir.Rows[i]["NOMBRE_DESTINO"], true, out error_transmision) == true)
                            {
                                arrayArchivosCorrectosCliente.Add("" + dt_evid_transmitir.Rows[i]["RUTA_DESTINO_CLIENTE"] + dt_evid_transmitir.Rows[i]["NOMBRE_DESTINO"]);
                                ftn_registra_status_bita("" + dt_evid_transmitir.Rows[i]["ID_ARCHIVO"], "1", "Transmitido al repositorio cliente.");
                                bandera1 = true;
                            }
                            else
                            {
                                arrayArchivosIncorrectosCliente.Add("" + dt_evid_transmitir.Rows[i]["RUTA_DESTINO_CLIENTE"] + dt_evid_transmitir.Rows[i]["NOMBRE_DESTINO"] + " --> ERROR: " + error_transmision);
                                ftn_registra_status_bita("" + dt_evid_transmitir.Rows[i]["ID_ARCHIVO"], "3", "Error al intentar transmitir al repositorio cliente: " + error_transmision);
                                bandera2 = true;
                            }
                        }

                        if (transmite_espejo == true)
                        {
                            if (obj_envio_sftp_espejo.sftp_transmitir_archivo("" + dt_evid_transmitir.Rows[i]["RUTA_ORIGEN"] + dt_evid_transmitir.Rows[i]["NOMBRE_ORIGEN"], "" + dt_evid_transmitir.Rows[i]["RUTA_DESTINO_ESPEJO"], "" + dt_evid_transmitir.Rows[i]["NOMBRE_DESTINO"], true, out error_transmision) == true)
                            {
                                arrayArchivosCorrectosEspejo.Add("" + dt_evid_transmitir.Rows[i]["RUTA_DESTINO_ESPEJO"] + dt_evid_transmitir.Rows[i]["NOMBRE_DESTINO"]);

                                if (bandera1 == true)
                                {
                                    ftn_registra_status_bita("" + dt_evid_transmitir.Rows[i]["ID_ARCHIVO"], "2", "Transmitido al repositorio cliente y espejo.");
                                }
                                else
                                {
                                    ftn_registra_status_bita("" + dt_evid_transmitir.Rows[i]["ID_ARCHIVO"], "2", "Transmitido al repositorio espejo.");
                                }
                            }
                            else
                            {
                                arrayArchivosIncorrectosEspejo.Add("" + dt_evid_transmitir.Rows[i]["RUTA_DESTINO_ESPEJO"] + dt_evid_transmitir.Rows[i]["NOMBRE_DESTINO"] + " --> ERROR: " + error_transmision);

                                if (bandera2 == true)
                                {
                                    ftn_registra_status_bita("" + dt_evid_transmitir.Rows[i]["ID_ARCHIVO"], "3", "Error al intentar transmitir al repositorio cliente y espejo: " + error_transmision);
                                }
                                else
                                {
                                    ftn_registra_status_bita("" + dt_evid_transmitir.Rows[i]["ID_ARCHIVO"], "3", "Error al intentar transmitir al repositorio espejo: " + error_transmision);
                                }

                            }
                        }
                    }
                }

                if (transmite_solo_espejo == true)
                {
                    obj_envio_sftp_espejo.sftp_liberar_recursos();
                }
                else
                {
                    obj_envio_sftp_cliente.sftp_liberar_recursos();
                    obj_envio_sftp_espejo.sftp_liberar_recursos();
                }

                //Notifica la cantidad de evidencias que se transmitieron...

                if (transmite_solo_espejo == true)
                {
                    //Proceso Espejo:
                    ftn_notifica_envios(arrayArchivosCorrectosEspejo, arrayArchivosIncorrectosEspejo, true);
                }
                else
                {
                    //Proceso Cliente:
                    ftn_notifica_envios(arrayArchivosCorrectosCliente, arrayArchivosIncorrectosCliente, false);

                    //Proceso Espejo:
                    ftn_notifica_envios(arrayArchivosCorrectosEspejo, arrayArchivosIncorrectosEspejo, true);
                }
            }
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
                            msg_proceso = msg_proceso + "Se transmitio la siguiente evidencia al repositorio SFTP del cliente. \n";
                        }
                        else if (archivos_correctos.Count > 1)
                        {
                            msg_proceso = msg_proceso + "Se transmitieron las siguientes " + archivos_correctos.Count + " evidencias al repositorio SFTP del cliente. \n";
                        }

                        msg_proceso = msg_proceso + "Fecha de busqueda: Del " + my_fecha_1 + " al " + my_fecha_2 + "\n";
                        msg_proceso = msg_proceso + "Cliente: " + my_cliente + "\n\n";

                        count = 1;
                        for (int j = 0; j < archivos_correctos.Count; j++)
                        {
                            msg_proceso = msg_proceso + "(" + count + ") " + archivos_correctos[j] + "\n";
                            count = count + 1;
                        }
                        count = 0;
                        msg_proceso = msg_proceso + "\n\n";
                    }

                    if (archivos_incorrectos.Count > 0)
                    {
                        if (archivos_incorrectos.Count == 1)
                        {
                            msg_proceso = msg_proceso + "La siguiente evidencia no se envio al repositorio SFTP del cliente. ¡Favor de verificar el error!.\n";
                        }
                        else if (archivos_incorrectos.Count > 1)
                        {
                            msg_proceso = msg_proceso + "Las siguientes " + archivos_incorrectos.Count + " evidencias NO se enviaron al repositorio SFTP del cliente. ¡Favor de verificar los errores!. \n";
                        }

                        msg_proceso = msg_proceso + "Fecha de busqueda: Del " + my_fecha_1 + " al " + my_fecha_2 + "\n";
                        msg_proceso = msg_proceso + "Cliente: " + my_cliente + "\n\n";

                        count = 1;
                        for (int j = 0; j < archivos_incorrectos.Count; j++)
                        {
                            msg_proceso = msg_proceso + "(" + count + ") " + archivos_incorrectos[j] + "\n";
                            count = count + 1;
                        }
                        count = 0;

                    }

                    msg_proceso = msg_proceso + "\n\nSaludos, \n" + "Server Reports.";

                    return obj_envio_correo.send_mail("[" + my_id_cron + "] - " + " [Exito] " + "Envio de evidencias SFTP Cliente " + my_cliente, [my_pargral[0, 1]], msg_proceso, [], [], false);
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
                            msg_proceso = msg_proceso + "Se transmitio la siguiente evidencia al repositorio SFTP espejo. \n";
                        }
                        else if (archivos_correctos.Count > 1)
                        {
                            msg_proceso = msg_proceso + "Se transmitieron las siguientes " + archivos_correctos.Count + " evidencias al repositorio SFTP espejo. \n";
                        }

                        msg_proceso = msg_proceso + "Fecha de busqueda: Del " + my_fecha_1 + " al " + my_fecha_2 + "\n";
                        msg_proceso = msg_proceso + "Cliente: " + my_cliente + "\n\n";

                        count = 1;
                        for (int j = 0; j < archivos_correctos.Count; j++)
                        {
                            msg_proceso = msg_proceso + "(" + count + ") " + archivos_correctos[j] + "\n";
                            count = count + 1;
                        }
                        count = 0;
                    }

                    if (archivos_incorrectos.Count > 0)
                    {
                        if (archivos_incorrectos.Count == 1)
                        {
                            msg_proceso = msg_proceso + "La siguiente evidencia no se envio al repositorio SFTP espejo. ¡Favor de verificar el error!. \n";
                        }
                        else if (archivos_incorrectos.Count > 1)
                        {
                            msg_proceso = msg_proceso + "Las siguientes " + archivos_incorrectos.Count + " evidencias no se enviaron al repositorio SFTP espejo. ¡Favor de verificar los errores!. \n";
                        }

                        msg_proceso = msg_proceso + "Fecha de busqueda: Del " + my_fecha_1 + " al " + my_fecha_2 + "\n";
                        msg_proceso = msg_proceso + "Cliente: " + my_cliente + "\n\n";

                        count = 1;
                        for (int j = 0; j < archivos_incorrectos.Count; j++)
                        {
                            msg_proceso = msg_proceso + "(" + count + ") " + archivos_incorrectos[j] + "\n";
                            count = count + 1;
                        }
                        count = 0;
                    }

                    if (transmite_solo_espejo == true)
                    {
                        msg_proceso = msg_proceso + "\n\n¡NOTA: PARA ESTE CLIENTE AUN NO SE HA CONFIGURADO UN REPOSITORIO SFTP EXTERNO, SOLO SE TRANSMITE AL ESPEJO!";
                    }

                    msg_proceso = msg_proceso + "\n\nSaludos, \n" + "Server Reports.";

                    return obj_envio_correo.send_mail("[" + my_id_cron + "] - " + " [Exito] " + "Envio de evidencias SFTP *** Espejo *** " + my_cliente, [my_pargral[0, 1]], msg_proceso, [], [], false);
                }
            }
            return "";
        }
        private bool ftn_registra_status_bita(string id_archivo, string status, string observaciones)
        {
            string observaciones_limitado = observaciones.Length > 1999 ? observaciones.Substring(0, 1999) : observaciones;

            par_st = new string[5, 4];
            par_st[0, 0] = "i";
            par_st[0, 1] = "i";
            par_st[0, 2] = "p_Id_Archivo";
            par_st[0, 3] = id_archivo;

            par_st[1, 0] = "i";
            par_st[1, 1] = "i";
            par_st[1, 2] = "p_Estatus";
            par_st[1, 3] = status;

            par_st[2, 0] = "i";
            par_st[2, 1] = "v";
            par_st[2, 2] = "p_Observaciones";
            par_st[2, 3] = observaciones_limitado;

            par_st[3, 0] = "o";
            par_st[3, 1] = "v";
            par_st[3, 2] = "p_Mensaje";
            par_st[3, 3] = "msg";

            par_st[4, 0] = "o";
            par_st[4, 1] = "i";
            par_st[4, 2] = "p_Codigo_Error";
            par_st[4, 3] = "cod";

            my_datos_sp.sql = "SC_RS_DIST.SPG_RS_DIST_EVIDENCIAS_SFTP.P_INS_STATUS_EVIDENCIA_BITA";

            my_datos_sp = obj_dm.datos_sp([my_datos_sp.sql], par_st, Convert.ToInt32(my_pargral[13, 1]), my_vs);

            //En caso de error...
            if (my_datos_sp.codigo != "1")
            {
                msg_proceso = "Se presento un error al intentar actualizar el estatus de envio de la evidencia " + id_archivo + ": \n\n" + my_datos_sp.msg + "\n\n" + "." + "\n\n" + "Saludos, \n" + "Server Reports.";
                obj_envio_correo.send_mail("[" + my_id_cron + "] - " + " [Error] " + "Envio de evidencias SFTP Cliente " + my_cliente, [my_pargral[0, 1]], msg_proceso);
            }

            return false;
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
                dataTable.Columns.Add("CREATED_BY", typeof(string));
                dataTable.Columns.Add("DATE_CREATED", typeof(string));
                dataTable.Columns.Add("MODIFIED_BY", typeof(string));
                dataTable.Columns.Add("DATE_MODIFIED", typeof(string));
                dataTable.Columns.Add("STATUS", typeof(string));
                dataTable.Columns.Add("OBSERVACIONES", typeof(string));

            }

            // //Publica/Evidencias/Cliente_Pruebas// --> cliente (Mi Local)
            // /evidencias/ --> cliente (SFTP Infra)
            // /Publica/Evidencias/Cliente_Pruebas/ --> Espejo (Mi Local)

            // Llenar con datos de prueba

            dataTable.Rows.Add(26948, 22573, "D:\\TMP\\evidencias_test\\", "/evidencias/20123/2025/05/", "/pruebas_spooler_espejo/Publica/Evidencias/pruebas/20123/2025/05/", "PRUEBA_DE_CARGA_SFTP_TEST_1.pdf", "1234567890.pdf", "SPOOLER-DESA", "15/05/2025", "", "", "2", "");
            dataTable.Rows.Add(26950, 22573, "D:\\TMP\\evidencias_test\\", "/evidencias/20123/2025/05/", "/pruebas_spooler_espejo/Publica/Evidencias/pruebas/20123/2025/05/", "PRUEBA_DE_CARGA_SFTP_TEST_1 - copia.pdf", "1234567891.pdf", "SPOOLER-DESA", "15/05/2025", "", "", "0", "");
            //dataTable.Rows.Add(13866, 20123, "D:\\TMP\\evidencias_test\\", "/pruebas_spooler_cliente/logis/evidencias/20123/2025/06/", "/pruebas_spooler_espejo/Publica/Evidencias/pruebas/20123/2025/06/", "PRUEBA_DE_CARGA_SFTP_TEST_1 - copia (9).pdf", "1234567892.pdf", "SPOOLER-DESA", "15/05/2025", "", "", "0", "");
            //dataTable.Rows.Add(13867, 20123, "D:\\TMP\\evidencias_test\\", "/pruebas_spooler_cliente/logis/evidencias/20123/2025/06/", "/pruebas_spooler_espejo/Publica/Evidencias/pruebas/20123/2025/06/", "PRUEBA_DE_CARGA_SFTP_TEST_1 - copia (8).pdf", "1234567893.pdf", "SPOOLER-DESA", "15/05/2025", "", "", "0", "");
            //dataTable.Rows.Add(13868, 20123, "D:\\TMP\\evidencias_test\\", "/pruebas_spooler_cliente/logis/evidencias/20123/2025/06/", "/pruebas_spooler_espejo/Publica/Evidencias/pruebas/20123/2025/06/", "PRUEBA_DE_CARGA_SFTP_TEST_1 - copia (7).pdf", "1234567894.pdf", "SPOOLER-DESA", "15/05/2025", "", "", "0", "");
            //dataTable.Rows.Add(13869, 20123, "D:\\TMP\\evidencias_test\\", "/pruebas_spooler_cliente/logis/evidencias/20123/2024/05/", "/pruebas_spooler_espejo/Publica/Evidencias/pruebas/20123/2024/05/", "PRUEBA_DE_CARGA_SFTP_TEST_1 - copia (6).pdf", "1234567895.pdf", "SPOOLER-DESA", "15/05/2025", "", "", "0", "");
            //dataTable.Rows.Add(13870, 20123, "D:\\TMP\\evidencias_test\\", "/pruebas_spooler_cliente/logis/evidencias/20123/2024/05/", "/pruebas_spooler_espejo/Publica/Evidencias/pruebas/20123/2024/05/", "PRUEBA_DE_CARGA_SFTP_TEST_1 - copia (5).pdf", "1234567896.pdf", "SPOOLER-DESA", "15/05/2025", "", "", "0", "");
            //dataTable.Rows.Add(13871, 20123, "D:\\TMP\\evidencias_test\\", "/pruebas_spooler_cliente/logis/evidencias/20123/2024/05/", "/pruebas_spooler_espejo/Publica/Evidencias/pruebas/20123/2024/05/", "PRUEBA_DE_CARGA_SFTP_TEST_1 - copia (4).pdf", "1234567897.pdf", "SPOOLER-DESA", "15/05/2025", "", "", "0", "");
            //dataTable.Rows.Add(13872, 20123, "D:\\TMP\\evidencias_test\\", "/pruebas_spooler_cliente/logis/evidencias/20123/2024/05/", "/pruebas_spooler_espejo/Publica/Evidencias/pruebas/20123/2024/05/", "PRUEBA_DE_CARGA_SFTP_TEST_1 - copia (3).pdf", "1234567898.pdf", "SPOOLER-DESA", "15/05/2025", "", "", "0", "");
            //dataTable.Rows.Add(13873, 20123, "D:\\TMP\\evidencias_test\\", "/pruebas_spooler_cliente/logis/evidencias/20123/2024/06/", "/pruebas_spooler_espejo/Publica/Evidencias/pruebas/20123/2024/06/", "PRUEBA_DE_CARGA_SFTP_TEST_1 - copia (2).pdf", "1234567899.pdf", "SPOOLER-DESA", "15/05/2025", "", "", "0", "");

            //error:
            dataTable.Rows.Add(26949, 22573, "D:\\TMP\\evidencias_test\\", "/evidencias/pruebas/20123/2024/06/", "/pruebas_spooler_espejo/Publica/Evidencias/pruebas/20123/2024/06/", "PRUEBA_DE_CARGA_SFTP_TEST_1 - copia (10).pdf", "1234567810.pdf", "SPOOLER-DESA", "15/05/2025", "", "", "0", "");

            //dataTable.Rows.Add(13875, 20123, "D:\\TMP\\evidencias_test\\", "/pruebas_spooler_cliente/logis/evidencias/20123/2024/07/", "/pruebas_spooler_espejo/Publica/Evidencias/pruebas/20123/2024/07/", "PRUEBA_DE_CARGA_SFTP_TEST_1 - copia (5).pdf", "12345678991.pdf", "SPOOLER-DESA", "15/05/2025", "", "", "0", "");
            //dataTable.Rows.Add(13876, 20123, "D:\\TMP\\evidencias_test\\", "/pruebas_spooler_cliente/logis/evidencias/20123/2024/08/", "/pruebas_spooler_espejo/Publica/Evidencias/pruebas/20123/2024/08/", "PRUEBA_DE_CARGA_SFTP_TEST_1 - copia (4).pdf", "12345678992.pdf", "SPOOLER-DESA", "15/05/2025", "", "", "0", "");
            dataTable.Rows.Add(26951, 22573, "D:\\TMP\\evidencias_test\\", "/evidencias/20123/2024/09/", "/pruebas_spooler_espejo/Publica/Evidencias/pruebas/20123/2024/09/", "PRUEBA_DE_CARGA_SFTP_TEST_1 - copia (3).pdf", "12345678993.pdf", "SPOOLER-DESA", "15/05/2025", "", "", "0", "");
            //dataTable.Rows.Add(13878, 20123, "D:\\TMP\\evidencias_test\\", "/pruebas_spooler_cliente/logis/evidencias/20123/2024/10/", "/pruebas_spooler_espejo/Publica/Evidencias/pruebas/20123/2024/10/", "PRUEBA_DE_CARGA_SFTP_TEST_1 - copia (2).pdf", "12345678994.pdf", "SPOOLER-DESA", "15/05/2025", "", "", "0", "");

        }


    }
}
