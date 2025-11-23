// scr_ui_toggle.gml — FINAL PERFECT TOGGLE (ON/OFF SWITCH)
function ui_toggle(_x, _y, _w, _h, _checked = false, _on_change = undefined, _id = "", _panel = undefined) {
    if (_panel == undefined) _panel = global.root_panel;
    else if (is_string(_panel)) _panel = ui_get_panel(_panel);
    
    var tg = {
        x: _x,
        y: _y,
        width: _w,
        height: _h,
        checked: _checked,
        hovered: false,
        on_change: _on_change,
        id: _id,
        panel: _panel
    };
    
    if (_id != "") global.ui_by_id[$ _id] = tg;
    array_push(_panel.elements, tg);
    array_push(global.ui_elements, tg);
    
    tg.update = function(inst, px, py) {
        var ax = inst.x + px;
        var ay = inst.y + py;
        var mx = device_mouse_x_to_gui(0);
        var my = device_mouse_y_to_gui(0);
        
        inst.hovered = point_in_rectangle(mx, my, ax, ay, ax + inst.width, ay + inst.height);
        
        if (inst.hovered && mouse_check_button_pressed(mb_left)) {
            inst.checked = !inst.checked;
            if (inst.on_change) inst.on_change(inst.checked);
        }
    };
    
    tg.draw = function(inst, px, py) {
        var ax = inst.x + px;
        var ay = inst.y + py;
        var radius = inst.height / 2;
        var knob_x = inst.checked ? ax + inst.width - radius : ax + radius;
        
        // Background track
        var track_col = inst.hovered ? c_ltgray : c_gray;
        draw_roundrect_color(ax, ay, ax + inst.width, ay + inst.height, track_col, track_col, false);
        draw_roundrect_color(ax, ay, ax + inst.width, ay + inst.height, c_black, c_black, true);
        
        // Fill when ON
        if (inst.checked) {
            draw_roundrect_color(ax + 2, ay + 2, ax + inst.width - 2, ay + inst.height - 2, c_green, c_green, false);
        }
        
        // Knob
        var knob_col = inst.checked ? c_white : c_dkgray;
        draw_circle_color(knob_x, ay + radius, radius - 4, knob_col, knob_col, false);
        draw_circle_color(knob_x, ay + radius, radius - 4, c_black, c_black, true);
        
        // Optional hover glow
        if (inst.hovered) {
            draw_set_alpha(0.2);
            draw_roundrect_color(ax, ay, ax + inst.width, ay + inst.height, c_white, c_white, false);
            draw_set_alpha(1);
        }
    };
    
    return tg;
}