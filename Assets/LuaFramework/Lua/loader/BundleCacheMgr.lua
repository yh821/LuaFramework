---
--- Created by Hugo
--- DateTime: 2023/5/9 22:42
---

---@class BundleCacheMgr : BaseClass
BundleCacheMgr = BundleCacheMgr or BaseClass()

function BundleCacheMgr:__init()
    if BundleCacheMgr.Instance then
        print_error("[CtrlManager] attempt to create singleton twice!")
        return
    end
    BundleCacheMgr.Instance = self

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

function BundleCacheMgr:__delete()
    self:Clear()
    BundleCacheMgr.Instance = nil
end

function BundleCacheMgr:Clear()
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
        self.v_caches[v] = nil
    end
end

function BundleCacheMgr:Update(now_time, delta_time)
    if now_time - self.last_sweep_time < 0.1 then
        return
    end

    self.last_sweep_time = now_time
    for k, v in pairs(self.v_caches) do
        if self.bundle_lock_num[k]
                and (self.v_refs[k] == nil or self.v_refs[k] <= 0)
                and (self.v_last_del_times[k] or now_time - self.v_last_del_times[k] >= self:GetCacheTime(k))
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

function BundleCacheMgr:SetOverrideCacheTime(bundle_name, cache_time)
    if IsNilOrEmpty(bundle_name) or cache_time == nil then
        print_error("[BundleCacheMgr]SetOverrideCacheTime, param is invalid:", bundle_name, cache_time)
        return
    end
    self.v_override_cache_times[bundle_name] = cache_time
    local deps = ResMgr.Instance:GetBundleDeps(bundle_name)
    if deps then
        for _, v in pairs(deps) do
            self.v_override_cache_times[v] = cache_time
        end
    end
end

--获取缓存时间(根据引用数量计算最长60秒)
function BundleCacheMgr:GetCacheTIme(bundle_name)
    local cache_time = 5
    if self.v_override_cache_times[bundle_name] then
        cache_time = self.v_override_cache_times[bundle_name]
    elseif self.v_max_refs[bundle_name] then
        cache_time = cache_time + self.v_max_refs[bundle_name] / 20 * 60
        if cache_time > 60 then
            cache_time = 60
        end
    end
    return cache_time
end

--是否所有引用都已释放
function BundleCacheMgr:IsRefersAllBeUnload(bundle_name)
    local refers = self.v_ab_refers_map[bundle_name]
    if refers then
        for i, v in pairs(refers) do
            if self.v_caches[v] then
                return false
            end
        end
    end
    return true
end

function BundleCacheMgr:IsBundleRefing(bundle_name)
    if self.v_caches[bundle_name] and self.v_refs[bundle_name] and self.v_refs[bundle_name] > 0 then
        return true
    end
    return false
end

function BundleCacheMgr:GetCacheRes(bundle_name)
    if self.bundle_lock_num[bundle_name] == nil then
        print_error("[BundleCacheMgr]GetCacheRes, the bundle is not lock:", bundle_name)
    end
    return self.v_caches[bundle_name]
end

function BundleCacheMgr:CacheRes(bundle_name, bundle)
    if bundle == nil then
        print_error("[BundleCacheMgr]CacheRes, cache bundle is nil:", bundle_name)
        return
    end
    if self.v_caches[bundle_name] then
        print_error("[BundleCacheMgr]CacheRes, cache bundle repeat:", bundle_name)
        return
    end
    self.v_caches[bundle_name] = AssetBundle.New(bundle)
end

--使用AssetBundle时所有依赖包+1
local is_refer_loop = false
function BundleCacheMgr:OnUseBundle(bundle_name)
    self:AddRef(bundle_name)
    local deps = ResMgr.Instance:GetBundleDeps(bundle_name)
    if deps then
        for _, dep in ipairs(deps) do
            is_refer_loop = false
            self:AddRefer(bundle_name, dep, 0)
            self:AddRef(dep)

            if IS_DEBUG_BUILD and is_refer_loop then
                self:DebugLogBundleLoopDepend(bundle_name, dep)
            end
        end
    end
end

function BundleCacheMgr:AddRefer(parent_bundle, depend_bundle, depth)
    depth = depth + 1
    if depth > 30 then
        is_refer_loop = true
        return
    end

    self.v_ab_refers_map[depend_bundle] = self.v_ab_refers_map[depend_bundle] or {}
    self.v_ab_refers_map[depend_bundle][parent_bundle] = parent_bundle

    local deps = ResMgr.Instance:GetBundleDeps(depend_bundle)
    if deps then
        for _, dep in ipairs(deps) do
            self:AddRefer(depend_bundle, dep, depth)
        end
    end
end

local debug_looped_bundle_map = {}
function BundleCacheMgr:DebugLogBundleLoopDepend(parent_bundle, child_bundle)
    local stack = {}
    local map = { [parent_bundle] = true }
    local looped_bundle
    local search
    search = function(depend_bundle, depth)
        depth = depth + 1
        if depth > 30 then
            return
        end

        table.insert(stack, depend_bundle)
        if map[depend_bundle] then
            looped_bundle = depend_bundle
            return true
        end

        map[depend_bundle] = true

        local deps = ResMgr.Instance:GetBundleDeps(depend_bundle)
        if deps then
            for _, dep in ipairs(deps) do
                if search(dep, depth) then
                    return true
                end
            end
        end

        table.remove(stack)
        map[depend_bundle] = false
    end
    search(child_bundle, 0)
    if not debug_looped_bundle_map[looped_bundle] then
        debug_looped_bundle_map[looped_bundle] = true

        local flag = false
        local str = ""
        for i, v in ipairs(stack) do
            if flag then
                str = str .. " -> " .. v
            end
            if v == looped_bundle and not flag then
                flag = true
                str = str .. looped_bundle
            end
        end
        print_error("[BundleCacheMgr]AB包出现环引用:", str)
    end
