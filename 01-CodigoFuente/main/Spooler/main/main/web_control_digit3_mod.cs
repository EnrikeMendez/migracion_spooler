using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data;

namespace serverreports
{
    internal class web_control_digit3_mod
    {
        Utilerias util = new Utilerias();
        public (string[,] LisDT_tit, DataTable[] LisDT, string arch) control_digit3(string Carpeta, string[,] file_name, string Cliente, string cedis, string[,] pargral, int visible_sql)
        {
            (string? codigo, string? msg, string? sql, DataTable? tb) datos_sp;
            (string[,] LisDT_tit, DataTable[] LisDT, string arch) inf;
            string[,] par_st = new string[6, 4];
            DM DM = new DM();

            DataTable[] LisDT = new DataTable[8];
            string[,] LisDT_tit = new string[8, 2];
            string arch = file_name[0, 0];           

            string[,] array_ftp_arch;
            string[,] tipo1 = {
                                {"Indice tipos", ""},
                                {"1 / Reemplazar los espacios por guion bajo \"_\" ej: EXP 123456 debe escribirse EXP_123456", ""},
                                {"2 / Reemplazar las diagonales  \"/\" por guion medio  \"-\"ej: EXP  \"/\" 123456 debe escribirse EXP  \"-\" 123456", ""},
                                {"3 / Se pueden hacer combinaciones, ej: EXP / 123 456 debe ser EXP - 123_456", ""},
                                { "4 / Las facturas se pueden repetir entre varios cliente(ej Sony) entonces","" },
                                { "si pasa esto se puede agregar un guion bajo seguido del numero del cliente","" },
                                { "Ej: 123456 se convierte en 123456_2399 Si no hay duplicados no es necesario","" },
                                { "Facturas incorrectas:","" },
                                { "5 / En caso que el sistema no logre identificar un numero de factura, revisarlo en la consulta general de factura","" },
                                { "Si en esta pantalla no aparece el numero entonces a pesar de lo que menciona en la factura debe de haber sido documentada","" },
                                { "5 / Buscar en esta pantalla con el numero de pedido en lugar de la factura.","" },
                                { "7 / Buscar en la expedicion en la cual se fue esta factura, que numero menciona la hoja de expedicion o la nota de carga","" },
                                { "De ahi encontraran la factura y tal vez se cambio un numero.","" },
                                { "Entonces hay que ingresar este numero tal como lo menciona Orfeo.","" },

                              };
            LisDT[3] = util.genera_tab(tipo1);
            LisDT_tit[3, 0] = "Tips Anomalias||||1";
            //Lista Clientes Habilitados,StandBy
            par_st = new string[5, 4];
            string s_idrandom = util.Tcampo(DM.datos("Select ROUND(dbms_random.VALUE(1, 999999)) ID_RANDOM  from dual", 0, 0), "ID_RANDOM");
            s_idrandom = s_idrandom;
            par_st[0, 0] = "i";
            par_st[0, 1] = "i";
            par_st[0, 2] = "p_ID_RANDOM";
            par_st[0, 3] = s_idrandom;

            par_st[1, 0] = "i";
            par_st[1, 1] = "i";
            par_st[1, 2] = "p_Numero_Cliente";
            par_st[1, 3] = null;
            if (Cliente != "")
                par_st[1, 3] = Cliente;


            par_st[2, 0] = "o";
            par_st[2, 1] = "c";
            par_st[2, 2] = "p_CurREPORTE_GENERAL";
            par_st[2, 3] = null;

            par_st[3, 0] = "o";
            par_st[3, 1] = "v";
            par_st[3, 2] = "p_MENSAJE";
            par_st[3, 3] = "msg";

            par_st[4, 0] = "o";
            par_st[4, 1] = "i";
            par_st[4, 2] = "p_CODIGO_ERROR";
            par_st[4, 3] = "cod";

            datos_sp.sql = " SC_RS_DIST.SPG_RS_DIST_CONTROL_DIGITAL.P_DAT_REPORTE_GENERAL";
            datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]), visible_sql);
            LisDT[7] = datos_sp.tb;
            LisDT_tit[7, 0] = "General";
            /*-------------------------------------------*/

            par_st = new string[3, 4];
            par_st[0, 0] = "o";
            par_st[0, 1] = "c";
            par_st[0, 2] = "p_CurREPORTE_STAND_BY";
            par_st[0, 3] = null;

            par_st[1, 0] = "o";
            par_st[1, 1] = "v";
            par_st[1, 2] = "p_MENSAJE";
            par_st[1, 3] = "msg";

            par_st[2, 0] = "o";
            par_st[2, 1] = "i";
            par_st[2, 2] = "p_CODIGO_ERROR";
            par_st[2, 3] = "cod";

            datos_sp.sql = " SC_RS_DIST.SPG_RS_DIST_CONTROL_DIGITAL.P_DAT_REPORTE_STAND_BY";
            datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]), visible_sql);
            LisDT[6] = datos_sp.tb;
            LisDT_tit[6, 0] = "STAND_BY";
            /*-------------------------------------------*/

            par_st = new string[3, 4];
            par_st[0, 0] = "o";
            par_st[0, 1] = "c";
            par_st[0, 2] = "p_CurClientes_Hab_Oro";
            par_st[0, 3] = null;

            par_st[1, 0] = "o";
            par_st[1, 1] = "v";
            par_st[1, 2] = "p_MENSAJE";
            par_st[1, 3] = "msg";

            par_st[2, 0] = "o";
            par_st[2, 1] = "i";
            par_st[2, 2] = "p_CODIGO_ERROR";
            par_st[2, 3] = "cod";

            datos_sp.sql = " SC_RS_DIST.SPG_RS_DIST_CONTROL_DIGITAL.P_DAT_CLIENTES_HABILITADOS_ORO";
            datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]), visible_sql);
            LisDT[5] = datos_sp.tb;
            LisDT_tit[5, 0] = "Lista Clientes Habilitados";

            /*-------------------------------------------*/

            par_st[0, 0] = "o";
            par_st[0, 1] = "c";
            par_st[0, 2] = "p_CurRESUMEN_GENERAL";
            par_st[0, 3] = null;

            datos_sp.sql = "  SC_RS_DIST.SPG_RS_DIST_CONTROL_DIGITAL.P_DAT_RESUMEN_GENERAL";
            datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]), visible_sql);
            LisDT[0] = datos_sp.tb;
            LisDT_tit[0, 0] = "Resumen Comparativo||Totales evidencias";
            LisDT_tit[0, 1] = "1|3";

            par_st[0, 0] = "o";
            par_st[0, 1] = "c";
            par_st[0, 2] = "p_CurRESUMEN_STAND_BY";
            par_st[0, 3] = null;

            datos_sp.sql = " SC_RS_DIST.SPG_RS_DIST_CONTROL_DIGITAL.P_DAT_RESUMEN_STAND_BY";
            datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]), visible_sql);
            LisDT[1] = datos_sp.tb;
            LisDT_tit[1, 0] = "Resumen Comparativo||Evidencias StandBy o VAS"; ;
            LisDT_tit[1, 1] = "1|3";

            par_st[0, 0] = "o";
            par_st[0, 1] = "c";
            par_st[0, 2] = "p_CurRESUMEN_STATUS";
            par_st[0, 3] = null;

            datos_sp.sql = " SC_RS_DIST.SPG_RS_DIST_CONTROL_DIGITAL.P_DAT_RESUMEN_STATUS";
            datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]), visible_sql);
            LisDT[2] = datos_sp.tb;
            LisDT_tit[2, 0] = "Resumen Comparativo";
            LisDT_tit[2, 1] = "1|3";

            /*-------------------------------------------*/
            par_st = new string[5, 4];
            par_st[0, 0] = "i";
            par_st[0, 1] = "v";
            par_st[0, 2] = "p_PROCESO";
            par_st[0, 3] = "EVIDENCIA";
            par_st[1, 0] = "i";
            par_st[1, 1] = "v";
            par_st[1, 2] = "p_TLN";
            par_st[1, 3] = "N";
            par_st[2, 0] = "o";
            par_st[2, 1] = "c";
            par_st[2, 2] = "p_Cur_FTP_SUC_CARGA";
            par_st[2, 3] = null;

            par_st[3, 0] = "o";
            par_st[3, 1] = "v";
            par_st[3, 2] = "p_MENSAJE";
            par_st[3, 3] = "msg";

            par_st[4, 0] = "o";
            par_st[4, 1] = "i";
            par_st[4, 2] = "p_CODIGO_ERROR";
            par_st[4, 3] = "cod";
            datos_sp.sql = "SC_RS_DIST.SPG_RS_DIST_CONTROL_DIGITAL.P_DAT_FTP_SUCURSAL_CARGA";
            datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]), visible_sql);
             string[,] tipo11 = {
                                {"FDS_SUCURSAL","FDS_IP"        ,"FDS_LOGIN"       , "FDS_PSW"   ,"FDS_CARPETA_RAIZ"                         ,"DFDS_EMAILS"},
                                {"ACA"         ,"192.168.100.33","usr_rs_sftp_dist", "cBH6oGF8dr","/Publica/Evidencias/Fandeli/23213/2025/05","cedisacapulco@logis.com.mx"},
                                {"AGU"         ,"192.168.100.33","usr_rs_sftp_dist", "cBH6oGF8dr","/Publica/Evidencias/Fandeli/23213/2025/05","cedisacapulco@logis.com.mx"}
                              };
            datos_sp.tb = util.genera_tab(tipo11);

            string host;
            string username;
            string password;
            int pto = 22;
            string carpeta = "";
            string rep_carpeta = carpeta;

            if (datos_sp.tb.Rows.Count > 0)
            {
                string[,] tipo2 = new string[1, 6];
                tipo2[0, 0] = "Cedis";
                tipo2[0, 1] = "Archivo";
                tipo2[0, 2] = "Peso";
                tipo2[0, 3] = "Fecha";
                tipo2[0, 4] = "Carpeta";
                tipo2[0, 5] = "Contacto";
                array_ftp_arch = tipo2;
                for (global::System.Int32 i = 0; i < datos_sp.tb.Rows.Count; i++)
                {
                    host = util.Tcampo_reg(datos_sp.tb, "FDS_IP", i);
                    username = util.Tcampo_reg(datos_sp.tb, "FDS_LOGIN", i);
                    password = util.Tcampo_reg(datos_sp.tb, "FDS_PSW", i);
                    carpeta = util.Tcampo_reg(datos_sp.tb, "FDS_CARPETA_RAIZ", i);
                    rep_carpeta = carpeta;
                    if (carpeta.Substring(carpeta.Length - 1, 1) == "/")
                        rep_carpeta = carpeta.Substring(0, carpeta.Length - 1);
                    rep_carpeta = rep_carpeta.Substring(rep_carpeta.LastIndexOf("/") + 1, rep_carpeta.Length - (rep_carpeta.LastIndexOf("/") + 1));
                    envio_sftp sftp = new envio_sftp(util.nvl("" + host), pto, util.nvl("" + username), util.nvl("" + password));
                    array_ftp_arch = archivos(sftp.ListSftpDir(carpeta, 0), util.Tcampo_reg(datos_sp.tb, "FDS_SUCURSAL", i), util.Tcampo_reg(datos_sp.tb, "DFDS_EMAILS", i).Replace("@logis.com.mx", ""), array_ftp_arch, rep_carpeta);
                    carpeta = carpeta + "/archivos_incorrectos";
                    rep_carpeta = carpeta + "/archivos_incorr" +
                        "ectos";
                    if (carpeta.Substring(carpeta.Length - 1, 1) == "/")
                        rep_carpeta = carpeta.Substring(0, carpeta.Length - 1);
                    rep_carpeta = rep_carpeta.Substring(rep_carpeta.LastIndexOf("/") + 1, rep_carpeta.Length - (rep_carpeta.LastIndexOf("/") + 1));
                    array_ftp_arch = archivos(sftp.ListSftpDir(carpeta, 0), util.Tcampo_reg(datos_sp.tb, "FDS_SUCURSAL", i), util.Tcampo_reg(datos_sp.tb, "DFDS_EMAILS", i).Replace("@logis.com.mx", ""), array_ftp_arch, rep_carpeta);
                    sftp.sftp_liberar_recursos();                   
                }


                Console.WriteLine(util.Tdetalle(util.genera_tab(tipo2)));
                LisDT[4] = util.genera_tab(array_ftp_arch);
                LisDT_tit[4, 0] = "Lista Anomalias";
             }
            /*_------------------------------------------*/

            inf.LisDT = LisDT;
            inf.LisDT_tit = LisDT_tit;
            inf.arch = arch;
            return inf;

        }

        private string[,] archivos(string[,] arc, string suc, string cont, string[,] cona, string carp)
        {
            string[,] array_ftp_arch;
            decimal resultado;
            array_ftp_arch = new string[arc.GetLength(0) + cona.GetLength(0), 6];
            Array.Copy(cona, array_ftp_arch, cona.Length);
            for (int x = cona.GetLength(0); x < array_ftp_arch.GetLength(0); x++)
            {
                if (arc[x - cona.GetLength(0), 0] != "")
                {
                    array_ftp_arch[x, 0] = suc;
                    array_ftp_arch[x, 1] = arc[x - cona.GetLength(0), 0];
                    if (decimal.TryParse(arc[x - cona.GetLength(0), 1], out resultado))
                        array_ftp_arch[x, 2] = util.format_tam(resultado);
                    else
                        array_ftp_arch[x, 2] = arc[x - cona.GetLength(0), 1];
                    array_ftp_arch[x, 3] = arc[x - cona.GetLength(0), 2];
                    array_ftp_arch[x, 4] = carp;
                    array_ftp_arch[x, 5] = cont;
                }
            }
            return array_ftp_arch;
        }
    }
}
