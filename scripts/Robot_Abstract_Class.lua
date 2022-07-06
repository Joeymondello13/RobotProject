local function read_file(path)
    local file = io.open(path,"r")
    if not file then return nil end
    local content = file:read "*a"
    file:close()
    return content
end
function init()
    initialPosition = sim.getObjectPosition(robotHandle,-1)
    intruderHandle=sim.callScriptFunction('getIntruderHandle@Pioneer_goal',sim.scripttype_childscript)
    intruderPos = sim.getObjectPosition(intruderHandle,-1)
    counter = 0
    energy = 300
    -------------------------------------------------------------------------------------------------------------------------------
    currentGoal= goalArray[1]
    previousGoal=currentGoal
    currentIndex = 1
    nextGoal = goalArray[2]
    arrivedAtFirstGoal = false
    -------------------------------------------------------------------------------------------------------------------------------
    noDetectionDist=0.5
    maxDetectionDist=0.2
    detect={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    braitenbergL={-0.2,-0.4,-0.6,-0.8,-1,-1.2,-1.4,-1.6, 0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0}
    braitenbergR={-1.6,-1.4,-1.2,-1,-0.8,-0.6,-0.4,-0.2, 0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0}
    v0=2
    vLeft = 0
    vRight = 0

    X_curr = getState()

    Kp = 0.4
    Kd = 0.20
    Ki = 0.000
    E = 0
    old_e = 0
    desiredV = 2

    wheel_radius=0.195/2
    b=0.1655
    vref=0.35
    e=0.24
    epsilon_q=1
    epsilon_c=2
    epsilon_r=0.005
    Qsafe=0.1
    Qinf=1
end

function findStartingPoint(PioneerPosition)
    return getIndex(currentGoal)
end
function findClosestPoint(robotPosition)
    intruder1=calculate120Degrees()
    intruder2=calculate240Degrees()
    dx = intruder1[1]-robotPosition[1]
    dy = intruder1[2]-robotPosition[2]
    dist = math.sqrt(dx*dx + dy*dy)
    dx2 = intruder2[1]-robotPosition[1]
    dy2 = intruder2[2]-robotPosition[2]
    dist2= math.sqrt(dx2*dx2 + dy2*dy2)
    return dist,dist2,intruder1,intruder2
end
function calculate120Degrees()
    plusTheta = math.rad(120)
    robotPos=getPolarCoords(leadBotPos)
    return convertToCartesian(robotPos)
end
function calculate240Degrees()
    plusTheta = math.rad(240)
    robotPos=getPolarCoords(leadBotPos)
    return convertToCartesian(robotPos)
end
getState = function()
    pos = sim.getObjectPosition(robotHandle,-1)
    ori = sim.getObjectOrientation(robotHandle,-1)
    ori[3] = math.atan2(math.sin(ori[3]), math.cos(ori[3]))
    return {pos[1], pos[2], ori[3]}
end

function getPolarCoords(leadBotPos)
    dx = leadBotPos[1] - intruderPos[1]
    dy = leadBotPos[2] - intruderPos[2]
    theta = math.atan2(dy,dx)
    r = math.sqrt(dx*dx + dy*dy)
    theta = theta + plusTheta
    return {r,theta}
end

function convertToCartesian(robotPos)
    x = robotPos[1] * math.cos(robotPos[2])
    x = intruderPos[1] + x
    y = robotPos[1] * math.sin(robotPos[2])
    y = intruderPos[2] + y
    return {x,y,pos[3]}
end
decrementEnergy = function()
    counter = counter + 1
    if counter >= 240 then
        energy = energy - 1
        counter = 0
        if energy <= 0 then
            energy = 0
        end
    end
end

incrementEnergy = function()
    counter = counter + 1
    if counter >= 6 then
        energy = energy +1
        counter = 0
    end
end

function getIndex(i)
    local index={}
    for k,v in pairs(goalArray) do
        index[v]=k
    end
    return index[i]
end

function arrivedAtIntruder()
    dx = currentGoal[1] - X_curr[1]
    dy = currentGoal[2] - X_curr[2]
    dist = math.sqrt(dx*dx + dy*dy)
    if(dist)<2 then
        return true
    else
        return false
    end
end
function getPosition()
    robotPosition = sim.getObjectPosition(robotHandle,-1)
    return robotPosition
end
function contains(goal)
    for i=1,10 do
        if chargingPoint[i] == currentGoal then
            return true
        end
    end
    return false
end
function drawLines(path)
    local lineSize=5 -- in points
    local maximumLines=9999
    local color={1,1,0}
    drawingContainer=sim.addDrawingObject(sim.drawing_lines,lineSize,0,-1,maximumLines,color) -- adds a line
    for i = 1, #path-1 do
        pt0=path[i]
        pt1=path[i+1]
        pt0[3]=0.1
        pt1[3]=0.1
        data={pt0[1],pt0[2],pt0[3],pt1[1],pt1[2],pt1[3]}
        sim.addDrawingObjectItem(drawingContainer,data)
    end
end



