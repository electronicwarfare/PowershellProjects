
#*****************************************************
#This script pulls OSIsoft PI data for an analog tag over a specific date range.
#The data is saved in a .txt file
#The PI archive servername, tagname, start and end times, and outfile must be updated for your system.

#*****************************************************
#Set up tag and dates,  and outfile location.

$archiveServer = "xxxArchiveNamexxx"

$myPI = Connect-PIDataArchive $archiveServer

$tagName = "xxxTagNamexxx"

#dates must be in osisoft pi format (1-Jul-22 13:00:00)
#there are entire websites devoted to OSIsoft PI times and references.

$startTime = "1-Jan-20" 

$endTime = "2-Jan-20 12:00:00"

$outFile = "xxxFolderforOuptutxxx" + $tagName + "_raw.txt"

#*****************************************************
#retrieve data
 
write-host "`n`nRetrieving Data`n`n"

$myValues = Get-PIValue -PointName $tagName -Connection $myPI -StartTime $startTime -EndTime $endTime | Select-Object -Property value,@{Name='TimeStamp (Local Time Zone)';Expression={$_.timestamp.tolocaltime()}} #| Out-File -FilePath E:\PI\Powershell_Out.txt

#gets the number of records.
$valueCount = $myValues.Length

#pulls the state value of the digital point
$analogValues = $myValues.Value

#pulls the time of the event
$sTime = ($myValues.'TimeStamp (Local Time Zone)' | Get-Date -Format s).Substring(11,8)

#pulls the date of the event
$sDate = $myValues.'TimeStamp (Local Time Zone)' | Get-Date -Format 'yyyy-MM-dd'

#*****************************************************
#output data to txt

write-host "`n`nOutputting to text file`n`n"



If(Test-Path $outFile){ Remove-Item $outFile}

$fs = New-Object System.IO.FileStream $outFile, 'Append', 'Write', 'Read'

$myStreamWriter = New-Object System.IO.StreamWriter($fs)

#outputs the data stream to a csv
for($i=0; $i -lt $valueCount; $i++){

    
    $myStreamWriter.WriteLine("$($AnalogValues[$i]),$($sDate[$i] + " " + $sTime[$i])")
    
    }

    $myStreamWriter.Close()

write-host "`n`nData Retrieval Process complete`n`n"










