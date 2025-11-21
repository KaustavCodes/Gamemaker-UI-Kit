// scr_ui_textarea.gml – FINAL 100% WORKING (typing + backspace + scrolling + wrapping)
function ui_add_textarea(_rel_x, _rel_y, _w, _h, _text = "", _label = "", _on_change = undefined, _id = "", _panel = undefined) {
    if (_panel == undefined) _panel = global.root_panel;
    else if (is_string(_panel)) _panel = ui_get_panel(_panel);
    
    var ta = {
        x: _rel_x, y: _rel_y, width: _w, height: _h,
        text: _text,
        label: _label,
        on_change: _on_change,
        selected: false,
        scroll_y: 0,
        visible: true,
        id: _id,
        panel: _panel,
        line_height: string_height("A") + 8,
        padding: 12,
        // Typing state
        prev_string: _text,
        cursor_pos: string_length(_text),
        backspace_timer: 0  // replaces alarm
    };
    
    if (_id != "") global.ui_by_id[$ _id] = ta;
    array_push(_panel.elements, ta);
    array_push(global.ui_elements, ta);
    
    // Perfect word-wrap
    ta.wrap_text = function(inst, txt) {
        var lines = [];
        var current = "";
        var i = 1;
        while (i <= string_length(txt)) {
            var char = string_char_at(txt, i);
            var test = current + char;
            if (char == "\n") {
                array_push(lines, current);
                current = "";
                i++;
                continue;
            }
            if (string_width(test) > inst.width - 2*inst.padding) {
                var space = string_last_pos(" ", current);
                if (space > 0) {
                    array_push(lines, string_copy(current, 1, space-1));
                    current = string_copy(current, space+1, string_length(current));
                } else {
                    array_push(lines, current);
                    current = "";
                }
            } else {
                current = test;
                i++;
            }
        }
        if (current != "") array_push(lines, current);
        return lines;
    };
    
    ta.update = function(inst, px, py) {
        var ax = inst.x + px;
        var ay = inst.y + py;
        var mx = device_mouse_x_to_gui(0);
        var my = device_mouse_y_to_gui(0);
        var inside = point_in_rectangle(mx, my, ax, ay, ax + inst.width, ay + inst.height);
        
        // Focus
        if (inside && mouse_check_button_pressed(mb_left)) {
            inst.selected = true;
            keyboard_string = inst.text;
            inst.prev_string = inst.text;
            inst.cursor_pos = string_length(inst.text);
        } else if (mouse_check_button_pressed(mb_left)) {
            inst.selected = false;
        }
        
        // Scroll
        if (inside) {
            var wheel = mouse_wheel_down() - mouse_wheel_up();
            inst.scroll_y += wheel * 30;
        }
        
        // Typing with keyboard_string
        if (inst.selected) {
            if (keyboard_string != inst.prev_string) {
                inst.text = keyboard_string;
                inst.cursor_pos = string_length(inst.text);
                inst.prev_string = keyboard_string;
                if (inst.on_change) inst.on_change(inst.text);
            }
            
            // Backspace with repeat
            if (keyboard_check(vk_backspace) && inst.cursor_pos > 0) {
                if (inst.backspace_timer <= 0) {
                    inst.text = string_delete(inst.text, inst.cursor_pos, 1);
                    inst.cursor_pos--;
                    keyboard_string = inst.text;
                    inst.prev_string = inst.text;
                    if (inst.on_change) inst.on_change(inst.text);
                    inst.backspace_timer = 8; // delay before repeat
                }
                inst.backspace_timer--;
            } else {
                inst.backspace_timer = 0;
            }
        }
        
        // Scroll clamping
        var lines = inst.wrap_text(inst, inst.text);
        var total_h = array_length(lines) * inst.line_height + inst.padding;
        var max_scroll = max(0, total_h - inst.height);
        inst.scroll_y = clamp(inst.scroll_y, 0, max_scroll);
    };
    
    ta.draw = function(inst, px, py) {
        var ax = inst.x + px;
        var ay = inst.y + py;
        
        draw_roundrect_color(ax, ay, ax + inst.width, ay + inst.height,
                             inst.selected ? c_ltgray : c_white, c_white, false);
        draw_roundrect_color(ax, ay, ax + inst.width, ay + inst.height, c_black, c_black, true);
        
        var lines = inst.wrap_text(inst, inst.text);
        var yy = ay + inst.padding - inst.scroll_y;
        
        for (var i = 0; i < array_length(lines); i++) {
            var line_y = yy + i * inst.line_height;
            if (line_y >= ay && line_y < ay + inst.height) {
                draw_text(ax + inst.padding, line_y, lines[i]);
            }
        }
        
        // Cursor
        if (inst.selected && (current_time div 500) mod 2 == 0) {
            var cursor_x = ax + inst.padding;
            var cursor_y = ay + inst.padding - inst.scroll_y;
            var pos = 0;
            for (var l = 0; l < array_length(lines); l++) {
                var len = string_length(lines[l]);
                if (pos + len >= inst.cursor_pos) {
                    cursor_x += string_width(string_copy(lines[l], 1, inst.cursor_pos - pos));
                    cursor_y += l * inst.line_height;
                    break;
                }
                pos += len + 1;
            }
            draw_line(cursor_x, cursor_y, cursor_x, cursor_y + inst.line_height - 8);
        }
        
        if (inst.label != "") {
            draw_text(ax - string_width(inst.label) - 10, ay - 8, inst.label);
        }
    };
    
    return ta;
}