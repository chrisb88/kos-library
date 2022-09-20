// ------- Maneuver
// Maneuver functions
@LAZYGLOBAL off.
runoncepath("0:/lib/staging").
runoncepath("0:/lib/status").

local maxBurnTimeTarget is 3.
local throttleDownAtDeltaV is 10.

global function executeManeuver {
    parameter mList.

    status("Executing maneuver...").

    local mnv is node(mList[0], mList[1], mList[2], mList[3]).
    addManeuverToFlightPlan(mnv).

    setEngineThrustLimit(100).
    local burnTime is calculateManeuverBurnTime(mnv).
    if burnTime < maxBurnTimeTarget {
        local factor is maxBurnTimeTarget / burnTime.
        setEngineThrustLimit(100 / factor).
    }

    local startTime is calculateManeuverStartTime(mnv).
    debug("Maneuver start time is " + timeSpan(startTime - time:seconds):full + " from now (" + timeStamp(startTime):full + ")").

    warpTo(startTime - 120).
//    wait until time:seconds > startTime - 10.
    lockSteeringAtManeuverTarget(mnv).
    wait until time:seconds > startTime.
    executeBurn(mnv).
    removeManeuverFromFlightPlan(mnv).

    unlock throttle.
    setEngineThrustLimit(100).
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

    return time:seconds + mnv:eta - calculateManeuverBurnTime(mnv) / 2.
}

local function calculateManeuverBurnTime {
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

local function setEngineThrustLimit {
    parameter limit.
    debug("Setting thrust limit to " + limit).

    local myEngines is list().

    list engines in myEngines.
    for en in myEngines {
        if en:ignition and not en:flameout {
            set en:thrustlimit to limit.
            unset oldThrust. // prevent to do any staging if we are in a burn and reduce thrust too much, see staging.ks
        }
    }
}

local function getEngineThrustLimit {
    local limit is 0.
    local count is 0.
    local myEngines is list().
    list engines in myEngines.
    for en in myEngines {
        if en:ignition and not en:flameout {
            set limit to limit + en:thrustlimit.
            set count to count + 1.
        }
    }

    return limit / count.
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

        local thrustLimit is getEngineThrustLimit().
        local maxDeltaV is throttleDownAtDeltaV * thrustLimit / 100.

        if mnv:deltaV:mag < maxDeltaV {
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
