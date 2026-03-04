-- =============================================================
--  explore_adv.lua  -  Runtime-Exploration des ADV Dialog-Systems
--  In der F9-Console ausfuehren (Ctrl+Enter)
--  Voraussetzung: Im Story/Explore-Modus (nach Save-Load)
-- =============================================================

-- ADVCore finden
local advCore = CS.UnityEngine.GameObject.FindObjectOfType(typeof(CS.ILLGAMES.ADV.ADVCore))
if advCore then
    print("=== ADVCore gefunden ===")
    print("  ParameterContainer: " .. tostring(advCore.ParameterContainer))
    
    local scenario = advCore.Scenario
    if scenario then
        print("  Scenario: " .. tostring(scenario))
        print("  LoadBundleName: " .. tostring(scenario.LoadBundleName))
        print("  LoadAssetName: " .. tostring(scenario.LoadAssetName))
        print("  CurrentLine: " .. tostring(scenario.CurrentLine))
        print("  IsSkip: " .. tostring(scenario.IsSkip))
        print("  IsAuto: " .. tostring(scenario.IsAuto))
        print("  VisibleWindow: " .. tostring(scenario.VisibleWindow))
        
        local cmdCtrl = scenario.CommandController
        if cmdCtrl then
            print("  CommandController: " .. tostring(cmdCtrl))
        end
        
        local nowCmds = scenario.NowCommandList
        if nowCmds then
            print("  NowCommandList: " .. tostring(nowCmds))
        end
    else
        print("  Scenario: nil (kein Dialog aktiv)")
    end
else
    print("[INFO] ADVCore nicht gefunden - kein Dialog aktiv")
end

-- Pack-Data pruefen
local ok, pack = pcall(function() return CS.ILLGAMES.ADV.ADVCore.Pack end)
if ok and pack then
    print("\n=== ADVCore.Pack (static) ===")
    print("  " .. tostring(pack))
else
    print("\n[INFO] ADVCore.Pack nicht verfuegbar")
end

-- ContentProvider - alle Events auflisten
print("\n=== Event Scenario Contents ===")
local ok2, contents = pcall(function()
    return CS.AC.ContentProvider.EventScenarioContents
end)
if ok2 and contents then
    print("Contents verfuegbar: " .. tostring(contents))
    -- Versuche zu iterieren
    local ok3, err = pcall(function()
        local e = contents:GetEnumerator()
        local count = 0
        while e:MoveNext() and count < 20 do
            local item = e.Current
            count = count + 1
            print(string.format("  [%d] Type=%s ID=%s EventID=%s Condition=%s Scenario=%s",
                count,
                tostring(item.Type),
                tostring(item.ID),
                tostring(item.EventID),
                tostring(item.ConditionFile),
                tostring(item.ScenarioFile)))
        end
        print(string.format("  ... (%d gezeigt)", count))
    end)
    if not ok3 then
        print("  Fehler beim Iterieren: " .. tostring(err))
        -- Alternativer Zugriff per Index
        local ok4, _ = pcall(function()
            for i = 0, 19 do
                local item = contents[i]
                if item then
                    print(string.format("  [%d] Type=%s EventID=%s", i, tostring(item.Type), tostring(item.EventID)))
                end
            end
        end)
    end
else
    print("  ContentProvider.EventScenarioContents nicht verfuegbar: " .. tostring(contents))
end

print("\n=== Ende ADV Exploration ===")
