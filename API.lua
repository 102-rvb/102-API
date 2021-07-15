local RitualnieAPI = {}

local HttpService = game:GetService("HttpService")
local Secret = ""
local Hostname = ""
local HTTPs = true
local Endpoints = require(script.Endpoints)

local function Request(EndpointData,Body)
	local finalURL
	local ResponseBody
	local HTTP_Request = {
		Url = finalURL,
		Method = EndpointData.Method,
		Headers = {
			["Content-Type"] = "application/json",
			["Authorization"] = Secret
		}
	}
	
	if HTTPs then
		finalURL = "https://" .. Hostname .. EndpointData.Path
	else
		finalURL = "http://" .. Hostname .. EndpointData.Path
	end
	
	if (not EndpointData.Method == "GET" or EndpointData.Method == "HEAD") then
		HTTP_Request.Body = HttpService:JSONEncode(Body) or "{}"
	end
	
	HTTP_Request = HttpService:RequestAsync(HTTP_Request)
	
	if HTTP_Request.Headers["Content-Type"]:find("application/json") then
		return HttpService:JSONDecode(HTTP_Request.Body)
	else
		warn("HTTP Request failed\nURL:",HTTP_Request.URL,"\nResponse",HTTP_Request)
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
	
	return Body or nil
end

-- https://api.diltz.link/logs/get?filter=Diltz&from=0&to=50000000&type=damage&jobid=1

function RitualnieAPI:GetLogs(filter,from,to,type,jobid)
	local BodyRequest = {
		Path = "",
		Method = Endpoints.GetLogsData.Method
	}
	
	if jobid then
		BodyRequest.Path = string.format("%s?filter=%s&from=%s&to=%s&type=%s&jobid=%s",Endpoints.GetLogsData.Path,HttpService:UrlEncode(filter),from,to,type,HttpService:UrlEncode(jobid))
	else
		BodyRequest.Path = string.format("%s?filter=%s&from=%s&to=%s&type=%s",Endpoints.GetLogsData.Path,HttpService:UrlEncode(filter),from,to,type)
	end
	
	local Success,Body = Request(BodyRequest)
	
	return (Body and Body.logs) or {}
end

return RitualnieAPI
