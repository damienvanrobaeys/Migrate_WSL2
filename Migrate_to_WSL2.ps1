$SystemRoot = $env:SystemRoot
$TEMP_Folder = $env:temp
$Log_File = "$TEMP_Folder\WSL_Migration.log"
$Current_Folder = split-path $MyInvocation.MyCommand.Path
$Version_to_Migrate = 2

If(test-path $Log_File){remove-item $Log_File}
new-item $Log_File -type file -force | out-null
Function Write_Log
	{
		param(
		$Message_Type,	
		$Message
		)
		
		$MyDate = "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)		
		Add-Content $Log_File  "$MyDate - $Message_Type : $Message"	
		write-host "$MyDate - $Message_Type : $Message"	
	}

Write_Log -Message_Type "INFO" -Message "Starting distributions migration to WSL $Version_to_Migrate"											
Add-Content $Log_File ""
write-host ""

$WSL_Output = "$TEMP_Folder\wsl_list_temp.txt"

wsl --set-default-version $Version_to_Migrate | out-null
Write_Log -Message_Type "INFO" -Message "Default version of WSL has been configured to v$Version_to_Migrate"															
Add-Content $Log_File ""
write-host ""

$List_Distrib = wsl -l -q | Where {($_ -ne "") -and ($_ -notlike "*:*")}
If($List_Distrib -ne $null)
	{
		Write_Log -Message_Type "INFO" -Message "Linux distributions are installed and will be migrated to WSL $Version_to_Migrate"												
		Add-Content $Log_File ""
		write-host ""	
		$List_Distrib | out-file $WSL_Output
		$Get_file_Content =  Get-Content $WSL_Output -Encoding Byte | Where-Object { ($_ -ne 0) -and ($_ -ne 254) -and ($_ -ne 255)}
		$encascii = [System.Text.Encoding]::ASCII
		$Distros = $encascii.GetString($Get_file_Content) | out-file $WSL_Output
		$Get_Distros_Content = get-content $WSL_Output | ? {$_}  
		ForEach($distro in $Get_Distros_Content)
			{
				Write_Log -Message_Type "INFO" -Message "Converting $distro to v$Version_to_Migrate"															
				wsl --set-version $distro $Version_to_Migrate | out-null
				Add-Content $Log_File ""
				write-host ""
			}
		Remove-item $WSL_Output -Force
	}
Else
	{
		Write_Log -Message_Type "INFO" -Message "No Liux distrubutions installed or configured"												
	}
	
