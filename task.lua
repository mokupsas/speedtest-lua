require('libspeedtest')
require("argparse")
local argparse = require("argparse")
local json = require "cjson"

file = io.open("servers.json", "r")
content = file:read "*a"
local servers = json.decode(content)
local parser = argparse("speedtest", "An speedtest library.")

parser:option("-c --country"):args(1):default "LT"
parser:flag("-a --auto")
parser:flag("-u --upload")
parser:flag("-d --download")
parser:flag("-g --get-location")
parser:option("-h --host"):args("1")
parser:option("-o --output", "Save result to a file", "result.txt"):args("?")

local args = parser:parse()
local host
local result = {} -- result table

-- Validate country code
args.country = string.upper(args.country)

-- If task isn't to get location, find host
if args.get_location == nil and args.host == nil then
   host = getLowestLatencyHost(servers[args.country])
elseif args.get_location == nil and args.host ~= nil then
   host = args.host
end

-- Determine speedtest mode auto/upload/download
if args.upload then
   result['upload']  = getUploadSpeed(host .. '/upload.php')
elseif args.download then 
   result['download'] = getDownloadSpeed(host .. '/download')
elseif args.get_location then 
   ip = getIpAddress()
   result = getLocationData(ip)

else -- auto
   result['download'] = getDownloadSpeed(host .. '/download')
   result['upload'] = getUploadSpeed(host .. '/upload.php')
end

print(json.encode(result))