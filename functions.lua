local argparse = require("argparse")

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

function readFile(file_name)
    file = io.open(file_name, "r")
    return file:read "*a"
end

function writeToFile(file, result)
    file,err = io.open(file,'w')
    file:write(result)
    file:close()
end