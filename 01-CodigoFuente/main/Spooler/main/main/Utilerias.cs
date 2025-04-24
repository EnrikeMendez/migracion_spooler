using ClosedXML.Excel;
using DocumentFormat.OpenXml.Math;
using SpreadsheetLight;
using System;
using System.Collections.Generic;
using System.Data;
using System.Drawing;
using System.Globalization;
using System.IO.Compression;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using MD5Hash;
using System.Security.Cryptography;

namespace serverreports
{
    internal class Utilerias
    {
        string idioma = "es-MX";
        /// <summary>
        /// Busca un campo dentro del DataTable y retorna el valor de dicho campo dentro de la primer fila.
        /// </summary>
        /// <param name="dtTemp">DataTable con los datos a consultar y del cual se considerará sólo la primer fila.</param>
        /// <param name="campo">Nombre del campo del caul se requiere obtener el valor</param>
        /// <returns></returns>
        public string Tcampo(DataTable dtTemp, string campo)
        {
            string valor = "";
            if (dtTemp.Rows.Count > 0 && campo != null)
            {
                for (int j = 0; j < 1; j++)
                {
                    valor = dtTemp.Rows[j][campo].ToString();
                    break;
                }
            }
            return valor;
        }

        public string listTcampo(DataTable dtTemp, string campo, string? comodin = ",")
        {
            string valor = "";
            if (dtTemp.Rows.Count > 0 && campo != null)
            {
                for (int j = 0; j < 1; j++)
                {
                    valor = dtTemp.Rows[j][campo].ToString() + comodin;
                    break;
                }
            }
            return valor;
        }

        public string Tdetalle(DataTable dtTemp)
        {
            string tit = "";
            string val = "";
            for (int j = 0; j < dtTemp.Rows.Count; j++)
            {
                for (int i = 0; i < dtTemp.Columns.Count; i++)
                {
                    if (j == 0) { tit = tit + dtTemp.Columns[i].ColumnName + "\t"; }
                    val = val + dtTemp.Rows[j][i].ToString() + "\t";
                }
                if (j == 0) { val = tit + "\n" + val + "\n"; }
                else
                {
                    val = val + "\n";
                }
            }
            return val;
        }

        public string nvl(string cadena, string? tp = "s")
        {
            if (tp.ToUpper() == "S")
            {
                if (string.IsNullOrEmpty(cadena))
                    return "";
                else
                    return cadena;
            }
            else
            {
                if (string.IsNullOrEmpty(cadena))
                    return "0";
                else
                    return cadena;
            }
        }

        public string iff(string cad1, string Cond, string cad2, string res1, string res2)
        {
            string rcad = "";
            switch (Cond)
            {
                case "=":
                    if (cad1 == cad2) rcad = res1; else rcad = res2;
                    break;
                case "<>":
                    if (cad1 != cad2) rcad = res1; else rcad = res2;
                    break;
            }
            return rcad;
        }
        
        public string arma_param(string cad, int num)
        {
            string valor = "";
            for (int i = 1; i <= num; i++)
            {
                valor = valor + "," + cad + i;
            }
            return valor;
        }

        public string Get_IP()
        {
            /******IP opc 0**/
            // IPAddress[] localIPs = Dns.GetHostAddresses(Dns.GetHostName());
            // Console.WriteLine("valor COMMAND " + Convert.ToString(localIPs[1]));
            // Console.WriteLine("valor COMMAND " + Convert.ToString(localIPs[0]));//mac adress
            // return Convert.ToString(localIPs[1]);
            /******IP opc 0**/
            /******IP opc 2**/
            string localIP = "";
            IPHostEntry host = Dns.GetHostEntry(Dns.GetHostName());// objeto para guardar la ip
            foreach (IPAddress ip in host.AddressList)
            {
                if (ip.AddressFamily.ToString() == "InterNetwork")
                {
                    localIP = ip.ToString();// esta es nuestra ip
                    break;
                }
            }
            return localIP;
            // Console.WriteLine("valor IP " + localIP);//mac adress
            /******IP opc 2**/
        }

