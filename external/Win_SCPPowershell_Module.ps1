# http://poshcode.org/6057
$Script:WinSCPCSettingsOptionsObjectType = ""
$Script:WinSCPDirHasBeenLoaded   = $false 
$script:WinSCPDLLFolder          = "" #path to folder containing the WinSCP DLL and EXE

Function Set-WinSCPDLLFolder {
    param(
        [parameter(Mandatory=$true)]
        [string]$DLLFolder
    )

    #Make sure the required components exist in $DLLFolder
    if (test-path $DLLFolder){
        if ((Test-Path "${DLLFolder}\WinSCPnet.dll")){}
        else{
            throw "no WinSCPnet.dll found in ${DLLFolder}."
        }
        if ((Test-Path "${DLLFolder}\WinSCP.exe")){}
        else{
            throw "no WinSCP.exe found in ${DLLFolder}."
        }
    }
    else {throw "$DLLFolder does not appear to exist."}
    # set the global for later use
    $script:WinSCPDLLFolder = $DLLFolder
    
    # adding the type here so it's accessible in later cmdlets.
    add-type -Path "$dllfolder\WinSCPnet.dll" -ErrorAction stop
    if ($?){
        $Script:WinSCPDirHasBeenLoaded = $true
    }
    $tempObj = New-Object WinSCP.SessionOptions
    $Script:WinSCPCSettingsOptionsObjectType = $tempObj.psobject.typenames[0]
}

