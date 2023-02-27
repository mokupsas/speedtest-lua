local cURL = require "cURL"
local json = require "cjson"
--Enums
require("taskType")
require("statusType")

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
    local start_time = os.time()
    --print(start_time)
    c = cURL.easy{
        url            = host,
        ssl_verifypeer = false,
        ssl_verifyhost = false,
        progressfunction = function(one, two, three, four)
            if countExecTime(start_time) > 0 then
                if four ~= 0 then
                    print(json.encode({status=STATUS_PENING, task=TASK_TYPE_UPLOAD}))
                elseif two ~= 0 then
                    print(json.encode({status=STATUS_PENING, task=TASK_TYPE_DOWNLOAD}))
                end
                start_time = os.time()
            end

            --[[
            if countExecTime(start_time) > 0 then
                print(countExecTime(start_time))
                start_time = os.time()
            end
            ]]
        end,
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

function countExecTime(start_time)
    end_time = os.time()
    return os.difftime(end_time,start_time)
end