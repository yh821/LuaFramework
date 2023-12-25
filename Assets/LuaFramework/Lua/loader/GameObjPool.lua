---
--- Created by Hugo
--- DateTime: 2023/5/9 20:12
---

require("loader/ObjPool")

---@class GameObjPool : ObjPool
GameObjPool = GameObjPool or BaseClass(ObjPool)

local localPosition = Vector3(0, 0, 0)
local localRotation = Quaternion.Euler(0, 0, 0)
local localScale = Vector3(0, 0, 0)

function GameObjPool:__init(root, full_path)
    self.v_root = root
    self.full_path = full_path or "none"

    self.v_cache_count = 0
    self.v_cache_gos = {}

    self._original_transform_info = nil
    self._cache_time = 0
    self.v_use_times = 0
    self.v_ref_count = 0
    self.v_is_valid_pool = true
    self.v_release_policy = ResPoolReleasePolicy.Default
end

function GameObjPool:__delete()
end

function GameObjPool:CacheOriginalTransformInfo(prefab)
    if IsNil(prefab) then
        return
    end
    if self._original_transform_info == nil then
        self._original_transform_info = { prefab.transform.localPosition, prefab.transform.localRotation, prefab.transform.localScale }
    end
end

function GameObjPool:GetCacheCount()
    return self.v_ref_count
end

function GameObjPool:Release(game_obj, policy)
    if not self.v_is_valid_pool then
        ResMgr.Instance:__Destroy(game_obj, policy)
        return false
    end

    self.v_ref_count = self.v_ref_count - 1
    if self.v_ref_count < 0 then
        print_error("[GameObjPool] ref count less 0!")
        return false
    end

    if self.v_ref_count >= 64 then
        ResMgr.Instance:__Destroy(game_obj, policy)
        return true
    end

    self.v_release_policy = policy or ResPoolReleasePolicy.Default
    self.v_cache_count = self.v_cache_count + 1
    self._cache_time = self:CalcCacheTime(self.v_use_times)
    self.v_cache_gos[game_obj] = Status.NowUnScaleTime + self._cache_time

    game_obj:SetActive(false)
    game_obj.transform:SetParent(self.v_root, false)

    return true
end

function GameObjPool:CalcCacheTime(use_times)
    local cache_time = 0
    if self.v_release_policy == ResPoolReleasePolicy.NotDestroy then
        cache_time = 999999999
    elseif IsLowMemorySystem then
        cache_time = 10
    else
        cache_time = 15 + (use_times / 20) * 60
        if cache_time > 60 then
            cache_time = 60
        end
    end
    return cache_time
end

function GameObjPool:GetGameObjIsCache(go)
    return self.v_cache_gos[go] ~= nil
end

function GameObjPool:ReleaseInObjId(ins_id)
    if not self.v_is_valid_pool then
        print_error("[GameObjPool] pool is invalid!")
        return false
    end

    self.v_ref_count = self.v_ref_count - 1
    if self.v_ref_count < 0 then
        print_error("[GameObjPool] ref count less 0!")
        return false
    end

    return true
end

function GameObjPool:TryPop()
    if not self.v_is_valid_pool then
        print_error("[GameObjPool] pool is invalid!")
        return
    end

    self.v_ref_count = self.v_ref_count + 1

    if self.v_cache_count <= 0 then
        return
    end

    local game_obj = next(self.v_cache_gos)
    game_obj:SetActive(true)

    if self._original_transform_info then
        game_obj.transform.localPosition = self._original_transform_info[1]
        game_obj.transform.localRotation = self._original_transform_info[2]
        game_obj.transform.localScale = self._original_transform_info[3]
    else
        game_obj.transform.localPosition = localPosition
        game_obj.transform.localRotation = localRotation
        game_obj.transform.localScale = localScale
    end

    self.v_cache_gos[game_obj] = nil
    self.v_cache_count = self.v_cache_count - 1
    self.v_use_times = self.v_use_times + 1

    return game_obj
end

function GameObjPool:Update(now_time)
    if not self.v_is_valid_pool then
        return
    end

    local flag = false
    for k, v in pairs(self.v_cache_gos) do
        if now_time >= v then
            flag = true
            self.v_cache_count = self.v_cache_count - 1
            self.v_cache_gos[k] = nil
            ResMgr.Instance:__Destroy(k)
            break
        end
    end

    if flag and self.v_cache_count <= 0 and self.v_ref_count <= 0 then
        self.v_is_valid_pool = false
    end

    return not self.v_is_valid_pool
end

function GameObjPool:Clear()
    local flag = false
    for k, v in pairs(self.v_cache_gos) do
        flag = true
        ResMgr.Instance:__Destroy(k)
    end

    self.v_cache_gos = {}
    self.v_cache_count = 0
    self.v_use_times = 0

    if flag and self.v_cache_count <= 0 and self.v_ref_count <= 0 then
        self.v_is_valid_pool = false
    end

    return not self.v_is_valid_pool
end

function GameObjPool:OnDestroy()
    self:Clear()
end

function GameObjPool:GetDebugStr()
    return string.format("%s    count=%s\n", self.full_path, self.v_cache_count)
end