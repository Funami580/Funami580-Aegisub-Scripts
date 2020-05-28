script_name = "Merge with move"
script_description = "Merge lines with a move line."
script_version = "0.1.0"
script_author = "Funami580"
script_namespace = "Funami580.MergeWithMove"

util = require 'aegisub.util'

function merge_with_move(subtitles, selected_lines, active_line)
    -- Check if a line is selected
    if #selected_lines < 2 then
        aegisub.debug.out("You have to select at least 2 lines.")
        return
    end

    -- Get line with move tag
    local move_line = subtitles[selected_lines[1]]

    -- Check for move tag
    local move_regex = "\\move%(([^%)]+)%)"
    local move_tag_indices = string.find(move_line.text, move_regex)

    if move_tag_indices == nil then
        aegisub.debug.out("The first selected line has to contain a move tag.")
        return
    end

    -- Get move tag values
    local move_tag = move_line.text
                              :gsub("[^{]*({[^}]*})[^{]*", "%1") -- Remove everything outside curly brackets
                              :match(move_regex) -- Get the values in the move tag
                              :gsub("%s+", "") -- Remove unnecessary spaces

    local move_tag_values = {}
    local i = 1

    for value in string.gmatch(move_tag, '([^,]+)') do
        local num = tonumber(value)

        if num == nil then
            aegisub.debug.out("Invalid move tag.")
            return
        end

        move_tag_values[i] = num
        i = i + 1
    end

    local move_tag_values_length = #move_tag_values

    if move_tag_values_length ~= 4 and move_tag_values_length ~= 6 then
        aegisub.debug.out("Invalid move tag.")
        return
    end

    -- Get all other selected lines
    local other_lines = {}

    for k, v in pairs({unpack(selected_lines, 2, #selected_lines)}) do
        local line = subtitles[v]

        if line.start_time < move_line.start_time or line.end_time > move_line.end_time then
            aegisub.debug.out("All selected lines have to be in the time range of the move tag line.")
            return
        end

        other_lines[k] = line
    end

    table.sort(other_lines, function (left, right) -- Sort the lines by the start time
        return left.start_time < right.start_time
    end)

    -- Fill up the time in-between
    local filled_lines = util.copy(other_lines)
    local last_time = -1

    for k, v in pairs(other_lines) do
        if last_time == -1 then
            last_time = v.end_time
            goto continue
        end

        local temp_last_time = last_time
        last_time = v.end_time

        if v.start_time - temp_last_time == 0 then
            goto continue
        elseif temp_last_time > v.start_time then
            aegisub.debug.out("The lines without the move tag shouldn't overlap in time.")
            return
        end

        local empty_line = create_line(move_line, "", temp_last_time, v.start_time)
        table.insert(filled_lines, empty_line)
        ::continue::
    end

    -- Check if the first line starts with the move line
    if other_lines[1].start_time - move_line.start_time > 0 then
        local empty_line = create_line(move_line, "", move_line.start_time, other_lines[1].start_time)
        table.insert(filled_lines, empty_line)
    end

    -- Check if last line goes till the end of the move line
    if move_line.end_time - other_lines[#other_lines].end_time > 0 then
        local empty_line = create_line(move_line, "", other_lines[#other_lines].end_time, move_line.end_time)
        table.insert(filled_lines, empty_line)
    end

    -- Sort the filled lines by start time descending
    table.sort(filled_lines, function (left, right)
        return left.start_time > right.start_time
    end)

    -- Move tag values + calc functions
    local x1 = move_tag_values[1]
    local y1 = move_tag_values[2]
    local x2 = move_tag_values[3]
    local y2 = move_tag_values[4]
    local t1 = move_tag_values[5]
    local t2 = move_tag_values[6]

    if t1 ~= nil and t2 ~= nil and t1 > t2 then
        aegisub.debug.out("Not possible: t1 > t2")
        return
    end

    local function get_x(time)
        return get_value_by_time(x1, x2, move_line.start_time, move_line.end_time, t1, t2, time)
    end

    local function get_y(time)
        return get_value_by_time(y1, y2, move_line.start_time, move_line.end_time, t1, t2, time)
    end

    -- Preparing new lines
    local new_lines = {}
    local j = 1

    for k, v in pairs(filled_lines) do
        local new_x1 = get_x(v.start_time - move_line.start_time)
        local new_x2 = get_x(v.end_time - move_line.start_time)
        local new_y1 = get_y(v.start_time - move_line.start_time)
        local new_y2 = get_y(v.end_time - move_line.start_time)
        local new_t1 = t1
        local new_t2 = t2

        if new_t1 ~= nil then
            new_t1 = t1 - (v.start_time - move_line.start_time)
        end

        if new_t2 ~= nil then
            new_t2 = t2 - (v.start_time - move_line.start_time)
        end

        local new_move_tag = create_move_tag(new_x1, new_y1, new_x2, new_y2, new_t1, new_t2, v.start_time, v.end_time)

        if new_move_tag == nil then
            aegisub.debug.out("Not possible: t1 > t2")
            return
        end

        local new_text = v.text .. move_line.text:gsub(move_regex, new_move_tag)
        local new_line = create_line(move_line, new_text, v.start_time, v.end_time)

        new_lines[j] = new_line
        j = j + 1
    end

    -- Commenting out old lines
    for k, v in pairs(selected_lines) do
        local line = subtitles[v]
        line.comment = true
        subtitles[v] = line
    end

    -- Inserting new lines
    local insert_index = selected_lines[#selected_lines] + 1

    for k, v in pairs(new_lines) do
        subtitles.insert(insert_index, v)
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

-- Get the position taking the move tag into regard
function get_value_by_time(result_begin, result_end, line_start, line_end, relative_start, relative_end, time)
    if relative_start == nil or relative_end == nil then
        return result_begin + ((result_end-result_begin)/(line_end-line_start)) * time
    elseif time < relative_start then
        return result_begin
    elseif time > relative_end then
        return result_end
    else
        return result_begin + ((result_end-result_begin)/((line_start+relative_end)-(line_start+relative_start))) * (time-relative_start)
    end
end

-- Creates move/pos tag by specified values
function create_move_tag(x1, y1, x2, y2, t1, t2, line_start, line_end)
    local formatted_x1 = round(x1, 1)
    local formatted_y1 = round(y1, 1)
    local formatted_x2 = round(x2, 1)
    local formatted_y2 = round(y2, 1)

    local new_t2 = t2

    if t2 > line_end - line_start then
        new_t2 = line_end - line_start
    end

    if t1 == nil or t2 == nil or (t1 <= 0 and t2 > line_end - line_start) then
        return string.format("\\move(%s,%s,%s,%s)", formatted_x1, formatted_y1, formatted_x2, formatted_y2)
    elseif (t1 <= 0 and t2 <= 0) or t1 > line_end - line_start then
        return string.format("\\pos(%s,%s)", formatted_x2, formatted_y2)
    elseif t1 >= 0 and t2 > 0 then
        return string.format("\\move(%s,%s,%s,%s,%s,%s)", formatted_x1, formatted_y1, formatted_x2, formatted_y2, t1, new_t2)
    elseif t1 < 0 and t2 > 0 then
        return string.format("\\move(%s,%s,%s,%s,0,%s)", formatted_x1, formatted_y1, formatted_x2, formatted_y2, new_t2)
    else
        return nil
    end
end

-- Rounds a number to the specified decimal places
function round(num, decimal_places)
    local mult = 10^(decimal_places or 0)
    return tostring(math.floor(num * mult + 0.5) / mult):gsub("%.0+$", "")
end

aegisub.register_macro(script_name, script_description, merge_with_move)
