﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by admin.
--- DateTime: 2023/4/2 13:11
---

---@class actionNode : taskNode
actionNode = BaseClass(taskNode)

function actionNode:isAction()
    return true
end