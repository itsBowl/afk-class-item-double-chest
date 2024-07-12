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

click_all_the_settings()
{
    
}

; util functions

game_close() ; kills the game, if it exists
{
    if WinExist("Destiny 2")
    {
        WinKill, Destiny 2
        Sleep, 20000
    }   
}

game_open() ; starts the game
{
    
    Run, steam://rungameid/1085660,, Hide ; This launches Destiny 2 through Steam
    Sleep, 20000
    WinWait, Destiny 2
    Sleep, 20000
    find_d2()
    search_start := A_TickCount
    while (simpleColorCheck("581|391|87|15", 87, 15) < 0.90)
        {
            if (A_TickCount - search_start > 90000)
                break
        }
        Sleep, 10
        Send, {enter}
        Send, {enter}
        Send, {enter}
        Sleep, 10000
        while (simpleColorCheck("802|274|64|20", 64, 20) < 0.12)
        {
            if (A_TickCount - search_start > 90000)
                break
        }
        d2_click(900, 374, 0)
        Sleep, 100 
        d2_click(900, 374)
        return
}