        public string filter_file_name(string archivo, string date_1, string date_2)
        {
            string arc_nom;
            string dt;
            arc_nom = archivo;
            arc_nom = arc_nom.Replace("%M", DateTime.Now.ToString("MMMM", CultureInfo.CreateSpecificCulture(idioma)));
            arc_nom = arc_nom.Replace("%D", DateTime.Now.ToString("dd", CultureInfo.CreateSpecificCulture(idioma)));
            arc_nom = arc_nom.Replace("%Y", DateTime.Now.ToString("yyyy", CultureInfo.CreateSpecificCulture(idioma)));
            string[] new_date_1 = date_1.Split("/");
            string[] new_date_2 = date_2.Split("/");
            if (date_2 != "" && date_2 != date_1)
            {
                dt = DateTime.Parse(new_date_1[1] + "-" + new_date_1[0] + "-" + new_date_1[2]).ToString("MMM-dd-yyyy") +
                             DateTime.Parse(new_date_2[1] + "-" + new_date_2[0] + "-" + new_date_2[2]).ToString("MMM-dd-yyyy");
                arc_nom = arc_nom.Replace("%P", dt.Replace(".", ""));

            }
            else
            {
                if (date_1 != "")
                {
                    dt = DateTime.Parse(new_date_1[1] + "-" + new_date_1[0] + "-" + new_date_1[2]).ToString("MMM-dd-yyyy");
                    arc_nom = arc_nom.Replace("%P", dt.Replace(".", ""));
                }
            }
            if (date_1 != "")
            {
                dt = DateTime.Parse(new_date_1[1] + "-" + new_date_1[0] + "-" + new_date_1[2]).ToString("MMM-dd-yyyy");
                arc_nom = arc_nom.Replace("%P", dt.Replace(".", ""));
            }
            return arc_nom;
        }

        public void CrearZip(string fileToAdd, string nombre, string ruta, int add)
        {
            var outFileName = Path.GetFileNameWithoutExtension(nombre) + ".zip";
            var fileNameToAdd = Path.Combine(ruta, "", fileToAdd);
            var zipFileName = Path.Combine(ruta, "", outFileName);
            if (add == 0)
            {
                using (ZipArchive archive = ZipFile.Open(zipFileName, ZipArchiveMode.Create))
                      archive.CreateEntryFromFile(fileNameToAdd, Path.GetFileName(fileNameToAdd));
            }
            if (add > 0)
            {
                using (ZipArchive archive = ZipFile.Open(zipFileName, ZipArchiveMode.Update))
                       archive.CreateEntryFromFile(fileNameToAdd, Path.GetFileName(fileNameToAdd));           
            }
        }

        public void CrearZip2(string fileToAdd ,  string ruta,int contador)
        {
            var zip   = Path.GetFileNameWithoutExtension(fileToAdd) + ".zip";
            var add_arch = Path.Combine(ruta, "", fileToAdd);
            var arch_zip   = Path.Combine(ruta, "", zip);
            using (ZipArchive archive = ZipFile.Open(arch_zip, ZipArchiveMode.Create))
            {
               archive.CreateEntryFromFile(fileToAdd, Path.GetFileName(add_arch));
            }
            Console.WriteLine(" zip creado");
        }


        public string agregar_zip_ant(string[] arch, string nombre, string ruta)
        {
    
            //   try
            //  {
            for (int i = 0; i < arch.Length - 1; i++)
            {
                CrearZip(arch[i], nombre, ruta, i);
            }
            //   }
            /*
               catch (Exception e)
               {
                   Console.WriteLine("Error archivo " + nombre + ".zip existe en ruta " + ruta + " error No. " + e.HResult);
               }
            */

            return ruta + "\\" + nombre + ".zip";
        }

        public string[,] agregar_zip(string[,] arch, string nombre, string ruta)
        {
            string[,] html = arch;
            //   try
            //  {
            for (int i = 0; i < arch.Rank - 1; i++)
            {
                CrearZip(arch[0, i], nombre, ruta, i);
            }
            //   }
            /*
               catch (Exception e)
               {
                   Console.WriteLine("Error archivo " + nombre + ".zip existe en ruta " + ruta + " error No. " + e.HResult);
               }
            */
            long sizeInBytes = new FileInfo(ruta + "\\" + nombre + ".zip").Length;
            //html[5, 0] = sizeInBytes.ToString();
            html[5, 0] = format_tam(sizeInBytes);
            return html;
        }


