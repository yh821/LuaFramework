---
--- Created by Hugo
--- DateTime: 2023/5/9 20:12
---

---@class GameObjectPool
GameObjectPool = GameObjectPool or BaseClass()

function GameObjectPool:__init(root, act_root,path)
    self.root=root
    self.act_root=act_root
    self.path=path or "none"
end

function GameObjectPool:__delete()
end