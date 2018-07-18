@{
    psdeploy = 'latest'

    buildhelpers_0_0_20 = @{
        Name = 'buildhelpers'
        DependencyType = 'PSGalleryModule'
        Parameters = @{
            Repository = 'PSGallery'
            SkipPublisherCheck = $true
        }
        Version = '0.0.20'
        DependsOn = 'nuget'
    }

    notepadplusplus = @{
        DependencyType = 'Package'
        Target = 'C:\npp'
        DependsOn = 'nuget'
    }

    nuget = @{
        DependencyType = 'FileDownload'
        Source = 'https://dist.nuget.org/win-x86-commandline/latest/nuget.exe'
        Target = 'C:\nuget.exe'
    }
}
