---
--- Created by Hugo
--- DateTime: 2023/7/14 17:51
---

---@class GameObjLoader : BaseClass
GameObjLoader = GameObjLoader or BaseClass()

local LoaderLayer = GameObject.Find("GameRoot/LoaderLayer").transform
local TypeRectTransform = typeof(UnityEngine.RectTransform)

function GameObjLoader:__init(parent_transform)
    self.name = "GameObjLoader"
    self.parent_transform = parent_transform or LoaderLayer

    self.is_active = true
    self.local_position = nil
    self.local_scale = nil
    self.local_rotation = nil

    self.is_use_obj_pool = nil
    self.release_policy = ResPoolReleasePolicy.Default
    self.is_optimize_effect = true
    self.is_async = true
    self.load_priority = ResLoadPriority.high
    self.is_reset_parent_transform = false
    self.cur_tbl = {}
    self.loading_tbl = {}
    self.wait_tbl = {}

    self.obj_alive_time = nil
    self.obj_alive_time_stamp = 0
end

function GameObjLoader:__delete()
    if not self.__is_had_del_in_cache then
        self.__is_had_del_in_cache = true
        if not self.__loader_key and not self.__loader_owner and not self.__loader_owner.__game_obj_loaders then
            self.__loader_owner.__game_obj_loaders[self.__loader_key] = nil
        end
    end

    self:Destroy()
    self.parent_transform = nil
    self.cur_tbl.bundle_name = nil
    self.wait_tbl.bundle_name = nil
    self.loading_tbl.bundle_name = nil

    if self.cur_tbl.shield_handle then
        self.cur_tbl.shield_handle:DeleteMe()
        self.cur_tbl.shield_handle = nil
    end
end

-- 一个loader只加载一个对象，如果删除要调用loader的Destroy接口安全移除
-- 如果该对象已经被其他地方非法删除了，以下有记录instance_id对象池进行清理
-- 如果该对象还在队列中，则充队列中取消
-- 入宫有正在等待加载的对象，则该等待对象将不再加载
-- 强制清除parent_transform的引用
function GameObjLoader:Destroy(is_reset_parent_transform)
    self.loading_tbl.bundle_name = nil
    if self.loading_tbl.queue_session then
        ResPoolMgr.Instance:__CancelGetInQueue(self.loading_tbl.queue_session)
        self.loading_tbl.queue_session = nil
    end

    self.wait_tbl.bundle_name = nil

    if self.cur_tbl.bundle_name then
        local go = self.cur_tbl.game_obj
        local instance_id = self.cur_tbl.instance_id
        self.cur_tbl.bundle_name = nil
        self.cur_tbl.prefab_name = nil
        self.cur_tbl.game_obj = nil
        self.cur_tbl.instance_id = 0

        if IsNil(go) then
            if self.is_use_obj_pool then
                ResPoolMgr.Instance:ReleaseInObjId(instance_id)
            else
                ResMgr.Instance:ReleaseInObjId(instance_id)
            end
        else
            self:__DestroyObj(go)
        end
    end

    if is_reset_parent_transform then
        self.parent_transform = LoaderLayer
    end
end

function GameObjLoader:__DestroyObj(obj)
    if IsNil(obj) then
        return
    end

    if self.is_use_obj_pool then
        ResPoolMgr.Instance:Release(obj, self.release_policy)
    else
        ResMgr.Instance:__Destroy(obj)
    end
end

function GameObjLoader:GetGameObj()
    return self.cur_tbl.game_obj
end

function GameObjLoader:Update(now_time, delta_time)
    if now_time >= self.obj_alive_time_stamp then
        self:Destroy()
        return true
    end

    return false
end

function GameObjLoader:__DelayDelObj()
    if self.obj_alive_time then
        self.obj_alive_time_stamp = self.obj_alive_time + Status.NowTime
        GameObjLoaderMgr.Instance:AddTimer(self)
    end
end

function GameObjLoader:SetObjAliveTime(obj_alive_time)
    self.obj_alive_time = obj_alive_time
    self:__DelayDelObj()
end

function GameObjLoader:SetIsAsyncLoad(is_async)
    self.is_async = is_async
end

function GameObjLoader:SetIsAsyncLoad(load_priority)
    if load_priority then
        self.load_priority = load_priority
    end
end

