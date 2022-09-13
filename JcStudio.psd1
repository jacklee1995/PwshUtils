@{
    RootModule = 'JcStudio.psm1'
    ModuleVersion = '0.0.1'
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
        'Src\datetime.psm1'
        'Src\logger.psm1'
        'Src\path.psm1'
        'Src\os.psm1'
        'Src\http.psm1'
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
