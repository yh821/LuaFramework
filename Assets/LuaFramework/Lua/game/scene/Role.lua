---
--- Created by Hugo
--- DateTime: 2023/5/6 17:41
---

---@class Role : SceneObj
Role = Role or BaseClass(SceneObj)

function Role:__init()
end

function Role:__delete()
end

function Role:InitAppearance()
    local parent = GameObject.Find("GameRoot/SceneObjLayer/Boy")
    if parent then
        local root = self:GetDrawObj():GetRoot()
        root.transform:SetParent(parent.transform, false)
        root:ResetTransform()
    end
end