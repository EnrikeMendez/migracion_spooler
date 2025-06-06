namespace Xpooler_Distribucion
{
    public class ServiceWorker : BackgroundService
    {
        private readonly ILogger<ServiceWorker> _logger;
        private readonly IConfiguration Configuration;

        public ServiceWorker(ILogger<ServiceWorker> logger, IConfiguration _configuration)
        {
            _logger = logger;
            Configuration = _configuration;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            int i = 0;
            bool allOK = true;
            int timeDelay = 1000;
            int processAtTime = 10;
            MainService _service = new MainService();
            
            try
            {
                int.TryParse(_service.GetConfigValue("TimeScan"), out timeDelay);
                int.TryParse(_service.GetConfigValue("ProcessAtTime"), out processAtTime);
                _logger.LogInformation("{time} El servicio se estará ejecutando cada: {timeDelay} segundos.", DateTime.Now.ToString("dd/MM/yyyy HH:mm:ss.fff"), timeDelay);

                if ((_service.GetConfigValue("DB_DIST") ?? string.Empty).Equals(string.Empty))
                {
                    _logger.LogWarning("{time} La conexión a Base de Datos no se encuentra registrada.", DateTime.Now.ToString("dd/MM/yyyy HH:mm:ss.fff"));
                    allOK = false;
                }
                else
                {
                    if (!(_service.GetConfigValue("DB_DIST")?? string.Empty).ToUpper().Contains("DATA SOURCE") ||
                        !(_service.GetConfigValue("DB_DIST")?? string.Empty).ToUpper().Contains("USER ID") ||
                        !(_service.GetConfigValue("DB_DIST")?? string.Empty).ToUpper().Contains("PASSWORD"))
                    {
                        _logger.LogWarning("{time} La conexión a Base de Datos no está configurada de manera correcta.", DateTime.Now.ToString("dd/MM/yyyy HH:mm:ss.fff"));
                        allOK = false;
                    }
                }


                if (allOK)
                {
                    timeDelay = timeDelay <= 0 ? 1000 : timeDelay * 1000;
                    processAtTime = processAtTime <= 0 ? 10 : processAtTime * 1;
                    await Task.Delay(timeDelay, stoppingToken);

                    while (!stoppingToken.IsCancellationRequested)
                    {
                        for (i = 0; i < processAtTime; i++)
                        {
                            if (_logger.IsEnabled(LogLevel.Information))
                            {
                                //_logger.LogInformation("Worker running at: {time}", DateTimeOffset.Now);
                                _logger.LogInformation(i.ToString());
                                _logger.LogInformation(_service.GetProcess());
                                //_service.GetProcess();
                            }
                        }
                        await Task.Delay(timeDelay, stoppingToken);
                    }
                }
                else
                {
                    _logger.LogWarning("{time} Fin del proceso.", DateTime.Now.ToString("dd/MM/yyyy HH:mm:ss.fff"));
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.ToString(), ex);
            }
        }
    }
}