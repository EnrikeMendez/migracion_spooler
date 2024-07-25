using System;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using System.Text;
using System.Threading.Tasks;
using DocumentFormat.OpenXml.EMMA;
using DocumentFormat.OpenXml.Vml;

namespace serverreports
{
    internal class web_fondo_fijo_mod
    {
        public string Fondo_fijo(string Archivo, string Empresa, string Divisa, string fecha, string[,] parins, string[,] contacmail, int vs)
        {
            DataTable dttmp = new DataTable();
            DM DM = new DM();

            int sw_error = 0;
            Utilerias util = new Utilerias();
            // envio_correo correo = new envio_correo();            
            //Excel xlsx = new Excel();
            //DataTable[] LisDT = new DataTable[1];
            //string[] LisDT_tit = new string[1];
            (string? codigo, string? msg, string? sql, DataTable? tb) datos_sp;
            string[,] html = new string[6, 2];
            string[,] par_st;
            par_st = new string[4, 4];
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
            dttmp = DM.sc_reportes_gen_rep_clave(vs);
            string rep_clave = util.Tcampo(dttmp, "GEN_REP_CLAVE");
            dttmp.Dispose();
            if (rep_clave == "")
            {
                datos_sp.codigo = "-20000";
                datos_sp.msg = "sc_reportes_gen_rep_clave : Error al llamar sc_reportes.gen_rep_clave";
            }          
            return "";
        }
    }
}
