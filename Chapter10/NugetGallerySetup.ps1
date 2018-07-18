$x = [xml](get-content web.config)
$x.SelectSingleNode('/configuration/connectionStrings/add[@name="Gallery.SqlServer"]')