        public string StringToHex(string hexstring)
        {
            // string value = "raul granados gonzalez";
            byte[] bytes = Encoding.UTF8.GetBytes(hexstring);
            string hexString = Convert.ToHexString(bytes);
            // Console.WriteLine($"String value: \"{value}\"");
            //Console.WriteLine($"   Hex value: \"{hexString}\"");
            //Console.WriteLine($"   Hex value 2: \"{StringToHex(value)}\"");
            //Console.WriteLine($"  valor ori: \"{FromHexString(hexString)}\"");
            //Console.WriteLine($"  valor ori2: \"{FromHexString(StringToHex(value))}\"");
            /*
            if (System.IO.File.Exists(value))
            {
                long sizeInBytes = new FileInfo(Carpeta + "\\" + file_name[0] + ".xlsx").Length;
            }
            else
            {   
            }
            */
            StringBuilder sb = new StringBuilder();
            foreach (char t in hexstring)
            {
                //Note: X for upper, x for lower case letters
                sb.Append(Convert.ToInt32(t).ToString("x2"));
            }
            return sb.ToString();
        }
        public string[,] hexafile_nv(string[,] file_name, string Carpeta, int id_rep, string file_n, string[,] pargral)        
        {
            string[,] html = file_name;
            //string[,] html = array;
            //  var stream =File.OpenRead(null);
            // string actualHash;
            DM DM = new DM();

            for (int i = 0; i < file_name.Rank - 1; i++)
            {
                string arch1 = file_name[0, i];

                
                long sizeInBytes = new FileInfo(Carpeta + "\\" + arch1).Length;
                //html[2, i] = sizeInBytes.ToString();
                html[2, i] = format_tam(sizeInBytes);
                if (sizeInBytes >= 104857600 || sizeInBytes <= 0)
                {
                    var stream = File.CreateText(Carpeta + "\\" + file_n + System.IO.Path.GetTempFileName());
                    //html[3, i] = StringToHex(Carpeta + "\\" + arch + System.IO.Path.GetTempFileName());
                    html[3, i] = stream.GetMD5().ToString();
                    stream.Dispose();
                }
                else
                {
                    var stream = File.OpenRead(Carpeta + "\\" + arch1);
                    html[3, i] = stream.GetMD5();
                    stream.Dispose();
                }
                /*
                If FSO.GetFile(Carpeta & tab_archivos(0, i)).size >= 104857600 Then
                   tab_archivos(3, i) = md5_hash.DigestStrToHexStr(Carpeta & file_name & FSO.GetTempName)
                Else
                   tab_archivos(3, i) = md5_hash.DigestFileToHexStr(Carpeta & tab_archivos(0, i))
                 End If
                If FSO.GetFile(Carpeta & tab_archivos(0, i)).size <= 0 Then
                  tab_archivos(3, i) = md5_hash.DigestStrToHexStr(Carpeta & file_name & FSO.GetTempName)
                End If
                */
                string file_name2;

                if (System.IO.File.Exists(Carpeta + "\\" + arch1))
                    file_name2 = left(arch1, arch1.Length - 5) +
                           mid(Path.GetFileName(System.IO.Path.GetTempFileName()), 4, 6)
                           + right(arch1, 5);
                /*
                If FSO.FileExists(Carpeta & file_name) Then
                    file_name = Left(file_name, Len(file_name) - 4) & Mid(FSO.GetBaseName(FSO.GetTempName), 4, 2) & Right(file_name, 4)
                End If
                */
                if (ValidaNombreArchivo(id_rep) == 1)
                {
                    file_name2 = mid(file_n, 7, file_n.Length - 10) + "_" + left(html[3, i], 6) + right(file_n, 5);
                    if (System.IO.File.Exists(Carpeta + "\\" + file_n))
                        file_name2 = left(file_n, file_n.Length - 5) + mid(Path.GetFileName(System.IO.Path.GetTempFileName()), 4, 2) + right(file_n, 5);
                    File.Move(Carpeta + html[0, i], Carpeta + file_n);
                    html[0, i] = file_n;
                    /*
                     If ValidaNombreArchivo(rs.Fields("ID_REP")) = True Then
                     '  CHG-DESA-10022023-02>>
                     file_name = Mid(tab_archivos(0, i), 7, Len(tab_archivos(0, i)) - 10) & "_" & Left(tab_archivos(3, i), 6) & Right(tab_archivos(0, i), 4)
                     If FSO.FileExists(Carpeta & file_name) Then
                          file_name = Left(file_name, Len(file_name) - 4) & Mid(FSO.GetBaseName(FSO.GetTempName), 4, 2) & Right(file_name, 4)
                     End If
                     FSO.MoveFile Carpeta & tab_archivos(0, i), Carpeta & file_name
                     tab_archivos(0, i) = file_name
                    'If mail_adjuntarArchivoXLS = True Then
                     '    FSO.CopyFile Carpeta & file_name, mail_tempFolder & file_name
                     '    mail_archivoAdjunto_xls = mail_tempFolder & file_name
                     'End If
                   End If                         
                   */
                }
                /*
                pargral[0, 0] = "DEST_MAIL";
                pargral[1, 0] = "Carpeta";
                pargral[2, 0] = "param_string";
                pargral[3, 0] = "days_deleted";
                pargral[4, 0] = "subCarpeta";
                pargral[5, 0] = "id_Reporte";
                pargral[6, 0] = "FECHA_1";
                pargral[7, 0] = "FECHA_2";
                pargral[8, 0] = "fecha_1_intervalo";
                */
                string ins = "insert into rep_archivos (id_rep, carpeta, nombre, date_created, DEST_MAIL, PARAMS, days_deleted, subcarpeta, tipo_reporte, HASH_MD5, FECHA_INICIO, FECHA_FIN) "
                  + "values ('" + id_rep.ToString() + "', '" + pargral[1, 1] + "', '" + html[0, i] + "', sysdate, '" + pargral[0, 1] + "'";
                if (pargral[8, 1] == "")
                    ins = ins + ",'" + pargral[2, 1].Replace("'", "''") + "', " + pargral[3, 1] + ", '" + nvl(pargral[4, 1]) + "', '" + nvl(pargral[5, 1]) + "', '" + html[3, i] + "', to_date('" + pargral[6, 1] + "', 'mm/dd/yyyy'), to_date('" + pargral[7, 1] + "', 'mm/dd/yyyy'))";
                else
                    ins = ins + ",'" + pargral[2, 1].Replace("'", "''") + "', " + pargral[3, 1] + ", '" + nvl(pargral[4, 1]) + "', '" + nvl(pargral[5, 1]) + "', '" + html[3, i] + "', to_date('" + pargral[8, 1] + "', 'mm/dd/yyyy'), to_date('" + pargral[6, 1] + "', 'mm/dd/yyyy'))";
                //Console.WriteLine(ins);
                DM.ejecuta_sql(ins);
            }
            return html;
        }

