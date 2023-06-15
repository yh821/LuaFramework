﻿---
--- Created by Hugo
--- DateTime: 2023/5/6 17:41
---

---@class Role : Character
Role = Role or BaseClass(Character)

function Role:__init()
end

function Role:__delete()
end

function Role:InitAppearance()
    local parent = GameObject.Find("GameRoot/SceneObjLayer/101001")
    if parent then
        local root = self:GetDrawObj():GetRoot()
        root.transform:SetParent(parent.transform, false)
        root:ResetTransform()
    end
end