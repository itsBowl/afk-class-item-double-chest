#SingleInstance, Force

settings_we_change := ["window_mode"
    ,"framerate_cap_enabled"
    ,"framerate_cap"
    ,"windowed_resolution_width"
    ,"windowed_resolution_height"
    ,"render_resolution_percentage"]

settings_we_need := {"window_mode" : 0
    , "framerate_cap_enabled" : 1
    , "framerate_cap" : 30
    , "windowed_resolution_width" : 1280 
    ,"windowed_resolution_height" : 720 
    ,"render_resolution_percentage" : 100}

; getting users keybinds 
keys_we_press := [
    ,"hold_zoom"
    ,"primary_weapon"
    ,"special_weapon"
    ,"heavy_weapon"
    ,"move_forward"
    ,"move_backward"
    ,"move_left"
    ,"move_right"
    ,"jump"
    ,"toggle_sprint"
    ,"interact"
    ,"ui_open_director" ; map
    ,"ui_open_start_menu_settings_tab"]



global keyBinds := get_d2_keybinds(keys_we_press)
global settings_we_use := get_settings(settings_we_change)

modify_cvars(settings_we_need)
Sleep, 1000
modify_cvars(settings_we_use)

F3::
{

}

get_settings(settings)
{
    
    FileRead, f, % A_AppData "\Bungie\DestinyPC\prefs\cvars.xml"
    if ErrorLevel
    {
        MsgBox, failed to oepn cvars file getSettings
        MsgBox,  %ErrorLevel% - %A_LastError%
        return False
    }
    filePath := A_AppData "\Bungie\DestinyPC\prefs\cvarsBackup.xml"
    file := FileOpen(filePath, "w")
    if !file
    {
        MsgBox, failed to create backup
    }
    file.Write(f)
    file.Close()

    b := {}
    for _, n in settings
    {
        pattern := "<cvar\s+name=""" n """\s+value=""([^""]+)""\s*/?>"
        if RegExMatch(f, pattern, m)
        {
            value := m1
            b[n] := value
        }
    }
    return b  
}

get_d2_keybinds(keybinds) ; very readable function that parses destiny 2 cvars file for keybinds
{
    FileRead, f, % A_AppData "\Bungie\DestinyPC\prefs\cvars.xml"
    if ErrorLevel
    {
        MsgBox, wailed to oepn cvars file getKeybinds
        return False
    }
    b := {}, t := {"shift": "LShift", "control": "LCtrl", "alt": "LAlt", "menu": "AppsKey", "insert": "Ins", "delete": "Del", "pageup": "PgUp", "pagedown": "PgDn", "keypad`/": "NumpadDiv", "keypad`*": "NumpadMult", "keypad`-": "NumpadSub", "keypad`+": "NumpadAdd", "keypadenter": "NumpadEnter", "leftmousebutton": "LButton", "middlemousebutton": "MButton", "rightmousebutton": "RButton", "extramousebutton1": "XButton1", "extramousebutton2": "XButton2", "mousewheelup": "WheelUp", "mousewheeldown": "WheelDown", "escape": "Esc"}
    for _, n in k 
        RegExMatch(f, "<cvar\s+name=""`" n `"""\s+value=""([^""]+)""", m) ? b[n] := t.HasKey(k2 := StrReplace((k1 := StrSplit(m1, "!")[1]) != "unused" ? k1 : k1[2], " ", "")) ? t[k2] : k2 : b[n] := "unused"
    
    return b
}

modify_cvars(settings)
{

    filePath := A_AppData "\Bungie\DestinyPC\prefs\cvars.xml"

    FileRead, f, %filePath%
    if ErrorLevel
    {
        MsgBox, wailed to oepn cvars file modifycvars
        return False
    }

    file := FileOpen(filePath, "w")
    if !file
    {
        MsgBox, failed to open modifiable cvars
        return False
    }

    for key, value in settings
    {
        pattern := "<cvar\s+name=""" key """\s+value=""[^""]+""\s*/?>"
        if RegExMatch(f, pattern, m)
        {

            f := RegExReplace(f, pattern, "<cvar name=""" key """ value=""" value """ />")
        }
    }
    file.Write(f)
    file.Close()
}