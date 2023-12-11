---
--- Created by Hugo
--- DateTime: 2023/10/12 15:31
---

---@class FileDownloader
FileDownloader = FileDownloader or BaseClass()

local UnityWebRequest = UnityEngine.Networking.UnityWebRequest
local UnityTime = UnityEngine.Time
local SysFile = System.IO.File

local zeroInt64 = int64.new(0, 0)
local zeroUInt64 = uint64.zero
local fhInt64 = int64.new(0, 400)

function FileDownloader:__init(url, update_callback, complete_callback, cache_path, bundle_name, bundle_hash, check_hash)
    self:ResetSample()
    self.v_progress = 0
    self.v_downloaded_bytes = 0
    self.v_update_callback = update_callback
    self.v_complete_callback = complete_callback

    coroutine.start(function()
        print_log("[FileDownloader] start download file:", url)
        self.v_request = UnityWebRequest.Get(url)
        local www = self.v_request:SendWebRequest()
        coroutine.www(www)

        if IsGameStop then
            self.v_request:Dispose()
            return
        end

        local err
        if self.v_request.result == UnityWebRequest.Result.ConnectionError then
            err = "[FIleDownloader] download file fail, ConnectionError: " .. url .. ", " .. self.v_request.error
        elseif self.v_request.result == UnityWebRequest.Result.ProtocolError then
            err = "[FIleDownloader] download file fail, ProtocolError: " .. url .. ", " .. self.v_request.error
        elseif self.v_request.result == UnityWebRequest.Result.DataProtocolError then
            err = "[FIleDownloader] download file fail, DataProtocolError: " .. url .. ", " .. self.v_request.error
        elseif self.v_request.responseCode < zeroInt64 or self.v_request.responseCode >= fhInt64 then
            err = "[FIleDownloader] download file fail, code error: " .. url .. ", " .. self.v_request.responseCode
        elseif self.v_request.downloadedBytes <= zeroUInt64 then
            err = "[FIleDownloader] download file fail, bytes error: " .. url .. ", " .. self.v_request.downloadedBytes
        end

        local callback = function(error)
            if error then
                print_error("[FIleDownloader] " .. error)
            end
            print_log("[FIleDownloader] download file complete: ", url)
            complete_callback(error, self.v_request)
            self.v_request:Dispose()
            self:Destroy()
        end

        self:CheckComplete(callback, cache_path, bundle_name, err, bundle_hash, check_hash)
    end)
end

function FileDownloader:CheckComplete(callback, cache_path, bundle_name, error, bundle_hash, check_hash)
    -- 如果AssetBundleMgr也在下载，可能会出现两边同事写入同一个文件，导致另一方回报错
    -- 所以这里等待AssetBundleMgr下载完
    if AssetBundleMgr:IsAssetBundleDownloading(cache_path) then
        local finish_callback = function(is_success)
            if is_success then
                callback(nil)
            else
                callback("[AssetBundleMgr] download fail!!!")
            end
        end
        AssetBundleMgr:WaitAssetBundleDownloaded(cache_path, bundle_name, finish_callback)
        return
    end

    if error == nil then
        if not RuntimeAssetHelper.TryWriteWebRequestDat(cache_path, self.v_request) then
            if SysFile.Exists(cache_path) then
                os.remove(cache_path)
            end
            error = "download file fail, write file error: " .. cache_path
        elseif check_hash and bundle_hash and tonumber(bundle_hash) and SysFile.Exists(cache_path) then

        end
    end

    callback(error)
end

function FileDownloader:Update()
    if self.v_destroy then
        return false
    end

    if self.v_request then
        local download_bytes = self.v_request:GetByteDownloads()
        self.v_sample_bytes = self.v_sample_bytes + download_bytes - self.v_downloaded_bytes
        self.v_downloaded_bytes = download_bytes
        self.v_progress = self.v_request.downloadProgress

        local interval = UnityTime.unscaledTime - self.v_sample_time
        self.v_sample_speed = self.v_downloaded_bytes / interval

        if self.v_update_callback then
            self.v_update_callback(self.v_progress, self.v_sample_speed, self.v_downloaded_bytes, 0)
        end

        if interval >= SPEED_SAMPLE_INTERVAL then
            self:ResetSample()
        end
    end

    return true
end

function FileDownloader:ResetSample()
    self.v_sample_bytes = 0
    self.v_sample_speed = 0
    self.v_sample_time = UnityTime.unscaledTime
end

function FileDownloader:Destroy()
    self.v_destroy = true
    self.v_request = nil
    self.v_update_callback = nil
    self.v_complete_callback = nil
end