---
--- Created by Hugo
--- DateTime: 2023/7/14 10:02
---
---@class LoadHelper
LoadHelper = LoadHelper or {}

local UnityWWW = UnityEngine.WWW
local TypeUnitySprite = typeof(UnityEngine.Sprite)
local TypeUnityTexture = typeof(UnityEngine.Texture)
local TypeGameLoadRawImage = typeof(LoadRawImage)

local cb_data_list = {}
local function GetCbData()
    local data = table.remove(cb_data_list)
    if not data then
        data = { true, true, true }
    end
    return data
end
local function ReleaseCbData(cb_data)
    cb_data[1] = true
    cb_data[2] = true
    cb_data[3] = true
    table.insert(cb_data_list, cb_data)
end

local function __AllocLoader(self, is_async, loader_key)
    if IsNilOrEmpty(loader_key) or type(loader_key) ~= "string" then
        print_error("your loader key is invalid!!! key=" .. loader_key)
    end

    if self._class_type == nil then
        print_error("[AllocLoader] Lua对象必须继承于BaseClass!!!")
        return
    end

    if self.__game_obj_loaders == nil then
        self.__game_obj_loaders = {}
    end

    local loader = self.__game_obj_loaders[loader_key]
    if loader then
        loader:SetIsAsyncLoad(is_async)
        return loader
    end

    loader = __GameObjLoader.New()
end

function LoadHelper.AllocAsyncLoader(self, arg)
    return __AllocLoader(self, true, arg)
end

function LoadHelper.AllocSyncLoader(self, arg)
    return __AllocLoader(self, false, arg)
end










