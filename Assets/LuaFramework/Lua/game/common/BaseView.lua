---
--- Created by Hugo
--- DateTime: 2023/5/6 0:18
---

local TypeUINameTable = typeof(UINameTable)

---@class BaseView
BaseView = BaseView or BaseClass()

function BaseView:__init(view_name)
    if IsNilOrEmpty(view_name) then
        self.view_name = GetClassName(self)
    else
        self.view_name = view_name
    end
end

function BaseView:__delete()
end

function BaseView:AddNodeList(gameObject)
    local name_table = gameObject:GetComponent(TypeUINameTable)
    self.node_list = U3DNodeList(name_table, self)
end

function BaseView:LoadCallback()

end