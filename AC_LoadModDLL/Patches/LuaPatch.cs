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
        
        // Signal AC_FSR plugin that Lua console is initialized
        try
        {
            var acFsrType = System.Type.GetType("AC_FSR.AC_FSR, AC_FSR");
            if (acFsrType != null)
            {
                var method = acFsrType.GetMethod("OnLuaConsoleInitialized", System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.Static);
                if (method != null)
                {
                    method.Invoke(null, null);
                    Plugin.Log.LogWarning("[AC_FSR] Signal sent to AC_FSR plugin");
                }
                else
                {
                    Plugin.Log.LogWarning("[AC_FSR] OnLuaConsoleInitialized method not found");
                }
            }
            else
            {
                Plugin.Log.LogWarning("[AC_FSR] AC_FSR type not found - plugin may not be loaded");
            }
        }
        catch (System.Exception ex)
        {
            Plugin.Log.LogWarning($"[AC_FSR] Failed to send signal: {ex.Message}");
        }
        
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
        luaEnv.DoString(
            @"
            function UnlockItems(v)
                CS.AiComi_LuaMod.TouchSceneHooks.UnlockItems = v
                print('[TouchScene] UnlockItems = ' .. tostring(v))
            end
        "
        );
    }
}
