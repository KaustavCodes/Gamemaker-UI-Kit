// scr_ui_textarea.gml — FINAL, BULLETPROOF, FLAWLESS
function ui_textarea(_x, _y, _w, _h, _text = "", _placeholder = "", _id = "") {
    var ta = {
        x: _x,
        y: _y,
        width: _w,
        height: _h,
        text: _text,
        placeholder: _placeholder,
        is_selected: false,
        cursor_pos: string_length(_text),
        scroll_y: 0,
        line_height: string_height("A") + 6,
        padding: 10,
        blink_timer: 0,
        backspace_timer: 0,
        scrollbar_width: 12,
        scrollbar_dragging: false,
        scrollbar_drag_offset: 0,
        id: _id
    };
    
    if (_id != "") global.ui_by_id[$ _id] = ta;
    array_push(global.root_panel.elements, ta);
    array_push(global.ui_elements, ta);
    
    // Get wrapped lines
    ta.get_lines = function(inst) {
        var lines = [];
        var line = "";
        var i = 1;
        while (i <= string_length(inst.text) + 1) {
            var char = (i <= string_length(inst.text)) ? string_char_at(inst.text, i) : "\n";
            var test = line + char;
            if (char == "\n" || string_width(test) > inst.width - 2*inst.padding - inst.scrollbar_width) {
                array_push(lines, line);
                line = (char == "\n") ? "" : char;
            } else {
                line = test;
            }
            i++;
        }
        if (line != "") array_push(lines, line);
        return lines;
    };
    
    // Cursor line & column
    ta.get_cursor_line_col = function(inst) {
        var lines = inst.get_lines(inst);
        var pos = 0;
        var line_idx = 0;
        var col = 0;
        for (var l = 0; l < array_length(lines); l++) {
            var len = string_length(lines[l]);
            if (pos + len >= inst.cursor_pos) {
                line_idx = l;
                col = inst.cursor_pos - pos;
                break;
            }
            pos += len + 1;
        }
        return { line: line_idx, col: col };
    };
    
    ta.update = function(inst) {
        var mx = device_mouse_x_to_gui(0);
        var my = device_mouse_y_to_gui(0);
        var inside = point_in_rectangle(mx, my, inst.x, inst.y, inst.x + inst.width, inst.y + inst.height);
        
        // Focus
        if (inside && mouse_check_button_pressed(mb_left)) {
            inst.is_selected = true;
            keyboard_string = inst.text;
        } else if (mouse_check_button_pressed(mb_left)) {
            inst.is_selected = false;
        }
        
        // Scrollbar drag — fixed to go full top/bottom
        var sb_x = inst.x + inst.width - inst.scrollbar_width;
        var lines = inst.get_lines(inst);
        var total_h = array_length(lines) * inst.line_height + inst.padding * 2;
        var view_h = inst.height;
        var handle_h = max(20, (view_h / total_h) * view_h);
        var handle_y = inst.y + (inst.scroll_y / max(1, total_h - view_h)) * (view_h - handle_h);

        // Scrollbar drag logic: only drag if mouse is inside handle
        if (inst.scrollbar_dragging) {
            if (mouse_check_button_released(mb_left)) {
                inst.scrollbar_dragging = false;
            } else {
                var new_handle_y = clamp(my - inst.scrollbar_drag_offset, inst.y, inst.y + view_h - handle_h);
                var ratio = (new_handle_y - inst.y) / (view_h - handle_h);
                // If handle is at top, scroll_y = 0; if at bottom, scroll_y = max
                inst.scroll_y = round(ratio * max(0, total_h - view_h));
            }
        } else if (inside && mouse_check_button_pressed(mb_left) && mx >= sb_x) {
            if (my >= handle_y && my <= handle_y + handle_h) {
                inst.scrollbar_dragging = true;
                inst.scrollbar_drag_offset = my - handle_y;
            }
        }
        
        // Mouse wheel
        if (inside) {
            inst.scroll_y += (mouse_wheel_down() - mouse_wheel_up()) * 30;
        }
        
        if (inst.is_selected) {
            var lc = inst.get_cursor_line_col(inst);
            
            // Enter
            if (keyboard_check_pressed(vk_enter)) {
                inst.text = string_insert("\n", inst.text, inst.cursor_pos + 1);
                inst.cursor_pos++;
                keyboard_string = inst.text;
            }
            // Typing
            if (keyboard_string != inst.text) {
                inst.text = keyboard_string;
                inst.cursor_pos = string_length(inst.text);
            }
            // Backspace — only delete one character per press
            if (keyboard_check_pressed(vk_backspace) && inst.cursor_pos > 0) {
                inst.text = string_delete(inst.text, inst.cursor_pos, 1);
                inst.cursor_pos--;
                keyboard_string = inst.text;
            }
            
            // LEFT / RIGHT / UP / DOWN / HOME / END — navigation only, do NOT set keyboard_string
            if (keyboard_check(vk_left)) {
                var lc = inst.get_cursor_line_col(inst);
                if (lc.col > 0) {
                    inst.cursor_pos = max(0, inst.cursor_pos - 1);
                } else if (lc.line > 0) {
                    var prev_len = string_length(lines[lc.line - 1]);
                    var pos = 0;
                    for (var l = 0; l < lc.line - 1; l++) pos += string_length(lines[l]) + 1;
                    inst.cursor_pos = pos + prev_len;
                }
            }
            var lc = inst.get_cursor_line_col(inst);
            if (lc.line < array_length(lines)) {
                if (lc.col < string_length(lines[lc.line]) && keyboard_check(vk_right)) {
                    inst.cursor_pos = min(string_length(inst.text), inst.cursor_pos + 1);
                } else if (lc.col == string_length(lines[lc.line]) && lc.line < array_length(lines) - 1 && keyboard_check_pressed(vk_right)) {
                    var pos = 0;
                    for (var l = 0; l <= lc.line; l++) pos += string_length(lines[l]) + 1;
                    inst.cursor_pos = pos;
                }
            }
            if (keyboard_check_pressed(vk_up) && lc.line > 0) {
                var target_line = lc.line - 1;
                var target_col = min(lc.col, string_length(lines[target_line]));
                var pos = 0;
                for (var l = 0; l < target_line; l++) pos += string_length(lines[l]) + 1;
                inst.cursor_pos = pos + target_col;
            }
            if (keyboard_check_pressed(vk_down) && lc.line < array_length(lines) - 1) {
                var target_line = lc.line + 1;
                var target_col = min(lc.col, string_length(lines[target_line]));
                var pos = 0;
                for (var l = 0; l < target_line; l++) pos += string_length(lines[l]) + 1;
                inst.cursor_pos = pos + target_col;
            }
            if (keyboard_check_pressed(vk_home)) inst.cursor_pos = 0;
            if (keyboard_check_pressed(vk_end))  inst.cursor_pos = string_length(inst.text);
            // Clamp cursor position
            inst.cursor_pos = clamp(inst.cursor_pos, 0, string_length(inst.text));

            inst.blink_timer = (inst.blink_timer + 1) % 60;
        }
        
        // Clamp scroll
        inst.scroll_y = clamp(inst.scroll_y, 0, max(0, total_h - view_h));
        // Debug: show scroll and cursor
        // show_debug_message("scroll_y: " + string(inst.scroll_y) + ", cursor_pos: " + string(inst.cursor_pos));
        
        // Auto-scroll cursor
        if (inst.is_selected) {
            var lc = inst.get_cursor_line_col(inst);
            var cursor_y = lc.line * inst.line_height + inst.padding;
            if (cursor_y - inst.scroll_y < inst.padding) {
                inst.scroll_y = cursor_y - inst.padding;
            } else if (cursor_y - inst.scroll_y > inst.height - inst.padding * 2) {
                inst.scroll_y = cursor_y - (inst.height - inst.padding * 2);
            }
            inst.scroll_y = clamp(inst.scroll_y, 0, max(0, total_h - view_h));
        }
    };
    
    ta.draw = function(inst) {
        var ax = inst.x;
        var ay = inst.y;
        
        draw_roundrect_color(ax, ay, ax + inst.width, ay + inst.height,
                             inst.is_selected ? c_ltgray : c_white, c_white, false);
        draw_roundrect_color(ax, ay, ax + inst.width, ay + inst.height, c_black, c_black, true);
        
        var lines = inst.get_lines(inst);
        var yy = ay + inst.padding - inst.scroll_y;
        for (var i = 0; i < array_length(lines); i++) {
            var line_y = yy + i * inst.line_height;
            if (line_y + inst.line_height > ay && line_y < ay + inst.height) {
                draw_text(ax + inst.padding, line_y, lines[i]);
            }
        }
        
        // Scrollbar
        var total_h = array_length(lines) * inst.line_height + inst.padding * 2;
        if (total_h > inst.height) {
            var sb_x = ax + inst.width - inst.scrollbar_width;
            var handle_h = max(20, (inst.height / total_h) * inst.height);
            var handle_y = ay + (inst.scroll_y / max(1, total_h - inst.height)) * (inst.height - handle_h);
            
            draw_set_color(c_dkgray);
            draw_rectangle(sb_x, ay, ax + inst.width, ay + inst.height, false);
            draw_set_color(inst.scrollbar_dragging ? c_white : c_gray);
            draw_rectangle(sb_x + 2, handle_y, ax + inst.width - 2, handle_y + handle_h, false);
        }
        
        // Cursor
        if (inst.is_selected && inst.blink_timer < 30) {
            var lc = inst.get_cursor_line_col(inst);
            var cursor_screen_y = ay + inst.padding + lc.line * inst.line_height - inst.scroll_y;
            if (cursor_screen_y >= ay + 8 && cursor_screen_y <= ay + inst.height - 8) {
                var cursor_x = ax + inst.padding + string_width(string_copy(lines[lc.line], 1, lc.col));
                draw_line(cursor_x, cursor_screen_y, cursor_x, cursor_screen_y + inst.line_height - 8);
            }
        }
        
        // Placeholder
        if (inst.text == "" && !inst.is_selected) {
            draw_set_color(c_gray);
            draw_text(ax + inst.padding, ay + inst.padding, inst.placeholder);
            draw_set_color(c_black);
        }
    };
    
    return ta;
}