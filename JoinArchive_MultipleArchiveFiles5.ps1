#converts bin file and source archive to the new archive destination
#Written by Jim Sheldon on May 3, 2019
#*******************************************************************
#run process function
function testOutput($x, $y, $z){

    Write-Host $x $y $z

}

#*******************************************************************
#sets the PI Archive Tool Process
function PITool($y1, $z1, $binFile, $sFolder, $dFolder, $srtTime, $endTime, $filterSTime, $filterEtime){
    
    #archive tool destination
    $buildArchiveTool = "E:\pi\bin\piarchss.exe" 

    
    $y1 = ($sFolder + $y1)
    $z1 = ($dFolder + $z1)

    $outFile = "E:\PI\arc\out\" + $y1.substring(19,29) +   "_" + $z1.substring(19,19)   + ".txt"

    #Write-Host $outFile

    
    #argurments and calling the process name
    $arguments = "-id $binFile -if $y1 -of $z1 -ost ""$srtTime"" -oet ""$endTime"" -filter_ex ""$filterSTime"" ""$filterETime"" "
    
    #lets the user know what is being processed
    Write-Host $arguments $outFile
    
    #Starts the process, waits until it is finished and keeps moving.
    Start-Process $buildArchiveTool $arguments -Wait -RedirectStandardOutput $outFile

    Return $arguments



}
#*******************************************************************
#Retrieves the file start time
Function getStartTime($srcFile){

#
$strDiagAll = E:\PI\adm\pidiag.exe -ahd $srcFile 
$strStartTime = $strDiagAll[7] 

#Write-Host $srcFile

#Write-Host $strDiagAll

return $strStartTime.Substring(19)

}

#*******************************************************************
#Retrieves the file end time
Function getEndTime($srcFile){

#
$strDiagAll = E:\PI\adm\pidiag.exe -ahd $srcFile 
$strEndTime = $strDiagAll[8] 

#Write-Host $strDiagAll

return $strEndTime.Substring(19)

}

#*******************************************************************
#*******************************************************************
#*******************************************************************
#Starts the main program. Modify file locations in this section.

#Source archive folder location
$sourceFolder = "E:\PI\Migrate\2014\"

#Source bin file location.
$sourceBinFile = "E:\PI\Migrate\Migrate_GGS\GGS_Tags_Out3.bin"

#processed file location
#$sourceFolder_Processed = "E:\PI\Migrate\Migrate_CGS\Test\processed.txt"

#Destination archive folder location
$destFolder = "E:\PI\arc\"

#This txt files lists the archive files that did not process at all.
$fileProcessNotes = "E:\PI\arc\out\GGS_ProcessNotes.txt"

#archive tool destination
$buildArchiveTool = "E:\pi\bin\piarchss.exe" 

#usually the new PI server name
#$newFilePrefix = "HDQv1773_"

#*********************************************************************


#gets the source archive files in a variable
$SourceArchiveFiles = Get-ChildItem -Name $sourceFolder -Filter *.arc 

#gets the dest archive files in a variable
$DestArchiveFiles = Get-ChildItem -Name $destFolder -Filter *.arc 

#sets the $lastArguments record
$lastArguments = ""



#********************************************************
#Setting the source variables

#checks to see if the processed text file exists, if so it deletes it.
If(Test-Path $fileProcessNotes){ Remove-Item $fileProcessNotes}

#source record variable
$i = 0

#sets the number of input files to process. If only one set this manuall to 1, just move the comment.$s
$srcCount = $SourceArchiveFiles.Length
#$srcCount = 1

#source start time variable
$A = ""

#source end time variable
$B = ""

#loops through each source archive file
DO{

    #this is the first record date
    $A = getStartTime ($sourceFolder + $SourceArchiveFiles[$i])

    #this is the next record date, if only one set this manually, just move the comment
    #and adjust the date.
    $B = getEndTime ($sourceFolder + $SourceArchiveFiles[$i])
    #B = "2010-06-28"

    #********************************************************
    #Setting the dest variables

    #dest record variable
    $destCount = 0

    #sets the number of dest files to process. If only one set this manuall to 1, just move the comment.
    $destCount = $DestArchiveFiles.Length

    #dest start time variable
    $C = ""

    #dest end time variable
    $D = ""

    #dest file record index
    $j = 0

    $x = 0

    

    #************************************************************************
    #loops to find the correct dest file to process.
    DO{

           
        #this sets the dest start time.
        $C = getStartTime ($destFolder + $DestArchiveFiles[$j])

         #this sets the dest end time.
        $D = getEndTime ($destFolder + $DestArchiveFiles[$j])

        #Write-Host $A $B $C $D

        #Read-Host "wait"

        if(([datetime]$A -ge [datetime]$C) -and ([datetime]$A -le [datetime]$D) -and ([datetime]$A -ne [datetime]$D)){

            if([datetime]$B -le [datetime]$D){

                
                Write-Host "here_one_AB" $i $j
                $lastArguments = PITool $SourceArchiveFiles[$i] $DestArchiveFiles[$j] $sourceBinFile $sourceFolder $destFolder $C $D $A $B 
                
                #flags the input archive file as fully processed.               
                $x = 1

                #Read-Host "wait"


            }
            elseif($j -ne $destCount-2){

                Write-Host "here_two_AD" $i $j
                $lastArguments = PITool $SourceArchiveFiles[$i] $DestArchiveFiles[$j] $sourceBinFile $sourceFolder $destFolder $C $D $A $D 

                #initiates $q which is the dest record.
                $q = $j + 1
                
                DO{

                    #this sets the next dest start time.
                    $C = getStartTime ($destFolder + $DestArchiveFiles[$q])

                    #this sets the next dest end time.
                    $D = getEndTime ($destFolder + $DestArchiveFiles[$q])
                
                    if([datetime]$B -lt [datetime]$D){

                        Write-Host "here_three_CB" $i ($q)
                        $lastArguments = PITool $SourceArchiveFiles[$i] $DestArchiveFiles[$q] $sourceBinFile $sourceFolder $destFolder $C $D $C $B    
                        

                        #flags the input archive file as fully processed.
                        $x = 1
                        

                        }
                    elseif($j -ne $destCount-3){

                        Write-Host "here_four_CD" $i ($q)
                        $lastArguments = PITool $SourceArchiveFiles[$i] $DestArchiveFiles[$q] $sourceBinFile $sourceFolder $destFolder $C $D $C $D 
                                        
                        #this sets the next dest start time.
                        #$C = getStartTime ($destFolder + $DestArchiveFiles[$j+$nextFile])

                        #this sets the next dest end time.
                        #$D = getEndTime ($destFolder + $DestArchiveFiles[$j+$nextFile])

                        #increases to the next file
                        $q = $q + 1
                                 
                     }

                     #write $x
                     #Write-Host $lastArguments

                 }While($x -eq 0)   

                }
                
                


            }
                
        $j++

        #write-host $j
        
        }While(($j -lt $destCount-3) -and ($x -eq 0))

        If($x -eq 0){Add-Content $fileProcessNotes $SourceArchiveFiles[$i]}

         $i++

         write-host $i " of " $srcCount " processed"
        
}While($i -lt $srcCount)

#ensures the last file is written to the text file as it was not processed
Add-Content $fileProcessNotes ("last_file -->  " + $SourceArchiveFiles[$i-1])
Add-Content $fileProcessNotes ("last_arguments -->  " + $lastArguments)







