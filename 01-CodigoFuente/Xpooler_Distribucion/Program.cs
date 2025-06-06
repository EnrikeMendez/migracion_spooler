using Xpooler_Distribucion;

var builder = Host.CreateApplicationBuilder(args);
builder.Services.AddHostedService<ServiceWorker>();

var host = builder.Build();
host.Run();