#confirms a remote path exists. i may update this function do do more, validate additional things.. that's why it exists.
Function Test-WinSCPRemotePathExists {
        param(
		[parameter(ValueFromPipeLine=$true,Mandatory=$true)]
		[WinSCP.Session]$WinSCPSessionObject,
        
        [parameter(Mandatory=$true)]
        [string]$RemotePath
    )
    if ($RemotePath.contains("\")){
        $RemotePath = $RemotePath -replace "\\","/" 
    }
    $WinSCPSessionObject.FileExists(($RemotePath.replace("*","")))
}


Function Get-WinSCPItemInfo {
    param(
		[parameter(ValueFromPipeLine=$true,Mandatory=$true)]
		[WinSCP.Session]$WinSCPSessionObject,
        
        [parameter(Mandatory=$true)]
        [string]$RemotePath
    )
    try{
        $WinSCPSessionObject.GetFileInfo($RemotePath)
    }
    catch {
        throw "$RemotePath does not exist"
    }
}


Function Get-PasswordFromEncryptedFile {
    param(
        [parameter(Mandatory=$true)]
        [string]$PasswordFile
    )

    if (-not (Test-Path $PasswordFile)){
        throw "Nonexistent Password file"
    }
    else {
        try{
            $encryptedPass = get-content $PasswordFile | ConvertTo-SecureString
            $encryptedStr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($encryptedPass)
            [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($encryptedStr)
            [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($encryptedStr) # Cleanup to avoid memory leak
        }
        catch {
            throw "Error decrypting Secure string.  Only files encrypted by $env:USERNAME on $env:COMPUTERNAME can be decrypted in this session."
        }

    }
}

Function New-PasswordFile {
    param(
        [parameter(Mandatory=$true)]
        [string]$PasswordFile
    )

    read-host -AsSecureString "Enter a password" | ConvertFrom-SecureString -ErrorAction stop| out-file $PasswordFile -ErrorAction Stop
}


Function New-WinSCPBlankSessionOptions{
    param(
        [parameter()]
        [string]$DLLFolder=$Script:WinSCPDLLFolder
    )

if (-not ($Script:WinSCPDirHasBeenLoaded)){
        Set-WinSCPDLLFolder -DLLFolder $DLLFolder
        $DLLFolder = $Script:WinSCPDLLFolder
    }
    
    # Setup session options
    New-Object WinSCP.SessionOptions


}


Function New-WinSCPSessionOptions {
    param(
        [parameter(Mandatory=$true)]
        [string]$Hostname,
        
        [parameter()]
        [validateset("Ftp","Scp","Sftp")] # Webdav was added as an option, but not adding it yet since I haven't looked into the requirements yet.
        [string]$Protocol="Sftp",

        [parameter()]
        [string]$Port = $null, # based on protocol, the session options automatically use the right default port so it is not required.

        [parameter(Mandatory=$true)]
        [string]$Username,
    
        [parameter(Mandatory=$true,ParameterSetName="SecurePass")]
        [string]$PasswordFile,

        [parameter(Mandatory=$true)]
        [string]$SshHostKeyFingerprint,

        [parameter(ParameterSetName="SecurePass")]
        [switch]$SetSecurePassword,

        [parameter(Mandatory=$true,ParameterSetName="PlainTextPass")]
        [ValidateNotNullOrEmpty()]
        [string]$PlainTextPassword,
        
        [parameter()]
        [string]$DLLFolder=$Script:WinSCPDLLFolder
    )
    
    if (-not ($Script:WinSCPDirHasBeenLoaded)){
        Set-WinSCPDLLFolder -DLLFolder $DLLFolder
        $DLLFolder = $Script:WinSCPDLLFolder
    }
    
    # Setup session options
    $sessionOptions = New-Object WinSCP.SessionOptions

    if ($SetSecurePassword){
        New-PasswordFile -PasswordFile $PasswordFile
    }

    $sessionOptions.Protocol   = [WinSCP.Protocol]::$Protocol
    $sessionOptions.HostName   = $HostName
    $sessionOptions.UserName   = $Username

    if ($port){
        $sessionOptions.PortNumber = $Port
    }

    if ($PasswordFile){
        $sessionOptions.Password = Get-PasswordFromEncryptedFile -PasswordFile $PasswordFile
    }
    else {
        $sessionOptions.Password = $PlainTextPassword
    }
    $sessionOptions.SshHostKeyFingerprint = $SshHostKeyFingerprint
 
    $sessionOptions
}

Function Connect-WinSCPSFTPServer{
    param(
        [parameter(Mandatory=$true,ParameterSetName="MakeObjPlainTextPass")]
        [parameter(Mandatory=$true,ParameterSetName="MakeObjSecurePass")]
        [string]$Hostname,

        [parameter(ParameterSetName="MakeObjPlainTextPass")]
        [parameter(ParameterSetName="MakeObjSecurePass")]
        [validateset("Ftp","Scp","Sftp")]
        [string]$Protocol="Sftp",
        
        [parameter(ParameterSetName="MakeObjPlainTextPass")]
        [parameter(ParameterSetName="MakeObjSecurePass")]
        [int]$Port = $null,

        [parameter(Mandatory=$true,ParameterSetName="MakeObjPlainTextPass")]
        [parameter(Mandatory=$true,ParameterSetName="MakeObjSecurePass")]
        [string]$Username,
    
        [parameter(Mandatory=$true,ParameterSetName="MakeObjSecurePass")]
        [string]$PasswordFile,

        [parameter(Mandatory=$true,ParameterSetName="MakeObjPlainTextPass")]
        [parameter(Mandatory=$true,ParameterSetName="MakeObjSecurePass")]
        [string]$SshHostKeyFingerprint,

        [parameter(Mandatory=$true,ParameterSetName="MakeObjPlainTextPass")]
        [ValidateNotNullOrEmpty()]
        [string]$PlainTextPassword,

        [parameter(ParameterSetName="PassObj")]
        [Object]$WinSCPSessionOptionsObject,

        [parameter()]
        [string]$DLLFolder=$Script:WinSCPDLLFolder,

        [parameter(ParameterSetName="MakeObjSecurePass")]
        [switch]$SetSecurePassword
    )
    
    if (-not ($Script:WinSCPDirHasBeenLoaded)){
        Set-WinSCPDLLFolder -DLLFolder $DLLFolder
        $DLLFolder = $Script:WinSCPDLLFolder
    }

    if ($SetSecurePassword){
        New-PasswordFile -PasswordFile $PasswordFile
    }
    
    $sessionOptions = $null
    if (-not $WinSCPSessionOptionsObject){
        if ($PasswordFile){
            $sessionOptions = New-WinSCPSessionOptions -DLLFolder $DLLFolder -Username $Username -Hostname $Hostname -Protocol $Protocol -Port $Port -PasswordFile $PasswordFile -SshHostKeyFingerprint $SshHostKeyFingerprint
        }
        if ($PlainTextPassword){
            $sessionOptions = New-WinSCPSessionOptions -DLLFolder $DLLFolder -Username $Username -Hostname $Hostname -Protocol $Protocol -Port $Port -PlainTextPassword $PlainTextPassword -SshHostKeyFingerprint $SshHostKeyFingerprint
        }
    }
    else{
        if ($WinSCPSessionOptionsObject.psobject.typenames[0] -eq $Script:WinSCPCSettingsOptionsObjectType){
            $sessionOptions = $WinSCPSessionOptionsObject
        }
        else{
            throw "invalid object type passed.  Object of type $Script:WinSCPCSettingsOptionsObjectType expected"
        }
    }

    $session = New-Object WinSCP.Session
	$session.ExecutablePath = "$DLLFolder\WinSCP.exe"
		
    # I need to rework the output text. I don't like it currently - will do write-verbose
	Write-Verbose "attempting to connect to server $Hostname"

    # connect to FTP session
	try {
	    $session.Open($sessionOptions)
	}
    catch {
        throw "Exception opening session.  Double-check your credentials"
	}
    if ($session.opened -eq $true){
        $session
    }
    else{
        throw "Unable to connect to server.  Check your connection details and try again"
    }
}; New-Alias -Name Connect-WinSCPServer -Value Connect-WinSCPSFTPServer -Description "Connect to a MFT server"


Function New-WinSCPTransferOptions {
    param(
        [parameter()]
        [ValidateSet("Ascii","Automatic","Binary")]
        [string]$Mode="Binary",

        [parameter()]
        [ValidateSet("Default","Off","On","Smart")]
        [string]$ResumeSupport="Default",

        [parameter()]
        [string]$FileMask="",

        [parameter()]
        [ValidateScript({$_ -ge 0})]
        [int]$SpeedLimitKB=0
    )
    

    # set optional params
	$TransferOptions = New-Object WinSCP.TransferOptions
	if($FileMask -ne "") {
		$TransferOptions.FileMask = $FileMask
	}
    $TransferOptions.SpeedLimit = $SpeedLimitKB
	$TransferOptions.TransferMode = [WinSCP.TransferMode]::$Mode
    $TransferOptions.ResumeSupport.State = [WinSCP.TransferResumeSupportState]::$ResumeSupport

    $TransferOptions
}

	






# This functions for a single file (might for multiple, haven't tested yet) and for a single folder. 
# I need to add some additional logic about the Local and remote locations to make sure there's a leading / at the end of the folder name.
Function New-WinSCPTransfer {
    param(
		[parameter(ValueFromPipeLine=$true,Mandatory=$true)]
		[WinSCP.Session]$WinSCPSessionObject,
        
        [parameter()]
		[validateset("Download","Upload")]
		[string]$TransferType,

        [parameter(Mandatory=$true)]
        [string]$LocalPath,

        [parameter(Mandatory=$true)]
        [string]$RemotePath,

        [parameter()]
        [ValidateSet("Ascii","Automatic","Binary")]
        [string]$Mode="Binary",

        [parameter()]
        [string]$FileMask="",

        [parameter()]
        [switch]$DeleteSourceFilesAfterTransfer,

        [parameter()]
        [ValidateSet("Default","Off","On","Smart")]
        [string]$ResumeSupport="Default",

        [parameter()]
        [ValidateScript({$_ -ge 0})]
        [int]$SpeedLimitKB=0
    )

    if (-not (Test-WinSCPRemotePathExists -WinSCPSessionObject $WinSCPSessionObject -RemotePath ($RemotePath.replace("*","")))){
		throw("The RemotePath does not exist on FTP: ${RemotePath}")
	}

	if ($DeleteSourceFilesAfterTransfer){
        $remove = $true
    }
    else {
        $remove = $false
    }
    $RemotePath = $RemotePath -replace "\\","/" # Invert the slashes in case they're wrong.  It behaves really erratically if the slashes are wrong.
    switch ($TransferType.tolower()){
        "download" {
            #if (-not ($LocalPath.endswith("/"))){
            #    $LocalPath += "\"
            #}
            break
        }
        "upload" {
            if (-not ($RemotePath.EndsWith("/")) -or ($RemotePath.EndsWith("*"))){
                $RemotePath += "/"
            }
            break
        }
    }
	
    $TransferOptions = New-WinSCPTransferOptions -Mode $Mode -ResumeSupport $ResumeSupport -FileMask $FileMask -SpeedLimitKB $SpeedLimitKB
	
    switch ($TransferType.tolower()){
        upload {
	        Write-Verbose "Beginning upload..."
	        # execute File Upload
	        $result = $WinSCPSessionObject.PutFiles($LocalPath, $RemotePath, $remove, $TransferOptions)
        }
        download{
		    Write-Verbose "Beginning download..."
		    # execute File Download
		    $result = $WinSCPSessionObject.GetFiles($RemotePath, $LocalPath, $remove, $TransferOptions)
        }
    }

	# need to validate this better.
	$result.Check()
		


    # Validate the transfers.  May rework some of this, haven't decided yet.
	if(($result.Transfers | Measure).count -gt 0) {
		write-verbose "Files successfully transfered:"
        $i = 1
		$result.Transfers | % {
			Write-Verbose "`t$i - $($_.Destination)"
            $i++
		}
	}
	if(($result.Failures | Measure).count -gt 0) {
		Write-Verbose "Failed file transfers:"
        $i=1
		$result.Failures | % {
			Write-Verbose "`t$i - $($_.FileName)"
            $i++
		}
	}
	if(-not $result.IsSuccess) {
		throw("FTP transfer Failed")
	}
}


Function New-WinSCPUpload {
    param(
		[parameter(ValueFromPipeLine=$true,Mandatory=$true)]
		[WinSCP.Session]$WinSCPSessionObject,
        
        [parameter(Mandatory=$true)]
        [string]$LocalPath,

        [parameter(Mandatory=$true)]
        [string]$RemotePath,

        [parameter()]
        [ValidateSet("Ascii","Automatic","Binary")]
        [string]$Mode="Binary",

        [parameter()]
        [string]$FileMask="",

        [parameter()]
        [switch]$DeleteSourceFilesAfterTransfer,

        [parameter()]
        [ValidateSet("Default","Off","On","Smart")]
        [string]$ResumeSupport="Default",

        [parameter()]
        [ValidateScript({$_ -ge 0})]
        [int]$SpeedLimitKB=0
    )

    if ($DeleteSourceFilesAfterTransfer){
        $WinSCPSessionObject | New-WinSCPTransfer -TransferType Upload -LocalPath $LocalPath -RemotePath $RemotePath -Mode $Mode -FileMask $FileMask -ResumeSupport $ResumeSupport -SpeedLimitKB $SpeedLimitKB -DeleteSourceFilesAfterTransfer
    }
    else{
        $WinSCPSessionObject | New-WinSCPTransfer -TransferType Upload -LocalPath $LocalPath -RemotePath $RemotePath -Mode $Mode -FileMask $FileMask -ResumeSupport $ResumeSupport -SpeedLimitKB $SpeedLimitKB
    }
    
}; New-Alias -Name Upload-Files -Value New-WinSCPUpload -Description "Upload a file using WinSCP"

Function New-WinSCPDownload {
    param(
		[parameter(ValueFromPipeLine=$true,Mandatory=$true)]
		[WinSCP.Session]$WinSCPSessionObject=$null,
        
        [parameter(Mandatory=$true)]
        [string]$LocalPath,

        [parameter(Mandatory=$true)]
        [string]$RemotePath,

        [parameter()]
        [ValidateSet("Ascii","Automatic","Binary")]
        [string]$Mode="Binary",

        [parameter()]
        [string]$FileMask="",

        [parameter()]
        [switch]$DeleteSourceFilesAfterTransfer,

        [parameter()]
        [ValidateSet("Default","Off","On","Smart")]
        [string]$ResumeSupport="Default",

        [parameter()]
        [ValidateScript({$_ -ge 0})]
        [int]$SpeedLimitKB=0
    )

    if ($DeleteSourceFilesAfterTransfer){
        $WinSCPSessionObject | New-WinSCPTransfer -TransferType Download -LocalPath $LocalPath -RemotePath $RemotePath -Mode $Mode -FileMask $FileMask -ResumeSupport $ResumeSupport -SpeedLimitKB $SpeedLimitKB -DeleteSourceFilesAfterTransfer
    }
    else{
        $WinSCPSessionObject | New-WinSCPTransfer -TransferType Download -LocalPath $LocalPath -RemotePath $RemotePath -Mode $Mode -FileMask $FileMask -ResumeSupport $ResumeSupport -SpeedLimitKB $SpeedLimitKB
    }
    
}; New-Alias -Name Download-Files -Value New-WinSCPDownload -Description "Upload a file using WinSCP"


Function Close-WinSCPSFTPServerConnection {
    param(
		[parameter(ValueFromPipeLine=$true,Mandatory=$true)]
		[WinSCP.Session]$WinSCPSessionObject=$null
    )

    $WinSCPSessionObject.dispose()
}




Function Get-WinSCPDirectoryList {
    param(
		[parameter(ValueFromPipeLine=$true,Mandatory=$true)]
		[WinSCP.Session]$WinSCPSessionObject=$null,
        
        [parameter(Mandatory=$true)]
        [string]$RemotePath
    )

    if (Test-WinSCPRemotePathExists -WinSCPSessionObject $WinSCPSessionObject -RemotePath $RemotePath){
        $WinSCPSessionObject.ListDirectory($RemotePath) | select -ExpandProperty files
    }
    else {
        Write-Warning "$RemotePath Does not exist"
        return $null
    }
}


Function New-WinSCPRemoteDirectory {
    param(
		[parameter(ValueFromPipeLine=$true,Mandatory=$true)]
		[WinSCP.Session]$WinSCPSessionObject,
        
        [parameter(Mandatory=$true)]
        [string]$RemotePath
    )

    if (Test-WinSCPRemotePathExists -WinSCPSessionObject $WinSCPSessionObject -RemotePath $RemotePath){
        Write-Verbose "$RemotePath already existed"
    }
    else{
        try {
            $WinSCPSessionObject.CreateDirectory($RemotePath)
            if ($?){
                Write-Verbose "$RemotePath has been created"
            }
        }
        catch {
            throw "Error creating $RemotePath"
        }
    }
}



Function Remove-WinSCPRemoteItem {
    param(
		[parameter(ValueFromPipeLine=$true,Mandatory=$true)]
		[WinSCP.Session]$WinSCPSessionObject,
        
        [parameter(Mandatory=$true)]
        [string]$RemotePath,

        [parameter()]
        [switch]$force
    )
    $delData = $null
    $dirContents = $null

    if (-not (Test-WinSCPRemotePathExists -WinSCPSessionObject $WinSCPSessionObject -RemotePath $RemotePath)){
        Write-Verbose "$RemotePath does not exist.  No action taken."
    }
    else{
        $itemInfo = Get-WinSCPItemInfo -WinSCPSessionObject $WinSCPSessionObject -RemotePath $RemotePath
        if ($itemInfo.isDirectory){
            $dirContents = @(Get-WinSCPDirectoryList -WinSCPSessionObject $WinSCPSessionObject -RemotePath $RemotePath)
            if (($dirContents.count -gt 0) -and (-not ($force))){
                #Check if it recurses, correct the notice if it doesn't.  Definitely don't want to recurse down.
                Write-Warning "${RemotePath} is a directory with additional files in it. at least $($dirContents.count) items. This check does NOT recurse - there may be a lot more files."
                $input = (read-host "Are you sure you want to delete everything inside ${RemotePath}?").tolower()
                if ($input.StartsWith("y")){
                    $delData = $WinSCPSessionObject.RemoveFiles($RemotePath)
                }
                else {
                    Write-Verbose "$RemotePath has not been deleted.  No action taken"
                }
            }
            else {
                $delData = $WinSCPSessionObject.RemoveFiles($RemotePath)
            }
        }
        else{
            $delData = $WinSCPSessionObject.RemoveFiles($RemotePath)
        }
    }

    #
    # List what was deleted, confirm the deletes were succesful
    #
    if ($delData -ne $null){
        # Validate the transfers.  May rework some of this, haven't decided yet.
	    if(($delData.Removals | Measure).count -gt 0) {
		    write-verbose "Files/folders successfully deleted:"
            $i = 1
		    $delData.Removals | % {
			    Write-Verbose "$i - $($_.FileName)"
                $i++
		    }
	    }
	    if(($delData.Failures | Measure).count -gt 0) {
		    Write-Verbose "Failed file/folder deletions:"
            $i=1
		    $delData.Failures | % {
			    Write-Verbose "$i - $($_.FileName)"
                $i++
		    }
	    }
	    if(-not $delData.IsSuccess) {
		    throw("Deletion of ${RemotePath} failed.")
	    }


    }
}


function Sync-WinSCPDirectory{
    param(
    	[parameter(ValueFromPipeLine=$true,Mandatory=$true)]
		[WinSCP.Session]$WinSCPSessionObject,

        [parameter(Mandatory=$true)]
        [string]$LocalPath,

        [parameter(Mandatory=$true)]
        [string]$RemotePath,

        [Parameter(Mandatory=$true)]
        [ValidateSet("Local","Remote","Both")]
        [WinSCP.SynchronizationMode]$SynchronizationMode,

        [Parameter()]
        [ValidateSet("None","Time","Size","Either")]
        [WinSCP.SynchronizationCriteria]$SynchronizationCriteria="Time",

        [Parameter()]
        [Switch]$Mirror,

        [parameter()]
        [ValidateSet("Ascii","Automatic","Binary")]
        [string]$TransferMode="Binary",

        [parameter()]
        [string]$FileMask="",

        [Parameter()]
        [Switch]$RemoveFilesAfterTransfer,

        [parameter()]
        [ValidateSet("Default","Off","On","Smart")]
        [string]$ResumeSupport="Default",

        [parameter()]
        [ValidateScript({$_ -ge 0})]
        [int]$SpeedLimitKB=0
    )

    $TransferOptions = New-WinSCPTransferOptions -Mode $Mode -ResumeSupport $ResumeSupport -FileMask $FileMask -SpeedLimitKB $SpeedLimitKB

    try{
        $output = $WinSCPSessionObject.SynchronizeDirectories($SynchronizationMode, $LocalPath, $RemotePath, $RemoveFilesAfterTransfer.IsPresent, $Mirror.IsPresent, $SynchronizationCriteria, $TransferOptions)
    }
    catch {
        #I want to update this later
        Throw $_
    }
    
    if (($output.uploads | Measure).count -gt 0){
        write-verbose "Files/folders successfully uploaded:"
        $i = 1
		$output.uploads | % {Write-Verbose "`t$i - $($_.FileName)"; $i++}
    }
    
    if (($output.downloads | Measure).count -gt 0){
        write-verbose "Files/folders successfully downloaded:"
        $i = 1
		$output.downloads | % {Write-Verbose "`t$i - $($_.FileName)"; $i++}
    }
    if (($output.Failures | Measure).count -gt 0){
        write-verbose "Files/folders Failed:"
        $i = 1
		$output.Failures | % {Write-Verbose "`t$i - $($_.FileName)"; $i++}
    }
}


#
# Check if the WinSCP .exe and .dll exist in the module direcory and auto-load if so.
#
$modulePath = split-path $SCRIPT:MyInvocation.MyCommand.Path -parent
if ((Test-Path "$modulePath\WinSCP.exe") -and (Test-Path "$modulePath\WinSCPnet.dll")){
    Set-WinSCPDLLFolder -DLLFolder $modulePath
}
else{
    throw "Unable to find the WinSCP executables WinSCPnet.dll and WinSCP.exe in $modulePath"
}
# End DLLFolder auto-load
#


export-modulemember -alias * -function *
