---
--- Created by Hugo
--- DateTime: 2023/12/18 15:49
---

local TypeTexture2D = typeof(UnityEngine.Texture2D)
local TypeRawImage = typeof(UnityEngine.UI.RawImage)

---@class LoadRawImageEventHandle : BaseClass
LoadRawImageEventHandle = BaseClass()

function LoadRawImageEventHandle.EnableLoadRawImageEvent(enabled_list)
    for i = 0, enabled_list.Count - 1 do
        local load_raw_image = enabled_list[i]
        if not IsNil(load_raw_image) then
            local bundle_name, asset_name = load_raw_image.BundleName, load_raw_image.AssetName
            local raw_image = load_raw_image.gameObject:GetComponent(TypeRawImage)
            if raw_image and not IsNilOrEmpty(bundle_name) and not IsNilOrEmpty(asset_name) then
                if raw_image.texture == nil then
                    local loader = LoadRawImageEventHandle.AllocLoader(load_raw_image)
                    loader:Load(bundle_name, asset_name, TypeTexture2D, function(texture)
                        if texture then
                            raw_image.enabled = true
                            load_raw_image:SetTexture(texture)
                        end
                    end)
                else
                    raw_image.enabled = true
                end
            end
        end
    end
end

function LoadRawImageEventHandle.DisableLoadRawImageEvent(disabled_list)
end

function LoadRawImageEventHandle.DestroyLoadRawImageEvent(destroyed_list)
    for i = 0, destroyed_list.Count - 1 do
        LoadUtil.DestroyResLoader(LoadRawImageEventHandle, "id_" .. destroyed_list[i])
    end
end

function LoadRawImageEventHandle.AllocLoader(load_raw_image)
    return LoadUtil.AllocResAsyncLoader(LoadRawImageEventHandle, "id_" .. load_raw_image:GetInstanceID())
end