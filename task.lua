require('libspeedtest')
require("argparse")
require("functions")
local json = require "cjson"
--Enums
require("taskType")
require("statusType")

local servers = json.decode(readFile("servers.json"))
ip = getIpAddress()
location = getLocationData(ip) -- get current location data 

local args = getArgumentParser():parse()
local host
local result = {} -- result table

-- If task isn't to get location, find host
if args.get_location == nil and args.host == nil then
   print(json.encode({status=STATUS_PENING, task=TASK_TYPE_HOST}))
   host = getLowestLatencyHost(getSerersByCountry(servers, location['country_name']))
   print(json.encode({status=STATUS_DONE, task=TASK_TYPE_HOST, host=host}))
   --host = "speedtest.litnet.lt:8080"
elseif args.get_location == nil and args.host ~= nil then
   host = args.host
end

-- Determine speedtest mode auto/upload/download
if args.upload then
   result = {
      status = STATUS_DONE,
      task = TASK_TYPE_UPLOAD,
      upload = getUploadSpeed(host .. '/upload.php')
   }
elseif args.download then 
   result = {
      status = STATUS_DONE,
      task = TASK_TYPE_DOWNLOAD,
      download = getDownloadSpeed(host .. '/download')
   }
elseif args.get_location then 
   result = location
else -- auto
   result = {
      status = STATUS_DONE,
      task = TASK_TYPE_AUTO,
      download = getDownloadSpeed(host .. '/download'),
      upload = getUploadSpeed(host .. '/upload.php')
   }
end

print(json.encode(result))