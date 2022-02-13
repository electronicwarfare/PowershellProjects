$outFolder = "E:\PI\Migrate\dest\out\" 

#gets the dest archive files in a variable
$outFiles = Get-ChildItem -Name $outFolder

#This txt files lists the archive files that did not process correctly.
$reprocessList = "E:\PI\Migrate\dest\out\reprocessArchives.txt"
$badList = "E:\PI\Migrate\dest\out\DidNotProcessArchives.txt"

#checks to see if the output files exist, if so they are deleted.
If(Test-Path $reprocessList){ Remove-Item $reprocessList}
If(Test-Path $badList){ Remove-Item $badList}

#Write-Host "here"

ForEach($i in $outFiles)
{
    
    #Sets the file path
    $filePath = $outFolder + $i

    #Write-Host $i
    
    $fileOuput = Get-Content -Path $filePath | Select -Last 3

    #Write-Host $fileOuput

 If(Select-String -InputObject $fileOuput -Pattern 'Archive Total seconds')
    {

        Write-Host "good " $i 

    }
    ElseIf(Select-String -InputObject $fileOuput -Pattern 'changed to Auto Dynamic')
    {

        Write-Host "good " $i 

    }
    ElseIf(Select-String -InputObject $fileOuput -Pattern 'out-of-order')
    {

        Write-Host "reprocess " $i 
        Add-Content $reprocessList $i

    }
    Else
    {

        Write-Host "bad " $i

        #Write-Host $fileOuput
        #If ($fileOuput -eq $null){write-host "null"}

        Add-Content $badList $i

    }

    

   
        

    
    
    
}


