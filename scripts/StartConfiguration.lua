require('StartConfiguration_Abstract_Class')

StartConfiguration='StartConfiguration'
Pioneer_offset='Pioneer_offset'
handle_signal='pathHandle'
replan_signal='replan_path'
isArrived_signal='getIsArrived'
collectionHandle=sim.getCollectionHandle('Col1#')
--Robot_name=sim.getObjectName(getPioneerHandle())

function getGoalHandle()
    return sim.getObjectHandle('Pioneer_goal')
end
function getGoalConfiguration()
    return sim.getObjectHandle('GoalConfiguration')
end
function getPioneerHandle()
    return sim.getObjectHandle('Pioneer_p3dx')
end
pathPlanner = function()
    if sim.getIntegerSignal('robot1Wait') == 1 then
        print('potential collision...waiting')
        sim.wait(25)
    end
    if sim.getIntegerSignal('robot1Wait') == 0 then
        robotHandle=sim.getObjectHandle(StartConfiguration)
        targetHandle=getGoalConfiguration()
        initPos=sim.getObjectPosition(robotHandle,-1)
        initOrient=sim.getObjectOrientation(robotHandle,-1)
        t=simOMPL.createTask('t')
        ss={simOMPL.createStateSpace('2d',simOMPL.StateSpaceType.pose2d,robotHandle,{-40,-40},{20,20},1)}
        simOMPL.setStateSpace(t,ss)
        simOMPL.setAlgorithm(t,simOMPL.Algorithm.RRTConnect)
        simOMPL.setCollisionPairs(t,{sim.getObjectHandle(Pioneer_offset),collectionHandle})
        startpos=sim.getObjectPosition(robotHandle,-1)
        startorient=sim.getObjectOrientation(robotHandle,-1)
        startpose={startpos[1],startpos[2],startorient[3]}
        simOMPL.setStartState(t,startpose)
        goalpos=sim.getObjectPosition(targetHandle,-1)
        goalorient=sim.getObjectOrientation(targetHandle,-1)
        goalpose={goalpos[1],goalpos[2],goalorient[3]}
        simOMPL.setGoalState(t,goalpose)
        r,path=simOMPL.compute(t,40,-1,20)
        print('path found ', r)
        if path then
            pathHandle,plan = visualizePath(path)
            --finalPlan=getGradient(plan)
            sim.setIntegerSignal(handle_signal, pathHandle)
        end
    end
end