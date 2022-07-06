function patrol()
    if controlSignal == 1 then
        currentIndex= currentIndex + 1
        currentGoal = goalArray[currentIndex]
        previousGoal= currentGoal
        nextGoal    = goalArray[currentIndex+1]
        if currentIndex == #goalArray then
            nextGoal = goalArray[1]
        end
        print("HAS ARRIVED")
        print(currentIndex)
        print(#goalArray)
        if currentIndex > #goalArray then
            currentIndex = 1
            currentGoal=goalArray[currentIndex]
            nextGoal = goalArray[2]
        end
    end
end
--[[isArrivedAt = function()
    dx = currentGoal[1] - X_curr[1]
    dy = currentGoal[2] - X_curr[2]
    dist = math.sqrt(dx*dx + dy*dy)
    if(dist)<0.1 then
        return true
    else
        return false
    end
end--]]
function getPreviousGoal()
    return previousGoal
end
function getCurrentGoal()
    return currentGoal
end
function getStartingIndex()
    return startingIndex
end
function getCurrentIndex()
    return currentIndex
end
function getDistanceFromCharger(robotPosition)
    charger={-18.55,-1.25,0}
    dx=charger[1]-robotPosition[1]
    dy=charger[2]-robotPosition[2]
    dist = math.sqrt(dx*dx + dy*dy)
    if(dist)<0.2 then
        energy=300
    end
end