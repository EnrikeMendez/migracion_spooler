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
                arc_nom = arc_nom.Replace("%p", dt.Replace(".", ""));

            }
            else
            {
                if (date_1 != "")
                {
                    dt = DateTime.Parse(new_date_1[1] + "-" + new_date_1[0] + "-" + new_date_1[2]).ToString("MMM-dd-yyyy");
                    arc_nom = arc_nom.Replace("%p", dt.Replace(".", ""));
                }
            }
            if (date_1 != "")
            {
                dt = DateTime.Parse(new_date_1[1] + "-" + new_date_1[0] + "-" + new_date_1[2]).ToString("MMM-dd-yyyy");
                arc_nom = arc_nom.Replace("%p", dt.Replace(".", ""));
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
        public string[,] hexafile_nv(string[,] file_name, string Carpeta, int id_rep, string file_n, string[,] parins)        
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
                parins[0, 0] = "DEST_MAIL";
                parins[1, 0] = "Carpeta";
                parins[2, 0] = "param_string";
                parins[3, 0] = "days_deleted";
                parins[4, 0] = "subCarpeta";
                parins[5, 0] = "id_Reporte";
                parins[6, 0] = "FECHA_1";
                parins[7, 0] = "FECHA_2";
                parins[8, 0] = "fecha_1_intervalo";
                */
                string ins = "insert into rep_archivos (id_rep, carpeta, nombre, date_created, DEST_MAIL, PARAMS, days_deleted, subcarpeta, tipo_reporte, HASH_MD5, FECHA_INICIO, FECHA_FIN) "
                  + "values ('" + id_rep.ToString() + "', '" + parins[1, 1] + "', '" + html[0, i] + "', sysdate, '" + parins[0, 1] + "'";
                if (parins[8, 1] == "")
                    ins = ins + ",'" + parins[2, 1].Replace("'", "''") + "', " + parins[3, 1] + ", '" + nvl(parins[4, 1]) + "', '" + nvl(parins[5, 1]) + "', '" + html[3, i] + "', to_date('" + parins[6, 1] + "', 'mm/dd/yyyy'), to_date('" + parins[7, 1] + "', 'mm/dd/yyyy'))";
                else
                    ins = ins + ",'" + parins[2, 1].Replace("'", "''") + "', " + parins[3, 1] + ", '" + nvl(parins[4, 1]) + "', '" + nvl(parins[5, 1]) + "', '" + html[3, i] + "', to_date('" + parins[8, 1] + "', 'mm/dd/yyyy'), to_date('" + parins[6, 1] + "', 'mm/dd/yyyy'))";
                //Console.WriteLine(ins);
                DM.ejecuta_sql(ins);
            }
            return html;
        }

        public string[,] hexafile(string[,] array, string[,] file_name, string Carpeta, int id_rep, string[,] parins)
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
                  + "values ('" + id_rep.ToString() + "', '" + parins[1, 1] + "', '" + html[0, i] + "', sysdate, '" + parins[0, 1] + "'";
                if (parins[8, 1] == "")
                    ins = ins + ",'" + parins[2, 1].Replace("'","''") + "', " + parins[3, 1] + ", '" + nvl(parins[4, 1]) + "', '" + nvl(parins[5, 1]) + "', '" + html[3, i] + "', to_date('" + parins[6, 1] + "', 'mm/dd/yyyy'), to_date('" + parins[7, 1] + "', 'mm/dd/yyyy'))";
                else
                    ins = ins + ",'" + parins[2, 1].Replace("'", "''") + "', " + parins[3, 1] + ", '" + nvl(parins[4, 1]) + "', '" + nvl(parins[5, 1]) + "', '" + html[3, i] + "', to_date('" + parins[8, 1] + "', 'mm/dd/yyyy'), to_date('" + parins[6, 1] + "', 'mm/dd/yyyy'))";
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
        parins[0, 0]  = "DEST_MAIL";
        parins[0, 1]  = dest_mail;
        parins[1, 0]  = "Carpeta";
        parins[1, 1]  = util.nvl(util.Tcampo(tdato_repor, "CARPETA"));
        parins[2, 0]  = "param_string";
        parins[2, 1]  = param_string;
        parins[3, 0]  = "days_deleted";
        parins[3, 1]  = days_deleted.ToString();
        parins[4, 0]  = "SUBCARPETA";
        parins[4, 1]  = util.nvl(util.Tcampo(tdato_repor, "SUBCARPETA"));
        parins[5, 0]  = "id_Reporte";
        parins[5, 1]  = id_Reporte.ToString();
        parins[6, 0]  = "FECHA_1";
        parins[6, 1]  = FECHA_1;
        parins[7, 0]  = "FECHA_2";
        parins[7, 1]  = FECHA_2;
        parins[8, 0]  = "fecha_1_intervalo";
        parins[8, 1]  = fecha_1_intervalo;
        parins[9, 0] = "id_cron";
        parins[9, 1] = rep_id.ToString();
        parins[10, 0] = "Servidor";
        parins[10, 1] = servidor;
        parins[11, 0] = "second_path";
        parins[11, 1] = second_path;
        parins[12, 0] = "Path_file";
        parins[12, 1] = Carpeta;
        */
        public int replica_tem(string arch, string[,] parins)

        {
            int resultado = 0;
            //string carpeta_resp = "C:\\pc\\ruta_alterna\\ejeml";
            string carpeta_resp = parins[11, 1] + "\\" + nvl(parins[1, 1]) + "\\" + iff(nvl(parins[4, 1]), "<>", "", nvl(parins[4, 1]) + "\\", "");
            /*
              if (!new System.IO.FileInfo(carpeta_resp + "\\" + arch + ".xlsx").Exists)
                System.IO.File.Copy(localPath + fileName, remotePath + fileName);
            */
            //string carpeta_resp = parins[11, 1] + "\\" + nvl(parins[1, 1]) + "\\" + iff(nvl(parins[4, 1]), "<>", "", nvl(parins[4, 1]) + "\\", "");
            if (arch != "")
            {
                Console.WriteLine("primera" + parins[11, 0]);
                //if (!Directory.Exists(parins[11, 1]))
                if (!Directory.Exists(carpeta_resp))
                {
                    if (!Directory.Exists(carpeta_resp))
                        Directory.CreateDirectory(carpeta_resp);
                }
                Console.WriteLine(parins[12, 1] + "\\" + arch + ".xlsx");
                if (new System.IO.FileInfo(parins[12, 1] + "\\" + arch + ".xlsx").Exists)
                    File.Copy(Path.Combine(parins[12, 1], arch + ".xlsx"), Path.Combine(carpeta_resp, arch + ".xlsx"), true);

                if (new System.IO.FileInfo(parins[12, 1] + "\\" + arch + ".zip").Exists)
                    File.Copy(Path.Combine(parins[12, 1], arch + ".zip"), Path.Combine(carpeta_resp, arch + ".zip"), true);
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

    }

}
