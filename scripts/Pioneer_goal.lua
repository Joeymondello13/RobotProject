require('PatrolPath')
function performLogic()
    X_curr = getState()
    r=math.random(1,100)
    signal = sim.getIntegerSignal('Intruder')
    if energy >= 0 then
        decrementEnergy()
    end
    --Intruder is detected
    if signal == 1 and sim.getIntegerSignal('getIsArrived') then
        currentIndex = 18
        sim.setIntegerSignal('pioneer0Goal',currentIndex)
        intruderPos = sim.getObjectPosition(intruderHandle,-1)
        if sim.callScriptFunction('getGoalStatus@Vision_sensor#0',sim.scripttype_childscript) then
            if X_curr[1] > intruderPos[1] then
                currentGoal = {intruderPos[1]+2,intruderPos[2],0}
            end
            if X_curr[1] <= intruderPos[1] then
                currentGoal = {intruderPos[1]-2,intruderPos[2],0}
            end
        end
        if sim.callScriptFunction('getGoalStatus@Vision_sensor#1',sim.scripttype_childscript) then
            leadBotPos = sim.callScriptFunction('getGoalPos@Pioneer_goal#17', sim.scripttype_childscript)
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
            leadBotPos = sim.callScriptFunction('getGoalPos@Pioneer_goal#18', sim.scripttype_childscript)
            dist,dist2,intruder1,intruder2=findClosestPoint(getPosition())
            if sim.callScriptFunction('getCurrentGoal@Pioneer_goal#17',sim.scripttype_childscript)[1] == intruder1[1] and
                    sim.callScriptFunction('getCurrentGoal@Pioneer_goal#17',sim.scripttype_childscript)[2] == intruder1[2]then
                currentGoal = intruder2
            elseif sim.callScriptFunction('getCurrentGoal@Pioneer_goal#17',sim.scripttype_childscript)[1] == intruder1[1] and
                    sim.callScriptFunction('getCurrentGoal@Pioneer_goal#17',sim.scripttype_childscript)[2] == intruder1[2]then
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
function getIntruderHandle()
    return sim.getObjectHandle('Intruder')
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
    require('Pioneer_goal')
    require('PatrolPath')
    robotHandle = sim.callScriptFunction('getGoalHandle@StartConfiguration',sim.scripttype_childscript)
    jfile='C:/Program Files/CoppeliaRobotics/CoppeliaSimEdu/scenes/scripts/result.json'
    data=read_file(jfile)
    json = require"json"
    A = json.decode(data)
    m1= A['0']
    goalArray=m1
    init()
end
function sysCall_actuation()
    signal = sim.getIntegerSignal('Intruder')
    performLogic()
    sim.setIntegerSignal('pioneer0Energy',energy)
    sim.setIntegerSignal('pioneer0Goal',currentIndex)
    controlSignal=sim.getIntegerSignal('arrivedAtFinalGoal')
    if sim.getIntegerSignal('robot1Wait') ~=1 then
        patrol()
    end
end
function getGoalPos()
    g =sim.getObjectHandle('GoalConfiguration')
    return sim.getObjectPosition(g, -1)
end
function getNextGoal()
    return nextGoal
end
