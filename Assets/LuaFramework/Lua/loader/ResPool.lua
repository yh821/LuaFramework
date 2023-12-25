---
--- Created by Hugo
--- DateTime: 2023/5/13 18:51
---

require("loader/ObjPool")

---@class ResPool : ObjPool
ResPool = ResPool or BaseClass(ObjPool)

function ResPool:__init(bundle_name)
    self.v_bundle_name = bundle_name
    self.v_asset_count = 0
    self.v_asset_dict = {}
    self.v_instance_id_map = {}
    self.v_wait_unload_t = {}

    self.v_is_valid_pool = true;
    ResMgr.Instance:UseBundle(bundle_name)

    if IS_CHECK_GRAPHIC_MEMORY then
        self.used_res_instance_id_map = {}
    end
end

function ResPool:GetAssetCount()
    return self.v_asset_count
end

function ResPool:CacheRes(asset_name, asset)
    if not self.v_is_valid_pool then
        print_error("[ResPool]CacheRes, the pool is invalid!!!")
        return
    end

    if asset == nil then
        print_error("[ResPool]CacheRes, asset is nil:", asset_name)
        return
    end

    if self.v_asset_dict[asset_name] then
        print_error("[ResPool]CacheRes, asset is repeat cache, because asset_name exits:", asset_name)
        return
    end

    if self.v_instance_id_map[asset:GetInstanceID()] then
        print_error("[ResPool]CacheRes, asset is repeat cache, because asset exits:", asset_name)
        return
    end

    if not ResMgr.Instance:IsCanSafeUseBundle(self.v_bundle_name) then
        print_error("[ResPool]CacheRes, bundle is invalid:", self.v_bundle_name, asset_name)
        return
    end

    self.v_asset_count = self.v_asset_count + 1
    self.v_asset_dict[asset_name] = { asset = asset, ref_count = 0, use_times = 0, asset_name = asset_name }
    self.v_instance_id_map[asset:GetInstanceID()] = asset_name
    self.v_wait_unload_t[asset_name] = Status.NowUnScaleTime + 15

    if IS_CHECK_GRAPHIC_MEMORY then
        self.used_res_instance_id_map[asset:GetInstanceID()] = asset_name
    end
end

function ResPool:ScanRes(asset_name)
    if self.v_asset_dict[asset_name] then
        return self.v_asset_dict[asset_name].asset
    end
end

function ResPool:GetRes(asset_name)
    if not self.v_is_valid_pool then
        print_error("[ResPool]GetRes, the pool is invalid!!!")
        return
    end

    local t = self.v_asset_dict[asset_name]
    if t == nil then
        return
    end

    if not ResMgr.Instance:IsCanSafeUseBundle(self.v_bundle_name) then
        print_error("[ResPool]GetRes, bundle is invalid:", self.v_bundle_name, asset_name)
        return
    end

    t.ref_count = t.ref_count + 1
    t.use_times = t.use_times + 1

    self.v_wait_unload_t[asset_name] = nil
    return t.asset
end

function ResPool:Release(asset, release_policy)
    if not self.v_is_valid_pool then
        print_error("[ResPool]Release, the pool is invalid!!!")
        return false
    end

    if asset == nil then
        print_error("[ResPool]Release, asset is nil:", self.v_bundle_name)
        return false
    end

    return self:ReleaseInObjId(asset:GetInstanceID(), release_policy)
end

function ResPool:ReleaseInObjId(instance_id, release_policy)
    if not self.v_is_valid_pool then
        print_error("[ResPool]ReleaseInObjId, the pool is invalid!!!")
        return false
    end

    local asset_name = self.v_instance_id_map[instance_id]
    if asset_name == nil then
        print_error("[ResPool]ReleaseInObjId, asset is not exits:", asset_name)
        return false
    end

    local t = self.v_asset_dict[asset_name]
    t.ref_count = t.ref_count - 1
    if t.ref_count > 0 then
        return false
    end

    if t.ref_count < 0 then
        print_error("[ResPool]ReleaseInObjId, ref_count is less 0!!!")
        return true
    end

    self.v_release_policy = release_policy or ResPoolReleasePolicy.Default
    self.v_wait_unload_t[asset_name] = Status.NowUnScaleTime + self:GetCacheTime(t.use_times)

    return true
end

--根据使用次数来控制释放时间，有些使用次数少的可以快些释放
function ResPool:GetCacheTime(use_times)
    local cache_time = 0
    if self._release_policy == ResPoolReleasePolicy.DestroyQuick then
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

function ResPool:Update(now_time)
    if not self.v_is_valid_pool then
        return false
    end

    local flag = false
    for k, v in pairs(self.v_wait_unload_t) do
        if now_time >= v then
            local t = self.v_asset_dict[k]
            self.v_asset_dict[k] = nil
            if t and t.asset then
                self.v_instance_id_map[t.asset:GetInstanceID()] = nil
            else
                print_error("[ResPool]Update, not found asset:", k)
            end

            self.v_asset_count = self.v_asset_count - 1
            self.v_wait_unload_t[k] = nil
            flag = true
        end
    end

    --池里的所有资源引用为0时，将释放该AB的引用
    if flag and self.v_asset_count <= 0 then
        if self.v_asset_count < 0 then
            print_error("[ResPool]Delete, v_asset_count less 0!!!")
        end

        self.v_is_valid_pool = false
        if self.v_release_policy == ResPoolReleasePolicy.DestroyQuick then
            BundleCacheMgr.Instance:SetOverrideCacheTime(self.v_bundle_name, 0)
        end
        ResMgr.Instance:ReleaseBundle(self.v_bundle_name)
    end

    return not self.v_is_valid_pool
end

function ResPool:Clear()
    for k, v in pairs(self.v_wait_unload_t) do
        local t = self.v_asset_dict[k]
        self.v_asset_dict[k] = nil
        if t and t.asset then
            self.v_instance_id_map[t.asset:GetInstanceID()] = nil
        else
            print_error("[ResPool]Delete, not found asset:", k)
        end

        self.v_asset_count = self.v_asset_count - 1

        if self.v_asset_count <= 0 then
            if self.v_asset_count < 0 then
                print_error("[ResPool]Delete, v_asset_count less 0!!!")
            end

            ResMgr.Instance:ReleaseBundle(self.v_bundle_name)
            self.v_is_valid_pool = false
            break
        end
    end

    self.v_wait_unload_t = {}
    return not self.v_is_valid_pool
end

function ResPool:GetDebugStr()
    local debug_str = string.format("[%s]\n", self.v_bundle_name)
    for i, v in pairs(self.v_asset_dict) do
        debug_str = debug_str .. string.format("asset_name=%s ref=%s \n", v.asset_name, v.ref_count)
    end
    debug_str = debug_str .. "\n"
    return debug_str
end

function ResPool:GetResInstanceIDs()
    local list = {}
    if IS_CHECK_GRAPHIC_MEMORY then
        for id, _ in pairs(self.used_res_instance_id_map) do
            table.insert(list, id)
        end
    end
    return list
end

function ResPool:GetResRefCount(instance_id)
    local asset_name
    if IS_CHECK_GRAPHIC_MEMORY then
        asset_name = self.used_res_instance_id_map[instance_id]
        if asset_name then
            local t = self.v_asset_dict[asset_name]
            if t then
                return t.ref_count, asset_name, self.v_asset_count
            end
        end
    end
    return 0, asset_name, self.v_asset_count
end

function ResPool:GetAllRes()
    local list = {}
    for asset_name, info in pairs(self.v_asset_dict) do
        list[asset_name] = info.ref_count
    end
    return list
end