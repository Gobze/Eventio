--// RemoteInvoke class - RemoteFunction wrapper

local BaseInvoke = require(script.Parent:WaitForChild("Bases"):WaitForChild("BaseInvoke"))
local RemoteInvoke = setmetatable({}, BaseInvoke)
RemoteInvoke.__index = RemoteInvoke

local isServer = game:GetService("RunService"):IsServer()
local storage = script.Parent:WaitForChild("Storage"):WaitForChild("RemoteInvokes")

--// Constructor

function RemoteInvoke.new(Data: string | RemoteFunction)
	local t = typeof(Data)
	assert((t == "string") or (t == "Instance" and game.IsA(Data, "RemoteFunction")), "[Eventio.RemoteInvoke]: Passed wrong first argument into .new(Data: string | RemoteFunction). Got " .. t)
	
	local self = setmetatable({
		_checkForPlayer = isServer,
		_invoker = isServer and "InvokeClient" or "InvokeServer",
		_callback = isServer and "OnServerInvoke" or "OnClientInvoke",
		_errSrc = "[Eventio.RemoteInvoke]: "
	}, RemoteInvoke)
	
	if t == "Instance" then
		self._object = Data
	else
		self.Name = Data
		self._object = storage:FindFirstChild(Data)
		if not self._object then
			if isServer then
				self._object = Instance.new("RemoteFunction", storage)
				self._object.Name = Data
			else
				self._object = storage:WaitForChild(Data) --// Client waits for the object to be made on server
			end
		end
	end
	
	return self
end

--// Type checker

function RemoteInvoke.Is(Anything: any): boolean
	return typeof(Anything) == "table" and getmetatable(Anything) == RemoteInvoke
end

--// Export module

return RemoteInvoke
