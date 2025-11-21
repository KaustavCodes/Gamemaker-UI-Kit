// ui_create_panel(x, y, w, h, id, visible)
function ui_create_panel(_x, _y, _w, _h, _id = "", _visible = true) {
    var p = {
        x: _x, y: _y, width: _w, height: _h,
        visible: _visible,
        elements: [],
        id: _id
    };
    
    p.draw = function(inst) {  // ← name doesn't matter, but use 'inst' consistently
        draw_set_alpha(0.95);
        draw_roundrect_color(inst.x, inst.y, inst.x + inst.width, inst.y + inst.height, 
                            c_dkgray, c_dkgray, false);
        draw_roundrect_color(inst.x, inst.y, inst.x + inst.width, inst.y + inst.height, 
                            c_black, c_black, true);
        draw_set_alpha(1);
    };
    
    array_push(global.ui_panels, p);
    if (_id != "") global.ui_panels_by_id[$ _id] = p;
    return p;
}

function ui_get_panel(_id) { return global.ui_panels_by_id[$ _id] ?? undefined; }
function ui_set_panel_visible(_id, _vis) { var p = ui_get_panel(_id); if (p) p.visible = _vis; }
function ui_toggle_panel(_id) { var p = ui_get_panel(_id); if (p) p.visible = !p.visible; }

function ui_get_element(_id) { return global.ui_by_id[$ _id] ?? undefined; }
function ui_get_value(_id) { 
    var e = ui_get_element(_id); 
    return (e && variable_struct_exists(e, "value")) ? e.value : undefined;
}

function ui_set_visible(_id, _vis) { 
    var e = ui_get_element(_id); 
    if (e) e.visible = _vis; 
}

function ui_remove_element(_id) {
    var e = ui_get_element(_id);
    if (!e) return;
    var p = e.panel;
    var i = array_find_index(p.elements, e);
    if (i != -1) array_delete(p.elements, i, 1);
    i = array_find_index(global.ui_elements, e);
    if (i != -1) array_delete(global.ui_elements, i, 1);
    variable_struct_remove(global.ui_by_id, _id);
}

// Returns true if mouse is over any VISIBLE panel (except root)
function ui_is_mouse_over_any_panel() {
    var mx = device_mouse_x_to_gui(0);
    var my = device_mouse_y_to_gui(0);
    
    for (var i = array_length(global.ui_panels)-1; i >= 0; i--) {  // reverse = topmost first
        var p = global.ui_panels[i];
        if (p.visible && p.id != "" && p.id != "root") {
            if (point_in_rectangle(mx, my, p.x, p.y, p.x + p.width, p.y + p.height)) {
                return true;
            }
        }
    }
    return false;
}