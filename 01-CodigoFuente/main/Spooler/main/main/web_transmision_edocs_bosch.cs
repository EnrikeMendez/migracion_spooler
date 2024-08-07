using DocumentFormat.OpenXml.Drawing;
using DocumentFormat.OpenXml.Presentation;
using System;
using System.Collections.Generic;
using System.ComponentModel.Design;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static System.Runtime.InteropServices.JavaScript.JSType;

namespace serverreports
{
    internal class web_transmision_edocs_bosch
    {
        //5132031
        public string transmision_edocs_bosch(string Carpeta, string[,] file_name, string Clientes, string Fecha_1, string Fecha_2, string imp_exp, string tipo_doc, string[,] parins, string[] contacmail, int visible_sql)
        {
            int sw_error = 0;
            Utilerias util = new Utilerias();
            envio_correo correo = new envio_correo();
            DM DM = new DM();
            Excel xlsx = new Excel();
            DataTable[] LisDT = new DataTable[1];
            string[] arh;
            if (file_name[4, 0] == "1")
                arh = new string[2];
            else
                arh = new string[1];
            string[] LisDT_tit = new string[1]; ;
            string[] tab_impexp;
            string[,] html = new string[6, 1];
            string[,] par_st = new string[9, 4];
            par_st[0, 0] = "i";
            par_st[0, 1] = "i";
            par_st[0, 2] = "p_Num_Cliente";
            par_st[0, 3] = Clientes;

            par_st[1, 0] = "i";
            par_st[1, 1] = "v";
            par_st[1, 2] = "p_Fecha_Inicio";
            par_st[1, 3] = Fecha_1;

            par_st[2, 0] = "i";
            par_st[2, 1] = "v";
            par_st[2, 2] = "p_Fecha_Fin";
            par_st[2, 3] = Fecha_2;

            par_st[6, 0] = "o";
            par_st[6, 1] = "c";
            par_st[6, 2] = "p_Cur_Trans_COVE";

            par_st[7, 0] = "o";
            par_st[7, 1] = "v";
            par_st[7, 2] = "p_Mensaje";
            par_st[7, 3] = "msg";

            par_st[8, 0] = "o";
            par_st[8, 1] = "i";
            par_st[8, 2] = "p_Codigo_Error";
            par_st[8, 3] = "cod";
            string arch = file_name[0, 0];


            (string? codigo, string? msg, string? sql, DataTable? tb) datos_sp;
            try
            {
                datos_sp.sql = "SC_RS.SPG_RS_COEX.P_RS_TRANSMISION_COVE";
                if (imp_exp.Trim() == "1" || imp_exp.Trim() == "2")
                {
                    LisDT = new DataTable[1];
                    LisDT_tit = new string[1];

                    par_st[3, 0] = "i";
                    par_st[3, 1] = "v";
                    par_st[3, 2] = "p_Impexp";
                    par_st[3, 3] = imp_exp;

                    par_st[4, 0] = "i";
                    par_st[4, 1] = "v";
                    par_st[4, 2] = "p_Tipo_Doc";
                    par_st[4, 3] = tipo_doc;

                    par_st[5, 0] = "i";
                    par_st[5, 1] = "v";
                    par_st[5, 2] = "p_Tipo_Op";
                    par_st[5, 3] = imp_exp;


                    datos_sp = DM.datos_sp([datos_sp.sql], par_st, visible_sql);
                    Console.WriteLine(" Mensaje store :" + datos_sp.msg);
                    Console.WriteLine(" Codigo store :" + datos_sp.codigo);
                    LisDT[0] = datos_sp.tb;
                    LisDT_tit[0] = util.iff(imp_exp, "=", "1", "Importación", "Exportación");
                   // xlsx.CrearExcel_file(LisDT, LisDT_tit, Carpeta + file_name);
                    xlsx.CrearExcel_file(LisDT, LisDT_tit, Carpeta + file_name[0, 0], 1);
                }
                else
                {
                    LisDT = new DataTable[2];
                    LisDT_tit = new string[2];
                    par_st[3, 0] = "i";
                    par_st[3, 1] = "v";
                    par_st[3, 2] = "p_Impexp";
                    par_st[3, 3] = null;

                    par_st[4, 0] = "i";
                    par_st[4, 1] = "v";
                    par_st[4, 2] = "p_Tipo_Doc";
                    par_st[4, 3] = tipo_doc;

                    par_st[5, 0] = "i";
                    par_st[5, 1] = "v";
                    par_st[5, 2] = "p_Tipo_Op";
                    par_st[5, 3] = "2";

                    datos_sp = DM.datos_sp([datos_sp.sql], par_st, visible_sql);
                    LisDT[0] = datos_sp.tb;
                    LisDT_tit[0] = "Exportación";
                    Console.WriteLine(" Mensaje store :" + datos_sp.msg);
                    Console.WriteLine(" Codigo store :" + datos_sp.codigo);
                    par_st[3, 0] = "i";
                    par_st[3, 1] = "v";
                    par_st[3, 2] = "p_Impexp";
                    par_st[3, 3] = null;

                    par_st[4, 0] = "i";
                    par_st[4, 1] = "v";
                    par_st[4, 2] = "p_Tipo_Doc";
                    par_st[4, 3] = tipo_doc;

                    par_st[5, 0] = "i";
                    par_st[5, 1] = "v";
                    par_st[5, 2] = "p_Tipo_Op";
                    par_st[5, 3] = "1";
                    //datos_sp = DM.datos_sp([datos_sp.sql], visible_sql, Clientes, Fecha_1, Fecha_2, "null", tipo_doc, "1");
                    datos_sp = DM.datos_sp([datos_sp.sql], par_st, visible_sql);
                    LisDT[1] = datos_sp.tb;

                    LisDT_tit[1] = "Importación";
                    Console.WriteLine(" Mensaje store :" + datos_sp.msg);
                    Console.WriteLine(" Codigo store :" + datos_sp.codigo);
                    //xlsx.CrearExcel_file(LisDT, LisDT_tit, Carpeta + file_name[0, 0], 1);
                    xlsx.CrearExcel_file(LisDT, LisDT_tit, Carpeta + "\\" + arch);

                }

                arh[0] = Carpeta + "\\" + file_name[0, 0] + ".xlsx";
                file_name[0, 0] = file_name[0, 0] + ".xlsx";
                //if (file_name[4, 0] == "1")
                //   arh[1] = util.agregar_zip(arh, file_name[0, 0], Carpeta);
                if (file_name[4, 0] == "1")
                {
                    //arh[1] = util.agregar_zip_nv(file_name, arch, Carpeta);
                    html = util.agregar_zip(file_name, arch, Carpeta);
                    arh[1] = Carpeta + "\\" + arch + ".zip";
                }

                //file_name[0, 0] = file_name[0, 0] + ".xlsx";
                html = util.hexafile_nv(file_name, Carpeta, int.Parse(parins[9, 1]), arch, parins);
                util.replica_tem(arch, parins);
                string warning_message = DM.msg_temp(parins, visible_sql);
                string mensaje = correo.display_mail(parins[10, 1], warning_message, arch, html, Int32.Parse(parins[3, 1]), "");
                //  correo.send_mail("Report: < Logis transmision_edocs_bosch > Envio ok", [], "proceso correcto", [Carpeta + "\\" + file_name + ".xlsx"]);
                if (contacmail.Length > 0)
                {
                    correo.send_mail("Report: <" + html[1, 0] + "> created v2024", [], mensaje, arh);
                }
                DM.act_proceso(parins, visible_sql);
                util.borra_arch(arh, Carpeta);
            }

            catch (Exception ex1)
            {
                datos_sp.codigo = ex1.HResult.ToString();
                datos_sp.msg = ex1.Message;
                sw_error = 1;
            }
            if (sw_error == 1)
                correo.msg_error(html[1, 0], datos_sp.codigo, datos_sp.msg);
            LisDT[0].Clear();
            return sw_error.ToString();
        }



