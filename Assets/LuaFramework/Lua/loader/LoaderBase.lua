---
--- Created by Hugo
--- DateTime: 2023/9/15 10:38
---

local SysUri = System.Uri
local SysObj = System.Object

local UnityLoadSceneMode = UnityEngine.SceneManagement.LoadSceneMode
local SceneSingleLoadMode = UnityLoadSceneMode.Single
local SceneAdditiveLoadModel = UnityLoadSceneMode.Additive

local UnityGameObject = UnityEngine.GameObject
local UnityDontDestroyOnLoad = UnityGameObject.DontDestroyOnLoad
local UnityInstantiate = UnityGameObject.Instantiate

---@class LoaderBase : BaseClass
LoaderBase = LoaderBase or BaseClass()

function LoaderBase:__init()
    self.v_lua_manifest_info = { bundleInfos = {} }
    self.v_manifest_info = { bundleInfos = {} }
    self.v_scene_loader_list = { }
    self.v_scene_loader = SceneLoader.New()

    self.is_ignore_hash_check = true
    self.is_can_check_crc = false
end

function LoaderBase:Update(time, delta_time)
    if self.v_scene_loader then
        self.v_scene_loader:Update()
    end
    for _, scene_loader in ipairs(self.v_scene_loader_list) do
        scene_loader:Update()
    end
end

function LoaderBase:CreateEmptyGameObj(name, dont_destroy)
    local go = UnityGameObject()
    if name then
        go.name = name
    end
    if dont_destroy then
        self:DontDestroyOnLoad(go)
    end
    return go
end

function LoaderBase:DontDestroyOnLoad(go)
    UnityDontDestroyOnLoad(go)
end

function LoaderBase:Instantiate(res, dont_destroy, parent)
    local go
    if not IsNil(parent) then
        go = UnityInstantiate(res, parent.transform, false)
    else
        go = UnityInstantiate(res)
    end

    go.name = res.name
    if dont_destroy and go.transform.parent == nil then
        self:DontDestroyOnLoad(go)
    end

    return go
end

function LoaderBase:DestroySysObj(so)
    if so then
        SysObj.Destroy(so)
    end
end

function LoaderBase:Destroy(go)
    assert(nil)
end

function LoaderBase:OnHotUpdateLuaComplete()
end

function LoaderBase:LoadUnitySceneAsync(bundle_name, asset_name, load_mode, callback)
    assert(nil)
end

function LoaderBase:LoadUnitySceneSync(bundle_name, asset_name, load_mode, callback)
    assert(nil)
end

function LoaderBase:LoadLocalLuaManifest(name)
    assert(nil)
end

function LoaderBase:LoadRemoteLuaManifest(callback)
    assert(nil)
end

function LoaderBase:LoadLocalManifest(name)
    assert(nil)
end

function LoaderBase:LoadRemoteManifest(name, callback)
    assert(nil)
end

function LoaderBase:LoadAssetBundle(bundle_name, is_async, callback, cb_data, load_priority)
    assert(nil)
end

function LoaderBase:UnLoadAssetBundle(bundle_name)
    assert(nil)
end

function LoaderBase:UpdateBundle(bundle_name, update_delegate, complete)
    assert(nil)
end

function LoaderBase:GetAllLuaManifestBundles()
    return {}
end

function LoaderBase:GetAllManifestBundles()
    return {}
end

function LoaderBase:GetBundlesWithoutCached(bundle_name)
    assert(nil)
end

function LoaderBase:GetManifestInfo(bundle_name)
    return self.v_manifest_info
end

function LoaderBase:LoadLevelSync(bundle_name, asset_name, load_mode, callback)
    if load_mode == SceneSingleLoadMode then
        self:__DestroyLoadingScenes()
        self.v_scene_loader:LoadLevelSync(bundle_name, asset_name, load_mode, callback)
    else
        local scene_loader = SceneLoader.New()
        table.insert(self.v_scene_loader_list, scene_loader)
        scene_loader:LoadLevelSync()
    end
end

function LoaderBase:LoadLevelAsync(bundle_name, asset_name, load_mode, callback)
    if load_mode == SceneSingleLoadMode then
        self:__DestroyLoadingScenes()
        self.v_scene_loader:LoadLevelAsync(bundle_name, asset_name, load_mode, callback)
    else
        local scene_loader = SceneLoader.New()
        table.insert(self.v_scene_loader_list, scene_loader)
        scene_loader:LoadLevelAsync()
    end
end

function LoaderBase:__DestroyLoadingScenes()
    self.v_scene_loader:Destroy()
    for _, scene_loader in ipairs(self.v_scene_loader_list) do
        scene_loader:Destroy()
    end
    self.v_scene_loader_list = {}
end

function LoaderBase:IsVersionCached(bundle_name, hash)
    if hash == nil and self.v_manifest_info.bundleInfos[bundle_name] then
        hash = self.v_manifest_info.bundleInfos[bundle_name].hash
    end
    return ResUtil.IsFileExist(bundle_name, hash)
end

function LoaderBase:SetAssetVersion(asset_version)
    self.v_asset_version = asset_version
end

function LoaderBase:GetAssetVersion()
    return self.v_asset_version
end

function LoaderBase:SetDownloadingUrl(url)
    if url == nil then
        print_error("[LoaderBase] set downloading url is nil!")
        return
    end
    print_log("[LoaderBase] set downloading url:", url)
    self.v_downloading_url = url
    self.is_ignore_hash_check = false
    self.is_can_check_crc = true
end

function LoaderBase:GetDownloadingUrl()
    return self.v_downloading_url
end

function LoaderBase:SetDownloadingUrl2(url)
    print_log("[LoaderBase] set downloading url2:", url)
    self.v_downloading_url2 = url
end

function LoaderBase:SetRuntimeDownloadingUrl(url)
    if url == nil then
        print_error("[LoaderBase] set runtime downloading url is nil!")
        return
    end
    self.v_runtime_downloading_url = url
end

function LoaderBase:GetRemotePath(bundle_name, version, retry_count, is_crc_no_match)
    if self.v_downloading_url2 and (is_crc_no_match or (retry_count and retry_count > 0)) then
        if is_crc_no_match or retry_count % 3 == 0 then
            local path = SysUri.EscapeUriString(string.format("%s/%s?v=%s", self.v_downloading_url2, bundle_name, version))
            print_log("切换到url2:", path)
            return path
        else
            return SysUri.EscapeUriString(string.format("%s/%s?v=%s", self.v_downloading_url, bundle_name, version))
        end
        return SysUri.EscapeUriString(string.format("%s/%s?v=%s", self.v_downloading_url, bundle_name, version))
    end
end

function LoaderBase:GetRuntimeRemotePath(bundle_name, version)
    return SysUri.EscapeUriString(string.format("%s/%s?v=%s", self.v_runtime_downloading_url, bundle_name, version))
end

function LoaderBase:GetIsIgnoreHashCheck()
    return self.is_ignore_hash_check
end

function LoaderBase:GetIsCanCheckCRC()
    return self.is_can_check_crc
end

function LoaderBase:GetLuaHashCode()
    return ""
end

function LoaderBase:GetHashCode()
    return ""
end

function LoaderBase:IsBundleMode()
    return false
end

function LoaderBase.ExistedInStreaming(path)
    return ResUtil.ExistedInStreaming(path)
end

function LoaderBase:IsCanSafeUseBundle(bundle_name)
    return true
end