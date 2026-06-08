; AutoHotkey v1 script


; Get hwnd of AutoHotkey window, for listener

; Path to the DLL, relative to the script
VDA_PATH := A_ScriptDir . "/VirtualDesktopAccessor.dll"
hVirtualDesktopAccessor := DllCall("LoadLibrary", "Str", VDA_PATH, "Ptr")

GetDesktopCountProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GetDesktopCount", "Ptr")
GoToDesktopNumberProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GoToDesktopNumber", "Ptr")
GetCurrentDesktopNumberProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GetCurrentDesktopNumber", "Ptr")
IsWindowOnCurrentVirtualDesktopProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "IsWindowOnCurrentVirtualDesktop", "Ptr")
IsWindowOnDesktopNumberProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "IsWindowOnDesktopNumber", "Ptr")
MoveWindowToDesktopNumberProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "MoveWindowToDesktopNumber", "Ptr")
IsPinnedWindowProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "IsPinnedWindow", "Ptr")
GetDesktopNameProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GetDesktopName", "Ptr")
SetDesktopNameProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "SetDesktopName", "Ptr")
CreateDesktopProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "CreateDesktop", "Ptr")
RemoveDesktopProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "RemoveDesktop", "Ptr")

; On change listeners
RegisterPostMessageHookProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "RegisterPostMessageHook", "Ptr")
UnregisterPostMessageHookProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "UnregisterPostMessageHook", "Ptr")

GetDesktopCount() {
    global GetDesktopCountProc
    count := DllCall(GetDesktopCountProc, "Int")
    return count
}

MoveCurrentWindowToDesktop(desktopNumber) {
    global MoveWindowToDesktopNumberProc, GoToDesktopNumberProc
    WinGet, activeHwnd, ID, A
    DllCall(MoveWindowToDesktopNumberProc, "Ptr", activeHwnd, "Int", desktopNumber, "Int")
    DllCall(GoToDesktopNumberProc, "Int", desktopNumber)
}

GoToPrevDesktop() {
    global GetCurrentDesktopNumberProc, GoToDesktopNumberProc
    current := DllCall(GetCurrentDesktopNumberProc, "Int")
    last_desktop := GetDesktopCount() - 1
    ; If current desktop is 0, go to last desktop
    if (current = 0) {
        MoveOrGotoDesktopNumber(last_desktop)
    } else {
        MoveOrGotoDesktopNumber(current - 1)
    }
    return
}

GoToNextDesktop() {
    global GetCurrentDesktopNumberProc
    current := DllCall(GetCurrentDesktopNumberProc, "Int")
    last_desktop := GetDesktopCount() - 1
    ; If current desktop is last, go to first desktop
    if (current = last_desktop) {
        MoveOrGotoDesktopNumber(0)
    } else {
        MoveOrGotoDesktopNumber(current + 1)
    }
    return
}

GoToDesktopNumber(num) {
    global GoToDesktopNumberProc
    DllCall(GoToDesktopNumberProc, "Int", num, "Int")
    return
}
MoveOrGotoDesktopNumber(num) {
    ; If user is holding down Mouse left button, move the current window also
    if (GetKeyState("LButton")) {
        MoveCurrentWindowToDesktop(num)
    } else {
        GoToDesktopNumber(num)
    }
    return
}
GetDesktopName(num) {
    global GetDesktopNameProc
    utf8_buffer := ""
    utf8_buffer_len := VarSetCapacity(utf8_buffer, 1024, 0)
    ran := DllCall(GetDesktopNameProc, "Int", num, "Ptr", &utf8_buffer, "Ptr", utf8_buffer_len, "Int")
    name := StrGet(&utf8_buffer, 1024, "UTF-8")
    return name
}
SetDesktopName(num, name) {
    ; NOTICE! For UTF-8 to work AHK file must be saved with UTF-8 with BOM

    global SetDesktopNameProc
    VarSetCapacity(name_utf8, 1024, 0)
    StrPut(name, &name_utf8, "UTF-8")
    ran := DllCall(SetDesktopNameProc, "Int", num, "Ptr", &name_utf8, "Int")
    return ran
}
CreateDesktop() {
    global CreateDesktopProc
    ran := DllCall(CreateDesktopProc)
    return ran
}
RemoveDesktop(remove_desktop_number, fallback_desktop_number) {
    global RemoveDesktopProc
    ran := DllCall(RemoveDesktopProc, "Int", remove_desktop_number, "Int", fallback_desktop_number, "Int")
    return ran
}

; SetDesktopName(0, "It works! 🐱")

