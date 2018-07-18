$path = "E:\Test"
$filter = "TestFile1*"

#Get-ChildItem with exclude
Measure-Command -Expression {
    $files = Get-ChildItem -Path "$path\*" -Filter $filter -Exclude *000* | Sort-Object -Property LastWriteTime -Descending | Select-Object -First 5
} | Select-Object -Property TotalSeconds #17 - 20 seconds

#Get-ChildItem with Where-Object filtering
Measure-Command -Expression {
    $files = Get-ChildItem -Path $path -Filter $filter | Where-Object Name -NotLike *000* | Sort-Object -Property LastWriteTime -Descending | Select-Object -First 5
} | Select-Object -Property TotalSeconds # 5- 7 seconds

#.NET objects combined with LINQ
Measure-Command -Expression {
    $directory = [System.IO.DirectoryInfo]::new($path)
    $files = $directory.GetFiles($filter) #files contains 50k out of 150k items

    [Func[System.IO.FileInfo, bool]] $delegate = { param($f) return $f.Name -notlike '*000*' }
    $files = [Linq.Enumerable]::Where($files, $delegate) #49815 items left

    $files = [Linq.Enumerable]::OrderByDescending($files, [Func[System.IO.FileInfo, System.DateTime]] { $args[0].LastWriteTime }) #like Sort-Object
    $files = [Linq.Enumerable]::Take($files, 5) #like Select-Object -First 5
    $files = [Linq.Enumerable]::ToArray($files) #convert the System.Collections.Generic.IEnumerable into an array
} | Select-Object -Property TotalSeconds # ~1 second 
