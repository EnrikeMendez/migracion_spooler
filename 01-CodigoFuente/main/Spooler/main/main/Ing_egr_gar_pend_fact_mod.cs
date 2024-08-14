using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data;

namespace serverreports
{
    internal class Ing_egr_gar_pend_fact_mod
    {

        public (string[] LisDT_tit, DataTable[] LisDT, string arch) Ing_egr_gar_pend_fact(string[,] file_name, string Empresa, string Divisa, string fecha, string[,] parins, string[] contacmail, int vs)
        {
            DataTable dttmp = new DataTable();
            DM DM = new DM();
            (string[] LisDT_tit, DataTable[] LisDT, string arch) inf;

            int sw_error = 0;
            Utilerias util = new Utilerias();
            // envio_correo correo = new envio_correo();            
            Excel xlsx = new Excel();
            DataTable[] LisDT = new DataTable[6];
            string[] LisDT_tit = new string[6];
            (string? codigo, string? msg, string? sql, DataTable? tb) datos_sp;
            string[,] html = new string[6, 2];
            string arch = file_name[0, 0];
            string[,] par_st;

            par_st = new string[5, 4];

            par_st[0, 0] = "i";
            par_st[0, 1] = "v";
            par_st[0, 2] = "p_USUARIO";
            par_st[0, 3] = "USUARIO_WEB_ORFEO2";

            par_st[1, 0] = "i";
            par_st[1, 1] = "v";
            par_st[1, 2] = "p_FECHA";
            if (fecha == "")
                par_st[1, 3] = null;
            else
                par_st[1, 3] = fecha;
            par_st[2, 0] = "o";
            par_st[2, 1] = "c";
            par_st[2, 2] = "p_Cur_BIMESTRAL";
            par_st[3, 0] = "o";
            par_st[3, 1] = "v";
            par_st[3, 2] = "p_Mensaje";
            par_st[3, 3] = "msg";
            par_st[4, 0] = "o";
            par_st[4, 1] = "i";
            par_st[4, 2] = "p_Codigo_Error";
            par_st[4, 3] = "cod";
            datos_sp.sql = "SC_RS.SPG_RS_COEX_DAF_REPORTES.P_DAT_RESUMEN_CLIENTES_BIM";
            datos_sp = DM.datos_sp([datos_sp.sql], par_st, vs);
            LisDT[0] = datos_sp.tb;
            LisDT_tit[0] = "Resumen";


            par_st = new string[5, 4];
            par_st[0, 0] = "i";
            par_st[0, 1] = "v";
            par_st[0, 2] = "p_USUARIO";
            par_st[0, 3] = "USUARIO_WEB_ORFEO2";
            par_st[1, 0] = "i";
            par_st[1, 1] = "v";
            par_st[1, 2] = "p_FECHA";
            if (fecha == "")
                par_st[1, 3] = null;
            else
                par_st[1, 3] = fecha;
            par_st[1, 3] = "07/08/2024";
            par_st[2, 0] = "o";
            par_st[2, 1] = "c";
            par_st[2, 2] = "p_Cur_RES_MES";
            par_st[3, 0] = "o";
            par_st[3, 1] = "v";
            par_st[3, 2] = "p_Mensaje";
            par_st[3, 3] = "msg";
            par_st[4, 0] = "o";
            par_st[4, 1] = "i";
            par_st[4, 2] = "p_Codigo_Error";
            par_st[4, 3] = "cod";
            datos_sp.sql = "SC_RS.SPG_RS_COEX_DAF_REPORTES.P_DAT_RESUMEN_CLIENTES_MES";
            datos_sp = DM.datos_sp([datos_sp.sql], par_st, vs);
            LisDT[1] = datos_sp.tb;
            LisDT_tit[1] = "Resumen";

            par_st = new string[4, 4];
            par_st[0, 0] = "i";
            par_st[0, 1] = "v";
            par_st[0, 2] = "p_USUARIO";
            par_st[0, 3] = "USUARIO_WEB_ORFEO2";
            par_st[1, 0] = "o";
            par_st[1, 1] = "c";
            par_st[1, 2] = "p_Cur_MAS_FINANCIADOS";
            par_st[2, 0] = "o";
            par_st[2, 1] = "v";
            par_st[2, 2] = "p_Mensaje";
            par_st[2, 3] = "msg";
            par_st[3, 0] = "o";
            par_st[3, 1] = "i";
            par_st[3, 2] = "p_Codigo_Error";
            par_st[3, 3] = "cod";
            datos_sp.sql = "SC_RS.SPG_RS_COEX_DAF_REPORTES.P_DAT_RESUMEN_CLIENTES_MAS_FIN";
            datos_sp = DM.datos_sp([datos_sp.sql], par_st, vs);
            LisDT[2] = datos_sp.tb;
            LisDT_tit[2] = "Resumen";

            par_st = new string[5, 4];
            par_st[0, 0] = "i";
            par_st[0, 1] = "v";
            par_st[0, 2] = "p_USUARIO";
            par_st[0, 3] = "USUARIO_WEB_ORFEO2";
            par_st[1, 0] = "i";
            par_st[1, 1] = "v";
            par_st[1, 2] = "p_FECHA";
            if (fecha == "")
                par_st[1, 3] = null;
            else
                par_st[1, 3] = fecha;
            par_st[2, 0] = "o";
            par_st[2, 1] = "c";
            par_st[2, 2] = "p_Cur_Resumen_Clientes";
            par_st[3, 0] = "o";
            par_st[3, 1] = "v";
            par_st[3, 2] = "p_Mensaje";
            par_st[3, 3] = "msg";
            par_st[4, 0] = "o";
            par_st[4, 1] = "i";
            par_st[4, 2] = "p_Codigo_Error";
            par_st[4, 3] = "cod";
            datos_sp.sql = "SC_RS.SPG_RS_COEX_DAF_REPORTES.P_DAT_RESUMEN_CLIENTES";
            datos_sp = DM.datos_sp([datos_sp.sql], par_st, vs);
            LisDT[3] = datos_sp.tb;
            LisDT_tit[3] = "Resumen Cliente";

            par_st = new string[4, 4];
            par_st[0, 0] = "i";
            par_st[0, 1] = "v";
            par_st[0, 2] = "p_Usuario";
            par_st[0, 3] = "USUARIO_WEB_ORFEO2";
            par_st[1, 0] = "o";
            par_st[1, 1] = "c";
            par_st[1, 2] = "p_Cur_Resumen_Folios";
            par_st[2, 0] = "o";
            par_st[2, 1] = "v";
            par_st[2, 2] = "p_Mensaje";
            par_st[2, 3] = "msg";
            par_st[3, 0] = "o";
            par_st[3, 1] = "i";
            par_st[3, 2] = "p_Codigo_Error";
            par_st[3, 3] = "cod";
            //datos_sp.sql = "SC_RS.SPG_RS_COEX.P_DAT_FOLIOS_INGR_EGRE_PEN_FAC";
            datos_sp.sql = "SC_RS.SPG_RS_COEX_DAF_REPORTES.P_DAT_RESUMEN_FOLIOS";
            datos_sp = DM.datos_sp([datos_sp.sql], par_st, vs);
            LisDT[4] = datos_sp.tb;
            LisDT_tit[4] = "Folios";


            par_st = new string[7, 4];
            par_st[0, 0] = "i";
            par_st[0, 1] = "v";
            par_st[0, 2] = "pfecha_max";
            if (fecha == "")
            {
                par_st[0, 3] = null;
            }
            else
                par_st[0, 3] = fecha;
            //par_st[0, 3] = "07/08/2024";

            par_st[1, 0] = "i";
            par_st[1, 1] = "i";
            par_st[1, 2] = "p_Empclave";
            par_st[1, 3] = "55"; //cambiar
            //par_st[1, 3] = Empresa; 

            par_st[2, 0] = "i";
            par_st[2, 1] = "v";
            par_st[2, 2] = "p_Divisa";
            // par_st[2, 3] = "MXN";
            par_st[2, 3] = Divisa;

            par_st[3, 0] = "i";
            par_st[3, 1] = "v";
            par_st[3, 2] = "p_Usuario";
            // par_st[2, 3] = "MXN";
            par_st[3, 3] = "USUARIO_WEB_ORFEO2";

            dttmp = DM.sc_reportes_gen_rep_clave(vs);
            string rep_clave = util.Tcampo(dttmp, "GEN_REP_CLAVE");
            dttmp.Dispose();
            par_st[4, 0] = "o";
            par_st[4, 1] = "c";
            par_st[4, 2] = "p_Cur_Folios";
            par_st[5, 0] = "o";
            par_st[5, 1] = "v";
            par_st[5, 2] = "p_Mensaje";
            par_st[5, 3] = "msg";
            par_st[6, 0] = "o";
            par_st[6, 1] = "i";
            par_st[6, 2] = "p_Codigo_Error";
            par_st[6, 3] = "cod";
            //datos_sp.sql = "SC_RS.SPG_RS_COEX.P_DAT_FOLIOS";
            datos_sp.sql = "SC_RS.SPG_RS_COEX_DAF_REPORTES.P_DAT_FOLIOS";
            datos_sp = DM.datos_sp([datos_sp.sql], par_st, vs);
            LisDT[5] = datos_sp.tb;
            LisDT_tit[5] = "EGR_ING_Pend_Fact";       

            //xlsx.CrearExcel_file(LisDT, LisDT_tit, parins[12, 1] + file_name[0, 0], null);
            inf.LisDT_tit = LisDT_tit;
            inf.LisDT = LisDT;
            inf.arch = arch;
            return inf;
        }

