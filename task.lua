require('libspeedtest')
require("argparse")
local argparse = require("argparse")
local json = require "cjson"

file = io.open("servers.json", "r")
content = file:read "*a"
local servers = json.decode(content)
countryCode = string.upper("lt")

print('Please wait...')

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
saveToFile('./results.txt', results)
