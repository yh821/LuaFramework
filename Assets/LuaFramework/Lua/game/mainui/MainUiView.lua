---
--- Created by Hugo
--- DateTime: 2022/5/6 0:18
---

---@class MainUiView : BaseView
MainUiView = MainUiView or BaseClass(BaseView)

--启动事件--
function MainUiView:__init(view_name)
    self.view_name = view_name
end

function MainUiView:__delete()
end