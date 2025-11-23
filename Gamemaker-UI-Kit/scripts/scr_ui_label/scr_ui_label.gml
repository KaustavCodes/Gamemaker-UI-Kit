// scr_ui_label.gml — FINAL 100% WORKING (no struct_override needed)
function ui_label(_x, _y, _text, _options = undefined, _id = "", _panel = undefined) {
    if (_panel == undefined) _panel = global.root_panel;
    else if (is_string(_panel)) _panel = ui_get_panel(_panel);
    
    // Default options
    var color     = c_black;
    var font      = -1;
    var halign    = fa_left;
    var valign    = fa_top;
    var alpha     = 1;
    var scale_x   = 1;
    var scale_y   = 1;
    var angle     = 0;
    var wrap_width = -1;
    
    // Apply user options if provided
    if (!is_undefined(_options)) {
        if (variable_struct_exists(_options, "color"))      color      = _options.color;
        if (variable_struct_exists(_options, "font"))       font       = _options.font;
        if (variable_struct_exists(_options, "halign"))     halign     = _options.halign;
        if (variable_struct_exists(_options, "valign"))     valign     = _options.valign;
        if (variable_struct_exists(_options, "alpha"))      alpha      = _options.alpha;
        if (variable_struct_exists(_options, "scale_x"))    scale_x    = _options.scale_x;
        if (variable_struct_exists(_options, "scale_y"))    scale_y    = _options.scale_y;
        if (variable_struct_exists(_options, "angle"))      angle      = _options.angle;
        if (variable_struct_exists(_options, "wrap_width")) wrap_width = _options.wrap_width;
    }
    
    var lbl = {
        x: _x,
        y: _y,
        text: _text,
        color: color,
        font: font,
        halign: halign,
        valign: valign,
        alpha: alpha,
        scale_x: scale_x,
        scale_y: scale_y,
        angle: angle,
        wrap_width: wrap_width,
        id: _id,
        panel: _panel
    };
    
    if (_id != "") global.ui_by_id[$ _id] = lbl;
    array_push(_panel.elements, lbl);
    array_push(global.ui_elements, lbl);
    
    lbl.update = function(inst, px, py) {
        // No interaction — labels are static
    };
    
    lbl.draw = function(inst, px, py) {
        var ax = inst.x + px;
        var ay = inst.y + py;
        
        draw_set_alpha(inst.alpha);
        draw_set_color(inst.color);
        draw_set_halign(inst.halign);
        draw_set_valign(inst.valign);
        if (inst.font != -1) draw_set_font(inst.font);
        
        if (inst.wrap_width > 0) {
            draw_text_ext_transformed(ax, ay, inst.text, -1, inst.wrap_width,
                                      inst.scale_x, inst.scale_y, inst.angle);
        } else {
            draw_text_transformed(ax, ay, inst.text,
                                  inst.scale_x, inst.scale_y, inst.angle);
        }
        
        // Reset
        draw_set_alpha(1);
        draw_set_color(c_black);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_font(-1);
    };
    
    return lbl;
}