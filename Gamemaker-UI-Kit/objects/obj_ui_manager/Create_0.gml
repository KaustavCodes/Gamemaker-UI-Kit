// Initialize UI system
global.ui_elements = [];
global.ui_by_id = {};

// Root panel (covers whole GUI)
global.root_panel = {
    x: 0,
    y: 0,
    width: display_get_gui_width(),
    height: display_get_gui_height(),
    elements: []
};