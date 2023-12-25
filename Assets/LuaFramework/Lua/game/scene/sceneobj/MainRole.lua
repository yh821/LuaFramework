---
--- Created by Hugo
--- DateTime: 2023/12/22 11:33
---

---@class MainRole : Role
MainRole = MainRole or BaseClass(Role)

function MainRole:__init()
end

function MainRole:__delete()
end

function MainRole:InitAppearance()
    local bundle, asset = ResPath.GetRoleModel(101001)
    self:ChangeModel(SceneObjPart.Main, bundle, asset, function(obj)
        MainCamera.target = Scene.Instance:GetMainRole():GetDrawObj():GetTransform()
    end)
end

function MainRole:CanDoMove()
    return true
end