---
--- Created by Hugo
--- DateTime: 2023/5/13 18:51
---

---@class ResPool : ObjPool
ResPool = ResPool or BaseClass(ObjPool)

function ResPool:__init()
end

function ResPool:__delete()
end

function ResPool:CacheRes(asset, obj)

end

function ResPool:Release(obj, policy)
    if not self._is_valid_pool then
        return false
    end
    if obj == nil then
        return false
    end

    return self:ReleaseInObjId(obj:GetInstanceID(), policy)
end

function ResPool:ReleaseInObjId(id, policy)
    if not self._is_valid_pool then
        return false
    end

    local asset = self._id_name_map[id]
    if asset == nil then
        return false
    end

    local t = self._asset_dic[asset]
    t.ref_count = t.ref_count - 1
    if t.ref_count > 0 then
        return false
    end

    if t.ref_count < 0 then
        return true
    end

    self._release_policy = policy or ResPoolReleasePolicy.default
    self._wait_unload_t[asset] = Status.NowUnScaleTime + self:GetCacheTime(t.use_times)

    return true
end

function ResPool:GetCacheTime(use_times)
    local cache_time = 0
    if self._release_policy == ResPoolReleasePolicy.destroy then
        cache_time = 0
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
