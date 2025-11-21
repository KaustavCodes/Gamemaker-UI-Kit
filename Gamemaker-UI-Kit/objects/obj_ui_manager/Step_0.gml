// Step Event of obj_ui_manager
var block_clicks = ui_is_mouse_over_any_panel();   // ← NEW

for (var p = 0; p < array_length(global.ui_panels); p++) {
    var panel = global.ui_panels[p];
    if (!panel.visible) continue;
    
    for (var i = 0; i < array_length(panel.elements); i++) {
        var elem = panel.elements[i];
        if (!elem.visible) continue;
        
        // NEW: Only process input if not blocked by a higher panel
        if (block_clicks && panel.id == "root") continue;
        
        if (struct_exists(elem, "update")) {
            elem.update(elem, panel.x, panel.y);
        }
    }
}