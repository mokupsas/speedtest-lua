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
parser:option("-o --output", "Save result to a file", "result.txt"):args("?")

local args = parser:parse()
local host

-- Validate country code
args.country = string.upper(args.country)

-- If task isn't to get location, find host
if args.get_location == nil then
   host = getLowestLatencyHost(servers[args.country])
end

-- Determine speedtest mode auto/upload/download
if args.upload then
   uploadSpeed = getUploadSpeed(host .. '/upload.php')
   print(uploadSpeed)
elseif args.download then 
   downloadSpeed = getDownloadSpeed(host .. '/download')
   print(downloadSpeed)
elseif args.get_location then 
   print(args.get_location)
else -- auto
   downloadSpeed = getDownloadSpeed(host .. '/download')
   print(downloadSpeed)
   uploadSpeed = getUploadSpeed(host .. '/upload.php')
   print(uploadSpeed)
end


--[[
local json = require "cjson"
require('libspeedtest')

print('Please wait...')

file = io.open("servers.json", "r")
content = file:read "*a"
local servers = json.decode(content)
local countryCode = string.upper("lt")

if doesTableExist(servers) == false then
   print("Table doesn't' exist")
   return
end

local host = getLowestLatencyHost(servers[countryCode])
print('Found host with lowest latency: ' .. host)

downloadSpeed = getDownloadSpeed(host .. '/download')
print('Average download MB/s: ' ..  downloadSpeed)

uploadSpeed = getUploadSpeed(host .. '/upload.php')
print('Average upload MB/s: ' ..  uploadSpeed)

results = outputJson(downloadSpeed, uploadSpeed)
print(results)

saveToFile('./results.txt', results)
]]