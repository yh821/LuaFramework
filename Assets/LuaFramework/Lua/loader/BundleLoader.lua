---
--- Created by Hugo
--- DateTime: 2023/9/15 10:35
---

require("loader/LoaderBase")

---@class BundleLoader : LoaderBase
---@field super LoaderBase
BundleLoader = BundleLoader or BaseClass(LoaderBase)

local SysFile = System.IO.File
local isDebugBuild = UnityEngine.Debug.isDebugBuild
local UnityGameObject = UnityEngine.GameObject
local UnityDestroy = UnityGameObject.Destroy
local UnityLoadSceneSync = UnityEngine.SceneManagement.SceneManager.LoadScene
local UnityLoadSceneAsync = UnityEngine.SceneManagement.SceneManager.LoadSceneAsync

local _luaab_lua = "LuaAssetBundle/LuaAssetBundle.lua"
local _temp_luaab_lua = "LuaAssetBundle/Temp/LuaAssetBundle.lua"
local _luaab_zip = "LuaAssetBundle/LuaAssetBundle.zip"
local _temp_luaab_zip = "LuaAssetBundle/Temp/LuaAssetBundle.zip"

local MAX_INSTANTIATE_COUNT = 4

local _lua_asset_bundles = { "^lua/.*", "^luajit32/.*", "^luajit64/.*" }
local function IsLuaAssetBundle(bundle_name)
    for i, v in ipairs(_lua_asset_bundles) do
        if string.match(bundle_name, v) then
            return true
        end
    end
    return false
end

function BundleLoader:__init()
    self.v_lua_manifest_info = { bundleInfos = {} }
    self.v_manifest_info = { bundleInfos = {} }
    self.v_goid_prefab_map = {}
    self.v_goid_go_monitors = {}
    self.v_goid_go_monitor_time = 0

    self.load_priority_type_list = {
        ResLoadPriority.sync,
        ResLoadPriority.ui_high,
        ResLoadPriority.ui_mid,
        ResLoadPriority.ui_low,
        ResLoadPriority.high,
        ResLoadPriority.mid,
        ResLoadPriority.low,
        ResLoadPriority.steal
    }

    self.load_priority_count_list = { 1, 1, 1, 1, 0.9, 0.7, 0.1, 0 }

    self.v_instantiate_count = 0
    self.v_priority_instantiate_queue = {}
    self.v_log_list = {}

    for i, v in ipairs(self.load_priority_type_list) do
        self.v_priority_instantiate_queue[v] = {}
    end
end

function BundleLoader:__delete()
end

function BundleLoader:Update(now_time, delta_time)
    BundleLoader.super.Update(self, now_time, delta_time)
    self:__UpdateInstantiate()
    AssetBundleMgr.Instance:Update()
    DownloadMgr.Instance:Update()
    self:MonitorGameObjLive(now_time)
end

function BundleLoader:IsBundleMode()
    return true
end

function BundleLoader:GetPrefab(instance_id)
    return self.v_goid_prefab_map[instance_id]
end

function BundleLoader:OnHotUpdateLuaComplete()
    local src = ResUtil.GetCachePath(_temp_luaab_lua)
    local dst = ResUtil.GetCachePath(_luaab_lua)
    local need_restart = self:NeedRestart(src, dst)
    if SysFile.Exists(src) then
        SysFile.Copy(src, dst, true)
        SysFile.Delete(src)
    end
    return need_restart
end

function BundleLoader:NeedRestart(src, dst)
    if not SysFile.Exists(dst) then
        local manifest = self:getPackageLuaManifest()
        if manifest then
            return manifest.manifestHashCode ~= self.v_lua_manifest_info.manifestHashCode
        else
            print_error("[BundleLoader] manifest is nil!")
            return false
        end
    end

    local text = SysFile.ReadAllText(dst)
    if text == nil then
        return true
    end

    local data = loadstring(text)
    if data == nil then
        return true
    end

    local manifest = data()
    if manifest == nil then
        return true
    end

    return manifest.manifestHashCode ~= self.v_lua_manifest_info.manifestHashCode
end

function BundleLoader:GetPackageLuaManifest()
    local text = ResUtil.LoadApkFileHelper(_luaab_lua)
    if text == nil then
        return
    end

    local data = loadstring(text)
    if data == nil then
        return
    end

    local manifest = data()
    if manifest == nil then
        return
    end

    return manifest
end

