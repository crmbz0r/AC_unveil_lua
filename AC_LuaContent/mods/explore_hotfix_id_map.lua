-- =============================================================
--  explore_hotfix_id_map.lua  -  Runtime-Extraction der hotfix_id_map
--  In der F9-Console ausfuehren (Ctrl+Enter)
--  Voraussetzung: Im Story/Explore-Modus (nach Save-Load)
-- =============================================================

-- Versuche hotfix_id_map direkt zu laden
local ok, id_map = pcall(require, 'hotfix_id_map')
if not ok then
    print("[WARN] hotfix_id_map konnte nicht geladen werden:")
    print(tostring(id_map))
    print("")
    print("Versuche alternative Methoden...")
    
    -- Alternative: Direkt ueber Resources.Load
    local ta = CS.UnityEngine.Resources.Load("hotfix_id_map", typeof(CS.UnityEngine.TextAsset))
    if ta then
        print("TextAsset gefunden! Laenge: " .. ta.text.Length)
        print("Erste 2000 Zeichen:")
        print(ta.text:Substring(0, math.min(2000, ta.text.Length)))
    else
        print("Kein TextAsset 'hotfix_id_map' in Resources gefunden.")
        print("")
        print("Die hotfix_id_map existiert moeglicherweise nicht in diesem Spiel.")
        print("xlua.hotfix() wird dann den nativen Pfad nutzen (org_hotfix).")
        print("")
        print("Alternative: HotfixDelegateBridge.Set(id, func) direkt nutzen.")
        print("IDs muessen dann manuell per Reverse Engineering gefunden werden.")
    end
    return
end

-- hotfix_id_map ist ein Lua-Table: { ["FullTypeName"] = { ["MethodName"] = {id1, id2, ...} } }
print("=== hotfix_id_map ===")
local typeCount = 0
local methodCount = 0
local idCount = 0

for typeName, methods in pairs(id_map) do
    typeCount = typeCount + 1
    print(string.format("\n[%s]", typeName))
    for methodName, ids in pairs(methods) do
        methodCount = methodCount + 1
        local idList = {}
        for _, id in ipairs(ids) do
            idCount = idCount + 1
            table.insert(idList, tostring(id))
        end
        print(string.format("  %-40s = {%s}", methodName, table.concat(idList, ", ")))
    end
end

print(string.format("\n=== %d Typen, %d Methoden, %d IDs ===", typeCount, methodCount, idCount))

-- Dump als Lua-Source fuer spaetere Nutzung
print("\n--- Lua-Source Dump (kopieren!) ---")
print("local hotfix_id_map = {")
for typeName, methods in pairs(id_map) do
    print(string.format('  ["%s"] = {', typeName))
    for methodName, ids in pairs(methods) do
        local idList = {}
        for _, id in ipairs(ids) do table.insert(idList, tostring(id)) end
        print(string.format('    ["%s"] = {%s},', methodName, table.concat(idList, ", ")))
    end
    print("  },")
end
print("}")
print("return hotfix_id_map")
