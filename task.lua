require('libspeedtest')
require("argparse")
require("functions")
local json = require "cjson"
--Enums
require("actionType")
require("statusType")

local args = getArgumentParser():parse()
local host
local servers = json.decode(readFile("servers.json"))

if args.output then writeToOutputFile("", true) end   -- clear output file

-- Fetching device IP address
local ip = getIpAddress()
if ip == false then
   doResponse(makeErrorArray("Couldn't fetch device ip address", ACTION_TYPE_DEVICEDATA, false))
   return;
end

-- Fetching device location
local location = getLocationData(ip) -- get current location data 
if location == false then
   doResponse(makeErrorArray("Couldn't fetch device location", ACTION_TYPE_DEVICEDATA, false))
   return;
end

if args.get_location == nil and args.host == nil then
   doResponse({status=STATUS_PENING, action=ACTION_TYPE_HOST})
   host = getLowestLatencyHost(getSerersByCountry(servers, location['country_name']))
   doResponse({status=STATUS_DONE, action=ACTION_TYPE_HOST, host=host})
elseif args.get_location == nil and args.host ~= nil then   -- If task isn't to get location, find host
   host = args.host
end

-- if user set custom host, check for availability
if args.host ~= nil then
   if getServerLatency(host) == false then --response is made and error messages are fetched inside getServerLatency
      return;
   end
end

-- Determine speedtest mode auto/upload/download
if args.upload then
   doResponse({status = STATUS_DONE, task = ACTION_TYPE_UPLOAD, upload = getUploadSpeed(host .. '/upload.php')})
elseif args.download then 
   doResponse({status = STATUS_DONE, action = ACTION_TYPE_DOWNLOAD, download = getDownloadSpeed(host .. '/download')})
elseif args.get_location then 
   doResponse(location)
else -- auto
   -- getting download speed
   doResponse({status=STATUS_DONE, action=ACTION_TYPE_DOWNLOAD, speed=getDownloadSpeed(host .. '/download')})
   --getting upload speed
   doResponse({status = STATUS_DONE, task = ACTION_TYPE_UPLOAD, speed = getUploadSpeed(host .. '/upload.php')})
end

doResponse({done=true})