#*****************************************************
#This script imports exported data from an existing txt file to a different tag.
#the entire txt file is imported.
#Written by Jim Sheldon on 1/2/20.

Add-Type -AssemblyName Microsoft.VisualBasic

#*****************************************************
#connect to the PI data archive server.

$archiveServer = "HDQv1773"

$myPI = Connect-PIDataArchive $archiveServer



#*****************************************************
#Set up tag 

$tagName = "OT.1MPBKR0001ACLSD"

#*****************************************************
#Set up input file

$inputFile = 0

Do{

$inputFile = [Microsoft.VisualBasic.Interaction]::InputBox("Please enter the complete path to the input file.`nRemove starting and ending quotes.","Input File")
#$inputFile = Read-Host -Prompt "`nPlease enter the complete path to the input file."

}While($inputFile -eq "")

#*****************************************************
#Sets up Test accuracy string

#Checks if the user wants to test the script or process.
$testPrompt = "Are these correct? Y or N`n`n"
$testServer = "Server Name: $archiveServer`n"
$testTagName = "Tag Name: $tagName`n"
$testInputFile = "Input File: $inputFile`n"

$testString = $testPrompt + $testServer + $testTagName + $testInputFile

#is it accurate prompt loop
Do{
    $accuracyCheck = [Microsoft.VisualBasic.Interaction]::InputBox($testString,"Check for Accuracy")
    
    If($accuracyCheck.ToUpper() -eq "N"){
    
        write-host "`n***Exiting Process Due to Accuracy Errors***`n"
        Exit
    }

}While($accuracyCheck.ToUpper() -ne "Y")


#Checks if the user wants to test the script or process.
$processOrTest = [Microsoft.VisualBasic.Interaction]::InputBox("Do you want to process or test?`nTo process press 9`nTo test press any key","Process or Test")


#Double checks for processing
If($processOrTest -eq 9){
    
    $areYouSure = [Microsoft.VisualBasic.Interaction]::InputBox("Are you sure you want to process?`nEnter Y or Any key for test.","2nd Chance")

    If($areYouSure.ToUpper() -ne "Y"){
    
        $processOrTest = 0
        write-host "`n ***Testing Only***"
        
        }
    Else{Write-Host "`n***Beginning to Process***"} 
}
    

#*****************************************************
#reading the input file.
$myValues = Get-Content "E:\PI\Powershell_Output\DCS.1MPBKR0001ACLSD_raw.txt"

ForEach($i in $myValues){

    $sTime = $i.Substring(2,19)
    $sDigitalState = $i.Substring(0,1)

    
    #$j = "-PointName $tagName -Time ""$sTime"" -Value $sDigitalState -WriteMode Replace -Connection $myPI"

    If($processOrTest -eq 9){

        $j
        Add-PIValue -PointName $tagName -Time $sTime -Value $sDigitalState -WriteMode Replace -Connection $myPI
        
    }
    Else{
        $j
        }

}

Write-Host "`n***Process Complete***"

    