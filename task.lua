require('libspeedtest')
require("argparse")
require("functions")
local json = require "cjson"
--Enums
require("actionType")
require("statusType")

local args = getArgumentParser():parse()
local host
local result = {} -- result table

if args.output then
   writeToOutputFile("", true)
end

local servers = json.decode(readFile("servers.json"))
ip = getIpAddress()

if ip == false then
   output = makeJsonError("Couldn't fetch device ip address", ACTION_TYPE_DEVICEDATA, false)
   print(output)
   writeToOutputFile(output)
   return;
end

location = getLocationData(ip) -- get current location data 

if location == false then
   output = makeJsonError("Couldn't fetch device location", ACTION_TYPE_DEVICEDATA, false)
   print(output)
   writeToOutputFile(output)
   return;
end

-- If task isn't to get location, find host
if args.get_location == nil and args.host == nil then
   output = json.encode({status=STATUS_PENING, action=ACTION_TYPE_HOST})
   print(output)
   writeToOutputFile(output)
   host = getLowestLatencyHost(getSerersByCountry(servers, location['country_name']))
   output = json.encode({status=STATUS_DONE, action=ACTION_TYPE_HOST, host=host})
   print(output)
   writeToOutputFile(output)
   --host = "speedtest.litnet.lt:8080"
elseif args.get_location == nil and args.host ~= nil then
   host = args.host
end

-- Determine speedtest mode auto/upload/download
if args.upload then
   result = {
      status = STATUS_DONE,
      task = ACTION_TYPE_UPLOAD,
      upload = getUploadSpeed(host .. '/upload.php')
   }
elseif args.download then 
   result = {
      status = STATUS_DONE,
      action = ACTION_TYPE_DOWNLOAD,
      download = getDownloadSpeed(host .. '/download')
   }
elseif args.get_location then 
   result = location
else -- auto
   download = getDownloadSpeed(host .. '/download')
   output = json.encode({status=STATUS_DONE, action=ACTION_TYPE_DOWNLOAD, speed=download})
   print(output)

   result = {
      status = STATUS_DONE,
      task = ACTION_TYPE_UPLOAD,
      speed = getUploadSpeed(host .. '/upload.php')
   }
end

print(json.encode(result))
done = json.encode({done=true})
print(done)

-- Output file
writeToOutputFile(json.encode(result))
writeToOutputFile(done) -- responds that actions are done