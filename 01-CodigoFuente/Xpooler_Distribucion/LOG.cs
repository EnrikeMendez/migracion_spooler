public static class LOG
{
    private static long iInfo = 0;
    private static string _sRuta = string.Empty;
    private static string CreaLog(bool esError = false)
    {
        string NombreArchivo = string.Format("Xpooler_Distribucion{0}{1}", EsModoPrueba() ? "_DEV_" : "_", DateTime.Now.ToString("yyyyMMdd"));
        string ruta = @"C:\" + NombreArchivo;

        try
        {
            //C:\Windows\SysWOW64
            ruta = NombreArchivo + (esError ? "_error" : string.Empty) + ".log";
            _sRuta = ruta.Trim();

            if (!File.Exists(ruta))
            {
                Console.WriteLine(Directory.GetCurrentDirectory());
                Console.WriteLine(ruta);

                using (StreamWriter sw = File.CreateText(ruta))
                {
                    sw.WriteLine(string.Format("Archivo creado el {0} \n", DateTime.Now.ToString("dd/MM/yyyy HH:mm:ss.fff")));
                }

                DirectoryInfo di = new DirectoryInfo(ruta);
                Console.WriteLine(di.FullName);

                if (di.Parent != null)
                {
                    if (Directory.Exists(di.Parent.FullName))
                    {
                        EliminaLOGantiguo(di.Parent.FullName);
                    }
                }
            }
        }
        catch
        { }
        finally
        { }

        return ruta;
    }
    public static string ObtenerCarpetaEnsamblado()
    {
        string res = string.Empty;
        try
        {
            if (System.Reflection.Assembly.GetEntryAssembly() != null)
            {
                res = System.Reflection.Assembly.GetEntryAssembly().Location;
            }
        }
        catch { res = System.IO.Directory.GetCurrentDirectory(); }

        return res;
    }
    public static void EscribeLog(string texto, bool esError = false)
    {
        string archivoLog = string.Empty;
        StreamWriter? sw = null;

        try
        {
            if (!esError)
            {
                if (texto.ToLower().Trim().StartsWith("error"))
                {
                    esError = true;
                }
            }

            archivoLog = CreaLog(esError);
            sw = new StreamWriter(archivoLog, true);

            texto = string.Format("{0} {1}", DateTime.Now.ToString("HH:mm:ss.fff"), texto);

            sw.WriteLine(texto);
        }
        catch
        { }
        finally
        {
            if (sw != null)
            {
                sw.Dispose();
                GC.SuppressFinalize(sw);
            }
        }
    }
    public static void RegistraExcepcion(Exception ex)
    {
        string msj;

        msj = string.Format("Error: {0}", ex.Message);

        if (ex.InnerException != null) { msj = msj + " \n " + ex.InnerException.Message; }
        if (ex.Source != null) { msj = msj + " \n " + ex.Source; }
        if (ex.StackTrace != null) { msj = msj + " \n " + ex.StackTrace; }
        if (ex.TargetSite != null)
        {
            msj = msj + " \n " + ex.TargetSite.Name;
            foreach (System.Reflection.ParameterInfo param in ex.TargetSite.GetParameters())
            {
                if (param.DefaultValue != null)
                {
                    if (string.IsNullOrEmpty(param.DefaultValue.ToString()))
                    {
                        msj = msj + " \n " + param.Name + " = string.Empty";
                    }
                    else
                    {
                        msj = msj + " \n " + param.Name + " = " + param.DefaultValue.ToString();
                    }
                }
                else
                {
                    msj = msj + " \n " + param.Name + " = NULL";
                }
            }
        }

        msj = msj.Trim();

        LOG.EscribeLog(msj, true);
    }
    public static void EliminaLOGantiguo(string sRuta)
    {
        FileInfo? fi = null;

        try
        {
            if (Directory.Exists(sRuta))
            {
                foreach (string sNombreArchivo in Directory.GetFiles(sRuta))
                {
                    try
                    {
                        if (sNombreArchivo.ToLower().Trim().EndsWith(".log") && LOG.puede_procesar_carpeta_archivo(sNombreArchivo))
                        {
                            fi = new FileInfo(sNombreArchivo);
                            if (fi.CreationTimeUtc < DateTime.Now.AddDays(-100))
                            {
                                File.Delete(sNombreArchivo);
                                EscribeLog(string.Format("	Como parte del mantenimiento del Repositorio de archivos, se eliminó el archivo LOG:	'{0}'.", sNombreArchivo));
                            }
                        }
                    }
                    catch { }
                }
            }
        }
        catch
        { }
    }
    public static void EliminaLOGantiguoSub(string sRuta)
    {
        FileInfo? fi = null;

        try
        {
            if (Directory.Exists(sRuta))
            {
                foreach (string sNombreArchivo in Directory.GetFiles(sRuta))
                {
                    try
                    {
                        if (iInfo > DateTime.Now.Day)
                        {
                            iInfo = iInfo / 2;
                            break;
                        }

                        if (sNombreArchivo.ToLower().Trim().EndsWith(".log") && LOG.puede_procesar_carpeta_archivo(sNombreArchivo))
                        {
                            fi = new FileInfo(sNombreArchivo);
                            if (fi.CreationTimeUtc < DateTime.Now.AddDays(-100))
                            {
                                File.Delete(sNombreArchivo);
                                EscribeLog(string.Format("	Como parte del mantenimiento del Repositorio de archivos, se eliminó el archivo LOG:	'{0}'.", sNombreArchivo));
                                iInfo++;
                            }
                        }
                    }
                    catch { }
                }
                foreach (string sNombreCarpeta in Directory.GetDirectories(sRuta))
                {
                    try
                    {
                        iInfo++;
                        if (iInfo > DateTime.Now.Day)
                        {
                            iInfo = iInfo % 2;
                            break;
                        }

                        EliminaLOGantiguoSub(sNombreCarpeta);
                    }
                    catch { }
                }
            }
        }
        catch
        { }
    }
    public static bool puede_procesar_carpeta_archivo(string sNombre_carpeta_archivo)
    {
        bool res = true;
        string txt = string.Empty;
        DateTime fecha = DateTime.Now;
        DateTime diaVencido = DateTime.Now.AddDays(-1);
        DateTime mesVencido = DateTime.Now.AddMonths(-1);

        try
        {
            txt = sNombre_carpeta_archivo.Replace("_", string.Empty).Replace("-", string.Empty).Replace("/", string.Empty).Replace(":", string.Empty).Replace("[", string.Empty).Replace("]", string.Empty).Replace("(", string.Empty).Replace(")", string.Empty).Replace(".", string.Empty).Replace(" ", string.Empty).Replace("\\", string.Empty);

            if (txt.Contains(fecha.ToString("dd")) || txt.Contains(fecha.ToString("MM")) || txt.Contains(fecha.ToString("yy")))
            {
                res = false;
            }
            else if (txt.Contains(diaVencido.ToString("dd")) || txt.Contains(diaVencido.ToString("MM")) || txt.Contains(diaVencido.ToString("yy")))
            {
                res = false;
            }
            else if (txt.Contains(mesVencido.ToString("dd")) || txt.Contains(mesVencido.ToString("MM")) || txt.Contains(mesVencido.ToString("yy")))
            {
                res = false;
            }
            else if (txt.Contains(fecha.AddYears(-3).ToString("dd")) || txt.Contains(fecha.AddYears(-2).ToString("MM")) || txt.Contains(fecha.AddYears(-1).ToString("yy")))
            {
                res = false;
            }
            else if (txt.Contains(fecha.Day.ToString()) || txt.Contains(fecha.Month.ToString()) || txt.Contains(fecha.Year.ToString()))
            {
                res = false;
            }
        }
        catch
        {
            res = false;
        }
        finally
        {
            txt = string.Empty;
            GC.SuppressFinalize(fecha);
            GC.SuppressFinalize(diaVencido);
            GC.SuppressFinalize(mesVencido);
        }

        return res;
    }
    public static bool EsModoPrueba()
    {
        try
        {
            System.Reflection.Assembly dll = System.Reflection.Assembly.Load("Xpooler-ProcesosImportantes");

            return dll.GetCustomAttributes(false)
                       .OfType<System.Diagnostics.DebuggableAttribute>()
                       .Select(da => da.IsJITTrackingEnabled)
                       .FirstOrDefault();
        }
        catch
        {
            return false;
        }
    }
    public static string ObtenerValor_AppConfig(string llave)
    {
        string? res = string.Empty;

        res = System.Configuration.ConfigurationManager.AppSettings.Get(llave);

        if (res == null)
        {
            res = string.Empty;
        }

        return res;
    }
}