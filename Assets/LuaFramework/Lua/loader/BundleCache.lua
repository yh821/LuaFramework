---
--- Created by Hugo
--- DateTime: 2023/5/9 22:42
---

---@class BundleCache : BaseClass
BundleCache = BundleCache or BaseClass()

function BundleCache:__init()
    self.last_sweep_time = 0
    self.v_override_cache_times = {}
    self.v_caches = {}
    self.v_refs = {}
    self.v_max_refs = {}
    self.v_last_del_times = {}
    self.v_last_use_times = {}
    self.v_ref_bundle_detail_dic = {}
    self.bundle_lock_num = {}
    self.v_ab_refers_map = {}
end

function BundleCache:__delete()
    local del_list = {}
    for k, v in pairs(self.v_caches) do
        if self.bundle_lock_num[k] == nil and (self.v_refs[k] == nil or self.v_refs[k] <= 0) then
            local bundle = self.v_caches[k]
            self.v_refs[k] = nil
            self.v_max_refs[k] = nil
            self.v_last_del_times[k] = nil
            self.v_last_use_times[k] = nil
            self.v_ref_bundle_detail_dic[k] = nil
            bundle:Unload(true)
            table.insert(del_list, k)
        end
    end

    for k, v in pairs(del_list) do
        self.v_caches[v] = nul
    end
end

function BundleCache:Update(time, delta_time)
    if time - self.last_sweep_time < 0.1 then
        return
    end

    self.last_sweep_time = time
    for k, v in pairs(self.v_caches) do
        if self.bundle_lock_num[k]
                and (self.v_refs[k] == nil or self.v_refs[k] <= 0)
                and (self.v_last_del_times[k] or time - self.v_last_del_times[k] >= self:GetCacheTime(k))
                and self:IsRefersAllBeUnload(k) then
            if IS_DEBUG_BUILD then
                print_log("[BundleCache]Unload", k, self:GetCacheTime(k))
            end
            local bundle = self.v_caches[k]
            self.v_caches[k] = nil
            self.v_refs[k] = nil
            self.v_max_refs[k] = nil
            self.v_last_del_times[k] = nil
            self.v_last_use_times[k] = nil
            self.v_override_cache_times[k] = nil
            bundle:Unload(true)
            break
        end
    end
end

function BundleCache:SetOverrideCacheTime(bundle_name, cache_time)
    if IsNilOrEmpty(bundle_name) or cache_time == nil then
        return
    end
    self.v_override_cache_times[bundle_name] = cache_time
    local deps = ResMgr:GetBundleDeps(bundle_name)
    if deps then
        for _, v in pairs(deps) do
            self.v_override_cache_times[v] = cache_time
        end
    end
end

function BundleCache:LockBundles(need_loads)

end

function BundleCache:UnLockBundles(need_loads)

end