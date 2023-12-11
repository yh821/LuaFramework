---
--- Created by Hugo
--- DateTime: 2023/9/19 10:53
---

---@class DownloadMgr
DownloadMgr = DownloadMgr or BaseClass()

require("loader/FileDownloader")

function DownloadMgr:__init()
    self.v_file_downloader_list = {}
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