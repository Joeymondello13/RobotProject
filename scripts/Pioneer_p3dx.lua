require('Pioneer_Abstract_Class')
--require('Pioneer_goal')
function sysCall_init()
    usensors={-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1}
    for i=1,16,1 do
        usensors[i]=sim.getObjectHandle("Pioneer_p3dx_ultrasonicSensor"..i)
    end
    -- Detatch the manipulation sphere:
    targetObj=sim.callScriptFunction('getGoalHandle@StartConfiguration',sim.scripttype_childscript)
    sim.setObjectParent(targetObj,-1,true)
    motorLeft=sim.getObjectHandle("Pioneer_p3dx_leftMotor")
    motorRight=sim.getObjectHandle("Pioneer_p3dx_rightMotor")
    package.path = package.path .. ";C:/Program Files/CoppeliaRobotics/CoppeliaSimEdu/scenes/scripts/?.lua;"
    Pioneer1 = Pioneer_Abstract_Class:extend()
    Pioneer1:init()
    counterOP = 0
    sim.setIntegerSignal('getIsArrived',0)
    obstaclesPresent = false
    goalPos= sim.callScriptFunction('getGoalPos@Pioneer_goal',sim.scripttype_childscript)
end

getState = function()
    robotHandle = sim.callScriptFunction('getPioneerHandle@StartConfiguration',sim.scripttype_childscript)
    pos = sim.getObjectPosition(robotHandle,-1)
    ori = sim.getObjectOrientation(robotHandle,-1)
    ori[3] = math.atan2(math.sin(ori[3]), math.cos(ori[3]))
    return {pos[1], pos[2], ori[3]}
end

function sysCall_sensing()
    Pioneer1:detectObstacles()
end

function sysCall_actuation()
    goalPos= sim.callScriptFunction('getGoalPos@Pioneer_goal',sim.scripttype_childscript)
    arrivedAtFinalGoal(goalPos)
    if getDistanceFromCharger(X_curr) < 0.2 then
        sim.callScriptFunction('setEnergy@Pioneer_goal',sim.scripttype_childscript,300)
    end
    if obstaclesPresent then
        --print(obstaclesPresent)
        dodgeObs = true
    end

    if sim.getIntegerSignal('replan_path') == 1 and sim.getIntegerSignal('Intruder') ~=1 then
        vLeft=0
        vRight=0
    end

    if dodgeObs then
        sim.setIntegerSignal('robot_obs',1)
        if counterOP < 40 then
            vLeft=1
            vRight=1
            counterOP = counterOP + 1
        end
        if counterOP >= 40 then
            vLeft=0
            vRight=0
            position = getState()
            sim.setObjectPosition(targetObj, -1, {position[1], position[2], 0})
            sim.clearIntegerSignal('replan_path')
            sim.setIntegerSignal('replan_path',1)
            counterOP = 0
            dodgeObs = false
        end
    else
        currentIndex = sim.callScriptFunction('getCurrentIndex@Pioneer_goal',sim.scripttype_childscript)
        v, w = Pioneer1:iteratePID()
        vLeft, vRight = Pioneer1:uniToDiff(v, w)
        if Pioneer1:isArrived() or goalFound and sim.getIntegerSignal('Intruder') ~=1  then
            v, w = 0,0
            if currentIndex == 18  then
                if counterVariable < 300 then
                    counterVariable = counterVariable + 1
                end
                if counterVariable >= 300 then
                    v,w = Pioneer1:iteratePID()
                    if Pioneer1:isArrived() then
                        v,w=0,0
                    end
                end
            end
        end
    end
    if sim.callScriptFunction('getPoints@StartConfiguration',sim.scripttype_childscript) ==2 and sim.getIntegerSignal('Intruder') == 1 then
        desiredV = .35
    end

    sim.setJointTargetVelocity(motorLeft,vLeft)
    sim.setJointTargetVelocity(motorRight,vRight)
    if Pioneer1:isArrived() then
        sim.setIntegerSignal('getIsArrived',1)
    else
        sim.setIntegerSignal('getIsArrived',0)
    end
    sim.setStringSignal('robot1Pos',sim.packTable(X_curr))
    robot2Pos = sim.getStringSignal('robot2Pos')
    if robot2Pos then
        robot2Pos=sim.unpackTable(robot2Pos)
    end
    robot3Pos = sim.getStringSignal('robot3Pos')
    if robot3Pos then
        robot3Pos=sim.unpackTable(robot3Pos)
    end
    nextGoal=sim.callScriptFunction('getNextGoal@Pioneer_goal',sim.scripttype_childscript)
    currentGoal=sim.callScriptFunction('getCurrentGoal@Pioneer_goal',sim.scripttype_childscript)
    if robot2Pos ~= nil and robot3Pos ~= nil then
        if getDistance(nextGoal,robot2Pos) < 1 or getDistance(nextGoal,robot3Pos) < 1 or getDistance(currentGoal,robot2Pos) < 1 or getDistance(currentGoal,robot3Pos) < 1 then
            sim.setIntegerSignal('robot1Wait',1)
        else
            sim.setIntegerSignal('robot1Wait',0)
        end
    end
end
function arrivedAtFinalGoal(goalPosition)
    dx = goalPosition[1] - X_curr[1]
    dy = goalPosition[2] - X_curr[2]
    counter = 0
    dist = math.sqrt(dx*dx + dy*dy)
    if(dist)<0.25 then
        sim.setIntegerSignal('arrivedAtFinalGoal',1)
    else
        sim.setIntegerSignal('arrivedAtFinalGoal',0)
    end
end
function controlRobot1(speed)
    vLeft = speed
    vRight = speed
end