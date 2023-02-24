-- Speedtest library

local cURL = require "cURL"
local json = require "cjson"
local argparse = require("argparse")

function doesTableExist(table)
    if table ~= nil then
        return true
    end
    return false
end

function getSerersByCountry(tabl, country)
    local serverByCountry = {}
    for k, v in pairs(tabl) do
        if v['Country'] == country then
            table.insert(serverByCountry, v)
        end
    end
    return serverByCountry
end

function getHeaders()
    return {
        "Accept: */*",
        "Accept-Language: en",
        "User-Agent: Mozilla/5.0 (X11; Linux i686; rv:110.0) Gecko/20100101 Firefox/110.0",
        "Accept-Charset: iso-8859-1,*,utf-8",
        "Cache-Control: no-cache"
    }
end

function curlEasy(host, time_out, no_prog, ignore_cont_len)
    c = cURL.easy{
        url            = host,
        ssl_verifypeer = false,
        ssl_verifyhost = false,
        httpheader     = getHeaders(),
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

function curlGetContent(host)
    local response = {}

    c = cURL.easy{
        url            = host,
        ssl_verifypeer = false,
        ssl_verifyhost = false,
        httpheader     = getHeaders(),
        writefunction  = function(str)
            response = str
        end
    }

    c:perform()
    return response 
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

    return lowest_latency_host
end

function getDownloadSpeed(url)
    c = curlEasy(url, 40, true, true)
    c:setopt_accept_encoding('gzip, deflate, br')
    c:perform()
    return c:getinfo(cURL.INFO_SPEED_DOWNLOAD_T) / 1000000 -- bytes to megabytes
end

function getUploadSpeed(url)
    c = curlEasy(url, 40, true, false)
    c:setopt(cURL.OPT_POSTFIELDS, readFileByTime("/dev/zero", 1))
    c:perform()
    return c:getinfo(cURL.INFO_SPEED_UPLOAD_T) / 1000000 -- bytes to megabytes
end

function getIpAddress()
    tabl = json.decode(curlGetContent("https://api.myip.com/"))
    return tabl['ip']
end

function getLocationData(ip)
    result = curlGetContent("https://ipapi.co/".. ip .."/json/")
    tabl = json.decode(result)
    
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

 -- Table to json string
 function tableToJson(tabl)
    local json = "{"

    local i=0
    for k, v in pairs(tabl) do
        if i>0 then json = json .. ', ' end -- adds comma between rows
        json = json .. '"'.. k ..'": '.. jsonValueType(v)
        i=i+1
    end

    json = json .. "}"
    return json
end

function jsonValueType(value)
    if type(value) == boolean then return tostring(value)
    else return '"'..tostring(value)..'"'
    end
end

function readFile(file_name)
    file = io.open(file_name, "r")
    return file:read "*a"
end

function writeToFile(file, result)
    file,err = io.open(file,'w')
    file:write(result)
    file:close()
end

function getArgumentParser()
    local parser = argparse("speedtest", "An speedtest library.")

    parser:option("-c --country"):args(1):default("ALL")
    parser:flag("-a --auto")
    parser:flag("-u --upload")
    parser:flag("-d --download")
    parser:flag("-g --get-location")
    parser:option("-h --host"):args("1")
    parser:option("-o --output", "Save result to a file", "result.txt"):args("?")
    return parser
end