def die(msg): "Error: " + msg | halt_error;

def print_error(msg): "Error: " + msg | debug | empty;

def filter_github(content; num): "Something: " + content + num | tostring;