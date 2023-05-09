---
--- Created by Hugo
--- DateTime: 2023/5/9 19:50
---

---@class ResUtil
ResUtil = {}

function ResUtil.GetAssetFullPath(bundle, asset)
    return string.format("%s/%s", bundle, asset)
end