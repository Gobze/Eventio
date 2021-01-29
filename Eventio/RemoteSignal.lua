--// RemoteSignal class - RemoteEvent wrapper

local BaseSignal = require(script.Parent:WaitForChild("Bases"):WaitForChild("BaseSignal"))
local RemoteSignal = setmetatable({}, BaseSignal)
RemoteSignal.__index = RemoteSignal

local isServer = game:GetService("RunService"):IsServer()
local storage = script.Parent:WaitForChild("Storage"):WaitForChild("RemoteSignals")

--/ Constructor

function RemoteSignal.new(Data: string | RemoteEvent)
	local t = typeof(Data)
	assert((t == "string") or (t == "Instance" and game.IsA(Data, "RemoteEvent")), "[Eventio.RemoteSignal]: Passed wrong first argument into .new(Data: string | RemoteEvent). Got " .. t)
	
	local self = setmetatable({
		_checkForPlayer = isServer,
		_caller = isServer and "FireClient" or "FireServer",
		_errSrc = "[Eventio.RemoteSignal]: "
	}, RemoteSignal)
	
	if t == "Instance" then
		self._object = Data
	else
		self.Name = Data
		self._object = storage:FindFirstChild(Data)
		if not self._object then
			if isServer then
				self._object = Instance.new("RemoteEvent", storage)
				self._object.Name = Data
			else
				self._object = storage:WaitForChild(Data) --// Client waits for the object to be made on server
			end
		end
	end
	
	self._signal = isServer and self._object.OnServerEvent or self._object.OnClientEvent
	
	return self
end

--// Type checker

function RemoteSignal.Is(Anything: any): boolean
	return typeof(Anything) == "table" and getmetatable(Anything) == RemoteSignal
end

--// Unique Methods

function RemoteSignal:FireAll(...): ()
	if isServer then
		self._object:FireAllClients(...)
	else
		error("[Eventio.RemoteSignal]: Tried using :FireAll(...) on a RemoteSignal from client.")
	end
end

function RemoteSignal:FireExcept(ExceptionPlayer: Player, ...): ()
	assert(typeof(ExceptionPlayer) == "Instance" and game.IsA(ExceptionPlayer, "Player"), "[Eventio.RemoteSignal]: Passed wrong first argument into :FireExcept(ExceptionPlayer: Player, ...). Got "..typeof(ExceptionPlayer))
	
	if isServer then
		for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
			if plr ~= ExceptionPlayer then
				self._object:FireClient(plr, ...)
			end
		end
	else
		error("[Eventio.RemoteSignal]: Tried using :FireExcept() on a RemoteSignal from client.")
	end
end

--// Export module

return RemoteSignal