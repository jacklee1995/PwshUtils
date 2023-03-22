@{
    RootModule = 'PwshUtils.psm1'
    ModuleVersion = '0.0.2'
    GUID = ''
    Author = 'jacklee1995'
    CompanyName = 'jcStudio'
    Copyright = '(c) 2022 jacklee1995, licensed under MIT License.'
    Description = 'A powershell utils set.'
    PowerShellVersion = '5.1'
    HelpInfoURI       = ''
    RequiredModules   = @()
    FunctionsToExport = ''
    NestedModules = @(
        'src\datetime.psm1'
        'src\http.psm1'
        'src\logger.psm1'
        'src\os.psm1'
        'src\path.psm1'
    )


    PrivateData = @{
        PSData = @{
            Tags = @('datetime', 'logger', 'path', 'os', 'http', 'date', 'time', 'network')
            LicenseUri = ''
            ProjectUri = ''
            IconUri = ''
            ReleaseNotes = ''
        }
    }

}