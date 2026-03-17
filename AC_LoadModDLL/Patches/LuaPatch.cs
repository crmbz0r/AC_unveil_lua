using System;
using System.IO;
using AC;
using BepInEx;
using HarmonyLib;
using XLua;

namespace AiComi_LuaMod;

// ─────────────────────────────────────────────────────────────
//  Harmony: grab LuaEnv once available
// ─────────────────────────────────────────────────────────────
[HarmonyPatch(typeof(ParameterContainer))]
internal static class LuaPatch
{
    [HarmonyPostfix, HarmonyPatch(nameof(ParameterContainer.BuildConditionsFromLua))]
    private static void AfterBuildConditions(ParameterContainer __instance)
    {
        if (DialogSceneHooks.NoFavorLoss)
            Plugin.Log.LogWarning("[Dialog] NoFavorLoss active");
        if (DialogSceneHooks.NoMoodLoss)
            Plugin.Log.LogWarning("[Dialog] NoMoodLoss active");
        if (DialogSceneHooks.ForcePositiveChoice)
            Plugin.Log.LogWarning("[Dialog] ForcePositiveChoice active");

        var luaEnv = __instance._luaEnv;
        if (luaEnv is null)
        {
            Plugin.Log.LogError("LuaEnv ist null!");
            return;
        }

        Plugin.Log.LogWarning("LuaEnv found! Initializing xLua plugin + console...");
        LuaConsole.Initialize(luaEnv);
        var modsPath =
            Path.Combine(Paths.PluginPath, "lua_scripts", "mods").Replace("\\", "/") + "/";
        luaEnv.Global.Set("MOD_PATH", modsPath);

        try
        {
            var path = Path.Combine(BepInEx.Paths.PluginPath, "AiComi_LuaMod.lua");
            if (File.Exists(path))
            {
                luaEnv.DoString(File.ReadAllText(path), "AiComi_LuaMod");
                Plugin.Log.LogWarning($"Lua-Mod loaded from: {path}");
            }
        }
        catch (Exception ex)
        {
            Plugin.Log.LogError($"Error occured during xLua-injection: {ex}");
        }

        // Register UnlockItems function for Lua access
        luaEnv.Global.Set(
            "UnlockItems",
            (Action<bool>)(
                v =>
                {
                    TouchSceneHooks.UnlockItems = v;
                    Plugin.Log.LogWarning($"[TouchScene] UnlockItems = {v}");
                }
            )
        );
    }
}
