Option Explicit

Const PROXY_IP_PORT = "1.2.3.4:0000"
Const OPEN_AFTER_ENABLING_PROXY = "http://www.google.com/"
Const PROXY_OVERRIDE = "localhost;google.com;<local>"

Const ENABLE_DEBUG_MESSAGES = 0
Const COMPUTER = "."

Const PROXY_IP_REGISTRY_PATH = "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ProxyServer"
Const PROXY_ENABLE_REGISTRY_PATH = "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ProxyEnable"
Const PROXY_OVERRIDE_REGISTRY_PATH = "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ProxyOverride"

Dim valUserIn, restartIe, quit, userOkToContinue
Dim objShell, RegLocate, objWMIService
Dim strComputer, colProcesses, IE, ieInstance, chkIeProcessList


Function echo(logValue)
	IF ENABLE_DEBUG_MESSAGES = 1 Then
		WScript.Echo logValue
	End If
End Function

Function getListOfProcessIntances(processName)
	Set objWMIService = GetObject("winmgmts:\\" & COMPUTER & "\root\cimv2")
	Set getListOfProcessIntances = objWMIService.ExecQuery ("Select * from Win32_Process Where Name = '" + processName + "'")
End Function

Function killAllIes()
	Set colProcesses = getListOfProcessIntances("iexplore.exe")
	For Each ieInstance In colProcesses
		echo("Killing Internet Explorer instances")
		Set chkIeProcessList = getListOfProcessIntances("iexplore.exe")
		If chkIeProcessList.Count > 0 Then
			ieInstance.Terminate()
		End If
		Wscript.Sleep 1000
		Set colProcesses = getListOfProcessIntances("iexplore.exe")
	Next
End Function

Function startIe()
	echo("Starting Internet Explorer instance")
	Set IE = WScript.CreateObject("InternetExplorer.Application")
	'IE.WindowState = wdWindowStateMaximize
	IE.visible=true
	'objShell.SendKeys "% X"
	Set startIe = IE
End Function

Function restartInternetExplorer(quit)
	echo("restart Internet explorer with parameter as " & quit)
	If quit=vbYes Then
		echo("Inside If restartInternetExplorer")
		Set IE = startIe()
		IE.Quit
		call killAllIes()
		Set IE = startIe()
	else
		echo("Inside else restartInternetExplorer")
		echo("Before killing IE")
		call killAllIes()
		echo("After killing IE")
		Set IE = startIe()
		IE.navigate OPEN_AFTER_ENABLING_PROXY
	End If
End Function

Function updateRegistry(regLocation, regValue, regValueType)
	echo("Updating registry at " + regLocation + " with value " + regValue + " of Type " + regValueType)
	Set objShell = WScript.CreateObject("WScript.Shell")
	objShell.RegWrite regLocation, regValue, regValueType
End Function


' Start of script execution ::
valUserIn = MsgBox("Use the proxy settings and open " + OPEN_AFTER_ENABLING_PROXY  + "?",4,"USE PROXY")

If valUserIn=vbYes Then
	call updateRegistry(PROXY_IP_REGISTRY_PATH, PROXY_IP_PORT, "REG_SZ")
	call updateRegistry(PROXY_ENABLE_REGISTRY_PATH, "1", "REG_DWORD")
	call updateRegistry(PROXY_OVERRIDE_REGISTRY_PATH, PROXY_OVERRIDE, "REG_SZ")
	echo("Proxy is Enabled")

	'restartIe = MsgBox("Kill all internet explorers and start " + OPEN_AFTER_ENABLING_PROXY + " ?",52,"Start Internet Explorer")
	'call restartInternetExplorer(restartIe)
	call restartInternetExplorer(vbNo)
else
	call updateRegistry(PROXY_ENABLE_REGISTRY_PATH, "0", "REG_DWORD")
	echo("Proxy is Disabled")
	'restartIe = MsgBox("Restart internet explorer for the proxy disabling to take effect? (All instances of IE will be killed!)",52,"Restart IE")
	call restartInternetExplorer(vbYes)
End If

WScript.Quit
