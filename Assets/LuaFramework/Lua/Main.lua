local UnityApplication = UnityEngine.Application

UNITY_EDITOR = false --编辑环境
INF = 9000000000000000 -- 1/0 --无穷大
IND = -9000000000000000 -- 0/0 --无穷小

IsLowMemorySystem = UnityEngine.SystemInfo.systemMemorySize <= 1500

require("common/util")
require("common/BaseClass")
require("game/common/U3DObject")
require("common/Vector3Pool")
require("common/SortTools")
require("common/CbdPool")
require("loader/ResUtil")
require("loader/LoadUtil")

function __TRACK_BACK__(msg)
    local track_text = debug.traceback(tostring(msg))
    print_error(track_text, "LUA ERROR")
    return false
end

function TryCall(func, p1, p2, p3)
    return xpcall(func, __TRACK_BACK__, p1, p2, p3)
end

--主入口函数。从这里开始lua逻辑
function Main()
    print("[Main] logic start")

    ResUtil.SetBaseCachePath(string.format("%s/%s", UnityApplication.persistentDataPath, "BundleCache"))

    if GAME_ASSET_BUNDLE then
        ResUtil.InitEncryptKey()
        if ResUtil.is_ios_encrypt_asset then
            ResUtil.SetBaseCachePath(string.format("%s/%s", UnityApplication.persistentDataPath, EncryptMgr.GetEncryptPath("BundleCache")))
        end
        require("loader/BundleLoader")
    else
        require("loader/SimulationLoader")
    end

    --require("loader/AssetBundleMgr")
    --require("loader/BundleCache")
    --require("loader/DownloadMgr")
end

--场景切换通知
function OnLevelWasLoaded(level)
    collectgarbage("collect")
    Time.timeSinceLevelLoad = 0
end

function OnApplicationQuit()
end