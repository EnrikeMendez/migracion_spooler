using DocumentFormat.OpenXml.Bibliography;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Linq.Expressions;
using System.Text;
using System.Threading.Tasks;

namespace serverreports
{
    internal class dist_transfer_ftp_mod
    {
        public string dist_ftp_transfer(long id_cron, String cliente, String subcarpeta, String fecha_1, String fecha_2, string[,] pargral, int vs)
        {
            DM obj_dm = new DM();
            Utilerias obj_utilerias = new Utilerias();
            envio_correo obj_envio_correo = new envio_correo();
            DataTable dt_conf_sftp_cliente = new DataTable();

            string msg_error = "";
            Boolean transmite_cliente = false;
            Boolean transmite_espejo = false;


            string[,] par_st;
            (string? codigo, string? msg, string? sql, DataTable? tb) my_datos_sp;


            // SP consulta evidencias del periodo...
            //...


            // Cambio a server de archivos...
            subcarpeta = obj_utilerias.cambioIpServer(subcarpeta, "192.168.100.11", "192.168.100.4");


            // SP consulta configuracion Cliente...
            par_st = new string[6, 4];

            par_st[0, 0] = "i";
            par_st[0, 1] = "v";
            par_st[0, 2] = "p_modalidad";
            par_st[0, 3] = "SFTP_ESPEJO_EVID_CLI";

            par_st[1, 0] = "i";
            par_st[1, 1] = "v";
            par_st[1, 2] = "p_cliente";
            par_st[1, 3] = cliente;

            par_st[2, 0] = "i";
            par_st[2, 1] = "v";
            par_st[2, 2] = "p_es_espejo";
            par_st[2, 3] = "False";

            par_st[3, 0] = "o";
            par_st[3, 1] = "c";
            par_st[3, 2] = "p_Cur_..."; //?

            par_st[4, 0] = "o";
            par_st[4, 1] = "v";
            par_st[4, 2] = "p_Mensaje";
            par_st[4, 3] = "msg";

            par_st[5, 0] = "o";
            par_st[5, 1] = "i";
            par_st[5, 2] = "p_Codigo_Error";
            par_st[5, 3] = "cod";

            my_datos_sp.sql = "SP_RS_DIST_SFTP_ACCESOS_CLI..."; //?

            my_datos_sp = obj_dm.datos_sp([my_datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]), vs);
            dt_conf_sftp_cliente = my_datos_sp.tb;

            //En caso de error...
            if (my_datos_sp.codigo == "0")
            {
                msg_error = "No se encontró la configuración de conexión al repositorio SFTP del Cliente " + cliente + ".";
                obj_envio_correo.send_error_mail1( "("+id_cron+") - " + " [Error] " + "Envio de evidencias SFTP cliente " + cliente, [pargral[0, 1]], msg_error + "\n\n" + "Saludos, \n" + "Server Reports.");
                transmite_cliente = false;
            }
            else
            {
                transmite_cliente = true;
            }


            // SP consulta configuracion Espejo...
            //...



            //Crea los directorios locales faltantes: \\192.168.100.4\reportes\web_reports\Archivos_FTP....
            if (transmite_cliente == true)
            {
                if (obj_utilerias.genera_arbol_carpetas_local(subcarpeta) != false)
                {
                    transmite_cliente = true;
                }
                else {
                    msg_error = "Ocurrió un error al intentar crear los directorios locales en el servidor para almacenar temporalmente las evidencias del cliente " + cliente + ".";
                    obj_envio_correo.send_error_mail1("(" + id_cron + ") - " + " [Error] " + "Envio de evidencias SFTP cliente " + cliente, [pargral[0, 1]], msg_error + "\n\n" + "Saludos, \n" + "Server Reports.");
                    transmite_cliente = false;
                }
            }



            //Conexion a Repositorio Cliente...
            if (transmite_cliente == true)
            {
                envio_sftp obj_envio_sftp = new envio_sftp("192.168.200.137", 22, "tester", "password");
                if (obj_envio_sftp.sftp_conexion() != false)
                {
                    transmite_cliente = true;
                }
                else
                {
                    transmite_cliente = false;
                }
            }

            //Conexion a Repositorio Espejo...
            if (transmite_espejo == true)
            {

            }




            //Crea los directorios remotos faltantes del Repositorio Cliente: /logis/evidencias/....
            if (transmite_cliente == true)
            {

            }

            //Crea los directorios remotos faltantes del Repositorio Espejo: /logis/evidencias/....
            if (transmite_espejo == true)
            {

            }





            return "";
        }
    }
}
