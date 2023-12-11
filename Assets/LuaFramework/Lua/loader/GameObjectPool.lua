---
--- Created by Hugo
--- DateTime: 2023/5/9 20:12
---

---@class GameObjectPool : ObjPool
GameObjectPool = GameObjectPool or BaseClass(ObjPool)

local localPosition = Vector3(0, 0, 0)
local localRotation = Quaternion.Euler(0, 0, 0)
local localScale = Vector3(0, 0, 0)

function GameObjectPool:__init(root, path)
    self._root = root
    self.path = path or "none"

    self._cache_count = 0
    self._cache_gos = {}

    self._original_transform_info = nil
    self._cache_time = 0
    self._use_times = 0
    self._ref_count = 0
    self._is_valid_pool = true
    self._release_policy = ResPoolReleasePolicy.Default
end

function GameObjectPool:__delete()
end

function GameObjectPool:CacheOriginalTransformInfo(prefab)
    if IsNil(prefab) then
        return
    end
    if self._original_transform_info == nil then
        self._original_transform_info = { prefab.transform.localPosition, prefab.transform.localRotation, prefab.transform.localScale }
    end
end

function GameObjectPool:GetCacheCount()
    return self._ref_count
end

function GameObjectPool:Release(game_obj, policy)
    if not self._is_valid_pool then
        ResManager.Instance:__Destroy(game_obj, policy)
        return false
    end

    self._ref_count = self._ref_count - 1
    if self._ref_count < 0 then
        print_error("[GameObjPool] ref count less 0!")
        return false
    end

    if self._ref_count >= 64 then
        ResManager.Instance:__Destroy(game_obj, policy)
        return true
    end

    self._release_policy = policy or ResPoolReleasePolicy.Default
    self._cache_count = self._cache_count + 1
    self._cache_time = self:CalcCacheTime(self._use_times)
    self._cache_gos[game_obj] = Status.NowUnScaleTime + self._cache_time

    game_obj:SetActive(false)
    game_obj.transform:SetParent(self._root, false)

    return true
end

function GameObjectPool:CalcCacheTime(use_times)
    local cache_time = 0
    if self._release_policy == ResPoolReleasePolicy.NotDestroy then
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

function GameObjectPool:GetGameObjIsCache(go)
    return self._cache_gos[go] ~= nil
end

function GameObjectPool:ReleaseInObjId(ins_id)
    if not self._is_valid_pool then
        print_error("[GameObjPool] pool is invalid!")
        return false
    end

    self._ref_count = self._ref_count - 1
    if self._ref_count < 0 then
        print_error("[GameObjPool] ref count less 0!")
        return false
    end

    return true
end

function GameObjectPool:TryPop()
    if not self._is_valid_pool then
        print_error("[GameObjPool] pool is invalid!")
        return
    end

    self._ref_count = self._ref_count + 1

    if self._cache_count <= 0 then
        return
    end

    local game_obj = next(self._cache_gos)
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

    self._cache_gos[game_obj] = nil
    self._cache_count = self._cache_count - 1
    self._use_times = self._use_times + 1

    return game_obj
end

function GameObjectPool:Update(now_time)
    if not self._is_valid_pool then
        return
    end

    local flag = false
    for k, v in pairs(self._cache_gos) do
        if now_time >= v then
            flag = true
            self._cache_count = self._cache_count - 1
            self._cache_gos[k] = nil
            ResManager.Instance:__Destroy(k)
            break
        end
    end

    if flag and self._cache_count <= 0 and self._ref_count <= 0 then
        self._is_valid_pool = false
    end

    return not self._is_valid_pool
end

function GameObjectPool:Clear()
    local flag = false
    for k, v in pairs(self._cache_gos) do
        flag = true
        ResManager.Instance:__Destroy(k)
    end

    self._cache_gos = {}
    self._cache_count = 0
    self._use_times = 0

    if flag and self._cache_count <= 0 and self._ref_count <= 0 then
        self._is_valid_pool = false
    end

    return not self._is_valid_pool
end

function GameObjectPool:OnDestroy()
    self:Clear()
end

function GameObjectPool:GetDebugStr()
    return string.format("%s    count=%s\n", self.full_path, self._cache_count)
end