function BundleLoader:LoadRemoteLuaManifest(callback)
    local remote_path = self:GetRemotePath(_luaab_zip, self.v_asset_lua_version) or ""
    local cache_path = ResUtil.GetCachePath(_temp_luaab_zip)
    print_log("[BundleLoader] remote lua manifest path:", remote_path)
    self:PushLogList("[BundleLoader] LoadRemoteLuaManifest, " .. remote_path)
    DownloadMgr.Instance:CreateFileDownloader(remote_path, nil, function(err, request)
        if not IsNilOrEmpty(err) then
            self:PushLogList("[BundleLoader] LoadRemoteLuaManifest Fail, " .. remote_path)
            callback(err)
            return
        end

        self:PushLogList("[BundleLoader] LoadRemoteLuaManifest Success, " .. remote_path)

        local is_unzip_succ = false
        local is_load_succ = false
        local is_version_match = false
        local is_project_match = false

        local temp_dir = ResUtil.GetCachePath("LuaAssetBundle/Temp")
        ZipUtil.UnZip(cache_path, temp_dir, function()
            is_unzip_succ = true
            self:PushLogList("[BundleLoader] LoadRemoteLuaManifest, Unzip Success!")

            --zipFile是加密过的，而里面的name没加密，这里做个拷贝
            if ResUtil.is_ios_encrypt_asset then
                local src = temp_dir .. "/LuaAssetBundle.lua"
                local dst = ResUtil.GetCachePath(_temp_luaab_lua)
                SysFile.Copy(src, dst, true)
            end

            is_load_succ = self:LoadLocalLuaManifest(_temp_luaab_lua)
            if is_load_succ then
                is_version_match = self:CheckVersion(self.v_lua_manifest_info.manifestHashCode)
                if is_version_match then
                    is_project_match = self:CheckProjectName(self.v_lua_manifest_info.projectName)
                end
            end
        end)

        if not is_unzip_succ then
            err = "[BundleLoader] LoadRemoteLuaManifest, unzip fail, " .. cache_path .. ", " .. temp_dir
        elseif not is_load_succ then
            err = "[BundleLoader] LoadRemoteLuaManifest, load local manifest fail!"
        elseif not is_version_match then
            err = "[BundleLoader] LoadRemoteLuaManifest, version is not match!"
        elseif not is_project_match then
            err = "[BundleLoader] LoadRemoteLuaManifest, projectName is not match!"
        end

        if not IsNilOrEmpty(err) then
            print_error(err)
            self:PrintLogList()
        end

        callback(err)

    end, cache_path)
end

--在线热更专用
function BundleLoader:RuntimeLoadRemoteLuaManifest(callback)
    local remote_path = self:GetRemotePath(_luaab_zip, self.v_asset_lua_version)
    local cache_path = ResUtil.GetCachePath(_temp_luaab_zip)
    print_log("[BundleLoader] remote lua manifest path:", remote_path)
    DownloadMgr.Instance:CreateFileDownloader(remote_path, nil, function(err, request)
        if IsNilOrEmpty(err) then
            local temp_dir = ResUtil.GetCachePath("LuaAssetBundle/Temp")
            ZipUtil.UnZip(cache_path, temp_dir, function()
                --zipFile是加密过的，而里面的name没加密，这里做个拷贝
                if ResUtil.is_ios_encrypt_asset then
                    local src = temp_dir .. "/LuaAssetBundle.lua"
                    local dst = ResUtil.GetCachePath(_temp_luaab_lua)
                    SysFile.Copy(src, dst, true)
                end
                self:LoadLocalLuaManifest(_temp_luaab_lua)
            end)
        end
        callback(err, request)
    end, cache_path)
end

function BundleLoader:LoadRemoteManifest(name, callback)
    local name_zip = name .. ".zip"
    local name_lua = name .. ".lua"

    local remote_path = self:GetRemotePath(name_zip, self.v_asset_version) or ""
    local cache_path = ResUtil.GetCachePath(name_zip)

    print_log("[BundleLoader] remote manifest path:", remote_path)
    self:PushLogList("[BundleLoader] LoadRemoteManifest, " .. remote_path)
    DownloadMgr.Instance:CreateFileDownloader(remote_path, nil, function(err, request)
        if not IsNilOrEmpty(err) then
            self:PushLogList("[BundleLoader] LoadRemoteManifest Fail, " .. remote_path)
            callback(err)
            return
        end

        self:PushLogList("[BundleLoader] LoadRemoteManifest Success, " .. remote_path)

        local is_unzip_succ = false
        local is_load_succ = false
        local is_version_match = false
        local is_project_match = false

        local cache_dir = ResUtil.GetBaseCachePath()
        ZipUtil.UnZip(cache_path, cache_dir, function()
            is_unzip_succ = true
            self:PushLogList("[BundleLoader] LoadRemoteManifest, Unzip Success!")

            --zipFile是加密过的，而里面的name没加密，这里做个拷贝
            if ResUtil.is_ios_encrypt_asset then
                local src = cache_dir .. "/" .. name_lua
                local dst = ResUtil.GetCachePath(name_lua)
                SysFile.Copy(src, dst, true)
            end

            is_load_succ = self:LoadLocalManifest(name_lua)
            if is_load_succ then
                is_version_match = self:CheckVersion(self.v_manifest_info.manifestHashCode)
                if is_version_match then
                    is_project_match = self:CheckProjectName(self.v_manifest_info.projectName)
                end
            end
        end)

        if not is_unzip_succ then
            err = "[BundleLoader] LoadRemoteManifest, unzip fail, " .. cache_path .. ", " .. cache_dir
        elseif not is_load_succ then
            err = "[BundleLoader] LoadRemoteManifest, load local manifest fail!"
        elseif not is_version_match then
            err = "[BundleLoader] LoadRemoteManifest, version is not match!"
        elseif not is_project_match then
            err = "[BundleLoader] LoadRemoteManifest, projectName is not match!"
        end

        if not IsNilOrEmpty(err) then
            print_error(err)
            self:PrintLogList()
        end

        callback(err)

    end, cache_path)