        public string transmision_edocs_bosch_ant(string Carpeta, string file_name, string Clientes, string Fecha_1, string Fecha_2, string imp_exp, string tipo_doc, int visible_sql)
        {
            int sw_error = 0;
            Utilerias util = new Utilerias();
            envio_correo correo = new envio_correo();
            DM DM = new DM();
            Excel xlsx = new Excel();
            DataTable[] LisDT = new DataTable[1];
            string[] LisDT_tit = new string[1]; ;
            string[] tab_impexp;

            (string? codigo, string? msg, string? sql, DataTable? tb) datos_sp;
            try
            {
                datos_sp.sql = "SC_DIST.SPG_RS_COEX.P_RS_TRANSMISION_COVE";
            if (imp_exp.Trim() == "1" || imp_exp.Trim() == "2")
            {
                LisDT = new DataTable[1];
                LisDT_tit = new string[1];
                datos_sp = DM.datos_sp_A([datos_sp.sql], visible_sql, Clientes, Fecha_1, Fecha_2, imp_exp, tipo_doc, imp_exp);
                Console.WriteLine(" Mensaje store :" + datos_sp.msg);
                Console.WriteLine(" Codigo store :" + datos_sp.codigo);
                LisDT[0] = datos_sp.tb;
                LisDT_tit[0] = util.iff(imp_exp, "=", "1", "Importación", "Exportación");
                xlsx.CrearExcel_file(LisDT, LisDT_tit, Carpeta + file_name);
            }
            else
            {
                LisDT = new DataTable[2];
                LisDT_tit = new string[2];
                datos_sp = DM.datos_sp_A([datos_sp.sql], visible_sql, Clientes, Fecha_1, Fecha_2, "null", tipo_doc, "2");
                LisDT[0] = datos_sp.tb;
                LisDT_tit[0] = "Exportación";
                Console.WriteLine(" Mensaje store :" + datos_sp.msg);
                Console.WriteLine(" Codigo store :" + datos_sp.codigo);
                datos_sp = DM.datos_sp_A([datos_sp.sql], visible_sql, Clientes, Fecha_1, Fecha_2, "null", tipo_doc, "1");
                LisDT[1] = datos_sp.tb;
                LisDT_tit[1] = "Importación";
                Console.WriteLine(" Mensaje store :" + datos_sp.msg);
                Console.WriteLine(" Codigo store :" + datos_sp.codigo);
                string[] arh = new string[2];
                
                xlsx.CrearExcel_file(LisDT, LisDT_tit, Carpeta + file_name, 1);
               correo.send_mail("Report: < Logis transmision_edocs_bosch > Envio ok", [], "proceso correcto", [Carpeta + "\\" + file_name + ".xlsx"]);
                }
        }
            catch (Exception ex1)
            {
                datos_sp.codigo = ex1.HResult.ToString();
                datos_sp.msg = ex1.Message;
                sw_error = 1;
            }
            if (sw_error == 1)
                correo.msg_error("edocs_bosch", datos_sp.codigo, datos_sp.msg);
            LisDT[0].Clear();
            return sw_error.ToString();
        }

