﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by admin.
--- DateTime: 2023/4/4 19:40
---

---@class parentNode : taskNode
---@field children taskNode[]
parentNode = BaseClass(taskNode)

function parentNode:tick()
	--override
end

---@return taskNode[]
function parentNode:getChildren()
	return self.children
end

function parentNode:isParent()
	return true
end