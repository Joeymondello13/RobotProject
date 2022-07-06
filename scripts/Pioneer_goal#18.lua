require('PatrolPath')
function performLogic()
    X_curr = getState()
    r=math.random(1,100)
    signal = sim.getIntegerSignal('Intruder')
    if energy >= 0 then
        decrementEnergy()
    end
    --getDistanceFromCharger(X_curr)
    --[[
        Step 1. Check energy and check for arrival and goalIndexSize
        Step 2. If goalIndexSize > 1, roll random number; if 1 set next goal
        Step 3. If goalIndexSize > 1, set next goal based on random number
        Step 4. If robot is below 200 energy and at a point near a charging station, go to charging station
        Step 5. Patrol to goal waypoint
        Step 6. If robot is at a charging station, charge up energy
        Step 7. Repeat

        currentIndex = The key; contains waypoints the robot can go to from that specific waypoint as values
        goalIndexSize = array that contains the total number of possible waypoints the robot can go to from a specific waypoint.
        getIndex function = returns the index that the currentGoal lies within goalArray
    --]]

    --Intruder is detected
    if signal == 1 and sim.getIntegerSignal('getIsArrived2') then
        currentIndex = 18
        sim.setIntegerSignal('pioneer2Goal',currentIndex)
        intruderPos = sim.getObjectPosition(intruderHandle,-1)
        if sim.callScriptFunction('getGoalStatus@Vision_sensor#2',sim.scripttype_childscript) then
            if X_curr[1] > intruderPos[1] then
                currentGoal = {intruderPos[1]+2,intruderPos[2],0}
            end
            if X_curr[1] <= intruderPos[1] then
                currentGoal = {intruderPos[1]-2,intruderPos[2],0}
            end
        end
        if sim.callScriptFunction('getGoalStatus@Vision_sensor#1',sim.scripttype_childscript) then
            leadBotPos = sim.callScriptFunction('getGoalPos@Pioneer_goal#17', sim.scripttype_childscript)
            ------------------NEW CODE----------------------------------------------------------------------
            dist,dist2,intruder1,intruder2=findClosestPoint(getPosition())
            if sim.callScriptFunction('getCurrentGoal@Pioneer_goal',sim.scripttype_childscript)[1] == intruder1[1] and
                    sim.callScriptFunction('getCurrentGoal@Pioneer_goal',sim.scripttype_childscript)[2] == intruder1[2]then
                currentGoal = intruder2
            elseif sim.callScriptFunction('getCurrentGoal@Pioneer_goal#18',sim.scripttype_childscript)[1] == intruder2[1] and
                    sim.callScriptFunction('getCurrentGoal@Pioneer_goal#18',sim.scripttype_childscript)[2] == intruder2[2]then
                currentGoal = intruder1
            else
                if dist2 < dist then
                    currentGoal = intruder2
                else
                    currentGoal = intruder1
                end
            end
        end
        if sim.callScriptFunction('getGoalStatus@Vision_sensor#0',sim.scripttype_childscript) then
            leadBotPos = sim.callScriptFunction('getGoalPos@Pioneer_goal', sim.scripttype_childscript)
            ------------------------------------------------------------------------------------------------------------
            dist,dist2,intruder1,intruder2=findClosestPoint(getPosition())
            if sim.callScriptFunction('getCurrentGoal@Pioneer_goal#17',sim.scripttype_childscript)[1] == intruder1[1] and
                    sim.callScriptFunction('getCurrentGoal@Pioneer_goal#17',sim.scripttype_childscript)[2] == intruder1[2]then
                currentGoal = intruder2
            elseif sim.callScriptFunction('getCurrentGoal@Pioneer_goal#17',sim.scripttype_childscript)[1] == intruder1[1] and
                    sim.callScriptFunction('getCurrentGoal@Pioneer_goal#17',sim.scripttype_childscript)[2] == intruder1[2]then
                currentGoal = intruder1
            else
                if dist2 < dist then
                    currentGoal = intruder2
                else
                    currentGoal = intruder1
                end
            end
        end
    end
    if sim.getIntegerSignal('obstaclesPresent')==1 then
        currentGoal=previousGoal
        return
    end
end
function getDistanceFromCharger(robotPosition)
    charger={-18.55,-1.25,0}
    dx=math.abs(robotPosition[1])-math.abs(charger[1])
    dy=math.abs(robotPosition[2])-math.abs(charger[2])
    dist = math.sqrt(dx*dx + dy*dy)
    if(dist)<0.2 then
        energy = 300
    end
    return dist
end
function setEnergy(amount)
    energy = amount
end
local function read_file(path)
    local file = io.open(path,"r")
    if not file then return nil end
    local content = file:read "*a"
    file:close()
    return content
end
function sysCall_init()
    require('Robot_Abstract_Class')
    require('Pioneer_goal#18')
    require('PatrolPath')
    robotHandle = sim.callScriptFunction('getGoalHandle@StartConfiguration#18',sim.scripttype_childscript)
    jfile='C:/Program Files/CoppeliaRobotics/CoppeliaSimEdu/scenes/scripts/result.json'
    data=read_file(jfile)
    json = require"json"
    A = json.decode(data)
    m3= A['2']
    goalArray=m3
    init()
end

function sysCall_actuation()
    signal = sim.getIntegerSignal('Intruder')
    performLogic()
    controlSignal=sim.getIntegerSignal('arrivedAtFinalGoal2')
    sim.setIntegerSignal('pioneer2Energy',energy)
    sim.setIntegerSignal('pioneer2Goal',currentIndex)
    if sim.getIntegerSignal('robot3Wait') ~=1 then
        patrol()
    end
end
function getGoalPos()
    g =sim.getObjectHandle('GoalConfiguration#1')
    return sim.getObjectPosition(g, -1)
end
function getNextGoal()
    return nextGoal
end