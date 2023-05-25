---
--- Created by Hugo
--- DateTime: 2023/5/9 20:12
---

---@class GameObjectPool : ObjPool
GameObjectPool = GameObjectPool or BaseClass(ObjPool)

function GameObjectPool:__init(root, act_root,path)
    self.root=root
    self.act_root=act_root
    self.path=path or "none"
end

function GameObjectPool:__delete()
end

function GameObjectPool:Release(obj, policy)
end

function GameObjectPool:ReleaseInObjId(id)
end