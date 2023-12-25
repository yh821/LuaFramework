---
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
    self:ChangeModel(SceneObjPart.Main, ResPath.GetMonsterModel(301001))
end