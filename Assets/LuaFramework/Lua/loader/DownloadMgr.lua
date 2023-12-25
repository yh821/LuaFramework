---
--- Created by Hugo
--- DateTime: 2023/9/19 10:53
---

---@class DownloadMgr : BaseClass
DownloadMgr = DownloadMgr or BaseClass()

require("loader/FileDownloader")

function DownloadMgr:__init()
    if DownloadMgr.Instance then
        print_error("[DownloadMgr] attempt to create singleton twice!")
        return
    end
    DownloadMgr.Instance = self

    self.v_file_downloader_list = {}
end

function DownloadMgr:__delete()
    DownloadMgr.Instance = nil
end

function DownloadMgr:CreateFileDownloader(url, update_callback, complete_callback, cache_path, bundle_name, bundle_hash, check_hash)
    local file_downloader = FileDownloader.New(url, update_callback, complete_callback, cache_path, bundle_name, bundle_hash, check_hash)
    self.v_file_downloader_list[file_downloader] = true
end

function DownloadMgr:Update()
    for v, _ in pairs(self.v_file_downloader_list) do
        if not v:Update() then
            self.v_file_downloader_list[v] = nil
        end
    end
end