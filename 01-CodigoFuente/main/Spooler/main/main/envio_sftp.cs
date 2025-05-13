using Renci.SshNet;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Mail;
using System.Text;
using System.Threading.Tasks;

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
        public Boolean sftp_conexion()
        {
            if (!_sftpClient.IsConnected)
            {
                _sftpClient.Connect();

                if (_sftpClient.IsConnected)
                {
                    Console.WriteLine("Conectado al servidor SFTP");
                    return true;
                }
                else
                {
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
                    return true;
                }
                else
                {
                    return false;
                }
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
        public void sftp_transmitir_archivo(string ruta_archivo_local, string ruta_archivo_remoto)
        {
            using (var fileStream = new FileStream(ruta_archivo_local, FileMode.Open))
            {
                _sftpClient.UploadFile(fileStream, ruta_archivo_remoto);
                Console.WriteLine($"Archivo transmitido: {ruta_archivo_remoto}");
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

    }
}
