// ------- Mun Transfer
// Performs a Hohmann transfer to the mun.
// Parameter:
// - targetAltitude: in m above the mun
@LAZYGLOBAL off.
runoncepath("0:/lib/math").
runoncepath("0:/lib/orbitmath").
runoncepath("0:/lib/status").
runoncepath("0:/lib/maneuver").
runoncepath("0:/lib/hillclimbing").

parameter targetAltitude is 100000.

local function main {
    parameter targetAltitude.

    performTransfer().
    performTransferCorrection(targetAltitude).
    performTransferInjection().
}

local function performTransfer {
    status("Begin transfer to mun...").
    info("Calculating transfer phase angle:").
    local transferPeriapsis is orbit:semiMajorAxis.
    local transferApoapsis is Mun:altitude + Kerbin:radius.
    local phaseAngleMun is calculatePhaseAngle(transferPeriapsis, transferApoapsis).
    local transferDeltaV is calculateDeltaVForHohmannTransfer(transferPeriapsis, transferApoapsis).

    info("Target phase angle: " + phaseAngleMun).

    local currentAngle is getPhaseAngle(ship:orbit, Mun:obt).
    debug("Current angle: " + currentAngle).
    local deltaAngle is normalizeAngle(currentAngle - phaseAngleMun).
    debug("deltaAngle: " + deltaAngle).

    // td = (angle * p) / 360
    local td is deltaAngle * orbit:period / 360.
    local mnv is node(time:seconds + td, 0, 0, transferDeltaV).
    addManeuverToFlightPlan(mnv).

    if not mnv:orbit:hasNextPatch {
        error("Calculation error: No encounter in orbit.").

        return.
    }

    removeManeuverFromFlightPlan(mnv).
    executeManeuver(list(time:seconds + td, 0, 0, transferDeltaV)).
}

local function performTransferCorrection {
    parameter targetAltitude.
    status("Performing transfer correction...").

    local timeForManeuver is round(time:seconds + 2 * 60).
    local transfer is calculateCorrectionBurn(timeForManeuver, targetAltitude).
    executeManeuver(transfer).
}

local function calculateCorrectionBurn {
    parameter timeForManeuver, targetAltitude.

    local deltaVRetro is list(0).
    local deltaVPro is list(0).
    set deltaVRetro to improveConverge(deltaVRetro, protectFromPositive(distanceApoapsisFromTargetAltitudeScore@:bind(timeForManeuver):bind(targetAltitude))).
    set deltaVPro to improveConverge(deltaVPro, protectFromNegative(distanceApoapsisFromTargetAltitudeScore@:bind(timeForManeuver):bind(targetAltitude))).

    debug("DeltaV retrogade burn: " + deltaVRetro[0]).
    debug("DeltaV prograde burn: " + deltaVPro[0]).

    local deltaV is 0.
    if deltaVRetro[0] <> 0 and abs(deltaVRetro[0]) < abs(deltaVPro[0]) {
        set deltaV to deltaVRetro[0].
    } else {
        set deltaV to deltaVPro[0].
    }

    debug("DeltaV: " + deltaV).
    if deltaV = 0 {
        error("DeltaV is zero!").
    }

    return list(timeForManeuver, 0, 0, deltaV).
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

local function performTransferInjection {
    status("Transfering to mun...").

    warpTo(time:seconds + orbit:nextPatchEta - 5).
    wait until orbit:body = Mun.
    status("Arrived at mun.").
}

main(targetAltitude).
