module MattMS.TryGiraffe.Server

open Microsoft.AspNetCore.Builder
open Microsoft.Extensions.Hosting
open Giraffe

let webApp = route "/" >=> text "It works"

[<EntryPoint>]
let main args =
    let builder = WebApplication.CreateBuilder args
    builder.Services.AddGiraffe() |> ignore
    let app = builder.Build()
    app.UseGiraffe webApp
    app.Run()
    0
