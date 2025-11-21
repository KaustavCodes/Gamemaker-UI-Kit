// scr_ui_checkbox – GUARANTEED TO SHOW (no sprite dependency)
function ui_add_checkbox(_rel_x, _rel_y, _size, _checked, _group = -1, _toggle_style = false, _label = "", _on_change = undefined, _id = "", _panel = undefined) {
    if (_panel == undefined) _panel = global.root_panel;
    else if (is_string(_panel)) _panel = ui_get_panel(_panel);
    
    var c = {
        x: _rel_x, y: _rel_y, size: _size,
        checked: _checked, value: _checked,
        group: _group, toggle_style: _toggle_style,
        label: _label, on_change: _on_change,
        hovered: false, visible: true,
        id: _id, panel: _panel
    };
    
    if (_id != "") global.ui_by_id[$ _id] = c;
    array_push(_panel.elements, c);
    array_push(global.ui_elements, c);
    
    c.update = function(inst, px, py) {
        var ax = inst.x + px;
        var ay = inst.y + py;
        var mx = device_mouse_x_to_gui(0);
        var my = device_mouse_y_to_gui(0);
        
        inst.hovered = point_in_rectangle(mx, my, ax, ay, ax + inst.size, ay + inst.size);
        
        if (inst.hovered && mouse_check_button_pressed(mb_left)) {
            inst.checked = !inst.checked;
            inst.value = inst.checked;
            
            if (inst.group >= 0 && inst.checked) {
                for (var i = 0; i < array_length(global.ui_elements); i++) {
                    var o = global.ui_elements[i];
                    if (o != inst && struct_exists(o, "group") && o.group == inst.group) {
                        o.checked = false; o.value = false;
                        if (o.on_change) o.on_change(false);
                    }
                }
            }
            if (inst.on_change) inst.on_change(inst.value);
        }
    };
    
    c.draw = function(inst, px, py) {
        var ax = inst.x + px;
        var ay = inst.y + py;
        var s = inst.size;
        
        if (inst.toggle_style) {
            // Toggle style (rounded rectangle)
            var col_bg   = inst.checked ? c_green : c_dkgray;
            var col_knob = inst.checked ? c_white : c_gray;
            draw_roundrect_color(ax, ay, ax + s*2, ay + s, col_bg, col_bg, false);
            draw_roundrect_color(ax, ay, ax + s*2, ay + s, c_black, c_black, true);
            draw_circle_color(ax + (inst.checked ? s*1.5 : s*0.5), ay + s/2, s*0.4, col_knob, col_knob, false);
        } else {
            // Classic checkbox
            draw_roundrect_color(ax, ay, ax + s, ay + s, c_white, c_white, false);
            draw_roundrect_color(ax, ay, ax + s, ay + s, c_black, c_black, true);
            if (inst.checked) {
                draw_set_color(c_blue);
                draw_line_width(ax + 4, ay + s/2, ax + s/2, ay + s - 6, 3);
                draw_line_width(ax + s/2, ay + s - 6, ax + s - 4, ay + 6, 3);
                draw_set_color(c_black);
            }
        }
        
        if (inst.hovered) {
            draw_set_alpha(0.3);
            draw_roundrect(ax, ay, ax + (inst.toggle_style ? s*2 : s), ay + s, false);
            draw_set_alpha(1);
        }
        
        if (inst.label != "") {
            draw_text(ax + (inst.toggle_style ? s*2 + 8 : s + 8), ay + s/2 - 8, inst.label);
        }
    };
    
    return c;
}