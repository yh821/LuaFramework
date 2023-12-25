---
--- Created by Hugo
--- DateTime: 2023/5/9 19:50
---

---@class ResUtil
ResUtil = {}

local AppStreamingAssetsPath = UnityEngine.Application.streamingAssetsPath
local SysFile = System.IO.File
local SysPath = System.IO.path
local SysDirectory = System.IO.Directory
local SysSearchOption = System.IO.SysSearchOption
local NewString = System.String.New

local cache_path
local base_cache_path
local streaming_files = {}
local is_ios_encrypt_asset = false
local FileExistMap = {}
local table_pool = {}
local string_pool = {}
local black_list = {}

local function __CreateClassNew(self, ...)
    local class = setmetatable({}, self)
    class:__init(...)
    return class
end

local function __CreateClassOnDestroy(self)
end

ResLoadPriority = {
    min = 0,
    steal = 1, --偷偷加载
    low = 2, --场景其他对象
    mid = 3,
    high = 4, --角色身体
    ui_low = 5, --ui特效
    ui_mid = 6, --ui小界面
    ui_high = 7, --ui大界面
    sync = 8, --同步加载
    max = 9
}

ResPoolReleasePolicy = {
    min = 0,
    Default = 1, --默认释放
    NotDestroy = 2, --不Destroy(永存)
    Culling = 3, --放到Act池(不隐藏，通过摄像机裁剪令其不可见)
    DestroyQuick = 4, --马上释放
    max = 5,
}

function ResUtil.CreateClass(base)
    local class
    if base then
        class = setmetatable({}, base)
        class.__index = class
    else
        class = {}
        class.__index = class
        class.New = __CreateClassNew
        class.OnDestroy = __CreateClassOnDestroy
    end
    return class
end

local lua_asset_bundles = { "^lua/.*", "^luajit32/.*", "^luajit64/.*" }
local is_lua_asset_bundle_cache = {}
function ResUtil.IsLuaAssetBundle(bundle_name)
    if is_lua_asset_bundle_cache[bundle_name] ~= nil then
        return is_lua_asset_bundle_cache[bundle_name]
    end
    for i, v in ipairs(lua_asset_bundles) do
        if string.match(bundle_name, v) then
            is_lua_asset_bundle_cache[bundle_name] = true
            return true
        end
    end
    is_lua_asset_bundle_cache[bundle_name] = false
    return false
end

function ResUtil.GetAssetFullPath(bundle_name, asset_name)
    return string.format("%s/%s", bundle_name, asset_name)
end

function ResUtil.SetBaseCachePath(path)
    if IsNilOrEmpty(path) then
        return
    end

    if not SysDirectory.Exists(path) then
        SysDirectory.CreateDirectory(path)
    end

    base_cache_path = path
end

function ResUtil.GetBaseCachePath()
    return base_cache_path
end

function ResUtil.GetCachePath(bundle_name, hash)
    if is_ios_encrypt_asset then
        local relative_path
        if hash then
            relative_path = string.format("%s-%s", bundle_name, hash)
        else
            relative_path = bundle_name
        end
        relative_path = EncryptMgr.GetEncryptPath(relative_path)
        return string.format("%s/%s", base_cache_path, relative_path)
    else
        if hash then
            return string.format("%s/%s-%s", base_cache_path, bundle_name, hash)
        else
            return string.format("%s/%s", base_cache_path, bundle_name)
        end
    end
end

function ResUtil.GetBundleFilePath(bundle_name, bundle_hash)
    local record_path = FileExistMap[bundle_name]
    if record_path then
        return record_path
    end
    --在Cache目录
    local bundle_file_path = ResUtil.GetCachePath(bundle_name, bundle_hash)
    if SysFile.Exists(bundle_file_path) then
        FileExistMap[bundle_name] = bundle_file_path
        return bundle_file_path
    end

    --在包体内
    if bundle_hash then
        local bundle_path = string.format("AssetBundle/%s-%s", bundle_name, bundle_hash)
        if ResUtil.ExistedInStreaming(bundle_path) then
            bundle_file_path = ResUtil.GetStreamingAssetPath(bundle_path)
            FileExistMap[bundle_name] = bundle_file_path
            return bundle_file_path
        end
    else
        local bundle_path = string.format("AssetBundle/%s", bundle_name)
        if ResUtil.ExistedInStreaming(bundle_path) then
            bundle_file_path = ResUtil.GetStreamingAssetPath(bundle_path)
            FileExistMap[bundle_name] = bundle_file_path
            return bundle_file_path
        end
    end

    if ResMgr:GetIsIgnoreHashCheck() then
        local file_name = SysPath.GetFileName(bundle_name)
        local bundle_dir = SysPath.GetDirectoryName(ResUtil.GetCachePath(bundle_name, bundle_hash))
        if SysDirectory.Exists(bundle_dir) then
            local file_list = SysDirectory.GetFiles(bundle_dir, string.format("%s-*", file_name), SysSearchOption.TopDirectoryOnly)
            if file_list and file_list.Length > 0 then
                return file_list:GetValue(0)
            end
        end

        local find_start
        for k, _ in pairs(streaming_files) do
            find_start, _ = string.find(k, string.format("AssetBundle/%s%-", bundle_name))
            if find_start == 1 then
                bundle_file_path = ResUtil.GetStreamingAssetPath(k)
                return bundle_file_path
            end
        end
    end

    return nil
