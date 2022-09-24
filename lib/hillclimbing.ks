// ------- Hill climbing
// Useful helper funtion for the hill climbing algorithm
@LAZYGLOBAL off.
runoncepath("0:/lib/status").

global function improveConverge {
    parameter data, scoreFunction.

    for stepSize in list(100, 10, 1, 0.1, 0.01) {
        debug("StepSize: " + stepSize).
        until false {
            local oldScore is scoreFunction(data).
            set data to improve(data, stepSize, scoreFunction).
            debug("Improved score: " + scoreFunction(data)).
            if oldScore <= scoreFunction(data) {
                debug("Best score: " + oldScore).
                break.
            }
        }
    }

    return data.
}

global function protectFromNegative {
    parameter originalFunction.

    local replacementFunction is {
        parameter data.
        if data[0] < 0 {
            return 2^64.
        }

        return originalFunction(data).
    }.

    return replacementFunction@.
}

global function protectFromPositive {
    parameter originalFunction.

    local replacementFunction is {
        parameter data.
        if data[0] > 0 {
            return 2^64.
        }

        return originalFunction(data).
    }.

    return replacementFunction@.
}

global function protectFromPast {
    parameter originalFunction.

    local replacementFunction is {
        parameter data.
        if data[0] < time:seconds + 15 {
            return 2^64.
        }

        return originalFunction(data).
    }.

    return replacementFunction@.
}

local function improve {
    parameter data, stepSize, scoreFunction.

    local scoreToBeat is scoreFunction(data).
    local bestCandidate is data.
    local candidates is list().
    local index is 0.

    until index >= data:length {
        local incCandidate is data:copy().
        local decCandidate is data:copy().
        set incCandidate[index] to incCandidate[index] + stepSize.
        set decCandidate[index] to decCandidate[index] - stepSize.
        candidates:add(incCandidate).
        candidates:add(decCandidate).
        set index to index + 1.
    }

    for candidate in candidates {
        local candidateScore is scoreFunction(candidate).
        if candidateScore < scoreToBeat {
            set scoreToBeat to candidateScore.
            set bestCandidate to candidate.
        }
    }

    return bestCandidate.
}
