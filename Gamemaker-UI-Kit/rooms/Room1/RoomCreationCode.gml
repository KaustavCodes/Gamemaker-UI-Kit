
ui_textbox(100, 10, 400, 50, "", "Click here and type...", "my_textbox");
ui_textarea(100, 90, 400, 150, "", "Type here — scroll with mouse or arrows!", "my_textarea");

ui_button(100, 280, 200, 60, "Click Me!", function() { show_message("Button works!"); }, "btn_test");

ui_toggle(100, 350, 80, 40, true, function(state) {
    show_debug_message("Toggle is now: " + (state ? "ON" : "OFF"));
}, "toggle_test");


ui_dropdown(100, 400, 300, 50,
    ["Easy", "Medium", "Hard", "Nightmare"],
    1,
    function(choice, index) {
        show_message("Selected: " + choice + " (" + string(index) + ")");
    },
    "dd_difficulty"
);

// Simple label
ui_label(100, 450, "Hello World!", {
    color: c_gray
}, "lbl_simple");

// Fancy label
ui_label(100, 500, "BIG BOLD TEXT", {
    color: c_red,
    font: fnt_big,
    halign: fa_left,
    valign: fa_middle,
    scale_x: 1.5,
    scale_y: 1.5,
    alpha: 0.8
}, "lbl_fancy");

// Wrapped label
ui_label(100, 550, "This is a very long text that will wrap nicely inside the box when given a width", {
    wrap_width: 300,
    color: c_blue
}, "lbl_wrapped");

