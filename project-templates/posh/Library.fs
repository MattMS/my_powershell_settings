namespace MattMS.MyPoshLibrary

open System.Management.Automation

[<Cmdlet(VerbsCommon.Get, "Many")>]
type GetManyCommand() =
    inherit Cmdlet()

    [<Parameter(Position=1)>]
    member val Repeat : int = 2 with get, set

    [<Parameter(ValueFromPipeline=true, ValueFromPipelineByPropertyName=true)>]
    member val Text : string[] = Array.empty with get, set

    override self.BeginProcessing () =
        self.WriteVerbose("Getting started")
        ()

    override self.EndProcessing () =
        self.WriteVerbose("All done")
        ()

    override self.ProcessRecord () =
        self.Text |> Seq.map (String.replicate self.Repeat) |> Seq.iter self.WriteObject
        ()