end

function BundleLoader:CheckVersion(version)
    if isDebugBuild or self.v_asset_version == "" then
        return true
    end
    if self.v_asset_version == nil then
        self:PushLogList("[BundleLoader] manifest version is not same, asset_version is nil!")
        return false
    end
    if version == nil then
        self:PushLogList("[BundleLoader] manifest version is not same, version is nil!")
        return false
    end
    if string.find(self.v_asset_version, version) == nil then
        self:PushLogList("[BundleLoader] manifest version is not same, " .. self.v_asset_version .. ", " .. version)
        return false
    end
    return true
end

function BundleLoader:CheckProjectName(project_name)
    local package_project_name = self:GetPackageProjectName()
    if IsNilOrEmpty(package_project_name) then
        return true
    end
    if IsNilOrEmpty(project_name) then
        self:PushLogList("[BundleLoader] project_name is nil!")
        return false
    end
    if project_name == package_project_name then
        self:PushLogList("[BundleLoader] project_name is not same, " .. package_project_name .. ", " .. project_name)
        return false
    end
    return true
end

local _package_project_name
function BundleLoader:GetPackageProjectName()
    if _package_project_name then
        return _package_project_name
    end

    local text = StreamingAssets.ReadAllText("AssetBundle/AssetBundle.lua")
    if text == nil then
        return
    end

    local data = loadstring(text)
    if data == nil then
        return
    end

    local manifest = data()
    if manifest == nil then
        return
    end

    _package_project_name = manifest.projectName or ""
    return _package_project_name
end

function BundleLoader:PushLogList(log)
    table.insert(self.v_log_list, log)
end

function BundleLoader:PrintLogList()
    local log = ""
    for i, v in ipairs(self.v_log_list) do
        log = log .. v .. '\n'
    end
    print_error(log)
end

function BundleLoader:LoadLocalLuaManifest(name)
    print_log("[BundleLoader] load local lua manifest:", name)
    name = name or ""
    local text = ResUtil.LoadFileHelper(name)
    if text == nil then
        self:PushLogList("[BundleLoader] LoadLocalLuaManifest, loadfile fail: " .. name)
        return true
    end

    local data = loadstring(text)
    if data == nil then
        self:PushLogList("[BundleLoader] LoadLocalLuaManifest, loadstring fail: " .. name)
        return false
    end

    local manifest = data()
    if manifest == nil then
        self:PushLogList("[BundleLoader] LoadLocalLuaManifest, execute fail: " .. name)
        return false
    end

    self.v_lua_manifest_info = manifest
    self:PushLogList("[BundleLoader] LoadLocalLuaManifest success: " .. self.v_lua_manifest_info.manifestHashCode)
    return true
end

function BundleLoader:LoadLocalManifest(name)
    print_log("[BundleLoader] load local manifest:", name)
    name = name or ""
    local text = ResUtil.LoadFileHelper(name)
    if text == nil then
        self:PushLogList("[BundleLoader] LoadLocalManifest, loadfile fail: " .. name)
        return true
    end

    local data = loadstring(text)
    if data == nil then
        self:PushLogList("[BundleLoader] LoadLocalManifest, loadstring fail: " .. name)
        return false
    end

    local manifest = data()
    if manifest == nil then
        self:PushLogList("[BundleLoader] LoadLocalManifest, execute fail: " .. name)
        return false
    end

    self.v_manifest_info = manifest
    self:PushLogList("[BundleLoader] LoadLocalManifest success: " .. self.v_manifest_info.manifestHashCode)
    return true
end

function BundleLoader:GetAllLuaManifestBundles()
    return self.v_lua_manifest_info.bundleInfos
