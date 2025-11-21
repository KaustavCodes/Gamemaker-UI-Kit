// Initialize UI system
global.ui_panels = [];
global.ui_panels_by_id = {};
global.ui_elements = [];
global.ui_by_id = {};

// Root panel (invisible, covers whole screen)
ui_create_panel(0, 0, display_get_gui_width(), display_get_gui_height(), "root", true);
global.root_panel = global.ui_panels_by_id.root;
global.root_panel.draw = function(self) { /* no background */ };