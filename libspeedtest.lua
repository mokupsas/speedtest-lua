-- Speedtest library

local cURL = require "cURL"

function doesTableExist(table)
    if table ~= nil then
        return true
    end
    return false
end

function curlEasy(host, time_out, no_prog, ignore_cont_len)
    headers = {
        "Accept: text/*",
        "Accept-Language: en",
        "User-Agent: Mozilla/5.0 (X11; Linux i686; rv:110.0) Gecko/20100101 Firefox/110.0",
        "Accept-Charset: iso-8859-1,*,utf-8",
        "Cache-Control: no-cache"
    }

    c = cURL.easy{
        url            = host,
        ssl_verifypeer = false,
        ssl_verifyhost = false,
        httpheader     = headers,
        writefunction  = function(str)
            -- print(str)
        end
    }

    -- Sets timeout if more than 0
    if time_out > 0 then
        c:setopt{ timeout = time_out }
    end

    -- Sets if not print progress data
    if no_prog == false then
        c:setopt{ noprogress = no_prog }
    end

    -- Sets to ignore transfer content length
    if ignore_cont_len == true then
        c:setopt{ ignore_content_length = ignore_cont_len }
    end

    return c
end

function getServerLatency(host)
    c = curlEasy(host, 1, true, false)

    -- Getting error s
    local status, err = pcall(c.perform, c)

    -- Checking for errors
    if err then 
        print('Error occured with host: ' .. host) 
    end

    -- Checking if server response was successful
    if c:getinfo(cURL.INFO_RESPONSE_CODE) ~= 200 then
        return false
    end
    
    return c:getinfo(cURL.INFO_RESPONSE_CODE)
end

-- Compares latency of all servers from table and returns host of lowest one
function getLowestLatencyHost(servers)
    local lowest_latency = 9999999
    local lowest_latency_host = nil

    -- Going through servers table
    for k, v in pairs(servers) do
       local latency = getServerLatency(v['Host'])
    
       -- Checking for lowest latency server
       if latency ~= false and latency < lowest_latency then
          lowest_latency = latency
          lowest_latency_host = v['Host']
       end
    end
    -- print('Lowest latency host: ' .. lowest_latency_host .. ' latency: ' .. lowest_latency)
    return lowest_latency_host
end

function getDownloadSpeed(url)
    c = curlEasy(url, 600, false, true)
    c:setopt_accept_encoding('gzip, deflate, br')
    c:perform()
    return c:getinfo(cURL.INFO_SPEED_DOWNLOAD_T) / 1000000 -- bytes to megabytes
end

function getUploadSpeed(url)
    c = curlEasy(url, 600, false, false)
    c:setopt(cURL.OPT_POSTFIELDS, readFileByTime("/dev/zero", 1))
    c:perform()
    return c:getinfo(cURL.INFO_SPEED_UPLOAD_T) / 1000000 -- bytes to megabytes
end

-- Reads file for given ammount of seconds (time)
function readFileByTime(filename, time)
    local data = ''
    start_time = os.time()
    file = io.open(filename, "r")
 
    for line in file:lines(100000000) do
       if stopAfterTime(start_time, time) then
          break
       end
       data = data .. line
    end
    return data
 end
 
 -- Returns true when given ammount of time passes 
 function stopAfterTime(start_time, after)
    if(os.time() - start_time > after) then
       return true
    end
    return false
 end

 -- Result to json
function outputJson(download, upload)
    return '{"download": '.. download ..', "upload": '.. upload ..'}'
end

function saveToFile(file, result)
    file,err = io.open(file,'w')
    file:write(result)
    file:close()
end