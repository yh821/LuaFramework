﻿---
--- Created by Hugo
--- DateTime: 2023/5/5 16:40
---

---@class ViewManager : BaseClass
ViewManager = ViewManager or BaseClass()

UiLayer = GameObject.Find("GameRoot/UiLayer")

function ViewManager:__init()
    if ViewManager.Instance then
        print_error("[ViewManager] attempt to create singleton twice!")
        return
    end
    ViewManager.Instance = self

    self._open_view_list = {}
end

function ViewManager:__delete()
    ViewManager.Instance = nil
end

function ViewManager:OpenView(view_name, callback)
    local view = self._open_view_list[view_name]
    if view then
        view:OnFlush()
        return
    end

    local bundle_name = string.lower("views/" .. view_name .. "_prefab")
    local asset_name = view_name .. "View"
    local prefab = EditorResourceMgr.LoadGameObject(bundle_name, asset_name)
    local go = ResMgr.Instance:Instantiate(prefab)
    if IsNil(go) then
        return
    end
    local trans = go.transform
    trans:SetParent(UiLayer.transform, false)
    trans.localPosition = Vector3Pool.GetTemp(0, 0, 0)
    go.name = view_name
    if callback then
        callback(go)
    end
end