function GameObjLoader:SetIsUseObjPool(is_use_obj_pool, release_policy)
    if self.is_use_obj_pool and self.is_use_obj_pool ~= is_use_obj_pool then
        print_error("[GameObjLoader] SetIsUseObjPool 只允许设置1次，以免引起不必要的bug")
        return
    end
    self.is_use_obj_pool = is_use_obj_pool
    self.release_policy = release_policy or ResPoolReleasePolicy.Default
end

function GameObjLoader:SetReleasePolicy(release_policy)
    self.release_policy = release_policy
end

function GameObjLoader:SetIsInQueueLoad(is_in_queue)
    if is_in_queue then
        self.load_priority = ResLoadPriority.low
    end
end

function GameObjLoader:SetParent(parent_transform)
    if not IsNil(parent_transform) then
        if parent_transform.SetParent then
            print_error("[GameObjLoader] SetParent 参数非Transform!")
        end
    end

    if self.parent_transform ~= parent_transform then
        self.is_reset_parent_transform = true
    end

    self.parent_transform = parent_transform
end

function GameObjLoader:SetLocalPosition(position)
    self.local_position = position
    if self.cur_tbl and not IsNil(self.cur_tbl.game_obj) then
        self.cur_tbl.game_obj.transform.localPosition = self.local_position
    end
end

function GameObjLoader:SetLocalRotation(rotation)
    self.local_rotation = rotation
    if self.cur_tbl and not IsNil(self.cur_tbl.game_obj) then
        self.cur_tbl.game_obj.transform.localRotation = self.local_rotation
    end
end

function GameObjLoader:SetLocalScale(scale)
    self.local_scale = scale
    if self.cur_tbl and not IsNil(self.cur_tbl.game_obj) then
        self.cur_tbl.game_obj.transform.localScale = self.local_scale
    end
end

function GameObjLoader:SetActive(active)
    if self.is_active ~= active then
        self.is_active = active
        if self.cur_tbl and not IsNil(self.cur_tbl.game_obj) then
            self.cur_tbl.game_obj:SetActive(active)
        end
    end
end

GameObjLoader.cb_data_list = {}
function GameObjLoader.GetCbData()
    local data = table.remove(GameObjLoader.cb_data_list)
    if data == nil then
        data = { true }
    end
    return data
end

function GameObjLoader.ReleaseCbData(cb_data)
    cb_data[1] = true
    table.insert(GameObjLoader.cb_data_list, cb_data)
end

function GameObjLoader:ReLoad(bundle_name, prefab_name, local_callback, cb_data)
    self:Destroy()
    self:Load(bundle_name, prefab_name, local_callback, cb_data)
end

function GameObjLoader:Load(bundle_name, prefab_name, load_callback, cb_data)
    if IsNilOrEmpty(bundle_name) or IsNilOrEmpty(prefab_name) then
        return
    end

    --若资源已存在则直接回调
    if self.cur_tbl
            and self.cur_tbl.bundle_name == bundle_name
            and self.cur_tbl.prefab_name == prefab_name
            and not IsNil(self.cur_tbl.game_obj) then
        self:OnLoadSuccess(self.cur_tbl.game_obj)
        if load_callback then
            load_callback(self.cur_tbl.game_obj, cb_data)
        end
        return
    end

    --资源正在加载不处理
    if self.loading_tbl.bundle_name == bundle_name and self.loading_tbl.prefab_name == prefab_name then
        self.wait_tbl.bundle_name = nil
        self.wait_tbl.prefab_name = nil
        self.wait_tbl.load_callback = nil
        self.wait_tbl.cb_data = nil
        return
    end

    if UNITY_EDITOR then
        if not EditorResourceMgr.IsExistsAsset(bundle_name, prefab_name) then
            print_error("加载资源不存在，请马上检查!!!")
            return
        end
    end

    if self.loading_tbl.bundle_name then
        self.wait_tbl.bundle_name = bundle_name
        self.wait_tbl.prefab_name = prefab_name
        self.wait_tbl.load_callback = load_callback
        self.wait_tbl.cb_data = cb_data
    else
        self:Destroy()
        self.loading_tbl.bundle_name = bundle_name
        self.loading_tbl.prefab_name = prefab_name
        self.loading_tbl.load_callback = load_callback
        self.loading_tbl.cb_data = cb_data
        self:DoLoad()
    end
end

