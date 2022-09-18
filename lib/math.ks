// ------- Math
// Mathematical helper functions
@LAZYGLOBAL off.

global function isWithinBounds {
    parameter value, targetValue, deviationPercent.

    local bounds is getBounds(targetValue, deviationPercent).

    debug("isWithinBounds: [" + bounds[0] + "..." + bounds[1] + "]").

    return value >= bounds[0] and value <= bounds[1].
}

global function getBounds {
    parameter targetValue, deviationPercent.

    local targetUpper is targetValue + targetValue * deviationPercent.
    local targetLower is targetValue - targetValue * deviationPercent.

    return list(targetLower, targetUpper).
}
