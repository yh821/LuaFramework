---
--- Created by Hugo
--- DateTime: 2023/12/14 21:46
---

local TypeUnitySprite = typeof(UnityEngine.Sprite)
local TypeSpriteAtlas = typeof(SpriteAtlas)

---@class AssetBundle : BaseClass
AssetBundle = AssetBundle or BaseClass()

function AssetBundle:__init(asset_bundle)
    self.asset_bundle = asset_bundle
    self.sprites = nil
end

function AssetBundle:Unload(unloadAllLoadedObjects)
    self.asset_bundle:Unload(unloadAllLoadedObjects or false)
    self.asset_bundle = nil
    self.sprites = nil
end

function AssetBundle:LoadSpriteAtlas()
    self.sprites = {}
    local sprite_atlas_list = {}
    local all_asset_names = self.asset_bundle:GetAllAssetNames()
    for i = 0, all_asset_names.Length - 1 do
        local asset_name = all_asset_names[i]
        if string.find(asset_name, "%.spriteatlas") then
            local sprite_atlas = self.asset_bundle:LoadAsset(asset_name, TypeSpriteAtlas)
            table.insert(sprite_atlas_list, sprite_atlas)
        end
    end

    for _, sprite_atlas in ipairs(sprite_atlas_list) do
        local sprite_list = sprite_atlas:GetSprites()
        for i = 0, sprite_list.Length - 1 do
            local sprite = sprite_list[i]
            local name = string.lower(sprite.name)
            local index = string.find(name, "%(clone%)")
            if index then
                name = string.sub(name, 1, index - 1)
            end
            self.sprites[name .. ".png"] = sprite
        end
    end
end

function AssetBundle:LoadAsset(asset_name, asset_type)
    if asset_type == nil then
        return self.asset_bundle:LoadAsset(asset_name)
    elseif asset_type ~= TypeUnitySprite then
        return sel.asset_bundle:LoadAsset(asset_name, asset_type)
    else
        if self.sprites == nil then
            self:LoadSpriteAtlas()
        end
        local sprite = self.sprites[asset_name]
        if sprite == nil then
            sprite = self.asset_bundle:LoadAsset(asset_name, asset_type)
        end
        return sprite
    end
end

function AssetBundle:LoadAssetAsync(asset_name, asset_type)
    if asset_type == nil then
        return self.asset_bundle:LoadAssetAsync(asset_name)
    elseif asset_type ~= TypeUnitySprite then
        return sel.asset_bundle:LoadAssetAsync(asset_name, asset_type)
    else
        print_error("暂时不支持异步加载Sprite")
        return nil
    end
end
