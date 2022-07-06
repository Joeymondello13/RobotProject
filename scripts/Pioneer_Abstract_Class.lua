require('class')
Pioneer_Abstract_Class = class()
function Pioneer_Abstract_Class:init()
    noDetectionDist=0.4
    maxDetectionDist=0.1
    detect={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    braitenbergL={-0.2,-0.4,-0.6,-0.8,-1,-1.2,-1.4,-1.6, 0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0}
    braitenbergR={-1.6,-1.4,-1.2,-1,-0.8,-0.6,-0.4,-0.2, 0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0}
    v0=1
    vLeft = 0
    vRight = 0
    obstaclesPresent = false
    X_curr = getState()

    Kp = 0.2
    Kd = 0.20
    Ki = 0.000
    E = 0
    old_e = 0
    desiredV = .15
    goalFound = false
    counterVariable = 0
    count = 0
    sum = 0
end
Pioneer_Abstract_Class:set{
    desiredV = {
        value = 0.15,
        set = function(self, newVal, oldVal) return newVal end
    }
}
function Pioneer_Abstract_Class:uniToDiff(v,w)
    R = 0.5
    L = 0.5
    vR = (2*v + w*L)/(2*R)
    vL = (2*v - w*L)/(2*R)
    return vR, vL
end
function Pioneer_Abstract_Class:iteratePID()
    X_curr = getState()
    goal = sim.getObjectPosition(targetObj,-1)



    --#Difference in x and y
    d_x = goal[1] - X_curr[1]
    d_y = goal[2] - X_curr[2]


    --#Angle from robot to goal
    g_theta = math.atan2(d_y, d_x)

    --#Error between the goal angle and robot angle
    alpha = g_theta - X_curr[3]


    --#alpha = g_theta - math.radians(90)
    e = math.atan2(math.sin(alpha), math.cos(alpha))


    e_P = e
    e_I = E + e
    e_D = e - old_e

    --# This PID controller only calculates the angular velocity with constant speed of v
    --# The value of v can be specified by giving in parameter or using the pre-defined value defined above.
    w = Kp*e_P + Ki*e_I + Kd*e_D

    w = math.atan2(math.sin(w), math.cos(w))

    E = E + e
    old_e = e

    v = desiredV
    if alpha > math.pi / 2 or alpha < -math.pi / 2 then
        v = -v
    end
    return v, w
end
function Pioneer_Abstract_Class:isArrived()
    dx = goal[1] - X_curr[1]
    dy = goal[2] - X_curr[2]
    dist = math.sqrt(dx*dx + dy*dy)
    if(dist)<0.1 then
        return true
    else
        return false
    end
end
function Pioneer_Abstract_Class:detectObstacles()
    for i=1,16,1 do
        res,dist=sim.readProximitySensor(usensors[i])
        if (res>0) and (dist<noDetectionDist) then
            if (dist<maxDetectionDist) then
                dist=maxDetectionDist
            end
            detect[i]=1-((dist-maxDetectionDist)/(noDetectionDist-maxDetectionDist))
        else
            detect[i]=0
        end
    end
    result=0
    for i=1,16 do
        result=result+detect[i]
    end
    if result > 0 then
        obstaclesPresent = true
        sim.setIntegerSignal('obstaclesPresent',1)
    else
        obstaclesPresent=false
        sim.setIntegerSignal('obstaclesPresent',0)
    end
end
function getDistanceFromCharger(robotPosition)
    charger={-16.83,-4.59,0}
    dx=math.abs(robotPosition[1])-math.abs(charger[1])
    dy=math.abs(robotPosition[2])-math.abs(charger[2])
    dist = math.sqrt(dx*dx + dy*dy)
    return dist
end
function getDistance(goal,robot)
    dx=goal[1]-robot[1]
    dy=goal[2]-robot[2]
    dist = math.sqrt(dx*dx + dy*dy)
    return dist
end