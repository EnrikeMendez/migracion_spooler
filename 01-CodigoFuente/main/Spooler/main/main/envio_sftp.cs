using Renci.SshNet;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Mail;
using System.Text;
using System.Threading.Tasks;
using static System.Runtime.InteropServices.JavaScript.JSType;

namespace serverreports
{
    internal class envio_sftp
    {
        //Obtener credenciales por cliente
        //SP....


        //Autenticación al repositorio SFTP
        private SftpClient _sftpClient;

        public envio_sftp(string ip, int puerto, string usuario, string contrasenia)
        {
            _sftpClient = new SftpClient(ip, puerto, usuario, contrasenia);
        }


        //Conexión al repositorio SFTP
        public bool sftp_conexion(out string error)
        {
            try
            {
                if (!_sftpClient.IsConnected)
                {
                    _sftpClient.Connect();

                    if (_sftpClient.IsConnected)
                    {
                        Console.WriteLine("Conectado al servidor SFTP");

                        error = "";
                        return true;
                    }
                    else
                    {
                        error = "Se produjo un error al intentar conectar al repositorio remoto.";
                        return false;
                    }
                }
                else
                {
                    sftp_desconexion();

                    _sftpClient.Connect();
                    if (_sftpClient.IsConnected)
                    {
                        Console.WriteLine("Conectado al servidor SFTP");

                        error = "";
                        return true;
                    }
                    else
                    {
                        error = "Se produjo un error al intentar conectar al repositorio remoto.";
                        return false;
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("Se produjo un error al intentar conectar al repositorio remoto: \n\n Detalle: \n" + ex.Message);
                sftp_desconexion();
                error = ex.Message;
                return false;
            }
        }


        //Generar directorios remotos
        public void sftp_genera_arbol_carpetas(string arbol_directorios)
        {
            // Separar la ruta en subdirectorios
            string[] subdirs = arbol_directorios.Split('/');
            string arbol_dirs = "";

            foreach (var subdir in subdirs)
            {
                if (string.IsNullOrEmpty(subdir))
                    continue;

                arbol_dirs = arbol_dirs == "" ? $"/{subdir}" : $"{arbol_dirs}/{subdir}";

                if (!_sftpClient.Exists(arbol_dirs))
                {
                    _sftpClient.CreateDirectory(arbol_dirs);
                    Console.WriteLine($"Directorio creado: {arbol_dirs}");
                }
                else
                {
                    Console.WriteLine($"El directorio ya existe: {arbol_dirs}");
                }
            }
        }


        //Transmite archivo al repositorio SFTP
        public bool sftp_transmitir_archivo(string ruta_archivo_local, string ruta_remota, string archivo, bool genera_directorios_remotos, out string error)
        {
            string err;
            try
            {
                //***** (1). Conexion *****
                if (sftp_conexion(out err) == true)
                {
                    //***** (2). Generacion de directorios remotos *****
                    if (genera_directorios_remotos == true)

                    {
                        sftp_genera_arbol_carpetas(ruta_remota);
                    }

                    //***** (3). Transmitir el archivo *****
                    using (var fileStream = new FileStream(ruta_archivo_local, FileMode.Open))
                    {
                        _sftpClient.UploadFile(fileStream, ruta_remota + archivo);
                        Console.WriteLine($"Archivo transmitido: {ruta_remota + archivo}");
                    }

                    //***** (4). Desconectar y liberar recursos *****
                    sftp_desconexion();

                    error = "";
                    return true;
                }
                else
                {
                    sftp_desconexion();

                    error = "No conectado al repositorio remoto.";
                    return false;
                }

            }
            catch (Exception ex)
            {
                Console.WriteLine("Se produjo un error en el proceso de transmisión del archivo: \n\n Detalle: \n" + ex.Message);
                sftp_desconexion();
                error = ex.Message;
                return false;
            }
        }


        //Desconecta al repositorio SFTP
        public void sftp_desconexion()
        {
            if (_sftpClient.IsConnected)
            {
                _sftpClient.Disconnect();
                Console.WriteLine("Desconectado del servidor SFTP");
            }
        }


        // Implementación de IDisposable para liberar recursos
        public void sftp_liberar_recursos()
        {
            sftp_desconexion();
            _sftpClient.Dispose();
        }


        /// <summary> 20250701
        /// Lista los objetos del directorio sftp 
        /// dir : especifica el directorio donde sera el area de trabajo
        /// archivo: 0 solo mostrara los archivos 1 se incluye los directorio y archivos
        /// </summary>
        /// <param name="dir"></param>
        /// <param name="archivos"></param>
        /// <returns></returns>
        public string[,] ListSftpDir(string? dir = "", int? archivos = 0)
        {
            string[,] array_ftp_arch = new string[1, 3];
            string err;
            List<string> lista = new List<string>();
            try
            {
                var lista_arch = new List<System.String>();
                if (sftp_conexion(out err) == true)
                {
                    int i = 0;
                    foreach (var entry in _sftpClient.ListDirectory(dir))
                    {
                        string elemento = entry.Name + ";" + entry.Length + ";" + entry.Attributes.LastWriteTime.Year + "/" + entry.Attributes.LastWriteTime.Month + "/" + entry.Attributes.LastWriteTime.Day + " " + entry.Attributes.LastWriteTime.TimeOfDay + ";" + entry.Attributes.Size;
                        if (archivos == 0)
                        {
                            if (entry.IsDirectory == false)
                                lista.Add(elemento);
                        }
                        else
                        {
                            lista.Add(elemento);
                        }
                    }
                    array_ftp_arch = new string[lista.Count, 3];
                    foreach (string elemento in lista)
                    {
                        string[] propiedad = elemento.Split(new[] { ';' }, 10, StringSplitOptions.RemoveEmptyEntries);
                        array_ftp_arch[i, 0] = propiedad[0];
                        array_ftp_arch[i, 2] = DateTime.Parse(propiedad[2]).ToString("MM/dd/yyyy HH:mm");
                        array_ftp_arch[i, 1] = propiedad[1];
                        i++;
                    }
                    sftp_desconexion();
                }
                else
                {
                    sftp_desconexion();
                    array_ftp_arch[0, 0] = "No conectado al repositorio remoto;";
                    array_ftp_arch[0, 2] = "NA;";
                    array_ftp_arch[0, 1] = "NA;";
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.HResult.ToString());
                array_ftp_arch = new string[1, 3];
                if (ex.Message.Contains("The remote name could not be resolved"))
                    array_ftp_arch[0, 0] = "No se puede conectar";
                else
                if (ex.Message.Contains("No such file"))
                    array_ftp_arch[0, 0] = "No existe directorio";
                else
                    array_ftp_arch[0, 0] = "Credencial erronea";
                array_ftp_arch[0, 1] = "";
                array_ftp_arch[0, 2] = "";
            }

            return array_ftp_arch;
        }
    }
}
