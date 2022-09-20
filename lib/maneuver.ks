// ------- Maneuver
// Maneuver functions
@LAZYGLOBAL off.
runoncepath("0:/lib/staging").
runoncepath("0:/lib/status").

global function executeManeuver {
    parameter mList.

    status("Executing maneuver...").

    local mnv is node(mList[0], mList[1], mList[2], mList[3]).
    addManeuverToFlightPlan(mnv).
    local startTime is calculateManeuverStartTime(mnv).
    // todo reduce engine thrust for verly low burn times

    debug("Maneuver start time is " + timeSpan(startTime - time:seconds):full + " from now (" + timeStamp(startTime):full + ")").

    warpTo(startTime - 120).
//    wait until time:seconds > startTime - 10.
    lockSteeringAtManeuverTarget(mnv).
    wait until time:seconds > startTime.
    executeBurn(mnv).
    removeManeuverFromFlightPlan(mnv).

    unlock throttle.
}

global function addManeuverToFlightPlan {
    parameter mnv.

    add mnv.
}

global function removeManeuverFromFlightPlan {
    parameter mnv.

    remove mnv.
}

local function calculateManeuverStartTime {
    parameter mnv.

    return time:seconds + mnv:eta - maneuverBurnTime(mnv) / 2.
}

local function maneuverBurnTime {
    parameter mnv.

    local dV is mnv:deltaV:mag.
    local g0 is constant:g0. // 9.80665, always the gravity of earth, as this is used for isp
    local isp is 0.
    local F is ship:availableThrust.
    local m0 is ship:mass.
    local myEngines is list().

    list engines in myEngines.
    for en in myEngines {
        if en:ignition and not en:flameout {
            set isp to isp + (en:isp * (en:availableThrust / ship:availableThrust)).
        }
    }

    debug("Combined ISP: " + round(isp, 2)).
    debug("Ships mass: " + round(m0, 2)).
    debug("Available thrust: " + round(F, 2)).

//    dV = v(e) * ln(m0 / mf)
//    dV = isp * g0 * ln(m0 / mf)
//    dV / (isp * g0) = ln(m0 / mf)
//    e^(dV / (isp * g0)) = m0 / mf
//    mf * e^(dV / (isp * g0)) = m0
    local mf is m0 / constant:e^(dV / (isp * g0)).
    debug("Ships mass after burn: " + round(mf, 2)).

//    F = isp * g0 * fuelFlow
    local fuelFlow is F / (isp * g0).
    debug("Fuel flow: " + round(fuelFlow, 2)).

//    mf = m0 - fuelFlow * t
//    mf + (fuelFlow * t) = m0
//    (fuelFlow * t = m0 - mf
    local t is (m0 - mf) / fuelFlow.
    debug("Burn time: " + round(t, 2) + "s").

    return t.
}

local function lockSteeringAtManeuverTarget {
    parameter mnv.

    lock steering to mnv:burnVector.
}

local function executeBurn {
    parameter mnv.

    debug("Executing burn...").
    lock throttle to 1.
    until isManeuverComplete(mnv) {
        doAutoStage().
        if mnv:deltaV:mag < 10 {
            local thr is -0.022449 + 0.0510204 * mnv:deltaV:mag.
            set thr to choose 0.1 if thr < 0.1 else thr.
            lock throttle to thr.
        }
    }
    lock throttle to 0.
    unlock steering.
}

local function isManeuverComplete {
    parameter mnv.

    if not(defined originalVector) {
        declare global originalVector to mnv:burnVector.
    }

    if vang(originalVector, mnv:burnVector) > 90 {
        debug("Maneuver is complete").
        unset originalVector.

        return true.
    }

    return false.
}
