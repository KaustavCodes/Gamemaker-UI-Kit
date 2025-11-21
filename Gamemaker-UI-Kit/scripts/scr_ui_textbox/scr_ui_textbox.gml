// scr_ui_textbox.gml
// Single-line text input
function ui_add_textbox(_rel_x, _rel_y, _w, _h, _text = "", _placeholder = "", _label = "", _on_change = undefined, _id = "", _panel = undefined) {
    if (_panel == undefined) _panel = global.root_panel;
    else if (is_string(_panel)) _panel = ui_get_panel(_panel);
    
    var tb = {
        x: _rel_x, y: _rel_y, width: _w, height: _h,
        text: _text,
        placeholder: _placeholder,
        label: _label,
        on_change: _on_change,
        cursor_pos: string_length(_text),
        selected: false,
        blink_timer: 0,
        visible: true,
        id: _id,
        panel: _panel
    };
    
    if (_id != "") global.ui_by_id[$ _id] = tb;
    array_push(_panel.elements, tb);
    array_push(global.ui_elements, tb);
    
    tb.update = function(inst, px, py) {
        var ax = inst.x + px;
        var ay = inst.y + py;
        var mx = device_mouse_x_to_gui(0);
        var my = device_mouse_y_to_gui(0);
        var clicked = point_in_rectangle(mx, my, ax, ay, ax + inst.width, ay + inst.height) && mouse_check_button_pressed(mb_left);
        
        if (clicked) {
            inst.selected = true;
            // Rough cursor position from mouse X
            var rel_x = mx - ax - 6;
            inst.cursor_pos = 0;
            for (var i = 1; i <= string_length(inst.text); i++) {
                if (string_width(string_copy(inst.text, 1, i)) > rel_x) break;
                inst.cursor_pos = i;
            }
        } else if (mouse_check_button_pressed(mb_left)) {
            inst.selected = false;
        }
        
        if (inst.selected) {
            if (keyboard_lastkey != -1) {
                if (keyboard_lastkey == vk_backspace && inst.cursor_pos > 0) {
                    inst.text = string_delete(inst.text, inst.cursor_pos, 1);
                    inst.cursor_pos--;
                } else if (keyboard_lastkey == vk_delete && inst.cursor_pos < string_length(inst.text)) {
                    inst.text = string_delete(inst.text, inst.cursor_pos + 1, 1);
                } else if (keyboard_lastkey == vk_left) {
                    inst.cursor_pos = max(0, inst.cursor_pos - 1);
                } else if (keyboard_lastkey == vk_right) {
                    inst.cursor_pos = min(string_length(inst.text), inst.cursor_pos + 1);
                } else if (keyboard_lastkey == vk_home) {
                    inst.cursor_pos = 0;
                } else if (keyboard_lastkey == vk_end) {
                    inst.cursor_pos = string_length(inst.text);
                } else if (keyboard_lastchar != "" && string_length(keyboard_lastchar) == 1) {
                    inst.text = string_insert(keyboard_lastchar, inst.text, inst.cursor_pos + 1);
                    inst.cursor_pos++;
                }
                
                if (inst.on_change) inst.on_change(inst.text);
                keyboard_lastkey = -1;
                keyboard_lastchar = "";
            }
            inst.blink_timer = (inst.blink_timer + 1) % 60;
        }
    };
    
    tb.draw = function(inst, px, py) {
        var ax = inst.x + px;
        var ay = inst.y + py;
        
        // Background
        draw_roundrect_color(ax, ay, ax + inst.width, ay + inst.height, inst.selected ? c_ltgray : c_white, c_white, false);
        draw_roundrect_color(ax, ay, ax + inst.width, ay + inst.height, c_black, c_black, true);
        
        // Text or placeholder
        var display_text = inst.text == "" ? inst.placeholder : inst.text;
        var text_col = inst.text == "" ? c_gray : c_black;
        draw_set_color(text_col);
        draw_text(ax + 6, ay + inst.height/2 - 8, display_text);
        draw_set_color(c_black);
        
        // Cursor
        if (inst.selected && inst.blink_timer < 30) {
            var cursor_x = ax + 6 + string_width(string_copy(inst.text, 1, inst.cursor_pos));
            draw_line(cursor_x, ay + 4, cursor_x, ay + inst.height - 4);
        }
        
        // Label
        if (inst.label != "") {
            draw_text(ax - string_width(inst.label) - 10, ay + inst.height/2 - 8, inst.label);
        }
    };
    
    return tb;
}