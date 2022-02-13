$arcFiles = Get-Content -Path C:\Users\OpTech\Desktop\ArcFiles.txt

#write-host $arcFiles

$arcTool = "C:\Program Files\PI\adm\piartool.exe"

Foreach($i in $arcFiles){

	$arguments_unregister = " -au " + $i
	$arguments_register = " -ar " + $i
	#write-host $arguments_unregister
	#write-host $arguments_register

	Start-Process $arcTool $arguments_unregister -Wait
	write-host $arguments_unregister
	
	Start-Process $arcTool $arguments_register -Wait
	write-host $arguments_register	

}