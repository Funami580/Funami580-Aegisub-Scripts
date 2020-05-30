script_name = "Lines by frames"
script_description = "Choose a range of frames which lines are created for."
script_version = "0.1.0"
script_author = "Funami580"
script_namespace = "Funami580.LinesByFrames"

util = require 'aegisub.util'

function lines_by_frames(subtitles, selected_lines, active_line)
    -- Check if exactly one line is selected
    if #selected_lines ~= 1 then
        aegisub.debug.out("You have to select exactly 1 line.")
        return
    end

    local current_index = selected_lines[1]
    local insert_index = current_index + 1
    local current_line = subtitles[current_index]

    -- Show dialog
    local dlg = {
        {
            class="label",
            label="Start frame:",
            x=0, y=0, width=1, height=1
        },
        {
            name="start_frame",
            class="intedit",
            x=1, y=0, width=2, height=1,
            min=0, value=aegisub.frame_from_ms(current_line.start_time), step=1
        },
        {
            class="label",
            label="End frame:",
            x=0, y=1, width=1, height=1
        },
        {
            name="end_frame",
            class="intedit",
            x=1, y=1, width=2, height=1,
            min=0, value=aegisub.frame_from_ms(current_line.end_time)-1, step=1
        },
        {
            class="label",
            label="Step:",
            x=0, y=2, width=1, height=1
        },
        {
            name="step",
            class="intedit",
            x=1, y=2, width=2, height=1,
            min=1, value=1, step=1
        },
        {
            class="label",
            label="Frames in text:",
            x=0, y=3, width=1, height=1
        },
        {
            name="frames_in_text",
            class="checkbox",
            x=1, y=3, width=1, height=1
        }
    }

    local btn, result = aegisub.dialog.display(dlg, {"OK", "Cancel"})

    if btn ~= "OK" then
        return
    end

    if result.start_frame > result.end_frame then
        aegisub.debug.out("The start frame cannot be bigger than the end frame.")
        return
    end

    -- Create lines from settings
    local new_lines = {}
    local j = 1

    for current_frame = result.start_frame, result.end_frame, result.step do
        local start_frame = current_frame
        local next_frame = math.min(current_frame + result.step, result.end_frame + 1)

        local text = start_frame

        if start_frame ~= next_frame - 1 then
            text = text .. "-" .. (next_frame - 1)
        end

        if not result.frames_in_text then
            text = ""
        end

        local line = create_line(current_line, text, aegisub.ms_from_frame(start_frame), aegisub.ms_from_frame(next_frame))

        new_lines[j] = line
        j = j + 1
    end

    -- Sort the lines by start time descending
    table.sort(new_lines, function (left, right)
        return left.start_time > right.start_time
    end)

    -- Insert lines
    for k, line in pairs(new_lines) do
        subtitles.insert(insert_index, line)
    end
end

-- Create a basic line
function create_line(template, text, start_time, end_time)
    local new_line = util.deep_copy(template)
    new_line.text = text
    new_line.start_time = start_time
    new_line.end_time = end_time
    return new_line
end

aegisub.register_macro(script_name, script_description, lines_by_frames)
