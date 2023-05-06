---
--- Created by Hugo
--- DateTime: 2023/5/6 17:42
---

---@class Monster : SceneObj
Monster = Monster or BaseClass(SceneObj)

function Monster:__init()
end

function Monster:__delete()
end

function Monster:InitAppearance()
    self:InitModel()
end

function Monster:InitModel()
    self:ChangeModel()
end