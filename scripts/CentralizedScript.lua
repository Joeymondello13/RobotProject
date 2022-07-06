function init()
    xml = simUI.create([[<ui closeable="true" on-close="closeEventHandler" resizable="true" size="400,300">
    <label text="Important Info"/>
    <tabs>
    <tab title = "Vehicle Energy ">
    <group>
    <label id ="100" text="Pioneer0 Energy:" />
    </group>
    <group>
    <label id= "101" text="Pioneer1 Energy:" />
    </group>
    <group>
    <label id= "103" text="Pioneer2 Energy:" />
    </group>
    <group>
    <label id= "102" text="Quadricopter Energy:"/>
    </group>
    </tab>
    <tab title = "Vehicle Goal ">
    <group>
    <label id= "200" text="Pioneer0 Goal:" />
    </group>
    <group>
    <label id= "201" text="Pioneer1 Goal:" />
    </group>
    <group>
    <label id= "203" text="Pioneer2 Energy:" />
    </group>
    <group>
    <label id = "202" text="Quadricopter Goal:" />
    </group>
    </tab>
    </tabs>
    </ui>]])
    simUI.setPosition(xml,0,650)
end
function closeEventHandler(h)
    sim.addLog(sim.verbosity_scriptinfos,'Window '..h..' is closing...')
    simUI.hide(h)
end