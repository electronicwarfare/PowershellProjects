#*****************************************************
#This script converts digital tag data that has lost the digital set during migration.
#Written by Jim Sheldon on 1/2/20.

#*****************************************************
#connect to the PI data archive server.

$archiveServer = "HDQv1773"

$myPI = Connect-PIDataArchive $archiveServer

#*****************************************************
#Set up tag and digital sets.

$tagName = "DCS.1MPBKR0001ACLSD"

#Checks if the user wants to test the script or process.
$zeroValue = Read-Host -Prompt "Enter the zero value for the digital set."
$oneValue = Read-Host -Prompt "Enter the one value for the digital set."

