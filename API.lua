local RitualnieAPI = {}

local HttpService = game:GetService("HttpService")
local Secret = "a8lmDOJOJIFOgOMTDpgS"
local Hostname = "vps.diltz.link:3002"
local HTTPs = false
local Endpoints = require(script.Endpoints)

local function Request(EndpointData,Body)
	Body = Body or {}
	
	local finalURL
	local ResponseBody
	local HTTP_Request
	
	if HTTPs then
		finalURL = "https://" .. Hostname .. EndpointData.Path
	else
		finalURL = "http://" .. Hostname .. EndpointData.Path
	end
	
	if EndpointData.Method == "GET" or EndpointData.Method == "HEAD" then
		HTTP_Request = HttpService:RequestAsync({
			Url = finalURL,
			Method = EndpointData.Method,
			Headers = {
				["Content-Type"] = "application/json",
				["secret"] = Secret
			},
		})
	else
		HTTP_Request = HttpService:RequestAsync({
			Url = finalURL,
			Method = EndpointData.Method,
			Headers = {
				["Content-Type"] = "application/json",
				["secret"] = Secret
			},
			Body = HttpService:JSONEncode(Body)
		})
	end
	
	if HTTP_Request.Body then
		ResponseBody = HttpService:JSONDecode(HTTP_Request.Body)
	end
	
	if (not HTTP_Request.Success) then
		if HTTP_Request.StatusCode == 504 then
			warn(string.format("HTTP Request failed at %s%s; Server didn't responded; Method: %s",Hostname,EndpointData.Path,EndpointData.Method))
		else
			if ResponseBody then
				warn(string.format("HTTP Request failed at %s%s; Serving-time: %s ms; Method: %s;\nMessage: %s",Hostname,EndpointData.Path,HTTP_Request.Headers["serving-time-ms"],EndpointData.Method,ResponseBody.message))
			else
				warn(string.format("HTTP Request failed at %s%s; Serving-time: %s ms; Method: %s",Hostname,EndpointData.Path,HTTP_Request.Headers["serving-time-ms"],EndpointData.Method))
			end
		end
		
		return false,nil
	else
		--print(string.format("Successful HTTP request to %s%s; Serving-time: %s ms; Method: %s",Hostname,EndpointData.Path,HTTP_Request.Headers["serving-time-ms"],EndpointData.Method))
		return true,ResponseBody
	end
end
	
function RitualnieAPI:GetKickQueue()
	local Success,Body = Request(Endpoints.KickQueue)
	
	if Success then
		return Body.query
	end
	
	return {}
end

function RitualnieAPI:GetUserBanInfo(ID)
	local Success,Body = Request({
		Path = Endpoints.BanlistGetUserInfo.Path .. "?id=" .. tostring(ID), 
		Method = Endpoints.BanlistGetUserInfo.Method
	})
	
	if Body and Body.query then
		return Body.query
	else
		return nil
	end
end

function RitualnieAPI:UnbanUser(ID)
	local Success,Body = Request(Endpoints.BanlistRemove,{
		id = tonumber(ID)
	})
	
	return true
end

function RitualnieAPI:GetUsersBannedData()
	local users = {}
	
	for k,v in pairs(game.Players:GetPlayers()) do
		table.insert(users,v.UserId)
	end
	
	local Success,Body = Request(Endpoints.GetUsersBannedData,users)

	if Body then
		return Body
	else
		return nil
	end
end

return RitualnieAPI