end

function BundleLoader:GetLuaBundleHash(bundle_name)
    local infos = self:GetAllLuaManifestBundles()
    if infos[bundle_name] then
        return infos[bundle_name].hash
    end
end

function BundleLoader:GetLuaBundleSize(bundle_name)
    local infos = self:GetAllLuaManifestBundles()
    if infos[bundle_name] then
        return infos[bundle_name].size
    end
    return 0
end

function BundleLoader:GetLuaHashCode()
    return self.v_lua_manifest_info.manifestHashCode
end

function BundleLoader:GetAllManifestBundles()
    return self.v_manifest_info.bundleInfos
end

function BundleLoader:GetBundleDeps(bundle_name)
    local infos = self:GetAllManifestBundles()
    if infos[bundle_name] then
        return infos[bundle_name].deps
    end
end

function BundleLoader:GetBundleHash(bundle_name)
    local infos = self:GetAllManifestBundles()
    if infos[bundle_name] then
        return infos[bundle_name].hash
    end
end

function BundleLoader:GetBundleCRC(bundle_name)
    local infos = self:GetAllManifestBundles()
    if infos[bundle_name] then
        return infos[bundle_name].crc or 0
    end
    return 0
end

function BundleLoader:GetBundleSize(bundle_name)
    local infos = self:GetAllManifestBundles()
    if infos[bundle_name] then
        return infos[bundle_name].size
    end
    return 0
end

function BundleLoader:GetHashCode()
    if self.v_manifest_info.manifestHashCode ~= nil and self.v_lua_manifest_info.manifestHashCode ~= nil then
        return self.v_manifest_info.manifestHashCode .. self.v_lua_manifest_info.manifestHashCode
    end
    return ""
end

--异步加载场景
function BundleLoader:LoadUnitySceneAsync(bundle_name, asset_name, load_mode, callback)
    local need_downloads, need_loads = self:CalcLoadBundleDepends(bundle_name)
    if need_downloads == nil or need_loads == nil then
        callback()
        return
    end

    if ResUtil.memory_debug then
        BundleCacheMgr.Instance:CacheBundleRefDetail(bundle_name, "[Asset]" .. asset_name)
        for _, v in pairs(need_loads) do
            BundleCacheMgr.Instance:CacheBundleRefDetail(v, bundle_name)
        end
    end

    --下载AB
    AssetBundleMgr.Instance:DownLoadBundles(need_downloads, function(is_succ)
        if not is_succ then
            callback()
            return
        end
        BundleCacheMgr.Instance:LockBundles(need_loads)
        --异步加载AB
        AssetBundleMgr.Instance:LoadMultiBundlesAsync(need_loads, function(is_succ)
            if not is_succ then
                BundleCacheMgr.Instance:UnLockBundles(need_loads)
                callback()
                return
            end

            local load_scene_option = UnityLoadSceneAsync(asset_name, load_mode)
            if load_scene_option == nil then
                print_error("[BundleLoader] unity scene is not exists:", bundle_name, asset_name)
                BundleCacheMgr.Instance:UnLockBundles(need_loads)
                callback()
                return
            end

            BundleCacheMgr.Instance:UnLockBundles(need_loads)
            self:UseBundle(bundle_name)
            callback(load_scene_option)
        end, nil, ResLoadPriority.high)
    end, nil, ResLoadPriority.high)
end

--同步加载场景
function BundleLoader:LoadUnitySceneSync(bundle_name, asset_name, load_mode, callback)
    local need_downloads, need_loads = self:CalcLoadBundleDepends(bundle_name)
    if need_downloads == nil or need_loads == nil then
        callback(false)
        return
    end

    if ResUtil.memory_debug then
        BundleCacheMgr.Instance:CacheBundleRefDetail(bundle_name, "[Asset]" .. asset_name)
        for _, v in pairs(need_loads) do
            BundleCacheMgr.Instance:CacheBundleRefDetail(v, bundle_name)
        end
    end

    --下载AB
    AssetBundleMgr.Instance:DownLoadBundles(need_downloads, function(is_succ)
        if not is_succ then
            callback(false)
            return
        end
        BundleCacheMgr.Instance:LockBundles(need_loads)
        --同步加载AB
        AssetBundleMgr.Instance:LoadMultiBundlesSync(need_loads, function(is_succ)
            if not is_succ then
                BundleCacheMgr.Instance:UnLockBundles(need_loads)
                callback(false)
                return
            end

            UnityLoadSceneSync(asset_name, load_mode)
            BundleCacheMgr.Instance:UnLockBundles(need_loads)
            self:UseBundle(bundle_name)
            callback(true)
        end)
    end, nil, ResLoadPriority.sync)
