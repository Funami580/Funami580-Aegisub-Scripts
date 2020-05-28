script_name = "Install fonts"
script_description = "Install the mixed-in fonts of a mkv file. Linux-only."
script_version = "0.1.0"
script_author = "Funami580"
script_namespace = "Funami580.InstallFonts" 

local is_windows = package.config:sub(1, 1) == "\\"

function install_fonts(subtitles, selected_lines, active_line)
    if is_windows then
        aegisub.debug.out("This tool can only be used on Linux.");
    else
        local properties = aegisub.project_properties()
        local current_dir = getPath(debug.getinfo(1).source)
        
        if isEmpty(properties.video_file) then
            aegisub.debug.out("Please open a video file first.")
        else
            btn, result = aegisub.dialog.display({}, {"Permanently", "Temporarily"})
            
            if btn == "Permanently" then
                os.execute(current_dir.."/Funami580.InstallFonts.sh \""..properties.video_file.."\" true")
                aegisub.debug.out("Fonts permanently installed, please re-open the video file.")
            elseif btn == "Temporarily" then
                os.execute(current_dir.."/Funami580.InstallFonts.sh \""..properties.video_file.."\" false")
                aegisub.debug.out("Fonts temporarily installed, please re-open the video file.")
            end
        end
    end
end

function getPath(str)
    return str:match("(.*/)")
end

function isEmpty(str)
  return str == nil or str == ''
end

aegisub.register_macro(script_name, script_description, install_fonts)
