using System.Data;
//3723307
namespace serverreports
{
    internal class trading_genera_GSK_mod
    {
        public string trading_genera_GSK(string Carpeta, string[,] file_name, string cliente, string Fecha_1, string Fecha_2, string empresa, Int32 idCron, string[,] parins, string[] contacmail, int vs)
        {
            int sw_error = 0;
            Utilerias util = new Utilerias();
            envio_correo correo = new envio_correo();
            DM DM = new DM();
            Excel xlsx = new Excel();
            DataTable[] LisDT = new DataTable[1];
            string[] LisDT_tit = new string[1]; ;
            string[] arh;
            if (file_name[4, 0] == "1")
                arh = new string[2];
            else
                arh = new string[1];
            (string? codigo, string? msg, string? sql, DataTable? tb) datos_sp;
            datos_sp.tb = LisDT[1];
            datos_sp.sql = "SC_DIST.SPG_RS_COEX.P_RS_GSK_PEDIMENTOS";
            //            datos_sp = DM.datos_sp([datos_sp.sql], vs);
            string[,] html = new string[6, 1];
            string[,] par_st = new string[3, 4];
                par_st[0, 0] = "o";
                par_st[0, 1] = "c";
                par_st[0, 2] = "p_Cur_GSK";
                par_st[1, 0] = "o";
                par_st[1, 1] = "v";
                par_st[1, 2] = "p_Mensaje";
                par_st[1, 3] = "msg";
                par_st[2, 0] = "o";
                par_st[2, 1] = "i";
                par_st[2, 2] = "p_Codigo_Error";
                par_st[2, 3] = "cod";

            try
            {

                datos_sp = DM.datos_sp([datos_sp.sql], par_st, vs);

            Console.WriteLine(" Mensaje store :" + datos_sp.msg);
            Console.WriteLine(" Codigo store :" + datos_sp.codigo);
            LisDT_tit[0] = "Shipments";
            //string[] arh = new string[2];
            LisDT[0] = datos_sp.tb;
            string arch = file_name[0, 0];

                if ((LisDT[0].Rows.Count > 0) && (datos_sp.codigo == "1"))
                {
                    xlsx.CrearExcel_file(LisDT, LisDT_tit, Carpeta + "\\" + file_name + ".xlsx");
                    //  correo.send_mail("Report: < Logis GSK > Envio ok", [], "proceso correcto");
                    /*
                    arh[0] = Carpeta + "\\" + file_name + ".xlsx";
                    arh[1] = util.agregar_zip(arh, file_name, Carpeta);
                    correo.send_mail("Report: < Logis GSK> Envio ok", [], "proceso correcto", arh);
                    */
                    arh[0] = Carpeta + "\\" + file_name[0, 0] + ".xlsx";
                    if (file_name[4, 0] == "1")
                        arh[1] = util.agregar_zip(arh, file_name[0, 0], Carpeta);
                    file_name[0, 0] = file_name[0, 0] + ".xlsx";
                    file_name[4, 0] = "0";
                    html = util.hexafile_nv(file_name, Carpeta, idCron, arch, parins);
                    util.replica_tem(arch, parins);
                    string mensaje = correo.display_mail(parins[10, 1], "", arch, html, Int32.Parse(parins[3, 1]), "");
                    if (contacmail.Length > 0) {
                        //correo.send_mail("Report: <  "+ html[1,0] + "> created v2024", contacmail, mensaje, arh);

                        correo.send_mail("Report: <  "+ html[1,0] + "> created v2024", [], mensaje, arh);
                        
                    }
                    DM.act_proceso(parins, vs);
                    util.borra_arch(arh, Carpeta);
                }
                else
                {
                   // arh[0] = AppDomain.CurrentDomain.BaseDirectory+"\\Grafica.xlsx";
                   /// arh[1] = AppDomain.CurrentDomain.BaseDirectory+"\\porteos_tln.xlsx";
                   // util.agregar_zip(arh, "prueb_zip", AppDomain.CurrentDomain.BaseDirectory);
                    if (datos_sp.codigo == "1")
                        datos_sp.msg = "No hay registros en la consulta :" + datos_sp.sql;
                    sw_error = 1;
                }
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
            LisDT[0].Dispose();
            datos_sp.tb.Dispose();
            return sw_error.ToString();
        }
    }
}