function GameObjLoader:DoLoad()
    if self.parent_transform == nil or self.parent_transform == LoaderLayer then
        if UNITY_EDITOR then
            print_warning("加载前必须设置parent_transform，请在Load之前通过SetParent指定父节点。")
        end
    end

    self.is_reset_parent_transform = false
    local cb_data = GameObjLoader.GetCbData()
    cb_data[1] = self

    if self.is_use_obj_pool then
        if self.is_async then
            self.loading_tbl.queue_session = ResPoolMgr.Instance:__GetDynamicObjAsync(
                    self.loading_tbl.bundle_name,
                    self.loading_tbl.prefab_name,
                    self.parent_transform,
                    GameObjLoader.LoadComplete,
                    cb_data,
                    self.load_priority
            )
        else
            ResPoolMgr.Instance:__GetDynamicObjSync(
                    self.loading_tbl.bundle_name,
                    self.loading_tbl.prefab_name,
                    self.parent_transform,
                    GameObjLoader.LoadComplete,
                    cb_data
            )
        end
    else
        if self.is_async then
            ResMgr.Instance:LoadGameObjectAsync(
                    self.loading_tbl.bundle_name,
                    self.loading_tbl.prefab_name,
                    self.parent_transform,
                    GameObjLoader.LoadComplete,
                    cb_data,
                    self.load_priority
            )
        else
            ResMgr.Instance:LoadGameObjectSync(
                    self.loading_tbl.bundle_name,
                    self.loading_tbl.prefab_name,
                    self.parent_transform,
                    GameObjLoader.LoadComplete,
                    cb_data
            )
        end
    end
end

function GameObjLoader.LoadComplete(game_obj, cb_data)
    local self = cb_data[1]
    GameObjLoader.ReleaseCbData(cb_data)

    local bundle_name = self.loading_tbl.bundle_name
    local prefab_name = self.loading_tbl.prefab_name
    local load_callback = self.loading_tbl.load_callback
    local cbd = self.loading_tbl.cb_data

    self.loading_tbl.bundle_name = nil
    self.loading_tbl.prefab_name = nil
    self.loading_tbl.load_callback = nil
    self.loading_tbl.cb_data = nil
    self.loading_tbl.queue_session = nil

    if self.wait_tbl.bundle_name then
        self:__DestroyObj(game_obj)
        self.loading_tbl.bundle_name = self.wait_tbl.bundle_name
        self.loading_tbl.prefab_name = self.wait_tbl.prefab_name
        self.loading_tbl.load_callback = self.wait_tbl.load_callback
        self.loading_tbl.cb_data = self.wait_tbl.cb_data
        self.wait_tbl.bundle_name = nil
        self.wait_tbl.prefab_name = nil
        self.wait_tbl.load_callback = nil
        self.wait_tbl.cb_data = nil

        self:DoLoad()
        return
    end

    if IsNil(game_obj) then
        return
    end

    if IsNil(self.parent_transform) or bundle_name == nil then
        self:__DestroyObj(game_obj)
        return
    end

    self.cur_tbl.bundle_name = bundle_name
    self.cur_tbl.prefab_name = prefab_name
    self.cur_tbl.game_obj = game_obj
    self.cur_tbl.instance_id = game_obj:GetInstanceID()

    self:OnLoadSuccess(game_obj)
    self:TryOptimizeEffect(game_obj)

    if load_callback then
        load_callback(game_obj, cbd)
    end

end

function GameObjLoader:OnLoadSuccess(game_obj)
    if self.is_reset_parent_transform and not IsNil(self.parent_transform) then
        self.is_reset_parent_transform = false
        game_obj.transform:SetParent(self.parent_transform, false)
    end

    if self.local_position then
        game_obj.transform.localPosition = self.local_position
    end
    if self.local_rotation then
        game_obj.transform.localRotation = self.local_rotation
    end
    if self.local_scale then
        game_obj.transform.localScale = self.local_scale
    end

    game_obj:SetActive(self.is_active)

    self:__DelayDelObj()
end

--TODO EffectOrderGroup.RefreshRenderOrder
function GameObjLoader:TryOptimizeEffect(game_obj)
    if self.is_use_obj_pool and self.is_optimize_effect then
        if game_obj:GetComponentInParent(TypeRectTransform) then
            EffectOrderGroup.RefreshRenderOrder(game_obj)
        end
    end
end












