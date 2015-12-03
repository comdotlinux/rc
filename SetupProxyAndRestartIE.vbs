Option Explicit

Const proxyIpPort = "1.2.3.4:0000"
Const urlToOpen = "http://www.google.com/"

Dim valUserIn, restartIe, quit, userOkToContinue
Dim objShell, RegLocate, objWMIService
Dim strComputer, colProcesses, IE, ieInstance
Set objShell = WScript.CreateObject("WScript.Shell")

strComputer = "."
Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")
    
On Error Resume Next

Function restartInternetExplorer(quit)
  Set colProcesses = objWMIService.ExecQuery ("Select * from Win32_Process Where Name = 'iexplore.exe'")
        For Each ieInstance In colProcesses
            ieInstance.Terminate()
            Wscript.Sleep 1000
        Next

        Set IE = WScript.CreateObject("InternetExplorer.Application")
    '    IE.WindowState = wdWindowStateMaximize
        IE.visible=true
    '    objShell.SendKeys "% X"
        
        If quit=vbYes Then
            IE.Quit
        else
            IE.navigate urlToOpen
        End If
End Function

userOkToContinue = MsgBox("Running this program may close all your Internet Explorer instances!!!",52,"You have been warned!")
If userOkToContinue=vbYes Then
    
    valUserIn = MsgBox("Use Proxy?",4,"Proxy")

    If valUserIn=vbYes Then
        RegLocate = "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ProxyServer"
        objShell.RegWrite RegLocate,proxyIpPort,"REG_SZ"
        RegLocate = "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ProxyEnable"
        objShell.RegWrite RegLocate,"1","REG_DWORD"
        RegLocate = "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ProxyOverride"
        objShell.RegWrite RegLocate,"localhost;<local>","REG_SZ"
        'MsgBox "Proxy is Enabled"

        restartIe = MsgBox("Kill all internet explorers and start IE?",52,"Start IE")

        If restartIe=vbYes Then
            call restartInternetExplorer(vbNo)
        End If
    else
        RegLocate = "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ProxyEnable"
        objShell.RegWrite RegLocate,"0","REG_DWORD"
        'MsgBox "Proxy is Disabled"
        restartIe = MsgBox("Restart internet explorer for the proxy to take effect? (All instances of IE will be killed!)",52,"Restart IE")
        If restartIe=vbYes Then
            call restartInternetExplorer(vbYes)
        End If
    End If

End If
WScript.Quit
