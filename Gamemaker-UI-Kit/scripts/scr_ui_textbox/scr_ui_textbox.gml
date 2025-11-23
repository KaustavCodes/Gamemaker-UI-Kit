// scr_ui_textbox.gml — ULTIMATE FINAL VERSION (Ctrl+A/C/V/X/Z + auto-scroll)
function ui_textbox(_x, _y, _w, _h, _text = "", _placeholder = "", _id = "") {
    var tb = {
        x: _x,
        y: _y,
        width: _w,
        height: _h,
        text: _text,
        placeholder: _placeholder,
        is_selected: false,
        cursor_pos: string_length(_text),
        scroll_offset: 0,
        blink_timer: 0,
        backspace_timer: 0,
        delete_timer: 0,
        undo_stack: ds_stack_create(),
        undo_pos: 0,
        id: _id
    };
    
    // Save initial state for undo
    ds_stack_push(tb.undo_stack, _text);
    
    if (_id != "") global.ui_by_id[$ _id] = tb;
    array_push(global.root_panel.elements, tb);
    array_push(global.ui_elements, tb);
    
    tb.update = function(inst) {
        var mx = device_mouse_x_to_gui(0);
        var my = device_mouse_y_to_gui(0);
        var inside = point_in_rectangle(mx, my, inst.x, inst.y, inst.x + inst.width, inst.y + inst.height);
        
        if (inside && mouse_check_button_pressed(mb_left)) {
            inst.is_selected = true;
            keyboard_string = inst.text;
            
            var rel_x = mx - (inst.x + 10) + inst.scroll_offset;
            inst.cursor_pos = 0;
            for (var i = 1; i <= string_length(inst.text); i++) {
                if (string_width(string_copy(inst.text, 1, i)) > rel_x) break;
                inst.cursor_pos = i;
            }
        } else if (mouse_check_button_pressed(mb_left)) {
            inst.is_selected = false;
        }
        
        if (inst.is_selected) {
            var ctrl = keyboard_check(vk_control);
            var shift = keyboard_check(vk_shift);
            
            // Ctrl+A — Select All
            if (ctrl && keyboard_check_pressed(ord("A"))) {
                inst.cursor_pos = string_length(inst.text);
                keyboard_string = inst.text;
            }
            
            // Ctrl+C — Copy
            if (ctrl && keyboard_check_pressed(ord("C"))) {
                clipboard_set_text(inst.text);
            }
            
            // Ctrl+V — Paste
            if (ctrl && keyboard_check_pressed(ord("V"))) {
                var paste = clipboard_get_text();
                inst.text = string_insert(paste, inst.text, inst.cursor_pos + 1);
                inst.cursor_pos += string_length(paste);
                keyboard_string = inst.text;
            }
            
            // Ctrl+X — Cut
            if (ctrl && keyboard_check_pressed(ord("X"))) {
                clipboard_set_text(inst.text);
                inst.text = "";
                inst.cursor_pos = 0;
                keyboard_string = "";
            }
            
            // Ctrl+Z — Undo
            if (ctrl && keyboard_check_pressed(ord("Z"))) {
                if (ds_stack_size(inst.undo_stack) > 1) {
                    ds_stack_pop(inst.undo_stack); // remove current
                    inst.text = ds_stack_top(inst.undo_stack);
                    inst.cursor_pos = string_length(inst.text);
                    keyboard_string = inst.text;
                }
            }
            
            // Save undo state (every 30 frames or on major change)
            if (current_time - inst.undo_pos > 500) {
                ds_stack_push(inst.undo_stack, inst.text);
                if (ds_stack_size(inst.undo_stack) > 20) ds_stack_pop(inst.undo_stack);
                inst.undo_pos = current_time;
            }
            
            // Normal typing
            if (keyboard_lastchar != "" && !ctrl && keyboard_lastkey != vk_backspace && keyboard_lastkey != vk_delete &&
                keyboard_lastkey != vk_left && keyboard_lastkey != vk_right &&
                keyboard_lastkey != vk_home && keyboard_lastkey != vk_end) {
                
                inst.text = string_insert(keyboard_lastchar, inst.text, inst.cursor_pos + 1);
                inst.cursor_pos++;
                keyboard_string = inst.text;
            }
            
            // Arrow keys
            if (keyboard_check_pressed(vk_left))  inst.cursor_pos = max(0, inst.cursor_pos - 1);
            if (keyboard_check_pressed(vk_right)) inst.cursor_pos = min(string_length(inst.text), inst.cursor_pos + 1);
            if (keyboard_check_pressed(vk_home))  inst.cursor_pos = 0;
            if (keyboard_check_pressed(vk_end))   inst.cursor_pos = string_length(inst.text);
            
            // Backspace / Delete
            if (keyboard_check(vk_backspace) && inst.cursor_pos > 0) {
                if (inst.backspace_timer <= 0) {
                    inst.text = string_delete(inst.text, inst.cursor_pos, 1);
                    inst.cursor_pos--;
                    keyboard_string = inst.text;
                    inst.backspace_timer = 8;
                }
                inst.backspace_timer--;
            } else inst.backspace_timer = 0;
            
            if (keyboard_check(vk_delete) && inst.cursor_pos < string_length(inst.text)) {
                if (inst.delete_timer <= 0) {
                    inst.text = string_delete(inst.text, inst.cursor_pos + 1, 1);
                    keyboard_string = inst.text;
                    inst.delete_timer = 8;
                }
                inst.delete_timer--;
            } else inst.delete_timer = 0;
            
            // AUTO-SCROLL: keep cursor visible
            var cursor_x = string_width(string_copy(inst.text, 1, inst.cursor_pos));
            var max_visible = inst.width - 20;
            if (cursor_x - inst.scroll_offset < 20) {
                inst.scroll_offset = max(0, cursor_x - 20);
            } else if (cursor_x - inst.scroll_offset > max_visible) {
                inst.scroll_offset = cursor_x - max_visible;
            }
            
            inst.blink_timer = (inst.blink_timer + 1) % 60;
        }
        
        keyboard_lastkey = -1;
        keyboard_lastchar = "";
    };
    
    tb.draw = function(inst) {
        var ax = inst.x;
        var ay = inst.y;
        
        draw_roundrect_color(ax, ay, ax + inst.width, ay + inst.height,
                             inst.is_selected ? c_ltgray : c_white, c_white, false);
        draw_roundrect_color(ax, ay, ax + inst.width, ay + inst.height, c_black, c_black, true);
        
        var display = (inst.text == "") ? inst.placeholder : inst.text;
        var col = (inst.text == "") ? c_gray : c_black;
        draw_set_color(col);
        draw_text(ax + 10 - inst.scroll_offset, ay + inst.height/2 - 8, display);
        draw_set_color(c_black);
        
        if (inst.is_selected && inst.blink_timer < 30) {
            var cursor_x = ax + 10 + string_width(string_copy(inst.text, 1, inst.cursor_pos)) - inst.scroll_offset;
            draw_line(cursor_x, ay + 8, cursor_x, ay + inst.height - 8);
        }
    };
    
    return tb;
}