end

function ResUtil.ClearFilePathCache()
    FileExistMap = {}
end

function ResUtil.LoadFileHelper(path)
    local full_path = ResUtil.GetCachePath(path)
    if SysFile.Exists(full_path) then
        return SysFile.ReadAllText(full_path)
    else
        return ResUtil.LoadApkFileHelper(path)
    end
end

function ResUtil.LoadApkFileHelper(path)
    if is_ios_encrypt_asset then
        local alias_path = ResUtil.GetStreamingAssetPath("AssetBundle/" .. path)
        return EncryptMgr.ReadEncryptFile(alias_path)
    else
        local alias_path = ResUtil.GetAliasResPath("AssetBundle/" .. path)
        return StreamingAssets.ReadAllText(alias_path)
    end
end

function ResUtil.IsFileExist(bundle_name, bundle_hash)
    return ResUtil.black_list[bundle_name] == nil and ResUtil.GetBundleFilePath(bundle_name, bundle_hash)
end

function ResUtil.DelCacheBundle(bundle_name)
    local cache_path = ResUtil.GetCachePath(bundle_name)
    local bundle_dir = SysPath.GetDirectoryName(cache_path)
    if SysDirectory.Exists(bundle_dir) then
        local file_name = SysPath.GetFileName(cache_path)
        local file_list = SysDirectory.GetFiles(bundle_dir, string.format("%s-*", file_name), SysSearchOption.TopDirectoryOnly)
        if file_list and file_list.Length > 0 then
            FileExistMap[bundle_name] = nil
            for i = 0, file_list.Length - 1 do
                if SysFile.Exists(file_list[i]) then
                    os.remove(file_list[i])
                end
            end
        end
    end
end

function ResUtil.RemoveFile(bundle_name, file_path)
    if IsNilOrEmpty(file_path) then
        print_error("[ResUtil] remove file fail:", bundle_name)
        return
    end

    if IsNilOrEmpty(bundle_name) then
        print_error("[ResUtil] bundle name is nil!")
    else
        FileExistMap[bundle_name] = nil
    end

    if SysFile.Exists(file_path) then
        os.remove(file_path)
    end
end

function ResUtil.ClearBundleFileCache(bundle_name)
    if bundle_name then
        FileExistMap[bundle_name] = nil
    end
end

function ResUtil.ExistedInCache(bundle_name, hash)
    local path = ResUtil.GetCachePath(bundle_name, hash)
    if black_list[bundle_name] == nil and SysFile.Exists(path) then
        return true
    end
    return false
end

function ResUtil.IsCachePath(path)
    if path == nil then
        return false
    end
    local cache_dir = "BundleCache"
    if is_ios_encrypt_asset then
        cache_dir = EncryptMgr.GetEncryptPath(cache_dir)
    end
    local start = string.find(path, string.format("/%s/", cache_dir))
    return not start
end

function ResUtil.ExistedInStreaming(path)
    return streaming_files[path]
end

function ResUtil.InitStreamingFilesInfo()
    streaming_files = {}
    local data
    if is_ios_encrypt_asset then
        local path = ResUtil.GetStreamingAssetPath("file_list.txt")
        data = EncryptMgr.ReadEncryptFile(path)
    else
        local path = ResUtil.GetAliasResPath("file_list.txt")
        data = StreamingAssets.ReadAllText(path)
    end

    local lines = Split(data, '\n')
    for _, line in ipairs(lines) do
        streaming_files[line] = true
    end
end

function ResUtil.InitEncryptKey()
    if EncryptMgr then
        is_ios_encrypt_asset = EncryptMgr.IsEncryptAsset()
    end
end

function ResUtil.GetStreamingAssetPath(path)
    path = ResUtil.GetAliasResPath(path)
    return string.format("%s/%s", AppStreamingAssetsPath, path)
end

function ResUtil.GetAgentAssetPath(path)
    path = ResUtil.GetStreamingAssetPath(path)
    if is_ios_encrypt_asset then
        local target_path = EncryptMgr.DecryptAgentAssets(path)
        if IsNilOrEmpty(target_path) then
            path = target_path
        end
    end
    return path
end

function ResUtil.GetTable()
    local t = next(table_pool)
    if t then
        table_pool[t] = nil
    else
        t = {}
    end
    return t
end

function ResUtil.ReleaseTable(t)
    table_pool[t] = t
end

function ResUtil.GetCString(lua_str)
    local c_str = string_pool[lua_str]
    if c_str == nil then
        c_str = NewString(lua_str)
        string_pool[lua_str] = c_str
    end
    return c_str
end

function ResUtil.AddProfileBeginSample(flag)
    if IS_OPEN_LUA_PROFILE then
        local lua_str = "lua:" .. flag
        ToLuaProfile.AddProfileBeginSample(ResUtil.GetCString(lua_str))
    end
end

function ResUtil.AddProfileEndSample()
    if IS_OPEN_LUA_PROFILE then
        ToLuaProfile.AddProfileEndSample()
    end
end

function ResUtil.GetAliasResPath(path)
    --return GameRoot.GetAliasResPath(path)
end