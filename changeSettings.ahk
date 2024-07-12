#SingleInstance, Force


MsgBox, Running

find_d2()

; getting users settings that we can see in the cvars that may need changing
settings_we_change := ["window_mode"
    ,"framerate_cap_enabled"
    ,"framerate_cap"
    ,"windowed_resolution_width"
    ,"windowed_resolution_height"
    ,"render_resolution_percentage"]

settings_we_change_to := {"window_mode" : 0
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



global key_binds := get_d2_keybinds(keys_we_press) ; this gives us a dictionary of keybinds

global settings := get_required_settings(settings_we_change)

modify_cvars(settings_we_change_to)

MsgBox, Finished Running


F2::get_mouse_pos_relative_to_d2()


F6::
{

    WinActivate, ahk_exe destiny2.exe

    ; settings = get_required_settings(settings_we_change)
    if (!key_binds["ui_open_start_menu_settings_tab"])
    {
        Send, {F1}
         Sleep, 3000
        d2_click(1144, 38, 0)
        Sleep, 100
        d2_click(1144, 38)
    }
    else
        Send, % "{" key_binds["ui_open_start_menu_settings_tab"] "}"
    Sleep, 900
    
    
    d2_click(211, 336) ; video
    Sleep, 1100
    d2_click(1187, 167, 0) ; goto window mode menu
    Sleep, 100
    d2_click(1187, 167) ; click on menu
    Sleep, 1000
    d2_click(1147, 201) ; set to windowed
    Sleep, 2500
    d2_click(1184, 273, 0) ; click on framerate cap enabled to enable it
    Sleep, 100
    d2_click(1184, 273)
    Sleep, 1000

    Send {Enter}
    Sleep, 500
    Send {Enter}



    return
}

get_mouse_pos_relative_to_d2() ; gets the mouse coords in x, y form relative to destinys client area
{
    ; Get the current mouse position
    MouseGetPos, mouseX, mouseY

    ; Calculate the position relative to the Destiny 2 client area
    relativeX := mouseX - DESTINY_X
    relativeY := mouseY - DESTINY_Y

    Clipboard := relativeX ", " relativeY
    return {X: relativeX, Y: relativeY}
}

d2_click(x, y, press_button:=1) ; click somewhere on d2
{
    Click, % DESTINY_X + x " " DESTINY_Y + y " " press_button
    return
}

get_required_settings(k)
{
    MsgBox, Getting settings
    FileRead, f, % A_AppData "\Bungie\DestinyPC\prefs\cvars - Test.xml"
    if ErrorLevel
    {
        MsgBox, Failed to open cvars to get settings
        return False
    }
        

    b := {}
    for _, n in k
        {
        pattern := "<cvar\s+name=""" n """\s+value=""([^""]+)""\s*/?>"
        if RegExMatch(f, pattern, m)
        {
            value := m1 ; m1 contains the value matched by ([^""]+)
            b[n] := value
        }
    }
    MsgBox, finished getting settings
    return b
}

modify_cvars(k)
{
    filePath := A_AppData "\Bungie\DestinyPC\prefs\cvars - Test.xml"
    
    FileRead, f, %filePath%
    if ErrorLevel
    {
        MsgBox, Failed to read file
        return False
    }
        

    file := FileOpen(filePath, "w")
    if !file
    {
        MsgBox, Unable to open file.
        return False
    }
        

    MsgBox Updating cvars
    for key, value in k
    {
        pattern := "<cvar\s+name=""" key """\s+value=""([^""]+)""\s*/?>"

        if RegExMatch(f, pattern, key)
        {
            f := RegExReplace(data, pattern, "<cvar name=""" key """ value=""" value """ />")
        }
    }
    file.Write(f)
    file.Close()

    MsgBox, Set cvars
}

find_d2() ; find the client area of d2
{
    ; Detect the Destiny 2 game window
    WinGet, Destiny2ID, ID, ahk_exe destiny2.exe

    ; Get the dimensions of the game window's client area
    WinGetPos, X, Y, Width, Height, ahk_id %Destiny2ID%
    if(Y < 1) {
        WinMove, ahk_exe destiny2.exe,, X, 1
    }
    WinGetPos, X, Y, Width, Height, ahk_id %Destiny2ID%
    VarSetCapacity(Rect, 16)
    DllCall("GetClientRect", "Ptr", WinExist("ahk_id " . Destiny2ID), "Ptr", &Rect)
    ClientWidth := NumGet(Rect, 8, "Int")
    ClientHeight := NumGet(Rect, 12, "Int")

    ; Calculate border and title bar sizes
    BorderWidth := (Width - ClientWidth) // 2
    TitleBarHeight := Height - ClientHeight - BorderWidth

    ; Update the global vars
    DESTINY_X := X + BorderWidth
    DESTINY_Y := Y + TitleBarHeight
    DESTINY_WIDTH := ClientWidth
    DESTINY_HEIGHT := ClientHeight
    return
}

get_d2_keybinds(k) ; very readable function that parses destiny 2 cvars file for keybinds
{
    FileRead, f, % A_AppData "\Bungie\DestinyPC\prefs\cvars - Test.xml"
    if ErrorLevel 
        return False
    b := {}, t := {"shift": "LShift", "control": "LCtrl", "alt": "LAlt", "menu": "AppsKey", "insert": "Ins", "delete": "Del", "pageup": "PgUp", "pagedown": "PgDn", "keypad`/": "NumpadDiv", "keypad`*": "NumpadMult", "keypad`-": "NumpadSub", "keypad`+": "NumpadAdd", "keypadenter": "NumpadEnter", "leftmousebutton": "LButton", "middlemousebutton": "MButton", "rightmousebutton": "RButton", "extramousebutton1": "XButton1", "extramousebutton2": "XButton2", "mousewheelup": "WheelUp", "mousewheeldown": "WheelDown", "escape": "Esc"}
    for _, n in k 
        RegExMatch(f, "<cvar\s+name=""`" n `"""\s+value=""([^""]+)""", m) ? b[n] := t.HasKey(k2 := StrReplace((k1 := StrSplit(m1, "!")[1]) != "unused" ? k1 : k1[2], " ", "")) ? t[k2] : k2 : b[n] := "unused"
    return b
}