        public string[,] hexafile(string[,] array, string[,] file_name, string Carpeta, int id_rep, string[,] pargral)
        {
            string[,] html = array;
            for (int i = 0; i < file_name.Rank - 1; i++)
            {
                long sizeInBytes = new FileInfo(Carpeta + "\\" + file_name[0, 0] + ".xlsx").Length;
                
                html[2, i] = sizeInBytes.ToString();
                if (sizeInBytes >= 104857600 || sizeInBytes <= 0)
                    html[3, i] = StringToHex(Carpeta + "\\" + file_name[0, 0] + System.IO.Path.GetTempFileName());
                else
                    html[3, i] = StringToHex(Carpeta + "\\" + file_name[0, 0]);
                /*
                If FSO.GetFile(Carpeta & tab_archivos(0, i)).size >= 104857600 Then
                   tab_archivos(3, i) = md5_hash.DigestStrToHexStr(Carpeta & file_name & FSO.GetTempName)
                Else
                   tab_archivos(3, i) = md5_hash.DigestFileToHexStr(Carpeta & tab_archivos(0, i))
                 End If
                If FSO.GetFile(Carpeta & tab_archivos(0, i)).size <= 0 Then
                  tab_archivos(3, i) = md5_hash.DigestStrToHexStr(Carpeta & file_name & FSO.GetTempName)
                End If
                */
                string file_name2;
                if (System.IO.File.Exists(Carpeta + "\\" + file_name[0, 0]))
                    file_name2 = left(file_name[0, 0], file_name[0, 0].Length - 5) +
                           mid(Path.GetFileName(System.IO.Path.GetTempFileName()), 4, 6)
                           + right(file_name[0, 0], 5);
                /*
                If FSO.FileExists(Carpeta & file_name) Then
                    file_name = Left(file_name, Len(file_name) - 4) & Mid(FSO.GetBaseName(FSO.GetTempName), 4, 2) & Right(file_name, 4)
                End If
                */
                if (ValidaNombreArchivo(id_rep) == 1)
                {
                    file_name2 = mid(file_name[0, 0], 7, file_name[0, 0].Length - 10) + "_" + left(html[3, i], 6) + right(file_name[0, 0], 5);
                    if (System.IO.File.Exists(Carpeta + "\\" + file_name[0, 0]))
                    {
                        file_name2 = left(file_name[0, 0], file_name[0, 0].Length - 5) + mid(Path.GetFileName(System.IO.Path.GetTempFileName()), 4, 2) + right(file_name[0, 0], 5);
                        File.Move(Carpeta + html[0, i], Carpeta + file_name);
                        html[0, i] = file_name[0, 0];
                        /*
                         If ValidaNombreArchivo(rs.Fields("ID_REP")) = True Then
                         '  CHG-DESA-10022023-02>>
                         file_name = Mid(tab_archivos(0, i), 7, Len(tab_archivos(0, i)) - 10) & "_" & Left(tab_archivos(3, i), 6) & Right(tab_archivos(0, i), 4)
                         If FSO.FileExists(Carpeta & file_name) Then
                              file_name = Left(file_name, Len(file_name) - 4) & Mid(FSO.GetBaseName(FSO.GetTempName), 4, 2) & Right(file_name, 4)
                         End If
                         FSO.MoveFile Carpeta & tab_archivos(0, i), Carpeta & file_name
                         tab_archivos(0, i) = file_name
                        'If mail_adjuntarArchivoXLS = True Then
                         '    FSO.CopyFile Carpeta & file_name, mail_tempFolder & file_name
                         '    mail_archivoAdjunto_xls = mail_tempFolder & file_name
                         'End If
                       End If                         
                       */
                    }
                }
                string ins = "insert into rep_archivos (id_rep, carpeta, nombre, date_created, DEST_MAIL, PARAMS, days_deleted, subcarpeta, tipo_reporte, HASH_MD5, FECHA_INICIO, FECHA_FIN) "
                  + "values ('" + id_rep.ToString() + "', '" + pargral[1, 1] + "', '" + html[0, i] + "', sysdate, '" + pargral[0, 1] + "'";
                if (pargral[8, 1] == "")
                    ins = ins + ",'" + pargral[2, 1].Replace("'","''") + "', " + pargral[3, 1] + ", '" + nvl(pargral[4, 1]) + "', '" + nvl(pargral[5, 1]) + "', '" + html[3, i] + "', to_date('" + pargral[6, 1] + "', 'mm/dd/yyyy'), to_date('" + pargral[7, 1] + "', 'mm/dd/yyyy'))";
                else
                    ins = ins + ",'" + pargral[2, 1].Replace("'", "''") + "', " + pargral[3, 1] + ", '" + nvl(pargral[4, 1]) + "', '" + nvl(pargral[5, 1]) + "', '" + html[3, i] + "', to_date('" + pargral[8, 1] + "', 'mm/dd/yyyy'), to_date('" + pargral[6, 1] + "', 'mm/dd/yyyy'))";
                
                Console.WriteLine(ins);

            }
            return html;
        }