end

local function LoadAssetCallBack(res, cb_data)
    ---@type BundleLoader
    local self = cb_data[CbdIndex.self]
    local bundle_name = cb_data[CbdIndex.bundle]
    local cb = cb_data[CbdIndex.callback]
    local up_cb_data = cb_data[CbdIndex.cb_data]
    local need_loads = cb_data[CbdIndex.need_load]
    CbdPool.ReleaseCbData(cb_data)

    BundleCacheMgr.Instance:UnLockBundles(need_loads)
    cb(res, up_cb_data, bundle_name)
end

local function LoadMultiBundlesCallBack(is_succ, cb_data)
    ---@type BundleLoader
    local self = cb_data[CbdIndex.self]
    local asset_type = cb_data[CbdIndex.type]
    local bundle_name = cb_data[CbdIndex.bundle]
    local asset_name = cb_data[CbdIndex.asset]
    local cb = cb_data[CbdIndex.callback]
    local up_cb_data = cb_data[CbdIndex.cb_data]
    local need_loads = cb_data[CbdIndex.need_load]
    local load_priority = cb_data[CbdIndex.priority]
    local is_async = cb_data[CbdIndex.is_async]

    if not is_succ then
        BundleCacheMgr.Instance:UnLockBundles(need_loads)
        cb(nil, up_cb_data, bundle_name)
        CbdPool.ReleaseCbData(cb_data)
        return
    end

    if is_async then
        AssetBundleMgr.Instance:LoadAssetAsync(bundle_name, asset_name, asset_type, LoadAssetCallBack, cb_data, load_priority)
    else
        AssetBundleMgr.Instance:LoadAssetSync(bundle_name, asset_name, asset_type, LoadAssetCallBack, cb_data, load_priority)
    end
end

local function DownloadBundlesCallBack(is_succ, cb_data)
    ---@type BundleLoader
    local self = cb_data[CbdIndex.self]
    local bundle_name = cb_data[CbdIndex.bundle]
    local cb = cb_data[CbdIndex.callback]
    local up_cb_data = cb_data[CbdIndex.cb_data]
    local need_loads = cb_data[CbdIndex.need_load]
    local load_priority = cb_data[CbdIndex.priority]

    if not is_succ then
        cb(nil, up_cb_data, bundle_name)
        CbdPool.ReleaseCbData(cb_data)
        return
    end

    BundleCacheMgr.Instance:LockBundles(need_loads)
    if load_priority >= ResLoadPriority.ui_low and load_priority <= ResLoadPriority.sync then
        AssetBundleMgr.Instance:LoadMultiBundlesSync(need_loads, LoadMultiBundlesCallBack, cb_data, load_priority)
    else
        AssetBundleMgr.Instance:LoadMultiBundlesAsync(need_loads, LoadMultiBundlesCallBack, cb_data, load_priority)
    end
end

--异步加载资源
function BundleLoader:LoadObjectAsync(bundle_name, asset_name, asset_type, callback, cb_data, load_priority)
    local need_downloads, need_loads = self:CalcLoadBundleDepends(bundle_name)
    if need_downloads == nil or need_loads == nil then
        callback(nil, cb_data, bundle_name)
        return
    end

    if ResUtil.memory_debug then
        BundleCacheMgr.Instance:CacheBundleRefDetail(bundle_name, "[Asset]" .. asset_name)
        for _, v in pairs(need_loads) do
            BundleCacheMgr.Instance:CacheBundleRefDetail(v, bundle_name)
        end
    end

    local cbd = CbdPool.CreateCbData()
    cbd[CbdIndex.self] = self
    cbd[CbdIndex.bundle] = bundle_name
    cbd[CbdIndex.asset] = asset_name
    cbd[CbdIndex.type] = asset_type
    cbd[CbdIndex.callback] = callback
    cbd[CbdIndex.cb_data] = cb_data
    cbd[CbdIndex.priority] = load_priority
    cbd[CbdIndex.is_async] = true
    cbd[CbdIndex.need_load] = need_loads

    --下载AB
    AssetBundleMgr.Instance:DownLoadBundles(need_downloads, DownloadBundlesCallBack, cbd, load_priority)
end

