// scr_ui_button – FIXED VERSION
function ui_add_button(_rel_x, _rel_y, _w, _h, _text, _callback, _label = "", _id = "", _panel = undefined) {
    if (_panel == undefined) _panel = global.root_panel;
    else if (is_string(_panel)) _panel = ui_get_panel(_panel);
    
    var b = {
        x: _rel_x, y: _rel_y, width: _w, height: _h,
        text: _text, label: _label,
        callback: _callback,
        hovered: false, pressed: false,
        visible: true, id: _id, panel: _panel
    };
    
    if (_id != "") global.ui_by_id[$ _id] = b;
    array_push(_panel.elements, b);
    array_push(global.ui_elements, b);
    
    // FIXED: Use local 'inst' instead of relying on 'self' argument
    b.update = function(inst, px, py) {
        var ax = inst.x + px;
        var ay = inst.y + py;
        var mx = device_mouse_x_to_gui(0);
        var my = device_mouse_y_to_gui(0);
        
        inst.hovered = point_in_rectangle(mx, my, ax, ay, ax + inst.width, ay + inst.height);
        
        if (inst.hovered && mouse_check_button_pressed(mb_left)) {
            inst.pressed = true;
        }
        if (inst.pressed && mouse_check_button_released(mb_left) && inst.hovered) {
            inst.pressed = false;
            inst.callback();
        }
    };
    
    b.draw = function(inst, px, py) {
        var ax = inst.x + px;
        var ay = inst.y + py;
        var col = inst.hovered ? c_ltgray : c_white;
        draw_roundrect_color(ax, ay, ax + inst.width, ay + inst.height, col, col, false);
        draw_roundrect_color(ax, ay, ax + inst.width, ay + inst.height, c_black, c_black, true);
        
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(ax + inst.width/2, ay + inst.height/2, inst.text);
        
        if (inst.label != "") {
            draw_set_halign(fa_left);
            draw_text(ax - string_width(inst.label) - 10, ay + inst.height/2 - 8, inst.label);
        }
    };
    
    return b;
}