; How to listen to desktop changes
DllCall(RegisterPostMessageHookProc, "Ptr", A_ScriptHwnd, "Int", 0x1400 + 30, "Int")
OnMessage(0x1400 + 30, "OnChangeDesktop")
OnChangeDesktop(wParam, lParam, msg, hwnd) {
    Critical, 100
    OldDesktop := wParam + 1
    NewDesktop := lParam + 1
    Name := GetDesktopName(NewDesktop - 1)

    ; Use Dbgview.exe to checkout the output debug logs
    OutputDebug % "Desktop changed to " Name " from " OldDesktop " to " NewDesktop
}

!1:: MoveOrGotoDesktopNumber(0)
!2:: MoveOrGotoDesktopNumber(1)
!3:: MoveOrGotoDesktopNumber(2)
!4:: MoveOrGotoDesktopNumber(3)
!5:: MoveOrGotoDesktopNumber(4)
!6:: MoveOrGotoDesktopNumber(5)
!7:: MoveOrGotoDesktopNumber(6)
!8:: MoveOrGotoDesktopNumber(7)
!9:: MoveOrGotoDesktopNumber(8)
!0:: MoveOrGotoDesktopNumber(9)





!g::
{
        MoveOrGotoDesktopNumber(9)
        Run, "E:\epic game\Epic Games\Launcher\Portal\Binaries\Win32\EpicGamesLauncher.exe"
        Run, "C:\Users\prajw\OneDrive\Desktop\NitroSense.lnk"
}
Return


CloseAllApplications() {
    WinGet, id, list,,, Program Manager
    Loop, %id%
    {
        this_id := id%A_Index%
        if (this_id = A_ScriptHwnd) {
            continue
        }
        WinGetTitle, this_title, ahk_id %this_id%
        if (this_title != "") {
            WinClose, ahk_id %this_id%
        }
    }
    
    Sleep, 1000 ; Wait for applications to exit gracefully
    
    ; Force close remaining windows that did not close (e.g. pgAdmin "close tab" prompts, VS, etc.)
    WinGet, id, list,,, Program Manager
    Loop, %id%
    {
        this_id := id%A_Index%
        if (this_id = A_ScriptHwnd) {
            continue
        }
        WinGetTitle, this_title, ahk_id %this_id%
        if (this_title != "") {
            WinGet, this_pid, PID, ahk_id %this_id%
            if (this_pid) {
                Process, Close, %this_pid%
            }
        }
    }
}

CleanBrowserSessions() {
    localAppDataPath := A_LocalAppData
    if (localAppDataPath = "") {
        EnvGet, localAppDataPath, LocalAppData
    }
    
    profiles := [ "Google\Chrome\User Data\Default"
                , "BraveSoftware\Brave-Browser\User Data\Default"
                , "Microsoft\Edge\User Data\Default"
                , "Perplexity\Comet\User Data\Default" ]
                
    for index, relPath in profiles {
        profilePath := localAppDataPath . "\" . relPath
        
        ; Delete all files in the Sessions directory
        FileDelete, %profilePath%\Sessions\*
        
        ; Delete legacy session files if they exist
        FileDelete, %profilePath%\Current Session
        FileDelete, %profilePath%\Current Tabs
        FileDelete, %profilePath%\Last Session
        FileDelete, %profilePath%\Last Tabs
    }
}

!q::
{
    ToolTip, Closing all applications and cleaning sessions...
    CloseAllApplications()
    Sleep, 2000 ; Wait for applications to exit and release file locks
    CleanBrowserSessions()
    ToolTip
}
Return

!w::
{
    ; 1. Open pgAdmin
    Run, "C:\Program Files\PostgreSQL\17\pgAdmin 4\runtime\pgAdmin4.exe"

    ; 2. Switch to Windows 2 (Desktop 1)
    GoToDesktopNumber(1)
    Sleep, 1000 ; Wait for desktop switch
    
    ; 3. Open Visual Studio and Visual Studio Code
    Run, "C:\Program Files\Microsoft Visual Studio\18\Community\Common7\IDE\devenv.exe"
    Run, "C:\Users\prajw\AppData\Local\Programs\Microsoft VS Code\Code.exe"
    
    ; 4. Wait for 5 seconds
    Sleep, 2000
   
    
    ; 5. Switch to Windows 1 (Desktop 0)
    GoToDesktopNumber(0)
    Sleep, 1000 ; Wait for desktop switch
    
    ; 6. Open Comet and navigate to the Teams link
    TeamsLink := "https://teams.microsoft.com/" ; Replace with your specific Teams link if needed
    Run, "C:\Users\prajw\AppData\Local\Perplexity\Comet\Application\comet.exe" "%TeamsLink%"
    
    ; 7. Wait for 5 seconds
    Sleep, 2000

    
    ; 9. Switch to Windows 2 (Desktop 1)
    GoToDesktopNumber(1)
    Sleep, 1000 ; Wait for desktop switch
    
}
Return

!t::
{
    MsgBox "✅ AutoHotkey v1 is loaded and working!"
Return

}