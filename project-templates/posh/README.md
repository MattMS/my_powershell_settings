# PowersHell

## Testing

```
dotnet publish
Import-Module ./bin/Debug/net5.0/publish/Library.dll
```

### Warnings

Testing needs to be done in a new terminal each time.
This is easiest in the VS Code terminal, as it can be opened to the correct path quickly.

Using `Remove-Module` does not appear to detach the DLL and causes `dotnet publish` to throw warnings.

## Reference

- [`Cmdlet` Class](https://docs.microsoft.com/en-au/dotnet/api/System.Management.Automation.Cmdlet?view=powershellsdk-7.0.0)
- [`CmdletAttribute` Class](https://docs.microsoft.com/en-au/dotnet/api/system.management.automation.cmdletattribute?view=powershellsdk-7.0.0)
- [`ParameterAttribute` Class](https://docs.microsoft.com/en-au/dotnet/api/system.management.automation.parameterattribute?view=powershellsdk-7.0.0)
- [`System.Management.Automation` Namespace](https://docs.microsoft.com/en-au/dotnet/api/system.management.automation?view=powershellsdk-7.0.0)
