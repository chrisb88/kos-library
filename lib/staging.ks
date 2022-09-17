// ------- Staging
@LAZYGLOBAL off.
runoncepath("0:/lib/status.ks").

global function doSafeStage {
    debug("Perform staging").

    wait until stage:ready.
    stage.
}

global function doAutoStage {
    if not(defined oldThrust) {
        global oldThrust is ship:availablethrust.
    }

    if ship:availablethrust < (oldThrust - 10) {
        until false {
            doSafeStage().
            wait 1.
            if ship:availableThrust > 0 {
                break.
            }
        }
        global oldThrust is ship:availablethrust.
    }
}

