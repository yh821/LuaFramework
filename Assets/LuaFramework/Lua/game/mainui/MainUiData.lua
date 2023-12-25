---
--- Created by Hugo
--- DateTime: 2023/5/5 18:39
---

---@class MainUiData : BaseClass
MainUiData = MainUiData or BaseClass()

function MainUiData:__init()
    if MainUiData.Instance then
        print_error("[MainUiData] attempt to create singleton twice!")
        return
    end
    MainUiData.Instance = self
end

function MainUiData:__delete()
    MainUiData.Instance = nil
end