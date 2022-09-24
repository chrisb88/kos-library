// ------- Math
// Mathematical helper functions
@LAZYGLOBAL off.
runoncepath("0:/lib/math").

global function calculatePhaseAngle {
    parameter currentSma, targetBodyOrbitRadius.
    // r1 = (sma + targetBodyOrbitRadius) / 2
    // ang_rad = pi * sqrt(r1 ^ 3 / r2 ^ 3)

    return rad2deg(constant:pi - constant:pi * sqrt(((currentSma + targetBodyOrbitRadius) / 2) ^ 3 / targetBodyOrbitRadius ^ 3)).
}

// Returns the phase angle between two bodies
global function getPhaseAngle {
    parameter currentOrbit, targetOrbit.

    local angleCurrent to getUniversalAngle(currentOrbit).
    local angleTarget to getUniversalAngle(targetOrbit).
    local angleResult to angleTarget - angleCurrent.

    return normalizeAngle(angleResult).
}

// Returns the angle to the universal reference direction
global function getUniversalAngle {
    parameter currentOrbit.

    return currentOrbit:lan + currentOrbit:argumentofperiapsis + currentOrbit:trueanomaly.
}

global function getSemiMajorAxis {
    parameter p, a.

    return (a + p) / 2.
}

// Calculates orbital speed using the vis-viva equation
global function calculateOrbitSpeed {
    parameter r, a.
    // v^2 = Mu * (2/r - 1/a)

    return sqrt(body:mu * (2 / r - 1 / a)).
}

global function calculateDeltaVForHohmannTransfer {
    parameter transferPeriapsis, transferApoapsis.

    debug("Caluclating deltaV for Hohmann transfer:").
    debug("transferPeriapsis: " + round(transferPeriapsis)).
    debug("transferApoapsis: " + round(transferApoapsis)).

    local r is transferPeriapsis.
    local a is transferPeriapsis. // sma in a circle equals the radius or periapsis

    debug("start a: " + round(a)).
    debug("start r: " + round(r)).

    local vCurrentApsis is calculateOrbitSpeed(r, a).
    debug("Speed at periapsis: " + round(vCurrentApsis, 2)).

    set a to getSemiMajorAxis(transferPeriapsis, transferApoapsis).

    debug("target a: " + round(a)).
    debug("target r: " + round(r)).

    local vTargetApsis is calculateOrbitSpeed(r, a).
    debug("Speed at apoapsis: " + round(vTargetApsis, 2)).

    local vD is vTargetApsis - vCurrentApsis.
    info("Need " + round(vD, 2) + " m/s deltaV to change orbit").

    return vD.
}