        public string transmision_edocs_bosch2(string Carpeta, string file_name, string Clientes, string Fecha_1, string Fecha_2, string imp_exp, string tipo_doc, int visible_sql)
        {
            DataTable[] LisDT;
            string[] LisDT_tit;
            string[,] tab_impexp;
            Utilerias util = new Utilerias();
            DM DM = new DM();
            Excel xlsx = new Excel();
            if (imp_exp.Trim() == "1" || imp_exp.Trim() == "2")
            {
                LisDT = new DataTable[1];
                LisDT_tit = new string[1];
                //  Console.WriteLine(DM.transmision_edocs_bosch(Clientes, Fecha_1, Fecha_2, imp_exp, tipo_doc, imp_exp, visible_sql));
                LisDT[0] = DM.datos(DM.transmision_edocs_bosch(Clientes, Fecha_1, Fecha_2, imp_exp, tipo_doc, imp_exp));
                LisDT_tit[0] = util.iff(imp_exp, "=", "1", "Importación", "Exportación");
                ///Console.WriteLine(util.Tdetalle(LisDT[0]));
                xlsx.CrearExcel_file(LisDT, LisDT_tit, Carpeta + file_name);
            }
            else
            {
                LisDT = new DataTable[2];
                LisDT_tit = new string[2];
                //Console.WriteLine("/********tipo 2***/////////");
                LisDT[0] = DM.datos(DM.transmision_edocs_bosch(Clientes, Fecha_1, Fecha_2, "", tipo_doc, "2", visible_sql));
                LisDT_tit[0] = "Exportación";
                // Console.WriteLine(util.Tdetalle(LisDT[0]));
                //Console.WriteLine("/********tipo 1***/////////");
                LisDT[1] = DM.datos(DM.transmision_edocs_bosch(Clientes, Fecha_1, Fecha_2, "", tipo_doc, "1", visible_sql));
                LisDT_tit[1] = "Importación";
                //Console.WriteLine(util.Tdetalle(LisDT[1]));
                xlsx.CrearExcel_file(LisDT, LisDT_tit, Carpeta + file_name, 1);
            }
            for (int i = 0; i < LisDT.Length; i++)
                LisDT[i].Clear();
            return "0";

        }

    }
}
