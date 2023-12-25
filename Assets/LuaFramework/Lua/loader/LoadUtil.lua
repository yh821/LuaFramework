---
--- Created by Hugo
--- DateTime: 2023/7/14 10:02
---
---@class LoadUtil
LoadUtil = LoadUtil or {}

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

local function LoadSpriteCallBack(sprite, cb_data)
    local image = cb_data[CbdIndex.self]
    local callback = cb_data[CbdIndex.callback]
    local cbd = cb_data[CbdIndex.cb_data]
    CbdPool.ReleaseCbData(cb_data)

    local enable = not IsNil(image)
    if enable then
        image.sprite = sprite
        image.enabled = enable
        if callback then
            callback(cbd)
        end
    end
end

function LoadUtil.LoadSprite(self, bundle_name, asset_name, callback, cb_data)
    local image = self
    self = self.__metaself__

    local sprite_loader = LoadUtil.AllocAsyncLoader(self, "image_" .. image.gameObject:GetInstanceID())
    image.enabled = not IsNil(image.sprite)

    local cbd = CbdPool.CreateCbData()
    cbd[CbdIndex.self] = image
    cbd[CbdIndex.callback] = callback
    cbd[CbdIndex.cb_data] = cb_data
    sprite_loader:Load(bundle_name, asset_name, TypeUnitySprite, LoadSpriteCallBack, cbd)
end

function LoadUtil.LoadSpriteAsync(self, bundle_name, asset_name, callback, cb_data)
    local image = self
    self = self.__metaself__

    local sprite_loader = LoadUtil.AllocAsyncLoader(self, "image_" .. image.gameObject:GetInstanceID())
    image.enabled = not IsNil(image.sprite)

    local cbd = CbdPool.CreateCbData()
    cbd[CbdIndex.self] = image
    cbd[CbdIndex.callback] = callback
    cbd[CbdIndex.cb_data] = cb_data
    sprite_loader:Load(bundle_name, asset_name, TypeUnitySprite, LoadSpriteCallBack, cbd)
end

local function LoadRawImageCallBack(texture, cb_data)
    local raw_image = cb_data[CbdIndex.self]
    local callback = cb_data[CbdIndex.callback]
    CbdPool.ReleaseCbData(cb_data)

    local enable = not IsNil(raw_image)
    if enable then
        raw_image.texture = texture
        raw_image.enabled = enable
        if callback then
            callback()
        end
    end
end

function LoadUtil.LoadRawImage(self, bundle_name, asset_name, callback, cb_data)
    local raw_image = self
    self = self.__metaself__

    raw_image.enabled = not IsNil(raw_image.texture)

    if asset_name and type(asset_name) == "string" then
        local load_raw_image = raw_image.gameObject:GetComponent(TypeGameLoadRawImage)
        local texture_loader = load_raw_image and LoadRawImageEventHandle.AllocLoader(load_raw_image)
                or LoadUtil.AllocResSyncLoader(self, "raw_image_" .. raw_image.gameObject:GetInstanceID())

        local cbd = CbdPool.CreateCbData()
        cbd[CbdIndex.self] = raw_image
        cbd[CbdIndex.callback] = callback
        texture_loader:Load(bundle_name, asset_name, TypeUnityTexture, LoadRawImageCallBack, cbd)
    else
        local image_path = bundle_name
        local cb = asset_name
        if UNITY_EDITOR then
            if not image_path:find("file:///.*")
                    and not image_path:find("http://.*")
                    and not image_path:find("https://.*")
            then
                image_path = "file:///" .. image_path
            end
        else
            if not image_path:find("file://.*")
                    and not image_path:find("http://.*")
                    and not image_path:find("https://.*")
            then
                image_path = "file://" .. image_path
            end
        end

        coroutine.start(function()
            local www = UnityWWW(image_path)
            coroutine.www(www)

            local err = www.error
            if not IsNilOrEmpty(err) then
                local err_msg = string.find("LoadSprite % for RawImage failed: %s", image_path, err)
                print_error(err_msg)
                return
            end

            local tex = www.texture
            if IsNil(tex) then
                local err_msg = string.find("LoadSprite % for RawImage is not a texture!", image_path)
                print_error(err_msg)
                return
            end

            --清理最后一次加载的texture
            if not IsNil(raw_image.texture) then
                ResMgr.Instance:Destroy(raw_image.texture)
            end

            if not IsNil(raw_image) then
                raw_image.enabled = true
                raw_image.texture = tex
            end

            www:Dispose()

            if cb then
                cb()
            end
        end)
    end
