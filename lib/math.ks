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

global function rad2deg {
    parameter rads.

    return rads * (180 / constant:pi).
}

global function normalizeAngle {
    parameter angle.

    return angle - 360 * floor(angle / 360).
}

global function ternarySearch {
    parameter f, left, right, absolutePrecision.

    until false {
    // left and right are the current bounds; the maximum is between them
        if abs(right - left) < absolutePrecision {
            return (left + right) / 2.
        }

        local leftThird is left + (right - left) / 3.
        local rightThird is right - (right - left) / 3.

        if f(leftThird) < f(rightThird) {
            set left to leftThird.
        } else {
            set right to rightThird.
        }
    }
}
