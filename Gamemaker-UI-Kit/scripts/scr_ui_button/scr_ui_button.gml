// scr_ui_button.gml — FINAL PERFECT BUTTON
function ui_button(_x, _y, _w, _h, _text, _callback, _id = "", _panel = undefined) {
    if (_panel == undefined) _panel = global.root_panel;
    else if (is_string(_panel)) _panel = ui_get_panel(_panel);
    
    var btn = {
        x: _x,
        y: _y,
        width: _w,
        height: _h,
        text: _text,
        callback: _callback,
        hovered: false,
        pressed: false,
        is_selected: false,
        id: _id,
        panel: _panel
    };
    
    if (_id != "") global.ui_by_id[$ _id] = btn;
    array_push(_panel.elements, btn);
    array_push(global.ui_elements, btn);
    
    btn.update = function(inst, px, py) {
        var ax = inst.x + px;
        var ay = inst.y + py;
        var mx = device_mouse_x_to_gui(0);
        var my = device_mouse_y_to_gui(0);
        
        inst.hovered = point_in_rectangle(mx, my, ax, ay, ax + inst.width, ay + inst.height);
        inst.is_selected = inst.hovered;
        
        if (inst.hovered && mouse_check_button_pressed(mb_left)) {
            inst.pressed = true;
        }
        
        if (inst.pressed && mouse_check_button_released(mb_left)) {
            inst.pressed = false;
            if (inst.hovered) {
                inst.callback();
            }
        }
    };
    
    btn.draw = function(inst, px, py) {
        var ax = inst.x + px;
        var ay = inst.y + py;
        
        // Background color based on state
        var bg_col = c_white;
        if (inst.pressed)      bg_col = c_dkgray;
        else if (inst.hovered) bg_col = c_ltgray;
        
        draw_roundrect_color(ax, ay, ax + inst.width, ay + inst.height, bg_col, bg_col, false);
        draw_roundrect_color(ax, ay, ax + inst.width, ay + inst.height, c_black, c_black, true);
        
        // Text
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(ax + inst.width/2, ay + inst.height/2, inst.text);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    };
    
    return btn;
}