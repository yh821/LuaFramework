---
--- Created by Hugo
--- DateTime: 2023/5/6 17:42
---

---@class Monster : Character
Monster = Monster or BaseClass(Character)

function Monster:__init()
end

function Monster:__delete()
end

function Monster:InitAppearance()
    self:ChangeModel(SceneObjPart.Main, ResPath.GetMonsterModel(301001))
end