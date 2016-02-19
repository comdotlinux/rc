Option Explicit

Const proxyIpPort = "1.2.3.4:0000"
Const urlToOpen = "http://www.google.com/"

Dim valUserIn, restartIe, quit, userOkToContinue
Dim objShell, RegLocate, objWMIService
Dim strComputer, colProcesses, IE, ieInstance, chkIeProcessList
Set objShell = WScript.CreateObject("WScript.Shell")

strComputer = "."
Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")
    
'On Error Resume Next

Function killAllIes()
    Set colProcesses = objWMIService.ExecQuery ("Select * from Win32_Process Where Name = 'iexplore.exe'")
    For Each ieInstance In colProcesses
        WScript.Echo "Killing Internet Explorer instances"
        set chkIeProcessList = objWMIService.ExecQuery ("Select * from Win32_Process Where Name = 'iexplore.exe'")
        If chkIeProcessList.Count > 0 Then
            ieInstance.Terminate()
        End If
        Wscript.Sleep 1000
    Next
End Function

Function startIEUsingWscript()
    'MsgBox("Starting Internet Explorer instance")
    Set IE = WScript.CreateObject("InternetExplorer.Application")
    'IE.WindowState = wdWindowStateMaximize
    IE.visible=true
    'objShell.SendKeys "% X"
    Set startIEUsingWscript = IE
End Function

Function restartInternetExplorer(quit)
    WScript.Echo quit
    If quit=vbYes Then
        WScript.Echo "Inside If restartInternetExplorer"
        Set IE = startIEUsingWscript
        IE.Quit
        call killAllIes()
    else
        WScript.Echo "Inside else restartInternetExplorer"
        WScript.Echo "Before killing IE"
        call killAllIes()
        WScript.Echo "After killing IE"
        Set IE = startIEUsingWscript
        IE.navigate doriPortalUrl
    End If
End Function

'userOkToContinue = MsgBox("Running this program may close all your Internet Explorer instances!!!",52,"You have been warned!")
userOkToContinue=vbYes
If userOkToContinue=vbYes Then
    
    valUserIn = MsgBox("Use Proxy?",4,"Proxy")

    If valUserIn=vbYes Then
        RegLocate = "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ProxyServer"
        objShell.RegWrite RegLocate,proxyIpPort,"REG_SZ"
        RegLocate = "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ProxyEnable"
        objShell.RegWrite RegLocate,"1","REG_DWORD"
        RegLocate = "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ProxyOverride"
        objShell.RegWrite RegLocate,_
        "localhost;*.google.*;<local>","REG_SZ"
        'MsgBox "Proxy is Enabled"

        'restartIe = MsgBox("Kill all internet explorers and start URL?",52,"Start IE")
        'call restartInternetExplorer(vbYes)
        call restartInternetExplorer(vbNo)
    else
        RegLocate = "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ProxyEnable"
        objShell.RegWrite RegLocate,"0","REG_DWORD"
        'MsgBox "Proxy is Disabled"
        'restartIe = MsgBox("Restart internet explorer for the proxy to take effect? (All instances of IE will be killed!)",52,"Restart IE")
        call restartInternetExplorer(vbYes)
    End If

End If
WScript.Quit
