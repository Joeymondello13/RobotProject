require('PatrolPath')
function performLogic()
    X_curr = getState()
    r=math.random(1,100)
    signal = sim.getIntegerSignal('Intruder')
    if energy >= 0 then
        decrementEnergy()
    end
    getDistanceFromCharger(X_curr)

    --Intruder is detected
    if signal == 1 then
        currentIndex = 18
        sim.setIntegerSignal('pioneer1Goal',currentIndex)
        intruderPos = sim.getObjectPosition(intruderHandle,-1)
        if sim.callScriptFunction('getGoalStatus@Vision_sensor#1',sim.scripttype_childscript) then
            if X_curr[1] > intruderPos[1] then
                currentGoal = {intruderPos[1]+2,intruderPos[2],0}
            end
            if X_curr[1] <= intruderPos[1] then
                currentGoal = {intruderPos[1]-2,intruderPos[2],0}
            end
        end
        if sim.callScriptFunction('getGoalStatus@Vision_sensor#0',sim.scripttype_childscript) then
            leadBotPos = sim.callScriptFunction('getGoalPos@Pioneer_goal', sim.scripttype_childscript)
            ---------------------------------------------------------------------------------------------------
            dist,dist2,intruder1,intruder2=findClosestPoint(getPosition())
            if sim.callScriptFunction('getCurrentGoal@Pioneer_goal#18',sim.scripttype_childscript)[1] == intruder1[1] and
                    sim.callScriptFunction('getCurrentGoal@Pioneer_goal#18',sim.scripttype_childscript)[2] == intruder1[2]then
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
        if sim.callScriptFunction('getGoalStatus@Vision_sensor#2',sim.scripttype_childscript) then
            --plusTheta = 4.18879
            leadBotPos = sim.callScriptFunction('getGoalPos@Pioneer_goal#18', sim.scripttype_childscript)
            --robotPos = getPolarCoords(leadBotPos)
            dist,dist2,intruder1,intruder2=findClosestPoint(getPosition())
            if sim.callScriptFunction('getCurrentGoal@Pioneer_goal',sim.scripttype_childscript)[1] == intruder1[1] and
                    sim.callScriptFunction('getCurrentGoal@Pioneer_goal',sim.scripttype_childscript)[2] == intruder1[2]then
                currentGoal = intruder2
            elseif sim.callScriptFunction('getCurrentGoal@Pioneer_goal',sim.scripttype_childscript)[1] == intruder1[1] and
                    sim.callScriptFunction('getCurrentGoal@Pioneer_goal',sim.scripttype_childscript)[2] == intruder1[2]then
                currentGoal = intruder1
            elseif dist2 < dist then
                currentGoal = intruder2
            else
                currentGoal = intruder1
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
    require('Pioneer_goal#17')
    require('PatrolPath')
    robotHandle = sim.callScriptFunction('getGoalHandle@StartConfiguration#17',sim.scripttype_childscript)
    jfile='C:/Program Files/CoppeliaRobotics/CoppeliaSimEdu/scenes/scripts/result.json'
    data=read_file(jfile)
    json = require"json"
    A = json.decode(data)
    m2= A['1']
    goalArray=m2
    init()
    signal = sim.setIntegerSignal('Intruder',0)
end

function sysCall_actuation()
    signal = sim.getIntegerSignal('Intruder')
    performLogic()
    controlSignal=sim.getIntegerSignal('arrivedAtFinalGoal1')
    sim.setIntegerSignal('pioneer1Energy',energy)
    sim.setIntegerSignal('pioneer1Goal',currentIndex)
    if sim.getIntegerSignal('robot2Wait') ~=1 then
        patrol()
    end
end
function getGoalPos()
    g =sim.getObjectHandle('GoalConfiguration#0')
    return sim.getObjectPosition(g, -1)
end
function getNextGoal()
    return nextGoal
end