-- =============================================================
--  explore_predicates.lua  –  Runtime-Exploration der _predicates
--  In der F9-Console ausführen (Ctrl+Enter)
--  Voraussetzung: Im Story/Explore-Modus (nach Save-Load)
-- =============================================================

-- ParameterContainer holen
local game = CS.UnityEngine.GameObject.FindObjectOfType(typeof(CS.Manager.Game))
if not game then
    print("[WARN] Manager.Game nicht gefunden - bist du im Hauptmenue?")
    return
end

local pc = game.ParameterContainer
if not pc then
    print("[WARN] ParameterContainer ist nil")
    return
end

local luaEnv = pc._luaEnv
print("LuaEnv: " .. tostring(luaEnv))

-- _predicates zugreifen
-- Hinweis: _predicates ist ein privates Feld, ggf. xlua.private_accessible nötig
xlua.private_accessible(typeof(CS.AC.ParameterContainer))

local predicates = pc._predicates
if not predicates then
    print("[WARN] _predicates ist nil - BuildConditionsFromLua noch nicht gelaufen?")
    return
end

print("=== _predicates ===")
print("Anzahl: " .. predicates.Count)

-- Keys auflisten
local keys = predicates.Keys
local e = keys:GetEnumerator()
local count = 0
while e:MoveNext() do
    local key = e.Current
    count = count + 1
    
    -- Den Predicate aufrufen (Invoke) um den aktuellen Zustand zu sehen
    local pred = predicates[key]
    local ok, result = pcall(function() return pred:Invoke() end)
    local status = ok and tostring(result) or ("ERROR: " .. tostring(result))
    
    print(string.format("  [%3d] %-40s = %s", count, key, status))
end

print("=== Ende (" .. count .. " Predicates) ===")
