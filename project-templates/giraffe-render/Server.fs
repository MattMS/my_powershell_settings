module MattMS.TryGiraffe.Server

open Microsoft.AspNetCore.Builder
open Microsoft.Extensions.Hosting
open Giraffe
open Giraffe.ViewEngine

let render = RenderView.AsString.xmlNode >> sprintf "<!doctype html>%s" >> htmlString

let wrapPage titleContent bodyContent =
    html [] [
        head [] [
            meta [_charset "utf-8"]
            title [] [str titleContent]
        ]
        body [] bodyContent
    ]

let index =
    wrapPage "Trying Giraffe" [
        h1 [] [str "Trying Giraffe"]
    ]

let webApp = route "/" >=> render index

[<EntryPoint>]
let main args =
    let builder = WebApplication.CreateBuilder args
    builder.Services.AddGiraffe() |> ignore
    let app = builder.Build()
    app.UseGiraffe webApp
    app.Run()
    0
