for (var i = 0; i < array_length(global.ui_elements); i++) {
    var elem = global.ui_elements[i];
    if (variable_struct_exists(elem, "draw")) {
        elem.draw(elem, 0, 0);
    }
}