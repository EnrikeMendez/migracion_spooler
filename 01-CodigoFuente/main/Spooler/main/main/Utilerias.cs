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
            var fileNameToAdd = Path.Combine(ruta, "data", fileToAdd);
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


        public string agregar_zip(string[] arch, string nombre, string ruta)
        {
            try
            {
                for (int i = 0; i < arch.Length; i++)
                {
                    CrearZip(arch[i], nombre, ruta, i);
                }
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message + " error No. " + e.HResult);
                //Console.WriteLine("Error archivo " + nombre + ".zip existe en ruta " + ruta + " error No. " + e.HResult);
            }
            return ruta + "\\" + nombre + ".zip";
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

        public string[,] hexafile(string[,] array, string[,] file_name, string Carpeta, int id_rep)
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

    }

}
