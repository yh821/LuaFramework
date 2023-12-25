---
--- Created by Hugo
--- DateTime: 2023/5/9 22:40
---

---@class AssetBundleMgr : BaseClass
AssetBundleMgr = AssetBundleMgr or BaseClass()

local ThreadPriorityHigh = UnityEngine.ThreadPriority.High
local ThreadPriorityLow = UnityEngine.ThreadPriority.Low

function AssetBundleMgr:__init()
    if AssetBundleMgr.Instance then
        print_error("[AssetBundleMgr] attempt to create singleton twice!")
        return
    end
    AssetBundleMgr.Instance = self
end

function AssetBundleMgr:__delete()
    AssetBundleMgr.Instance = nil
end

function AssetBundleMgr:DownLoadBundles(need_downloads, callback, cb_data, priority)
end

function AssetBundleMgr:LoadMultiBundlesAsync(need_loads, callback, cb_data, priority)
end

function AssetBundleMgr:LoadMultiBundlesSync(need_loads, callback, cb_data, priority)
end

function AssetBundleMgr:LoadAssetAsync(bundle_name, asset_name, asset_type, callback, cb_data, priority)
end

function AssetBundleMgr:LoadAssetSync(bundle_name, asset_name, asset_type, callback, cb_data, priority)
end

function AssetBundleMgr:IsLowLoad()
    return self.v_background_loading_priority == ThreadPriorityLow
end

function AssetBundleMgr:IsAssetBundleDownloading(cache_path)
    return self.v_download_bundle_records[cache_path] ~= nil
end

-- 等待AB下载完成（要求这个AB已经在下载中）
function AssetBundleMgr:WaitAssetBundleDownloaded(cache_path, bundle_name, finish_callback)
    if self.v_download_bundle_records[cache_path] == nil then
        callback(false)
        return
    end

    -- 因为这个AB已经在下载中了，DownLoadBundles接口回自动把这次下载插入到检查列表里
    self:DownLoadBundles({ bundle_name }, finish_callback, nil, ResLoadPriority.high)
end