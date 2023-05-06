---
--- Created by Hugo
--- DateTime: 2023/5/5 16:40
---

---@class ViewManager
ViewManager = ViewManager or BaseClass()

function ViewManager:__init()
    if ViewManager.Instance then
        print_error("[ViewManager] attempt to create singleton twice!")
        return
    end
    ViewManager.Instance = self
end

function ViewManager:__delete()
    ViewManager.Instance = nil
end

function ViewManager:CreatePanel(view_name, callback)
    local bundle = string.lower("views/" .. view_name .. "_prefab")
    local asset = view_name .. "View"
    local gameObject = EditorResourceMgr.LoadGameObject(bundle, asset)
    if IsNil(gameObject) then
        return
    end
    gameObject.name = view_name
    if callback then
        callback(gameObject)
    end
end