// scr_ui_slider – works without any sprites
function ui_add_slider(_rel_x, _rel_y, _w, _h, _value = 0, _min = 0, _max = 1, _step = 0, _label = "", _on_change = undefined, _id = "", _panel = undefined) {
    if (_panel == undefined) _panel = global.root_panel;
    else if (is_string(_panel)) _panel = ui_get_panel(_panel);
    
    var s = {
        x: _rel_x, y: _rel_y, width: _w, height: _h,
        value: clamp(_value, _min, _max),
        min_val: _min, max_val: _max, step: _step,
        label: _label, on_change: _on_change,
        dragged: false, visible: true,
        id: _id, panel: _panel
    };
    
    if (_id != "") global.ui_by_id[$ _id] = s;
    array_push(_panel.elements, s);
    array_push(global.ui_elements, s);
    
    s.update = function(inst, px, py) {
        var ax = inst.x + px;
        var ay = inst.y + py;
        var mx = device_mouse_x_to_gui(0);
        var my = device_mouse_y_to_gui(0);
        
        var hovered = point_in_rectangle(mx, my, ax, ay, ax + inst.width, ay + inst.height);
        
        if (hovered && mouse_check_button_pressed(mb_left)) inst.dragged = true;
        if (mouse_check_button_released(mb_left)) inst.dragged = false;
        
        if (inst.dragged) {
            var rel = clamp((mx - ax) / inst.width, 0, 1);
            var val = inst.min_val + rel * (inst.max_val - inst.min_val);
            if (inst.step > 0) val = round(val / inst.step) * inst.step;
            val = clamp(val, inst.min_val, inst.max_val);
            if (val != inst.value) {
                inst.value = val;
                if (inst.on_change) inst.on_change(val);
            }
        }
    };
    
    s.draw = function(inst, px, py) {
        var ax = inst.x + px;
        var ay = inst.y + py;
        var bar_y = ay + inst.height/2;
        
        // Background bar
        draw_set_color(c_dkgray);
        draw_rectangle(ax, bar_y - 4, ax + inst.width, bar_y + 4, false);
        
        // Filled part
        var fill_w = (inst.value - inst.min_val) / (inst.max_val - inst.min_val) * inst.width;
        draw_set_color(c_aqua);
        draw_rectangle(ax, bar_y - 4, ax + fill_w, bar_y + 4, false);
        
        // Knob
        var knob_x = ax + fill_w;
        draw_set_color(c_white);
        draw_circle(knob_x, bar_y, 10, false);
        draw_set_color(c_black);
        draw_circle(knob_x, bar_y, 10, true);
        
        // Label & value
        if (inst.label != "") {
            draw_text(ax - string_width(inst.label) - 10, ay + inst.height/2 - 8, inst.label);
        }
        draw_text(ax + inst.width + 10, ay + inst.height/2 - 8, string(round(inst.value * 100)) + "%");
    };
    
    return s;
}