        public string Ing_egr_gar_pend_fact_ante(string Archivo, string Empresa, string Divisa, string fecha, string[,] parins, string[] contacmail, int vs)
        {
            DataTable dttmp = new DataTable();
            DM DM = new DM();
            Utilerias util = new Utilerias();
            (string? codigo, string? msg, string? sql, DataTable? tb) datos_sp;
            string[,] par_st;
            par_st = new string[5, 4];
            par_st[0, 0] = "o";
            par_st[0, 1] = "v";
            par_st[0, 2] = "pmsg";
            par_st[0, 3] = "o";
            par_st[2, 0] = "i";
            par_st[2, 1] = "i";
            par_st[2, 2] = "pemp";
            par_st[2, 3] = "55";
            //par_st[2, 3] = Empresa;
            par_st[3, 0] = "i";
            par_st[3, 1] = "v";
            par_st[3, 2] = "pdiv";
            // par_st[3, 3] = "MXN";
            par_st[3, 3] = Divisa;
            par_st[4, 0] = "i";
            par_st[4, 1] = "v";
            par_st[4, 2] = "pfecha_max";
            if (fecha == "")
                par_st[4, 3] = null;
            else
                par_st[4, 3] = fecha;

            dttmp = DM.sc_reportes_gen_rep_clave(vs);
            string rep_clave = util.Tcampo(dttmp, "GEN_REP_CLAVE");
            dttmp.Dispose();
            if (rep_clave == "")
            {
                datos_sp.codigo = "-20000";
                datos_sp.msg = "sc_reportes_gen_rep_clave : Error al llamar sc_reportes.gen_rep_clave";
            }
            par_st[1, 0] = "i";
            par_st[1, 1] = "v";
            par_st[1, 2] = "prep_clave";
            // par_st[1, 3] = "2397C";
            par_st[1, 3] = rep_clave;

            datos_sp.sql = "LOGIS.SC_REPORTES.STEP_FOLIOS_EGR_ING_PEND";
            datos_sp = DM.datos_sp([datos_sp.sql, "1"], par_st, vs);
            string campox = datos_sp.sql;
            datos_sp.tb.Dispose();
            if (datos_sp.sql != "OK")
            {

   
                datos_sp.codigo = "-20000";
                datos_sp.msg = "sc_reportes_step_folios_egr_ing_pend : Error al llamar sc_reportes_step_folios_egr_ing_pend";
            }
            par_st = new string[4, 4];
            par_st[0, 0] = "i";
            par_st[0, 1] = "v";
            par_st[0, 2] = "p_Rep_Clave";
            par_st[0, 3] = rep_clave;
            par_st[1, 0] = "o";
            par_st[1, 1] = "c";
            par_st[1, 2] = "p_Cur_GSK";
            par_st[2, 0] = "o";
            par_st[2, 1] = "v";
            par_st[2, 2] = "p_Mensaje";
            par_st[2, 3] = "msg";
            par_st[3, 0] = "o";
            par_st[3, 1] = "i";
            par_st[3, 2] = "p_Codigo_Error";
            par_st[3, 3] = "cod";
            datos_sp.sql = "SC_DIST.SPG_RS_COEX.P_OBTEN_INGR_EGRE_PEN_FACT";
            datos_sp = DM.datos_sp([datos_sp.sql], par_st, vs);
            Console.WriteLine(util.Tdetalle(datos_sp.tb));

            string cp = "C:\\pc\\ruta_alterna\\ejeml\\";
            if (!Directory.Exists(cp))
            {
                Directory.CreateDirectory(cp);
            }

            DateTime DateTime = DateTime.Now;
            using (StreamWriter sw = File.CreateText(cp + " Detail.txt"))
            {

                sw.WriteLine(util.Tdetalle(datos_sp.tb));

            }

            return "";

        }
    }
}
