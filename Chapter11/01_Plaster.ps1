# List the default (shipped) templates
Get-PlasterTemplate

# List all templates
Get-PlasterTemplate -IncludeInstalledModules

# Create new, empty template
mkdir .\PlasterTemplates\FirstTemplate -Force
New-PlasterManifest -TemplateType Project -TemplateName FirstTemplate -Path .\PlasterTemplates\FirstTemplate\plasterManifest.xml

# The template needs to be extended first
# See the online help at https://github.com/PowerShell/Plaster/blob/master/docs/en-US/about_Plaster_CreatingAManifest.help.md
# or use Get-Help
Get-Help about_Plaster_CreatingAManifest
psedit .\PlasterTemplates\FirstTemplate\plasterManifest.xml

# Extend the template

# Add some parameters
[xml]$content = Get-Content -Path .\PlasterTemplates\FirstTemplate\plasterManifest.xml

# This XML has a namespace - instanciate a namespace manager before
$nsm = [System.Xml.XmlNamespaceManager]::new($Content.NameTable)
$nsm.AddNamespace('pl', "http://www.microsoft.com/schemas/PowerShell/Plaster/v1")

$parameterNode = $content.SelectSingleNode('/pl:plasterManifest/pl:parameters', $nsm)

$node = $content.CreateElement('parameter', $nsm.LookupNamespace('pl'))
$name = $content.CreateAttribute('name')
$name.Value = 'Author'
$type = $content.CreateAttribute('type')
$type.Value = 'user-fullname'
$prompt = $content.CreateAttribute('prompt')
$prompt.Value = 'Please enter your full name.'
$node.Attributes.Append($name)
$node.Attributes.Append($type)
$node.Attributes.Append($prompt)
$parameterNode.AppendChild($node)

$node = $content.CreateElement('parameter', $nsm.LookupNamespace('pl'))
$name = $content.CreateAttribute( 'name')
$name.Value = 'ModuleName'
$type = $content.CreateAttribute('type')
$type.Value = 'text'
$prompt = $content.CreateAttribute('prompt')
$prompt.Value = 'Please enter the module name.'
$node.Attributes.Append($name)
$node.Attributes.Append($type)
$node.Attributes.Append($prompt)
$parameterNode.AppendChild($node)

$node = $content.CreateElement('parameter', $nsm.LookupNamespace('pl'))
$name = $content.CreateAttribute('name')
$name.Value = 'Version'
$type = $content.CreateAttribute('type')
$type.Value = 'text'
$default = $content.CreateAttribute('default')
$default.Value = '0.1.0'
$prompt = $content.CreateAttribute('prompt')
$prompt.Value = 'Please enter a module version.'
$node.Attributes.Append($name)
$node.Attributes.Append($type)
$node.Attributes.Append($default)
$node.Attributes.Append($prompt)
$parameterNode.AppendChild($node)

$content.Save('.\PlasterTemplates\FirstTemplate\plasterManifest.xml')

# Test it
$destination = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath MyFirstModule
$template = Invoke-Plaster -TemplatePath .\PlasterTemplates\FirstTemplate -DestinationPath $destination -PassThru
Get-ChildItem -Path $template.DestinationPath

# Automatic discovery
# Your module manifest needs to contain an Extensions key in
# the PSData hashtable
$excerpt = @{
    Extensions = @(
        @{
            Module         = "Plaster"
            MinimumVersion = "0.3.0"
            Details        = @{
                TemplatePaths = @("Templates\FirstTemplate", "Templates\SecondTemplate")
            }
        }
    )
}

# That given, you can use these templates as well. They also appear in VSCode
$destination = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath AutoDiscovered
$templates = Get-PlasterTemplate -IncludeInstalledModules
Invoke-Plaster -TemplatePath $templates[-1].TemplatePath -DestinationPath $destination