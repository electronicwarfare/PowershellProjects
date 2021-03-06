#This script converts an OSIsoft PI bin file and source archive to the new archive.
#this is used when merging archives manually. It is can take a long time.
#6 months of data conversion can take 1-2 days.
#This script is intended for multiple source files and will not work for only one source file, however:
#if you need to merge a single source file, there are sections in the script to change. Read carefully.

#!!!Go down through the program section to adjust variables and folders.!!!
#!!! you will see three !!! to know to update variables and folders for your systems. 
#

#Written by Jim Sheldon on May 3, 2019
#*******************************************************************
#run process function
function testOutput($x, $y, $z){

    Write-Host $x $y $z

}

#*******************************************************************
#sets the PI Archive Tool Process and variables, output file location.
function PITool($y1, $z1, $binFile, $sFolder, $dFolder, $srtTime, $endTime, $filterSTime, $filterEtime, $processOrTest){
    
    # !!! piarchss.exe PI archive tool file location. This may be different on your system.
    $buildArchiveTool = "E:\pi\bin\piarchss.exe" 

    
    
    $y1 = ($sFolder + $y1)
    $z1 = ($dFolder + $z1)

    # !!! This would be your output folder location
    $outFile = "xxxOutputFolderLocationxxx" + $y1.substring(23,28) +   "_" + $z1.substring(19,28)   + ".txt"

    #Write-Host $outFile

    $dayTime = Get-Date -Format g
     
    
    #argurments and calling the process name
    $arguments = "-id $binFile -if $y1 -of $z1 -ost ""$srtTime"" -oet ""$endTime"" -filter_ex ""$filterSTime"" ""$filterETime"" "
    
    #lets the user know what is being processed
    Write-Host "`n"$dayTime `n$arguments`n $outFile "`n"
    #Write-Host $outFile
    
    If($processOrTest -eq 9){

        #Starts the process, waits until it is finished and keeps moving.
        Start-Process $buildArchiveTool $arguments -Wait -RedirectStandardOutput $outFile

}

    Return $arguments



}
#*******************************************************************
#Retrieves the file start time using one of the built in PI tools pidiag.exe
Function getStartTime($srcFile){

# !!! enter the location for pidiag.exe
$strDiagAll = E:\PI\adm\pidiag.exe -ahd $srcFile 
$strStartTime = $strDiagAll[7] 

#Write-Host $srcFile

#Write-Host $strDiagAll

#this statement returns 0 if the file is busy. Eliminates error messages.
If($null -ne $strStartTime){return $strStartTime.Substring(19)}
Else{return 0}

}

#*******************************************************************
#Retrieves the file end time using one of the built in PI tools pidiag.exe
Function getEndTime($srcFile){

# !!! enter the location for pidiag.exe
$strDiagAll = E:\PI\adm\pidiag.exe -ahd $srcFile 
$strEndTime = $strDiagAll[8] 

#Write-Host $strDiagAll

return $strEndTime.Substring(19)

}

#*******************************************************************
#*******************************************************************
#*******************************************************************
#Starts the main program. Modify file locations in this section.

# !!! Source archive folder location
$sourceFolder = "xxxSourceArchiveFolderLocationxxx"

# !!! Source bin file location.
$sourceBinFile = "xxxSourceBinFolderLocationxxx"

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

# !!! Destination archive folder location
$destFolder = "E:\PI\Migrate\dest\"

# !!! piarchss.exe archive tool location
$buildArchiveTool = "E:\pi\bin\piarchss.exe" 



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
#If(Test-Path $fileProcessNotes){ Remove-Item $fileProcessNotes}

#source record variable
$i = 0

#sets the number of input files to process. If only one set this manually to 1, just move the comment
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

        #this statement checks to see if the dest file is busy, if so it skips the error messages.
        If($C -ne 0){

            #this sets the dest end time.
            $D = getEndTime ($destFolder + $DestArchiveFiles[$j])

            }
        Else{
        
            $D = 0
            #Write-Host "`n" $DestArchiveFiles[$j] " is being used. `n"
            }
        
        #write-host $SourceArchiveFiles[$i]
        #Write-Host $A $B $C $D
        #Write-Host $j $destCount

        #Read-Host "wait"

        if(([datetime]$A -ge [datetime]$C) -and ([datetime]$A -le [datetime]$D) -and ([datetime]$A -ne [datetime]$D) -and ($C -ne 0)){

            if([datetime]$B -le [datetime]$D){

                
                Write-Host "here_one_AB" $i $j
                $lastArguments = PITool $SourceArchiveFiles[$i] $DestArchiveFiles[$j] $sourceBinFile $sourceFolder $destFolder $C $D $A $B $processOrTest
                
                #flags the input archive file as fully processed.               
                $x = 1

                #Read-Host "wait"


            }
            elseif($j -lt $destCount){

                Write-Host "here_two_AD" $i $j
                $lastArguments = PITool $SourceArchiveFiles[$i] $DestArchiveFiles[$j] $sourceBinFile $sourceFolder $destFolder $C $D $A $D $processOrTest

                #Write-Host $j
                
                If($j -eq $destCount-1){

                    write-host "end of dest files"
                    break
                }
                
                #initiates $q which is the dest record.
                $q = $j + 1
                
                                
                
                Do {
                    
                    #this sets the next dest start time.
                    $C = getStartTime ($destFolder + $DestArchiveFiles[$q])

                    #this sets the next dest end time.
                    $D = getEndTime ($destFolder + $DestArchiveFiles[$q])
                
                    #write-host $q $destCount
                    #write-host $A $B $C $D
                    
                    if(([datetime]$C -lt [datetime]$B) -and ([datetime]$B -lt [datetime]$D)){

                        Write-Host "here_three_CB" $i ($q)
                        $lastArguments = PITool $SourceArchiveFiles[$i] $DestArchiveFiles[$q] $sourceBinFile $sourceFolder $destFolder $C $D $C $B $processOrTest    
                        

                        #flags the input archive file as fully processed.
                        $x = 1
                        

                        }
                    elseif(($q -lt $destCount) -and ([datetime]$B -gt [datetime]$D)){

                        Write-Host "here_four_CD" $i ($q)
                        $lastArguments = PITool $SourceArchiveFiles[$i] $DestArchiveFiles[$q] $sourceBinFile $sourceFolder $destFolder $C $D $C $D $processOrTest
                                        
                        #this sets the next dest start time.
                        #$C = getStartTime ($destFolder + $DestArchiveFiles[$j+$nextFile])

                        #this sets the next dest end time.
                        #$D = getEndTime ($destFolder + $DestArchiveFiles[$j+$nextFile])

                        #increases to the next file
                        $q = $q + 1
                                 
                     }
                     Else{$q = $q + 1}

                     
                     #Write-Host $lastArguments


                 }While(($x -eq 0) -and ($q -lt $destCount))  

                }
                
                


            }
                
        $j++

        
                        
        }While(($j -lt $destCount) -and ($x -eq 0))

        #If($x -eq 0){Add-Content $fileProcessNotes $SourceArchiveFiles[$i]}

         $i++
         #Write-Host $j-1 $destCount
         #Write-Host $SourceArchiveFiles[$i]
         write-host $i " of " $srcCount " processed"
         Write-Host ""
         Write-Host ""
         Write-Host ""
        
}While($i -lt $srcCount)









