--// RemoteSignal class - RemoteEvent wrapper

local BaseSignal = require(script.Parent:WaitForChild("Bases"):WaitForChild("BaseSignal"))
local RemoteSignal = setmetatable({}, BaseSignal)
RemoteSignal.__index = RemoteSignal
RemoteSignal.ClassName = "RemoteSignal"

local isServer = game:GetService("RunService"):IsServer()
local storage = script.Parent:WaitForChild("Storage"):WaitForChild("RemoteSignals")

--/ Constructor

function RemoteSignal.new(Data: string | RemoteEvent)
	local t = typeof(Data)
	assert((t == "string") or (t == "Instance" and game.IsA(Data, "RemoteEvent")), "Passed wrong first argument into .new(Data: string | RemoteEvent). Got " .. t)

	local self = setmetatable({
		Connections = {},
		_assertPlrArg = isServer,
		_caller = isServer and "FireClient" or "FireServer",
		_signal = isServer and "OnServerEvent" or "OnClientEvent"
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

	return self
end

--// Type checker

function RemoteSignal.Is(Anything: any): boolean
	return typeof(Anything) == "table" and getmetatable(Anything) == RemoteSignal
end

--// Unique Methods

function RemoteSignal:FireAll(...): ()
	assert(self._object.Parent, "Instance associated with the " .. self.ClassName .. (self.Name and "(" .. self.Name .. ")" or "") .. " was destroyed!")
	if isServer then
		self._object:FireAllClients(...)
	else
		error("Tried using :FireAll(...) on a RemoteSignal from client.")
	end
end

function RemoteSignal:FireExcept(ExceptionPlayer: Player, ...): ()
	assert(self._object.Parent, "Instance associated with the " .. self.ClassName .. (self.Name and "(" .. self.Name .. ")" or "") .. " was destroyed!")
	assert(typeof(ExceptionPlayer) == "Instance" and game.IsA(ExceptionPlayer, "Player"), "Passed wrong first argument into :FireExcept(ExceptionPlayer: Player, ...). Got "..typeof(ExceptionPlayer))

	if isServer then
		for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
			if plr ~= ExceptionPlayer then
				self._object:FireClient(plr, ...)
			end
		end
	else
		error("Tried using :FireExcept() on a RemoteSignal from client.")
	end
end

--// For debugging

function RemoteSignal:__tostring()
	return self.ClassName .. (self.Name and "(" .. self.Name .. ")" or "")
end

--// Export module

return RemoteSignal