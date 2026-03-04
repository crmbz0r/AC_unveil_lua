-- =============================================================
--  explore_save_persistence.lua  -  Test ob Events den Save ueberleben
--  In der F9-Console ausfuehren (Ctrl+Enter)
--  Voraussetzung: Im Story/Explore-Modus (nach Save-Load)
-- =============================================================

-- == Phase 1: Aktuellen Zustand dumpen ==
print("=== EventTable.EventMemory (Runtime HashSet) ===")
local em = CS.AC.Lua.EventTable.EventMemory
if not em then
    print("[WARN] EventMemory ist nil!")
    return
end
print("Count: " .. em.Count)

local e = em:GetEnumerator()
local ids = {}
while e:MoveNext() do
    table.insert(ids, e.Current)
end
table.sort(ids)
for _, id in ipairs(ids) do
    print("  Event " .. id)
end

-- == Phase 2: SaveData.EventMemory (Persisted IntKeyDictionary<Counter>) ==
print("\n=== SaveData.EventMemory (Persistiert) ===")
local game = CS.UnityEngine.GameObject.FindObjectOfType(typeof(CS.Manager.Game))
if not game then
    print("[WARN] Manager.Game nicht gefunden")
    return
end

xlua.private_accessible(typeof(CS.AC.ParameterContainer))
local pc = game.ParameterContainer
local saveData = pc._saveData
if not saveData then
    print("[WARN] _saveData ist nil")
    return
end

local savedEM = saveData.EventMemory
if not savedEM then
    print("[WARN] SaveData.EventMemory ist nil")
    return
end

print("SaveData.EventMemory Count: " .. savedEM.Count)
local savedKeys = savedEM.Keys
local se = savedKeys:GetEnumerator()
local savedIds = {}
while se:MoveNext() do
    table.insert(savedIds, se.Current)
end
table.sort(savedIds)
for _, id in ipairs(savedIds) do
    local counter = savedEM[id]
    -- Counter hat implicit int conversion, aber in Lua brauchen wir _value
    local ok, val = pcall(function() return counter._value end)
    local valStr = ok and tostring(val) or "?"
    print(string.format("  Event %d = Counter(%s)", id, valStr))
end

-- == Phase 3: Vergleich ==
print("\n=== Vergleich ===")
local runtimeOnly = {}
local savedOnly = {}
local runtimeSet = {}
local savedSet = {}

for _, id in ipairs(ids) do runtimeSet[id] = true end
for _, id in ipairs(savedIds) do savedSet[id] = true end

for _, id in ipairs(ids) do
    if not savedSet[id] then table.insert(runtimeOnly, id) end
end
for _, id in ipairs(savedIds) do
    if not runtimeSet[id] then table.insert(savedOnly, id) end
end

if #runtimeOnly > 0 then
    print("Nur in EventTable (NICHT persistiert!):")
    for _, id in ipairs(runtimeOnly) do print("  " .. id) end
else
    print("Alle Runtime-Events sind auch in SaveData.")
end

if #savedOnly > 0 then
    print("Nur in SaveData (nicht im Runtime-HashSet):")
    for _, id in ipairs(savedOnly) do print("  " .. id) end
else
    print("Alle SaveData-Events sind auch im Runtime-HashSet.")
end

-- == Phase 4: Test-Event hinzufuegen ==
print("\n=== Test: Event 9999 hinzufuegen ===")
print("Fuege Event 9999 zu EventTable.EventMemory hinzu...")
em:Add(9999)
print("EventTable.EventMemory hat jetzt Event 9999: " .. tostring(CS.AC.Lua.EventTable.ContainsMemory(9999)))

print("\nFuege Event 9999 auch zu SaveData.EventMemory hinzu...")
local ok2, err = pcall(function()
    local counter = CS.AC.User.Counter(1)
    savedEM:Add(9999, counter)
end)
if ok2 then
    print("SaveData.EventMemory hat jetzt Event 9999!")
    print("JETZT SPEICHERN und dann NEU LADEN um Persistenz zu testen.")
    print("Nach dem Laden: dieses Script nochmal ausfuehren und pruefen ob 9999 noch da ist.")
else
    print("Fehler beim Hinzufuegen zu SaveData: " .. tostring(err))
    print("Versuche alternativen Weg...")
    local ok3, err3 = pcall(function()
        -- Alternativer Weg: Counter.Rent
        local counter = CS.AC.User.Counter.Rent(1)
        savedEM[9999] = counter
    end)
    if ok3 then
        print("Alternativer Weg erfolgreich!")
    else
        print("Auch fehlgeschlagen: " .. tostring(err3))
    end
end

print("\n=== Ende ===")
print("Workflow:")
print("1. Script ausfuehren (Events werden hinzugefuegt)")
print("2. Im Spiel speichern")
print("3. Spiel neu laden / Save laden")
print("4. Script nochmal ausfuehren")
print("5. Pruefen ob Event 9999 noch in beiden Listen ist")
