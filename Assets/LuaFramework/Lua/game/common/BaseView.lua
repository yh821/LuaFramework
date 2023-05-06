---
--- Created by Hugo
--- DateTime: 2023/5/6 0:18
---

local TypeUINameTable = typeof(UINameTable)

---@class BaseView
BaseView = BaseView or BaseClass()

function BaseView:__init()
    self.view_name = "unknow"
end

function BaseView:__delete()
end

function BaseView:AddNodeList(gameObject)
    local name_table = gameObject:GetComponent(TypeUINameTable)
    self.node_list = U3DNodeList(name_table, self)
end