
function UpdateUI()
    pioneer0Energy = sim.getIntegerSignal('pioneer0Energy')
    pioneer1Energy = sim.getIntegerSignal('pioneer1Energy')
    pioneer2Energy = sim.getIntegerSignal('pioneer2Energy')
    pioneer0Goal = sim.getIntegerSignal('pioneer0Goal')
    pioneer1Goal = sim.getIntegerSignal('pioneer1Goal')
    pioneer2Goal = sim.getIntegerSignal('pioneer2Goal')
    --quadGoal = sim.getIntegerSignal('Quad Goal')
    --quadEnergy = sim.getIntegerSignal('Quad Energy')
    signal=sim.getIntegerSignal('Intruder')
    if signal == 1 then
        --print('INTRUDER ALERT!')
        --sim.setIntegerSignal('Intruder', 0)
    end
    if pioneer0Energy ~= nil and pioneer1Energy ~= nil then
        simUI.setLabelText(xml,100,'Pioneer0 Energy: '..pioneer0Energy)
        simUI.setLabelText(xml,101,'Pioneer1 Energy: '..pioneer1Energy)
        simUI.setLabelText(xml,103,'Pioneer2 Energy: '..pioneer2Energy)
        --simUI.setLabelText(xml,102,'Quad Energy:      '..quadEnergy)
        simUI.setLabelText(xml,200,'Pioneer0 Goal:      '..pioneer0Goal)
        simUI.setLabelText(xml,201,'Pioneer1 Goal:      '..pioneer1Goal)
        simUI.setLabelText(xml,203,'Pioneer2 Goal:      '..pioneer2Goal)
        --simUI.setLabelText(xml,202,'Quad Goal:           '..quadGoal)
    end
end