end

function LoadUtil.PlayEffect(self)
    local asset = self
    self = self.__metaself__
    local loader = LoadUtil.AllocAsyncLoader(self, "effect_" .. asset.gameObject:GetInstanceID())
    loader:SetParent(asset.transform)
    loader:Load(asset.EffectAsset.BundleName, asset.EffectAsset.AssetName, nil)
end

function LoadUtil.StopEffect(self)
    local asset = self
    self = self.__metaself__
    LoadUtil.DelGameObjLoader(self, "effect_" .. asset.gameObject:GetInstanceID())
end

---@return GameObjLoader
local function __AllocLoader(self, is_async, loader_key)
    if IsNilOrEmpty(loader_key) or type(loader_key) ~= "string" then
        print_error("your loader key is invalid!!! key=" .. loader_key)
        return
    end

    if self._class_type == nil then
        print_error("[AllocLoader] Lua对象必须继承于BaseClass!!!")
        return
    end

    if self.__game_obj_loaders == nil then
        self.__game_obj_loaders = {}
    end

    local loader = self.__game_obj_loaders[loader_key]
    if not loader then
        loader = GameObjLoader.New()
        loader.__loader_key = loader_key
        loader.__loader_owner = self
        self.__game_obj_loaders[loader_key] = loader
    end

    loader:SetIsAsyncLoad(is_async)

    return loader
end

---@return GameObjLoader
function LoadUtil.AllocAsyncLoader(self, loader_key)
    return __AllocLoader(self, true, loader_key)
end

---@return GameObjLoader
function LoadUtil.AllocSyncLoader(self, loader_key)
    return __AllocLoader(self, false, loader_key)
end

function LoadUtil.DelGameObjLoader(self, loader_key)
    if self.__game_obj_loaders and self.__game_obj_loaders[loader_key] then
        local loader = self.__game_obj_loaders[loader_key]
        self.__game_obj_loaders[loader_key] = nil
        loader.__is_had_del_in_cache = true
        loader:DeleteMe()
    end
end

function LoadUtil.ReleaseGameObjLoaders(self)
    for i, loader in pairs(self.__game_obj_loaders) do
        loader.__is_had_del_in_cache = true
        loader:DeleteMe()
    end
    self.__game_obj_loaders = nil
end

---@return ResLoader
local function __AllocResLoader(self, is_async, loader_key)
    if IsNilOrEmpty(loader_key) or type(loader_key) ~= "string" then
        print_error("your loader key is invalid!!! key=" .. loader_key)
        return
    end

    if self._class_type == nil then
        print_error("[AllocLoader] Lua对象必须继承于BaseClass!!!")
        return
    end

    if self.__res_loaders == nil then
        self.__res_loaders = {}
    end

    local loader = self.__res_loaders[loader_key]
    if loader then
        loader = ResLoader.New()
        loader.__loader_key = loader_key
        loader.__loader_owner = self
        self.__res_loaders[loader_key] = loader
    end

    loader:SetIsAsyncLoad(is_async)

    return loader
end

---@return ResLoader
function LoadUtil.AllocResAsyncLoader(self, loader_key)
    return __AllocResLoader(self, true, loader_key)
end

---@return ResLoader
function LoadUtil.AllocResSyncLoader(self, loader_key)
    return __AllocResLoader(self, false, loader_key)
end

function LoadUtil.DestroyResLoader(self, loader_key)
    if self.__res_loaders and self.__res_loaders[loader_key] then
        local loader = self.__res_loaders[loader_key]
        self.__res_loaders[loader_key] = nil
        loader.__is_had_del_in_cache = true
        loader:DeleteMe()
    end
end

function LoadUtil.ReleaseResLoaders(self)
    local loader_count = 0
    for i, loader in pairs(self.__res_loaders) do
        loader.__is_had_del_in_cache = true
        loader:DeleteMe()
        loader_count = loader_count + 1
    end
    if loader_count > 200 then
        print_warning("[LoadUtil]ReleaseResLoaders, too many res_loader:" .. loader_count, self.view_name)
    end
    self.__res_loaders = nil
end







