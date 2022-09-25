// ------- Launch
// Performs a launch in the given direction
// until the apoapsis reaches the given altitude.
// Parameter:
// - altitude: in m
// - direction: [0...360] degree
@LAZYGLOBAL off.
runoncepath("0:/lib/staging.ks").
runoncepath("0:/lib/status.ks").

global function launch {
    parameter altitude, direction.

    status("Launching to " + altitude + "m...").

    doLaunch().
    doAscent(direction).

    until apoapsis > altitude {
        doAutoStage().
    }

    doShutdown().
}

local function doLaunch {
    debug("Launching").

    set throttle to 1.
    doSafeStage().

    until ship:maxthrust > 0 {
        doSafeStage().
    }
}

local function doAscent {
    parameter targetDirection.

    if targetDirection < 0 or targetDirection > 360 {
        warning("Invalid direction " + targetDirection).
        set targetDirection to 90.
        warning("Setting direction to " + targetDirection).
    }

    status("Ascending " + targetDirection + "°").

    local targetPitch is 0.

    lock targetPitch to 88.963 - 1.03287 * alt:radar^0.409511.
    lock steering to heading(targetDirection, targetPitch).

    // Reduce throttle on ascend until 50km altitude. It doens't save that much fuel though
    lock throttle to choose 1 if ship:altitude > 50000 else 6 - 0.1 * ship:orbit:eta:apoapsis.
}

local function doShutdown {
    debug("Shutdown engines").

    set throttle to 0.
    lock steering to prograde.
}
