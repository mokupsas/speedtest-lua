local cURL = require "cURL"

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