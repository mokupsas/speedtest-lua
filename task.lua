require('libspeedtest')
require("argparse")
require("functions")
local json = require "cjson"

local servers = json.decode(readFile("servers.json"))
ip = getIpAddress()
location = getLocationData(ip) -- get current location data 

local args = getArgumentParser():parse()
local host
local result = {} -- result table

-- If task isn't to get location, find host
if args.get_location == nil and args.host == nil then
   host = getLowestLatencyHost(getSerersByCountry(servers, location['country_name']))
elseif args.get_location == nil and args.host ~= nil then
   host = args.host
end

-- Determine speedtest mode auto/upload/download
if args.upload then
   result['upload']  = getUploadSpeed(host .. '/upload.php')
elseif args.download then 
   result['download'] = getDownloadSpeed(host .. '/download')
elseif args.get_location then 
   result = location
else -- auto
   result['download'] = getDownloadSpeed(host .. '/download')
   result['upload'] = getUploadSpeed(host .. '/upload.php')
end

print(json.encode(result))