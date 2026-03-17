-- =============================================================
--  AiComi xLua plugin with dedicated console & some cheats
--  Run by BepInEx Plugin -> ParameterContainer._luaEnv.DoString()
-- =============================================================

local util = require 'xlua.util'
local MOD_NAME = 'AiComi xLua Console v0.1'
-- MOD_PATH set automatically by C#
function run(filename)
    local f = io.open(MOD_PATH .. filename, "r")
    if not f then print("[ERROR] File not found: " .. filename) return end
    local code = f:read("*a")
    f:close()
    local fn, err = load(code)
    if not fn then print("[ERROR] " .. tostring(err)) return end
    fn()
end
local function log(msg)
    print('[' .. MOD_NAME .. '] ' .. tostring(msg))
end

-- =============================================================
--  Show loaded scene as functionality check
-- =============================================================

local function dump_scene()
    local scene = CS.UnityEngine.SceneManagement.SceneManager.GetActiveScene()
    log('Current scene: ' .. scene.name)
    local roots = scene:GetRootGameObjects()
    for i = 0, roots.Length - 1 do
        log('  Root GO: ' .. roots[i].name)
    end
end

-- =============================================================
--  Show EventMemory status as functionality check
-- =============================================================

local function dump_events()
    local em = CS.AC.Lua.EventTable.EventMemory
    log('EventMemory entries: ' .. tostring(em.Count))
    local enumerator = em:GetEnumerator()
    while enumerator:MoveNext() do
        log('  EventID: ' .. tostring(enumerator.Current))
    end
end

-- =============================================================
--  Init – Decide what to run on startup, if you don'tostring
--  want the scene or event dumps in the BepInEx console,
--  simply commment the dump_scene or dump_events out with -- 
-- =============================================================

log('xLua plugin loaded successfully!')
dump_scene()
dump_events()

log('xLua console ready for usage.')