local argparse = require("argparse")
local json = require "cjson"

function getArgumentParser()
    local parser = argparse("speedtest", "An speedtest library.")

    parser:option("-c --country"):args(1):default("ALL")
    parser:flag("-a --auto")
    parser:flag("-u --upload")
    parser:flag("-d --download")
    parser:flag("-g --get-location")
    parser:option("-s --host"):args("1")
    parser:option("-o --output", "Save result to a file", "result.txt"):args("1")
    return parser
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

function readFile(file_name)
    file = io.open(file_name, "r")
    return file:read "*a"
end

function writeToOutputFile(result, overwrite)
    local args = getArgumentParser():parse()

    if args.output then
        if overwrite == nil or overwrite == false then
            file,err = io.open(args.output,'a')
        else
            file,err = io.open(args.output,'w')
        end
        file:write(result.."\n")
        file:close()
    end
end

function makeErrorArray(msg, action_type, contin)
    return {status=STATUS_ERROR, error_msg=msg, action=action_type, continue=contin}
end

function countSpeed(start_time, bytes_sent)
    return bytes_sent / countExecTime(start_time) / 1000000
end

function countExecTime(start_time)
    end_time = os.time()
    return os.difftime(end_time,start_time)
end

function doResponse(array)
    output = json.encode(array)
    print(output)
    writeToOutputFile(output)
end