end

function BundleCacheMgr:OnUnUseBundle(bundle_name)
    self:DelRef(bundle_name)
    local deps = ResMgr.Instance:GetBundleDeps(depend_bundle)
    if deps then
        for _, dep in ipairs(deps) do
            self:DelRef(dep)
        end
    end
end

function BundleCacheMgr:AddRef(bundle_name)
    local ref = (self.v_refs[bundle_name] or 0) + 1
    self.v_refs[bundle_name] = ref
    self.v_max_refs[bundle_name] = math.max(self.v_max_refs[bundle_name] or 0, ref)
    self.v_last_del_times[bundle_name] = nil
    self.v_last_use_times[bundle_name] = Status.NowUnScaleTime
end

function BundleCacheMgr:DelRef(bundle_name)
    local ref = self.v_refs[bundle_name]
    if ref == nil then
        return
    end

    if ref <= 0 then
        print_error("[BundleCacheMgr]DelRef, ref less 0:", bundle_name, ref)
    end

    self.v_refs[bundle_name] = self.v_refs[bundle_name] - 1
    self.v_last_del_times[bundle_name] = Status.NowUnScaleTime
end

function BundleCacheMgr:LockBundles(bundle_list)
    for _, v in ipairs(bundle_list) do
        self.bundle_lock_num[v] = (self.bundle_lock_num[v] or 0) + 1
    end
end

function BundleCacheMgr:UnLockBundles(bundle_list)
    for _, v in ipairs(bundle_list) do
        local num = (self.bundle_lock_num[v] or 0) - 1
        self.bundle_lock_num[v] = num
        if num == 0 then
            self.bundle_lock_num[v] = nil
        elseif num < 0 then
            print_error("[BundleCacheMgr]UnLockBundles, lock_num less 0:", v, num)
        end
    end
end

---------------------------------------------------------debug----------------------------------------------------------

function BundleCacheMgr:CheckAssetBundleLeak()
    local content = {}
    for k, v in pairs(self.v_last_use_times) do
        if self.v_refs[k] > 0 then
            local ref = self.v_refs[k]
            local timer = math.floor(Status.NowUnScaleTime - v)
            table.insert(content, {
                text = string.format("ref=%s, last_use=%s, %s, %s\n", ref, timer, k, self.v_caches[k] ~= nil),
                timer = timer,
                ref = ref
            })
        end
    end

    SortTools.SortDesc(content, "timer", "ref")
    local str = ""
    local tbl = {}
    for i, v in pairs(content) do
        table.insert(tbl, v.text)
    end
    str = table.concat(tbl)
    return str
end

function BundleCacheMgr:CheckAssetBundleDetailLeak()
    local tbl = {}
    for k, v in pairs(self.v_last_use_times) do
        if self.v_refs[k] > 0 then
            local sb = {}
            local lookup = {}
            self:GetAssetBundleRefInfo(k, sb, 0, lookup)
            if #sb > 0 then
                for _, s in ipairs(sb) do
                    table.insert(tbl, s)
                    table.insert(tbl, '\n')
                end
                table.insert(tbl, '\n')
            end
        end
    end

    return table.concat(tbl)
end

function BundleCacheMgr:CacheBundleRefDetail(bundle_name, refer)
    if bundle_name == refer then
        return
    end
    local refers = self.v_ref_bundle_detail_dic[bundle_name]
    if refers == nil then
        refers = {}
        self.v_ref_bundle_detail_dic[bundle_name] = refers
    end
    refers[refer] = true
end

function BundleCacheMgr:GetAssetBundleRefInfo(bundle_name, sb, depth, lookup)
    local indent = ""
    for i = 0, depth do
        indent = indent .. "    "
    end

    local begin = string.find(bundle_name, "Asset")
    if begin then
        table.insert(sb, indent .. bundle_name)
        return
    end

    local refers = self.v_ref_bundle_detail_dic[bundle_name]
    if refers == nil then
        return
    end

    local ref_count = self.v_refs[bundle_name] or 0
    lookup[bundle_name] = true
    local elapse_time = math.floor(Status.NowUnScaleTime - (self.v_last_use_times[bundle_name] or Status.NowUnScaleTime))
    local show_bundle_name = bundle_name
    if depth == 0 then
        show_bundle_name = "[AB]" .. bundle_name
    end

    table.insert(sb, string.format("%s%s, ref=%s, last_use_time=%ss", indent, show_bundle_name, ref_count, elapse_time))

    for k, v in pairs(refers) do
        if lookup[k] then
            print_error("[BundleCacheMgr]AB包出现环引用:", bundle_name, "=>", k)
        else
            self:GetAssetBundleRefInfo(k, sb, depth + 1, lookup)
        end
    end

    lookup[bundle_name] = nil
end

function BundleCacheMgr:GetBundleCount(t)
    t.bundle_count = 0
    for i, v in pairs(self.v_caches) do
        t.bundle_count = t.bundle_count + 1
    end
end

function BundleCacheMgr:GetBundleRef(bundle_name)
    local ref_count = self.v_refs[bundle_name] or 0
    local detail_content = ""
    if ref_count > 1 then
        local refers = self.v_ab_refers_map[bundle_name]
        if refers then
            local sb = {}
            for k, _ in pairs(refers) do
                if self.v_caches[k] then
                    table.insert(sb, "\t" .. k)
                end
            end
            detail_content = table.concat(sb)
        end
    end
    return ref_count, detail_content
end