        public string mid(string cad, int ini, int? fin = 0)
        {
            string val = "";
            if (fin == 0)
                val = cad.Substring(cad.Length - ini, ini);
            else
                val = cad.Substring(ini, (int)fin);
            return val;
        }

        public string left(string cad, int pos)
        {
            string val = "";
            val = cad.Substring(0, pos);
            return val;
        }

        public string right(string cad, int pos)
        {
            string val = "";
            val = cad.Substring(cad.Length - pos, pos);
            return val;
        }

        public int ValidaNombreArchivo(int idRep)
        {
            int val = 0;
            if (idRep == 252 || idRep == 253 || idRep == 342 || idRep == 343 || idRep == 344)
                val = 1;
            return val;
        }
        /*
        pargral[0, 0]  = "DEST_MAIL";
        pargral[0, 1]  = dest_mail;
        pargral[1, 0]  = "Carpeta";
        pargral[1, 1]  = util.nvl(util.Tcampo(tdato_repor, "CARPETA"));
        pargral[2, 0]  = "param_string";
        pargral[2, 1]  = param_string;
        pargral[3, 0]  = "days_deleted";
        pargral[3, 1]  = days_deleted.ToString();
        pargral[4, 0]  = "SUBCARPETA";
        pargral[4, 1]  = util.nvl(util.Tcampo(tdato_repor, "SUBCARPETA"));
        pargral[5, 0]  = "id_Reporte";
        pargral[5, 1]  = id_Reporte.ToString();
        pargral[6, 0]  = "FECHA_1";
        pargral[6, 1]  = FECHA_1;
        pargral[7, 0]  = "FECHA_2";
        pargral[7, 1]  = FECHA_2;
        pargral[8, 0]  = "fecha_1_intervalo";
        pargral[8, 1]  = fecha_1_intervalo;
        pargral[9, 0] = "id_cron";
        pargral[9, 1] = rep_id.ToString();
        pargral[10, 0] = "Servidor";
        pargral[10, 1] = servidor;
        pargral[11, 0] = "second_path";
        pargral[11, 1] = second_path;
        pargral[12, 0] = "Path_file";
        pargral[12, 1] = Carpeta;
        */
        public int replica_tem(string arch, string[,] pargral)

