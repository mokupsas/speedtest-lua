-- Speedtest library

local cURL = require "cURL"
require "curlHandler"
local json = require "cjson"
--Enums
require("actionType")
require("statusType")

function getServerLatency(host)
    c = curlEasy(host, 1, true, false)

    -- Getting error s
    local status, err = pcall(c.perform, c)

    -- Checking for errors
    if err then 
        -- print('Error occured with host: ' .. host) 
        output = json.encode({status=STATUS_ERROR, error_msg="Error occured with host: ".. host, action=ACTION_TYPE_HOST, continue=true})
        print(output)
        writeToOutputFile(output)
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

    return lowest_latency_host
end

function getDownloadSpeed(url)
    print(json.encode({status=STATUS_PENING, action=ACTION_TYPE_DOWNLOAD}))
    c = curlEasy(url, 40, false, true)
    c:setopt_accept_encoding('gzip, deflate, br')
    c:perform()
    return c:getinfo(cURL.INFO_SPEED_DOWNLOAD_T) / 1000000 -- bytes to megabytes
end

function getUploadSpeed(url)
    print(json.encode({status=STATUS_PENING, action=ACTION_TYPE_UPLOAD}))
    c = curlEasy(url, 40, false, false)
    c:setopt(cURL.OPT_POSTFIELDS, readFileByTime("/dev/zero", 1))
    c:perform()
    return c:getinfo(cURL.INFO_SPEED_UPLOAD_T) / 1000000 -- bytes to megabytes
end

function getIpAddress()
    --response = curlGetContent("https://api.myip.com/")
    response = curlGetContent("http://ip-api.com/json/")
    if response == false then
       return false
    end
    tabl = json.decode(response)
    return tabl['query']
end

function getLocationData(ip)
    response = curlGetContent("https://ipapi.co/".. ip .."/json/")

    if response == false then
        return false
     end

    tabl = json.decode(response)
    
    if tabl['error'] then return false end

    local location = {}
    location['city'] = tabl['city']
    location['country_name'] = tabl['country_name']
    location['country_code'] = tabl['country_code']
    location['postal'] = tabl['postal']
    location['latitude'] = tabl['latitude']
    location['longitude'] = tabl['longitude']

    return location
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