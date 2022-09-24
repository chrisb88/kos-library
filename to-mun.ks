// ------- To Mun
// Performs a Hohmann transfer to the mun.
// Parameter:
// - targetAltitude: in m above the mun
runoncepath("0:/lib/math").
runoncepath("0:/lib/orbitmath").
runoncepath("0:/lib/status").
runoncepath("0:/lib/maneuver").
runoncepath("0:/lib/hillclimbing").

parameter targetAltitude is 100000.

local function performTransfer {
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

local function performTransferCorrection {
    parameter targetAltitude.
    status("Transfer phase...").

    local timeForManeuver is round(time:seconds + 2 * 60).
    local transfer is calculateCorrectionBurn(timeForManeuver, targetAltitude).
    executeManeuver(transfer).
}

local function calculateCorrectionBurn {
    parameter timeForManeuver, targetAltitude.

    local deltaV is list(0).
    set deltaV to improveConverge(deltaV, protectFromPositive(distanceApoapsisFromTargetAltitudeScore@:bind(timeForManeuver):bind(targetAltitude))).

    return list(timeForManeuver, 0, 0, deltaV[0]).
}

local function distanceApoapsisFromTargetAltitudeScore {
    parameter timeForManeuver, targetAltitude, data.

    local result is 2^64.
    local mnv is node(timeForManeuver, 0, 0, data[0]).
    addManeuverToFlightPlan(mnv).
    if mnv:orbit:hasNextPatch {
        set result to abs(targetAltitude - mnv:orbit:nextPatch:periapsis).
    }
    removeManeuverFromFlightPlan(mnv).

    return result.
}

//performTransfer().
//performTransferCorrection(targetAltitude).