        {
            int resultado = 0;
            //string carpeta_resp = "C:\\pc\\ruta_alterna\\ejeml";
            string carpeta_resp = pargral[11, 1] + "\\" + nvl(pargral[1, 1]) + "\\" + iff(nvl(pargral[4, 1]), "<>", "", nvl(pargral[4, 1]) + "\\", "");
            /*
              if (!new System.IO.FileInfo(carpeta_resp + "\\" + arch + ".xlsx").Exists)
                System.IO.File.Copy(localPath + fileName, remotePath + fileName);
            */
            //string carpeta_resp = pargral[11, 1] + "\\" + nvl(pargral[1, 1]) + "\\" + iff(nvl(pargral[4, 1]), "<>", "", nvl(pargral[4, 1]) + "\\", "");
            if (arch != "")
            {
                Console.WriteLine("primera" + pargral[11, 0]);
                //if (!Directory.Exists(pargral[11, 1]))
                if (!Directory.Exists(carpeta_resp))
                {
                    if (!Directory.Exists(carpeta_resp))
                        Directory.CreateDirectory(carpeta_resp);
                }
                Console.WriteLine(pargral[12, 1] + "\\" + arch + ".xlsx");
                if (new System.IO.FileInfo(pargral[12, 1] + "\\" + arch + ".xlsx").Exists)
                    File.Copy(Path.Combine(pargral[12, 1], arch + ".xlsx"), Path.Combine(carpeta_resp, arch + ".xlsx"), true);

                if (new System.IO.FileInfo(pargral[12, 1] + "\\" + arch + ".zip").Exists)
                    File.Copy(Path.Combine(pargral[12, 1], arch + ".zip"), Path.Combine(carpeta_resp, arch + ".zip"), true);
                resultado = 1;
            }
            return resultado;
        }


        /*
  
    If tab_archivos(0, i) <> "" Then
        If FSO.FolderExists(second_path) Then
            If Not FSO.FolderExists(second_path & rs.Fields("CARPETA") & "\" & IIf(NVL(rs.Fields("SUBCARPETA")) <> "", NVL(rs.Fields("SUBCARPETA")) & "\", "")) Then
                Call Create_Entire_Path(second_path & rs.Fields("CARPETA") & "\" & IIf(NVL(rs.Fields("SUBCARPETA")) <> "", NVL(rs.Fields("SUBCARPETA")) & "\", ""))
            End If
            
            'copiar el archivo en el otro servidor
            If FSO.FileExists(Carpeta & tab_archivos(0, i)) Then
                FSO.CopyFile Carpeta & tab_archivos(0, i), second_path & rs.Fields("CARPETA") & "\" & IIf(NVL(rs.Fields("SUBCARPETA")) <> "", NVL(rs.Fields("SUBCARPETA")) & "\", "") & tab_archivos(0, i), True
            End If
            |
            'insercion de datos en la tabla de errores para copiar lo luego
           
            'copiar el zip
            If FSO.FileExists(Carpeta & Left(tab_archivos(0, i), Len(tab_archivos(0, i)) - 3) & "zip") Then
                FSO.CopyFile Carpeta & Left(tab_archivos(0, i), Len(tab_archivos(0, i)) - 3) & "zip", second_path & rs.Fields("CARPETA") & "\" & IIf(NVL(rs.Fields("SUBCARPETA")) <> "", NVL(rs.Fields("SUBCARPETA")) & "\", "") & Left(tab_archivos(0, i), Len(tab_archivos(0, i)) - 3) & "zip", True
            End If  
        Else
        End If
    End If
Next
         */

        public int borra_arch(string[] arch, string ruta)
        {
            int sw = 0;
            if (Directory.Exists(ruta))
            {
                for (int i = 0; i < arch.Length; i++)
                {
                    File.Delete(arch[i]);
                }
                sw = 1;
            }
            return sw;
        }
        public string format_tam(decimal tam)
        {
            int n = 0;
            String subj = "";
            while (tam > 1024)
            {
                tam = Math.Round(tam / 1024);
                n++;
            }
            switch (n)
            {
                case 0:
                    subj = "B";
                    break;
                case 1:
                    subj = "KB";
                    break;
                case 2:
                    subj = "MB";
                    break;
                case 3:
                    subj = "GB";
                    break;
                case 4:
                    subj = "TB";
                    break;
                default:
                    subj = "Trop long !!!";
                    break;
            }
            return tam.ToString() + " " + subj;
        }

