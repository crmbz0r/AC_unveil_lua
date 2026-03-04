-- =============================================================
--  AiComi Lua Mod Template
--  Wird via BepInEx Plugin -> LuaBehaviour.luaEnv.DoString() ausgeführt
-- =============================================================

local util = require 'xlua.util'

local MOD_NAME = 'MeinMod v0.1'

-- Logger-Shortcut
local function log(msg)
    CS.AC.Lua.Logger.Log('[' .. MOD_NAME .. '] ' .. tostring(msg))
end

log('Mod geladen!')

-- =============================================================
--  EventTable erkunden
-- =============================================================

local function dump_events()
    local em = CS.AC.Lua.EventTable.EventMemory
    log('EventMemory Einträge: ' .. tostring(em.Count))
    -- Enumerator über das HashSet<int>
    local enumerator = em:GetEnumerator()
    while enumerator:MoveNext() do
        log('  EventID: ' .. tostring(enumerator.Current))
    end
end

-- =============================================================
--  Szenenbaum erkunden
-- =============================================================

local function dump_scene()
    local scene = CS.UnityEngine.SceneManagement.SceneManager.GetActiveScene()
    log('Aktive Szene: ' .. scene.name)
    local roots = scene:GetRootGameObjects()
    for i = 0, roots.Length - 1 do
        log('  Root GO: ' .. roots[i].name)
    end
end

-- =============================================================
--  Hotfix-Beispiel (auskommentiert bis hotfix_id_map bekannt)
-- =============================================================

-- Sobald wir die hotfix_id_map haben:
-- xlua.hotfix(CS.MeinNamespace.MeineKlasse, 'MeineMethode', function(self, ...)
--     log('MeineMethode wurde aufgerufen!')
--     -- Original-Logik kann hier nachgebaut oder übersprungen werden
-- end)

-- =============================================================
--  Event freischalten (Beispiel)
-- =============================================================

local function unlock_event(event_id)
    local em = CS.AC.Lua.EventTable.EventMemory
    if not CS.AC.Lua.EventTable.ContainsMemory(event_id) then
        em:Add(event_id)
        log('Event ' .. event_id .. ' freigeschaltet')
    else
        log('Event ' .. event_id .. ' war bereits aktiv')
    end
end

-- =============================================================
--  Init
-- =============================================================

dump_scene()
dump_events()

log('Bereit.')