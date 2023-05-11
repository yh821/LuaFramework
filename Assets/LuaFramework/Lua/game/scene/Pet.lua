---
--- Created by Hugo
--- DateTime: 2023/5/10 18:42
---

---@class Pet : SceneObj
Pet = Pet or BaseClass(SceneObj)

function Pet:__init()
end

function Pet:__delete()
end

function Pet:InitAppearance()
    self:ChangeModel(SceneObjPart.Main, ResPath.GetPetModel(201001))
end