#converts bin file and source archive to the new archive destination
#Written by Jim Sheldon on May 3, 2019
#*******************************************************************

#Source archive folder location
$sourceFolder = "E:\PI\Migrate\dest\TobeReproccessed\1\"

#usually the new PI server name
$newFilePrefix = "HDQv1773_"

#bin files location with tags
$sourceBinFile = "E:\PI\Migrate\HDQv1615_Tags3.bin"

#Destination archive folder location
$destinationFolderReprocess = "E:\PI\Migrate\dest\processed\"

#archive tool destination
$buildArchiveTool = "E:\pi\bin\piarchss.exe"

#text output folder location
$outFolder = "E:\PI\Migrate\dest\out\"

#Checks if the user wants to test the script or process.
$processOrTest = Read-Host -Prompt "Do you want to process or test?`nTo process press 9`nTo test press any key"

#Double checks for processing
If($processOrTest -eq 9){

    $areYouSure = Read-Host -Prompt "`nAre you sure you want to process? Enter Y or N"

    If($areYouSure.ToUpper() -ne "Y"){
    
        $processOrTest = 0
        write-host "`n ***Testing Only***"
        
        }
    Else{Write-Host "`n***Beginning to Process***"} 
}

#*********************************************************************
#Clear-variable "SourceArchiveFiles"

#gets the source archive files in a variable
$SourceArchiveFiles = Get-ChildItem -Name $sourceFolder -Filter *.arc 

#tracks the rec no for informational purposes.
$recCount = 1

#loops through each source archive file
foreach($i in $SourceArchiveFiles) 
{

   #takes off the first ten chars of the filename, may not be needed.
    $partFileName = $i.ToString()
    
    #source archive file name
    $sourceFileName = $sourceFolder + $i
       
    #new archive file name and dest
    $destFileNameReprocess = $destinationFolderReprocess + $newFilePrefix + $partFileName.Substring(9) 

     #output text file name
    $outFile = $outFolder + $newFilePrefix + $partFileName.Substring(9) + ".txt"
        

    #argurments and calling the process name. 
    $arguments = "-id $sourceBinFile -if $sourceFileName -of $destFileNameReprocess -f 0 -noinputcheck"

    write-host $arguments $outFile #$sourceFileName $destFileName #$destFileNameReprocess  $outFile 
            

    If($processOrTest -eq 9){
    
        #Starts the process, waits until it is finished and keeps moving.
        Start-Process $buildArchiveTool -ArgumentList $arguments -Wait -RedirectStandardOutput $outFile     

    }
       

    #for display and information purposes
    Write-Host "Processed " $recCount " of " $SourceArchiveFiles.Length

    $recCount= $recCount + 1

}
write-host ""
write-host ""
write-host ""
write-host "****FINISHED****"