        public DataTable Tdetalle_regtot(DataTable dtTemp, int col_ini, int int_fin, int ing_tot, int col_tot_proc, int porc = 0)
        {
            DataTable dtTemp_re = new DataTable();
            dtTemp_re = dtTemp;
            DataRow nvreg;
            int total = 0;
            int varcolporc = 0;
            decimal total_gral = 0;
            string tit = "";
            string val = "";
            if (ing_tot == 1)
            {
                nvreg = dtTemp_re.NewRow();
                for (int i = col_ini; i < dtTemp.Columns.Count; i++)
                {
                    total = 0;
                    if (i == col_ini)
                    {
                        nvreg[dtTemp.Columns[i - 1].ColumnName] = "Total";
                    }
                    for (int j = 0; j < dtTemp.Rows.Count; j++)
                    {
                        if (j == 0)
                        {
                            tit = dtTemp.Columns[i].ColumnName;
                        }
                        val = dtTemp.Rows[j][i].ToString();
                        total = total + Convert.ToInt32(val);
                    }
                    if (dtTemp.Rows.Count > 0)
                        nvreg[tit] = total.ToString();
                    else
                    {
                        tit = dtTemp.Columns[i].ColumnName;
                        nvreg[tit] = total.ToString();
                    }
                }
                total_gral = total;
                dtTemp_re.Rows.Add(nvreg);
            }
            // nvreg = dtTemp_re.NewRow();
            Console.WriteLine("Total :" + total_gral.ToString());

            //porcetanje
            if (total_gral == 0)
            {
                total = 0;
                for (int i = col_tot_proc; i < dtTemp.Columns.Count; i++)
                {
                    total = 0;
                    for (int j = 0; j < dtTemp.Rows.Count; j++)
                    {
                        if (j == dtTemp.Rows.Count - 1)
                        {
                            val = dtTemp.Rows[j][i].ToString();
                            total = total + Convert.ToInt32(val);
                            break;
                        }
                    }
                    if (total > 0) break;
                }
                total_gral = total;
            }
  
            if (porc == 1)
            {
                Console.WriteLine("Total rev:" + total_gral.ToString());
                nvreg = dtTemp_re.NewRow();
                varcolporc = 0;
                if (ing_tot == 0) varcolporc = dtTemp.Columns.Count - (col_tot_proc);
                for (int i = col_ini; i < dtTemp.Columns.Count- varcolporc; i++)
                {
                    total = 0;
                    if (i == dtTemp.Columns.Count - int_fin) break;
                    if (i == col_ini)
                    {
                        nvreg[dtTemp.Columns[i - 1].ColumnName] = "%";

                    }
                    for (int j = 0; j < dtTemp.Rows.Count; j++)
                    {
                        if (j == 0)
                        {
                            tit = dtTemp.Columns[i].ColumnName;
                        }
                        if (j == dtTemp.Rows.Count - 1)
                        {
                            val = dtTemp.Rows[j][i].ToString();
                            total = total + Convert.ToInt32(val);
                        }
                    }
                    if (total == 0)
                        nvreg[tit] = total.ToString();
                    else
                        nvreg[tit] = (Math.Round((total * 100) / total_gral, 2)).ToString();
                }
                dtTemp_re.Rows.Add(nvreg);
            }
            return dtTemp_re;
        }

        public DataTable Tdetalle_reversa(DataTable dtTemp)
        {
            DataTable dtTemp_re = new DataTable();
            string tit = "";
            string val = "";
            
            for (int j = 0; j < dtTemp.Rows.Count; j++)
            {
                if (j == 0)
                {
                    tit = dtTemp.Columns[0].ColumnName;
                    dtTemp_re.Columns.Add(tit);
                }
                tit = dtTemp.Rows[j][0].ToString();
                dtTemp_re.Columns.Add(tit, typeof(System.Decimal));
     
            }
            for (int i = 1; i < dtTemp.Columns.Count; i++)
            {
                DataRow nvreg = dtTemp_re.NewRow();
                for (int j = 0; j < dtTemp.Rows.Count; j++)
                {
                    if (j == 0)
                    {
                        tit = dtTemp_re.Columns[j].ColumnName;
                        val = dtTemp.Columns[i].ColumnName;
                        nvreg[tit] = val;
                    }
                    tit = dtTemp_re.Columns[j + 1].ColumnName;
                    val = dtTemp.Rows[j][i].ToString();
                    nvreg[tit] = val;                }
                dtTemp_re.Rows.Add(nvreg);
            }

            return dtTemp_re;
        }

