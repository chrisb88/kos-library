// ------- Status
// set global var "verbose" to:
// verbose <0: no output
// verbose 0 : error
// verbose 1 : warning, error
// verbose 2 : status, warning, error
// verbose 3 : debug, status, warning, error
@LAZYGLOBAL off.

global function error {
    parameter msg.

    _log(msg, 0).
}

global function warning {
    parameter msg.

    _log(msg, 1).
}

global function info {
    parameter msg.

    _log(msg, 2).
}

global function status {
    parameter msg.

    _log(msg, 2).
}

global function debug {
    parameter msg.

    _log(msg, 3).
}

local function _log {
    parameter msg, level.

    if level <= verbose {
        print msg.
    }
}
