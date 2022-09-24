// ------- To Mun
// Performs a Hohmann transfer to the mun.
// Parameter:
// - targetAltitude: in m above the mun
runoncepath("0:/lib/math").
runoncepath("0:/lib/orbitmath").
runoncepath("0:/lib/status").
runoncepath("0:/lib/maneuver").

parameter targetAltitude is 100000.

local function main {
    parameter targetAltitude.
    status("Calculating transfer phase angle...").
    local transferPeriapsis is orbit:semiMajorAxis.
    local transferApoapsis is Mun:altitude + Kerbin:radius.
    local phaseAngleMun is calculatePhaseAngle(transferPeriapsis, transferApoapsis).
    local transferDeltaV is calculateDeltaVForHohmannTransfer(transferPeriapsis, transferApoapsis).

    status("Target phase angle: " + phaseAngleMun).

    local currentAngle is getPhaseAngle(ship:orbit, Mun:obt).
    debug("Current angle: " + currentAngle).
    local deltaAngle is normalizeAngle(currentAngle - phaseAngleMun).
    debug("deltaAngle: " + deltaAngle).

    // td = (angle * p) / 360
    local td is deltaAngle * orbit:period / 360.
    local mnv is node(time:seconds + td, 0, 0, transferDeltaV).
    addManeuverToFlightPlan(mnv).

    if not mnv:hasNextPatch {
        error("Calculation error: No encounter in orbit.").

        return.
    }

    removeManeuverFromFlightPlan(mnv).
    executeManeuver(list(time:seconds + td, 0, 0, transferDeltaV)).
}

main(targetAltitude).
