// Main menu buttons (root panel = always visible)
ui_add_button(100, 100, 200, 50, "Play", function() { 
    show_debug_message("Play clicked!"); 
});

ui_add_button(100, 170, 200, 50, "Settings", function() { 
    ui_toggle_panel("settings");   // ← THIS IS THE ONLY CHANGE NEEDED
});

// Settings panel — starts hidden
var panel = ui_create_panel(200, 100, 400, 400, "settings", false);

ui_add_checkbox(20, 20, 32, true,  -1, false, "Sound",    function(v){ show_debug_message("Sound: "+string(v)); }, "chk_sound", panel);
ui_add_checkbox(20, 70, 60, false, -1, true,  "God Mode", undefined, "toggle_god", panel);
ui_add_slider  (20, 140, 360, 40, 0.7, 0, 1, 0.05, "Volume", function(v){ audio_master_gain(v); }, "sld_volume", panel);
ui_add_button  (20, 300, 150, 50, "Close", function() { ui_toggle_panel("settings"); }, "Close", "", panel);

ui_add_textbox(20, 20, 360, 40, "", "Enter name...", "Player Name:", function(txt) { 
    show_debug_message("Name: " + txt); 
}, "tb_name", panel);

ui_add_textarea(20, 80, 360, 150, 
    "This is a very long text that will wrap properly and scroll when needed.\nLine 2\nLine 3\nLine 4\nLine 5\nLine 6\nLine 7\nLine 8\nLine 9\nLine 10", 
    "Message:", undefined, "ta_message", panel);