--同步加载资源
function BundleLoader:LoadObjectSync(bundle_name, asset_name, asset_type, callback, cb_data)
    local need_downloads, need_loads = self:CalcLoadBundleDepends(bundle_name)
    if need_downloads == nil or need_loads == nil then
        callback(nil, cb_data, bundle_name)
        return
    end

    if ResUtil.memory_debug then
        BundleCacheMgr.Instance:CacheBundleRefDetail(bundle_name, "[Asset]" .. asset_name)
        for _, v in pairs(need_loads) do
            BundleCacheMgr.Instance:CacheBundleRefDetail(v, bundle_name)
        end
    end

    local cbd = CbdPool.CreateCbData()
    cbd[CbdIndex.self] = self
    cbd[CbdIndex.bundle] = bundle_name
    cbd[CbdIndex.asset] = asset_name
    cbd[CbdIndex.type] = asset_type
    cbd[CbdIndex.callback] = callback
    cbd[CbdIndex.cb_data] = cb_data
    cbd[CbdIndex.priority] = ResLoadPriority.sync
    cbd[CbdIndex.is_async] = false
    cbd[CbdIndex.need_load] = need_loads

    --下载AB
    AssetBundleMgr.Instance:DownLoadBundles(need_downloads, DownloadBundlesCallBack, cbd, ResLoadPriority.sync)
end

--异步加载prefab并实例化GameObject
function BundleLoader:LoadGameObjectAsync(bundle_name, asset_name, parent, callback, cb_data, load_priority)
    self:__LoadGameObj(bundle_name, asset_name, parent, callback, cb_data, load_priority, true)
end

--同步加载prefab并实例化GameObject
function BundleLoader:LoadGameObjectSync(bundle_name, asset_name, parent, callback, cb_data)
    self:__LoadGameObj(bundle_name, asset_name, parent, callback, cb_data, ResLoadPriority.sync, false)
end

local function GetPrefabCallBack(prefab, cb_data)
    ---@type BundleLoader
    local self = cb_data[CbdIndex.self]
    local cb = cb_data[CbdIndex.callback]
    local cbd = cb_data[CbdIndex.cb_data]
    local bundle_name = cb_data[CbdIndex.bundle]
    local asset_name = cb_data[CbdIndex.asset]
    local parent = cb_data[CbdIndex.parent]
    local is_async = cb_data[CbdIndex.is_async]
    local load_priority = cb_data[CbdIndex.priority]
    CbdPool.ReleaseCbData(cb_data)

    if IS_DEBUG_BUILD then
        print_log("[BundleLoader] async load game_object complete:", bundle_name, asset_name, prefab)
    end

    if prefab == nil then
        cb(nil, cbd)
        return
    end

    if load_priority >= ResLoadPriority.ui_low and load_priority <= ResLoadPriority.sync then
        self:__Instantiate(prefab, parent, cb, cbd)
    else
        local t = CbdPool.CreateCbData()
        t[CbdIndex.prefab] = prefab
        t[CbdIndex.bundle] = bundle_name
        t[CbdIndex.parent] = parent
        t[CbdIndex.callback] = cb
        t[CbdIndex.cb_data] = cbd
        table.insert(self.v_priority_instantiate_queue[load_priority], t)
    end
end

function BundleLoader:__LoadGameObj(bundle_name, asset_name, parent, callback, cb_data, load_priority, is_async)
    if IS_DEBUG_BUILD then
        print_log("[BundleLoader] start async load game_object:", bundle_name, asset_name)
    end

    if load_priority == nil or load_priority >= ResLoadPriority.max or load_priority <= ResLoadPriority.min then
        print_error("[BundleLoader] load_priority is invalid!")
        return
    end

    local cbd = CbdPool.CreateCbData()
    cbd[CbdIndex.self] = self
    cbd[CbdIndex.bundle] = bundle_name
    cbd[CbdIndex.asset] = asset_name
    cbd[CbdIndex.parent] = parent
    cbd[CbdIndex.callback] = callback
    cbd[CbdIndex.cb_data] = cb_data
    cbd[CbdIndex.priority] = load_priority
    cbd[CbdIndex.is_async] = is_async
    ResPoolMgr.Instance:GetPrefab(bundle_name, asset_name, GetPrefabCallBack, cbd, load_priority, is_async)
end

function BundleLoader:__UpdateInstantiate()
    local max_instantiate_count = AssetBundleMgr.Instance:IsLowLoad() and MAX_INSTANTIATE_COUNT or MAX_INSTANTIATE_COUNT * 2
    local remain_can_instantiate_count = math.max(max_instantiate_count - self.v_instantiate_count, 1)
    for i, v in ipairs(self.load_priority_type_list) do
        local allocate_can_instantiate_count = math.ceil(remain_can_instantiate_count * self.load_priority_type_list[i])
        if allocate_can_instantiate_count == 0 and self.v_instantiate_count == 0 then
            allocate_can_instantiate_count = 1
        end
        remain_can_instantiate_count = remain_can_instantiate_count - self:__InstantiateInPriority(v, allocate_can_instantiate_count)
    end
    self.v_instantiate_count = 0
end

