---
--- Created by Hugo
--- DateTime: 2023/12/11 15:14
---

---@class SimulationLoader : LoaderBase
local M = BaseClass(LoaderBase)

local UnityGameObject = UnityEngine.GameObject
local UnityDestroy = UnityGameObject.Destroy
local TypeUnityGameObject = typeof(UnityGameObject)

local wait_load_obj_queue = {}
local wait_load_game_obj_queue = {}

function M:__init()
    self.v_goid_prefab_map = {}
    self.v_goid_go_monitors = {}
    self.v_goid_go_monitor_time = 0
    self.load_scene_t = nil
end

function M:Update(time, delta_time)
    BundleLoader.super.Update(self, time, delta_time)
    EditorResourceMgr.SweepOriginalInstanceIdMap()
    self:UpdateQueueLoad()
    self:MonitorGameObjLive(time)
    self:UpdateSceneLoad()
end

function M:GetPrefab(instance_id)
    return self.v_goid_prefab_map[instance_id]
end

--监测obj是否被移除，逻辑层往往因为在父节点移除而没调用Destroy的方法
function M:MonitorGameObjLive(time)
    if time < self.v_goid_go_monitor_time then
        return
    end
    self.v_goid_go_monitor_time = time + 1

    local die_goids = {}
    local monitor_count = 0
    for k, v in pairs(self.v_goid_go_monitors) do
        monitor_count = monitor_count + 1
        if v:Equals(nil) then
            table.insert(die_goids, k)
        end
    end

    for _, v in ipairs(die_goids) do
        self:ReleaseInObjId(v)
    end

    if #die_goids > 0 then
        print_log("[BundleLoader] monitor_count=" .. monitor_count .. ", die_game_obj count=" .. #die_goids)
    end
end

function M:Destroy(go)
    self:__Destroy(go)
end

function M:__Destroy(go)
    if IsNil(go) then
        return
    end
    self:ReleaseInObjId(go:GetInstanceID())
    UnityDestroy(go)
end

function M:ReleaseInObjId(instance_id)
    if self.v_goid_prefab_map[instance_id] then
        ResPoolMgr:Release(self.v_goid_prefab_map[instance_id])
        self.v_goid_go_monitors[instance_id] = nil
        self.v_goid_prefab_map[instance_id] = nil
    end
end

--模拟AB模式加载延迟
local delayLoad = 0

function M:UpdateQueueLoad()
    if #wait_load_obj_queue > 0 then
        local count = 1 + math.ceil(#wait_load_obj_queue / 5)
        count = math.min(count, 1)
        while count > 0 do
            count = count - 1
            local t = wait_load_obj_queue[1]
            if t.time + delayLoad > UnityEngine.Time.realtimeSinceStartup then
                break
            end
            table.remove(wait_load_obj_queue, 1)
            self:InternalLoadObject(t.bundle_name, t.asset_name, t.asset_type, t.cb, t.cb_data)
        end
    end

    if #wait_load_game_obj_queue > 0 then
        local count = 1 + math.ceil(#wait_load_game_obj_queue / 5)
        count = math.min(count, 1)
        local last_bundle_name = ""
        local last_asset_name = ""
        while true do
            if #wait_load_game_obj_queue <= 0 then
                break
            end
            count = count - 1
            local t = wait_load_game_obj_queue[1]
            if count < 0 and t.bundle_name ~= last_bundle_name and t.asset_name ~= last_asset_name then
                break
            end
            if t.time + delayLoad > UnityEngine.Time.realtimeSinceStartup then
                break
            end
            table.remove(wait_load_game_obj_queue, 1)
            last_bundle_name = t.bundle_name
            last_asset_name = t.asset_name
            self:__InternalLoadObject(t.bundle_name, t.asset_name, t.cb, t.cb_data, true, t.parent)
        end
    end
end

function M:LoadLocalLuaManifest(name)
end

function M:LoadRemoteLuaManifest(callback)
    callback()
end

function M:LoadLocalManifest(name)
end

function M:LoadRemoteManifest(name, callback)
    callback()
end

--异步加载资源(texture,prefab,material等)
function M:__LoadObjectAsync(bundle_name, asset_name, asset_type, cb, cb_data, load_priority)
    table.insert(wait_load_obj_queue, {
        bundle_name = bundle_name,
        asset_name = asset_name,
        asset_type = asset_type,
        cb = cb,
        cb_data = cb_data,
        time = UnityEngine.Time.realtimeSinceStartup,
        load_priority = load_priority
    })
end

--同步加载资源(texture,prefab,material等)
function M:__LoadObjectSync(bundle_name, asset_name, asset_type, cb, cb_data)
    self:InternalLoadObject(bundle_name, asset_name, asset_type, cb, cb_data)
end

function M:InternalLoadObject(bundle_name, asset_name, asset_type, cb, cb_data)
    asset_type = asset_type or TypeUnityGameObject
    local obj = EditorResourceMgr.LoadObject(bundle_name, asset_name, asset_type)
    if IsNil(obj) then
        print_error("[SimulationLoader] load object error", bundle_name, asset_name)
    else
        BundleCache:OnUseBundle(bundle_name)
    end

    cb(obj, cb_data)
end

return M