        public string[,] abc_cel(int ini, int ancho)
        {
            string[,] arryapos = new string[1, 2];
            int iniabc = ini;
            //int sw = 26;  

            //int alto = 10;
            //int spacio = 0;
            string posini = "";
            /*ancho*/

            int vi = 0;
            string var = "";
            vi = ini + ancho;
            int valor = (vi / 26);
            switch (valor)
            {
                case 1:
                    vi = vi - 26;
                    posini = "A";
                    break;
                case 2:
                    vi = vi - 52;
                    posini = "B";
                    break;
            }

            posini = posini + Convert.ToChar(vi - 1 + 65).ToString();

            valor = (iniabc / 26);
            switch (valor)
            {
                case 1:
                    iniabc = iniabc - 26;
                    var = "A";
                    break;
                case 2:
                    iniabc = iniabc - 52;
                    var = "B";
                    break;
            }

            var = Convert.ToChar(iniabc - 1 + 65).ToString();

            /* for (int i = 0; i < 26; i++)
        {
            if (i > 25 && i < 51)
                vi = i - 25;
            else
                if (i > 50 && i < 76)
                vi = i - 50;
            else
                vi = i;
            string abc = Convert.ToChar(vi + 65).ToString();
            if (((ancho + sw) + spacio) == vi)
            {
                posini = Convert.ToChar(vi + 65).ToString();
            }
            if (abc == var)
                sw = vi;
         }

            if (ancho >= 26 && ancho < 51)
            posini = posini + posini;
        else if (ancho >= 51 && ancho < 76)
            posini = posini + posini + posini;
        else
            posini = posini;
  */
            arryapos[0, 0] = var;
            arryapos[0, 1] = posini;

            Console.WriteLine("posicion de inicial :" + arryapos[0, 0].ToString());
            Console.WriteLine("ancho :" + arryapos[0, 1].ToString());
            return arryapos;
        }

        public int Tcampo_numcol(DataTable dtTemp, string campo)
        {
            int valor = 0;
            if (dtTemp.Rows.Count > 0 && campo != null)
            {
                for (int j = 0; j < dtTemp.Columns.Count; j++)
                {
                    if (dtTemp.Columns[j].ColumnName == campo)
                    {
                        valor = j;
                        break;
                    }
                }
            }

            return valor;
        }

        public List<string> txt(DataTable dtTemp, List<string>? campos = null, string? separador = ",")
        {
            List<string> elementos = new List<string>();
            string val = "";
            int x = dtTemp.Rows.Count;
            elementos.Clear();
            if (campos != null)
                x = campos.Count;
            for (int i = 0; i < dtTemp.Rows.Count; i++)
            {
                val = "";
                for (int j = 0; j < x; j++)
                {
                    if (j == (x - 1))
                        if (campos != null)
                            try { val = val + nvl(dtTemp.Rows[i][campos[j]].ToString()); } catch (Exception) { val = val + "Nofound [" + campos[j] + "]"; }
                        else
                            val = val + nvl(dtTemp.Rows[i][j].ToString());
                    else
                        if (campos != null)
                        try { val = val + nvl(dtTemp.Rows[i][campos[j]].ToString()) + separador; } catch (Exception) { val = val + "Nofound [" + campos[j] + "]" + separador; }
                    else
                        val = val + nvl(dtTemp.Rows[i][j].ToString()) + separador;
                }
                elementos.Add(val);
            }
            return elementos;
        }

        public DataTable tab_col_def(DataTable dtTemp, string[,] datosdef)
        {
            DataTable dtTemp_re = new DataTable();
            string tit;

            string val = "";
            for (int j = 0; j < datosdef.GetLength(0); j++)
            {
                tit = datosdef[j, 0];
                if (datosdef[j, 1].ToUpper() == "S")
                    dtTemp_re.Columns.Add(tit, typeof(System.String));
                else if (datosdef[j, 1].ToUpper() == "I")
                    dtTemp_re.Columns.Add(tit, typeof(System.Int32));
                else
                    dtTemp_re.Columns.Add(tit);
            }
            for (int i = 0; i < dtTemp.Rows.Count; i++)
            {
                DataRow nvreg = dtTemp_re.NewRow();
                for (int j = 0; j < datosdef.GetLength(0); j++)
                {
                    tit = datosdef[j, 0];
                    if ((datosdef[j, 2].ToUpper()) == "V")
                        val = dtTemp.Rows[i][tit].ToString();
                    else
                        val = "";
                    nvreg[tit] = val;
                }
                dtTemp_re.Rows.Add(nvreg);
            }
            return dtTemp_re;
        }
    }
}