function BundleLoader:__InstantiateInPriority(load_priority, instantiate_count)
    if instantiate_count < 0 then
        print_error("[BundleLoader] big bug, instantiate_count less 0!")
        instantiate_count = 0
    end

    local queue = self.v_priority_instantiate_queue[load_priority]
    local count = math.min(instantiate_count, #queue)
    for i = 1, count do
        local t = table.remove(queue, 1)
        self:__Instantiate(t[CbdIndex.prefab], t[CbdIndex.parent], t[CbdIndex.callback], t[CbdIndex.cb_data])
        CbdPool.ReleaseCbData(t)
    end

    return count
end

function BundleLoader:__Instantiate(prefab, parent, callback, cb_data)
    self.v_instantiate_count = self.v_instantiate_count + 1
    if prefab then
        local go = ResMgr.Instance:Instantiate(prefab, true, parent)
        local instance_id = go:GetInstanceID()
        self.v_goid_go_monitors[instance_id] = go
        self.v_goid_prefab_map[instance_id] = prefab
        callback(go, cb_data)
    else
        callback(nil, cb_data)
    end
end

function BundleLoader:CalcLoadBundleDepends(bundle_name)
    local deps = self:GetBundleDeps(bundle_name)
    if not deps then
        print_error("[BundleLoader] not found dependency:", bundle_name)
        return
    end
    local bundle_hash = self:GetBundleHash(bundle_name)
    if not bundle_hash then
        print_error("[BundleLoader] not exists in manifest:", bundle_name)
        return
    end
    local need_downloads = {}
    local need_loads = { bundle_name }
    if not ResUtil.IsFileExist(bundle_name, bundle_hash) then
        need_downloads = { bundle_name }
    end

    for i, dep in ipairs(deps) do
        local hash = self.v_manifest_info.bundleInfos[dep].hash
        if not ResUtil.IsFileExist(dep, hash) then
            table.insert(need_loads, dep)
            table.insert(need_downloads, dep)
        else
            table.insert(need_loads, dep)
        end
    end

    return need_downloads, need_loads
end

function BundleLoader:MonitorGameObjLive(time)
    if time < self.v_goid_go_monitor_time then
        return
    end
    self.v_goid_go_monitor_time = time + 1

    local die_goids = ResUtil.GetTable()
    local die_num = 0
    local monitor_count = 0
    for k, v in pairs(self.v_goid_go_monitors) do
        monitor_count = monitor_count + 1
        if v:Equals(nil) then
            die_num = die_num + 1
            die_goids[die_num] = k
            table.insert(die_goids, k)
        end
    end

    for i = 1, die_num do
        self:ReleaseInObjId(die_goids[i])
        ResPoolMgr.Instance:OnGameObjIllegalDestroy(die_goids[i])
        die_goids[i] = nil
    end

    ResUtil.ReleaseTable(die_goids)

    if die_num > 0 then
        print_log("[BundleLoader] monitor_count=" .. monitor_count .. ", die_game_obj count=" .. #die_goids)
    end
end

function BundleLoader:Destroy(go, release_policy)
    self:__Destroy(go, release_policy)
end

function BundleLoader:__Destroy(go, release_policy)
    if IsNil(go) then
        return
    end

    if ResPoolMgr.Instance:IsInGameObjPool(go:GetInstanceID(), go) then
        print_error("[BundleLoader] big bug, destroy pool game object!")
        return
    end

    self:ReleaseInObjId(go:GetInstanceID(), release_policy)
    UnityDestroy(go)
end

function BundleLoader:ReleaseInObjId(instance_id, release_policy)
    local prefab = self.v_goid_prefab_map[instance_id]
    if prefab then
        ResPoolMgr.Instance:Release(prefab, release_policy)
        self.v_goid_go_monitors[instance_id] = nil
        self.v_goid_prefab_map[instance_id] = nil
    end
end

function BundleLoader:IsCanSafeUseBundle(bundle_name)
    if not BundleCacheMgr.Instance:IsBundleRefing(bundle_name) then
        return false
    end

    local deps = self:GetBundleDeps(bundle_name)
    if deps then
        for _, dep in ipairs(deps) do
            if not BundleCacheMgr.Instance:IsBundleRefing(dep) then
                return false
            end
        end
    end

    return true
end

--下载Bundle
function BundleLoader:UpdateBundle(bundle_name, update_callback, complete_callback, check_hash)
    local bundle_path = ""
    local bundle_hash = ""
    if IsLuaAssetBundle(bundle_name) then
        bundle_path = "LuaAssetBundle/" .. bundle_name
        bundle_hash = self:GetLuaBundleHash(bundle_hash)
    else
        bundle_path = bundle_name
        bundle_hash = self:GetBundleHash(bundle_hash)
    end
    local remote_path = self:GetRemotePath(bundle_path, bundle_hash)
    local cache_path = ResUtil.GetCachePath(bundle_path, bundle_hash)
    DownloadMgr.Instance:CreateFileDownloader(remote_path, update_callback, complete_callback, cache_path, bundle_name, bundle_hash, check_hash)
end

--下载Bundle(在线热更专用)
function BundleLoader:RuntimeUpdateBundle(bundle_name, update_callback, complete_callback)
    local bundle_path = ""
    local bundle_hash = ""
    if IsLuaAssetBundle(bundle_name) then
        bundle_path = "LuaAssetBundle/" .. bundle_name
        bundle_hash = self:GetLuaBundleHash(bundle_hash)
    else
        bundle_path = bundle_name
        bundle_hash = self:GetBundleHash(bundle_hash)
    end
    local remote_path = self:GetRuntimeRemotePath(bundle_path, bundle_hash)
    local cache_path = ResUtil.GetCachePath(bundle_path, bundle_hash)
    DownloadMgr.Instance:CreateFileDownloader(remote_path, update_callback, complete_callback, cache_path, bundle_name)
end

function BundleLoader:UnloadScene(bundle_name)
    self:ReleaseBundle(bundle_name)
end

function BundleLoader:GetBundlesWithoutCached(bundle_name)
    local bundles = {}
    if not ResUtil.IsFileExist(bundle_name, self:GetBundleHash(bundle_name)) then
        bundles[bundle_name] = true
    end
    local deps = self:GetBundleDeps(bundle_name)
    if deps then
        for _, dep in ipairs(deps) do
            if not ResUtil.IsFileExist(dep, self:GetBundleHash(dep)) then
                bundles[dep] = true
            end
        end
    end
    return bundles
end

function BundleLoader:LoadAssetBundle(bundle_name, is_async, callback, cb_data, load_priority)
    if is_async then
        self:LoadAssetBundleAsync(bundle_name, callback, cb_data, load_priority)
    else
        self:LoadAssetBundleSync(bundle_name, callback, cb_data)
    end
end

function BundleLoader:UnLoadAssetBundle(bundle_name)
    self:ReleaseBundle(bundle_name)
end

function BundleLoader:LoadAssetBundleSync(bundle_name, callback, cb_data)
    local need_downloads, need_loads = self:CalcLoadBundleDepends(bundle_name)
    if need_downloads == nil or need_loads == nil then
        callback(nil, cb_data, bundle_name)
        return
    end
    AssetBundleMgr.Instance:DownLoadBundles(need_downloads, function(is_succ)
        if not is_succ then
            callback(nil, cb_data, bundle_name)
            return
        end
        BundleCacheMgr.Instance:LockBundles(need_loads)
        --同步加载AB
        AssetBundleMgr.Instance:LoadMultiBundlesSync(need_loads, function(is_succ)
            if not is_succ then
                BundleCacheMgr.Instance:UnLockBundles(need_loads)
                callback(nil, cb_data, bundle_name)
                return
            end

            self:UseBundle(bundle_name)
            local bundle = BundleCacheMgr.Instance:GetCacheRes(bundle_name)
            BundleCacheMgr.Instance:UnLockBundles(need_loads)
            callback(bundle.asset_bundle, cb_data, bundle_name)
        end)
    end, nil, ResLoadPriority.sync)
end

function BundleLoader:LoadAssetBundleAsync(bundle_name, callback, cb_data, load_priority)
    local need_downloads, need_loads = self:CalcLoadBundleDepends(bundle_name)
    if need_downloads == nil or need_loads == nil then
        callback(nil, cb_data, bundle_name)
        return
    end
    AssetBundleMgr.Instance:DownLoadBundles(need_downloads, function(is_succ)
        if not is_succ then
            callback(nil, cb_data, bundle_name)
            return
        end
        BundleCacheMgr.Instance:LockBundles(need_loads)
        --异步加载AB
        AssetBundleMgr.Instance:LoadMultiBundlesAsync(need_loads, function(is_succ)
            if not is_succ then
                BundleCacheMgr.Instance:UnLockBundles(need_loads)
                callback(nil, cb_data, bundle_name)
                return
            end

            self:UseBundle(bundle_name)
            local bundle = BundleCacheMgr.Instance:GetCacheRes(bundle_name)
            BundleCacheMgr.Instance:UnLockBundles(need_loads)
            callback(bundle.asset_bundle, cb_data, bundle_name)
        end, nil, load_priority)
    end, nil, load_priority)
end

function BundleLoader:GetAllGameObjectInstanceID()
    local list = {}
    local index = 0
    for id, _ in pairs(self.v_goid_prefab_map) do
        list[index] = id
        index = index + 1
    end
    return list
end