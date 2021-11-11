namespace MattMS.TryASP

type MyResponse =
    {
        Ok: bool
        Value: int
    }

namespace MattMS.TryASP.Controllers

open Microsoft.AspNetCore.Mvc
open Microsoft.Extensions.Logging
open MattMS.TryASP

[<ApiController>]
[<Route("[controller]")>]
type RandomController (logger : ILogger<RandomController>) =
    inherit ControllerBase()

    // Visit at https://localhost:5001/Random
    [<HttpGet>]
    member _.Get() =
        let rng = System.Random()
        let value = rng.Next(0, 255)
        logger.LogInformation("Picked {value}", value)
        {
            Ok = true
            Value = value
        }

namespace MattMS.TryASP

open Microsoft.AspNetCore.Builder
open Microsoft.AspNetCore.Hosting
open Microsoft.Extensions.Configuration
open Microsoft.Extensions.DependencyInjection
open Microsoft.Extensions.Hosting

type Startup(configuration: IConfiguration) =
    member _.Configuration = configuration

    member _.Configure(app: IApplicationBuilder, env: IWebHostEnvironment) =
        if (env.IsDevelopment()) then
            app.UseDeveloperExceptionPage() |> ignore

        app.UseHttpsRedirection()
            .UseRouting()
            .UseAuthorization()
            .UseEndpoints(fun endpoints ->
                endpoints.MapControllers() |> ignore
            ) |> ignore

    member _.ConfigureServices(services: IServiceCollection) =
        services.AddControllers() |> ignore

module Program =
    [<EntryPoint>]
    let main args =
        Host.CreateDefaultBuilder(args)
            .ConfigureWebHostDefaults(fun builder ->
                builder.UseStartup<Startup>() |> ignore
            )
            .Build().Run()

        0
