for (var p = 0; p < array_length(global.ui_panels); p++) {
    var panel = global.ui_panels[p];
    if (!panel.visible) continue;
    
    if (struct_exists(panel, "draw")) panel.draw(panel);
    
    for (var i = 0; i < array_length(panel.elements); i++) {
        var elem = panel.elements[i];
        if (!elem.visible) continue;
        if (struct_exists(elem, "draw")) {
            elem.draw(elem, panel.x, panel.y);
        }
    }
}