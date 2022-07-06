function simGeneratePath(path)
    local setContorlPoint = function(pos)
        local ptData={pos[1],pos[2],pos[3],0.0,0.0,0.0,1.0,0,0,1.0,1.0}
        return ptData
    end
    local line_size = 5
    local intParams = {line_size,sim.distcalcmethod_dl,0}
    local pathHandle=sim.createPath(-1,intParams,nil,nil)
    print(sim.getObjectName(pathHandle))
    for i, data in pairs(path) do
        --      local point = path[#path-i+1]
        local point = path[i]
        --point[3]= 0.05
        local result=sim.insertPathCtrlPoints(pathHandle,0,0,1,setContorlPoint(point))
    end
    return pathHandle
end
function checkPath(goal,robot)
    dx = math.abs(goal[1]) - math.abs(robot[1])
    dy = math.abs(goal[2]) - math.abs(robot[2])
    dist = math.sqrt(dx*dx + dy*dy)
    if(dist)<0.4 then
        return true
    else
        return false
    end
end
function getGradient(path)
    prev=0
    finalPath={}
    for i=1,#path-1 do
        m=(path[i+1][2] - path[i][2])/(path[i+1][1]-path[i][1])
        delta=math.abs(m-prev)
        if delta > 0.2 then
            prev=m
            table.insert(finalPath,path[i])
        end
    end
    table.insert(finalPath,path[#path])
    return finalPath
end
visualizePath=function(path)
    if not _lineContainer then
       -- _lineContainer=sim.addDrawingObject(sim.drawing_lines,25,0,-1,40,{0.2,0.2,0.2})
    end
    --sim.addDrawingObjectItem(_lineContainer,nil)
    plan = {}
    if path then
        local pc=#path/3
        for i=1,pc-1,1 do
            --lineDat={path[(i-1)*3+1],path[(i-1)*3+2],initPos[3],path[i*3+1],path[i*3+2],initPos[3]}
            --sim.addDrawingObjectItem(_lineContainer,lineDat)
            plan[i] = {path[i*3+1],path[i*3+2],initPos[3]}
        end
    end
    planb = getGradient(plan)
    --if #planb == 1 then
      --  planb[2]=planb[1]
       -- planb[1]=pioneerPos
    --end
    return simGeneratePath(planb),planb
end

function sysCall_threadmain()
    --sim.clearIntegerSignal('pathHandle')
    goalHandle = getGoalHandle()
    startWaitFlag = true
    while sim.getSimulationState()~=sim.simulation_advancing_abouttostop do
        Robot_name=sim.getObjectName(getPioneerHandle())
        if Robot_name == "Pioneer_p3dx" and startWaitFlag then
            sim.wait(0,true)
        end
        if Robot_name == "Pioneer_p3dx#17" and startWaitFlag then
            sim.wait(50,true)
        end
        if Robot_name == "Pioneer_p3dx#18" and startWaitFlag then
            sim.wait(100,true)
        end
        startWaitFlag = false
        pathPlanner()
        followPath()
        if pathHandle then
            sim.removeObject(pathHandle)
        end
        if sim.getIntegerSignal('Intruder') == 1 then
            sim.setIntegerSignal('chaseIntruder',1)
        end
        sim.clearIntegerSignal(handle_signal)
    end
end
isArrived = function()
    dx = plan[#plan][1] - pioneerPos[1]
    dy = plan[#plan][2] - pioneerPos[2]
    dist = math.sqrt(dx*dx + dy*dy)
    if(dist)<0.2 then
        return true
    else
        return false
    end
end
function followPath()
    sim.setIntegerSignal(replan_signal,0)
    counter=1
    pathHandle = sim.getIntegerSignal(handle_signal)
    if pathHandle then
        sim.setObjectPosition(getGoalHandle(),-1,plan[counter])
        print('numberOfPoints',#plan)
        pioneerPos = sim.getObjectPosition(getPioneerHandle(),-1)
        while sim.getObjectPosition(goalHandle,-1) ~= plan[#plan] and not isArrived() do
            pioneerPos = sim.getObjectPosition(getPioneerHandle(),-1)
            if sim.getObjectPosition(goalHandle,-1)[1] == plan[counter][1] and sim.getObjectPosition(goalHandle,-1)[2] == plan[counter][2] and sim.getIntegerSignal(isArrived_signal)==1 then
                if counter < #plan then
                    counter = counter+1
                    print('counter',counter)
                end
                sim.setObjectPosition(goalHandle,-1,plan[counter])
                sim.wait(15,true)
            end
            if sim.getIntegerSignal(replan_signal) == 1 or sim.getIntegerSignal('Intruder')==1 then
                if sim.getIntegerSignal('robot1Wait') == 0 and sim.getIntegerSignal("robot2Wait") == 0 and sim.getIntegerSignal("robot3Wait") then
                    sim.wait(20)
                    sim.removeObject(pathHandle)
                    print('followpath')
                    pathPlanner()
                    sim.setIntegerSignal(replan_signal,0)
                    followPath()
                    print('replan')
                end
            end
        end
    end
end
function getPoints()
    if plan then
        return #plan
    else
        return 0
    end
end
