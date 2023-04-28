UNITY_EDITOR = false

require("common/BaseClass")
require("common/util")

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
end

--场景切换通知
function OnLevelWasLoaded(level)
    collectgarbage("collect")
    Time.timeSinceLevelLoad = 0
end

function OnApplicationQuit()
end