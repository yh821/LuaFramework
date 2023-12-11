---
--- Created by Hugo
--- DateTime: 2023/5/9 22:40
---

---@class AssetBundleMgr
AssetBundleMgr = AssetBundleMgr or BaseClass()

function AssetBundleMgr:__init()
end

function AssetBundleMgr:__delete()
end

function AssetBundleMgr:DownLoadBundles(need_downloads, callback, priority, cbd)

end

function AssetBundleMgr:LoadMultiBundlesAsync()
end

function AssetBundleMgr:LoadMultiBundlesSync()
end

function AssetBundleMgr:LoadAssetAsync()

end
function AssetBundleMgr:LoadAssetSync()

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
    self:DownLoadBundles({ bundle_name }, callback, ResLoadPriority.high)
end