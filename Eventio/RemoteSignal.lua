--// RemoteSignal class - RemoteEvent wrapper

local BaseSignal = require(script.Parent:WaitForChild("Bases"):WaitForChild("BaseSignal"))
local RemoteSignal = setmetatable({}, BaseSignal)
RemoteSignal.__index = RemoteSignal
RemoteSignal.ClassName = "RemoteSignal"

local IsServer = game:GetService("RunService"):IsServer()
local Storage = script.Parent:WaitForChild("Storage"):WaitForChild("RemoteSignals")
local Players = game:GetService("Players")

--/ Constructor

function RemoteSignal.new(Data: string | RemoteEvent)
	local t = typeof(Data)
	assert((t == "string") or (t == "Instance" and game.IsA(Data, "RemoteEvent")), "Passed wrong first argument into .new(Data: string | RemoteEvent) -> RemoteSignal. Got " .. t)

	local self = setmetatable({
		_connections = {},
		_assertPlrArg = IsServer,
		_caller = IsServer and "FireClient" or "FireServer",
		_signal = IsServer and "OnServerEvent" or "OnClientEvent"
	}, RemoteSignal)

	if t == "Instance" then
		self._object = Data
	else
		self.Name = Data
		self._object = Storage:FindFirstChild(Data)
		if not self._object then
			if IsServer then
				self._object = Instance.new("RemoteEvent", Storage)
				self._object.Name = Data
			else
				self._object = Storage:WaitForChild(Data) --// Client waits for the object to be made on server
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
	assert(RemoteSignal.Is(self), ":FireAll(...) -> void must be used on a RemoteSignal using :")
	assert(IsServer, "Tried using :FireAll(...) -> void on a RemoteSignal from client.")
	assert(self._object and self._object.Parent, tostring(self) .. " was destroyed!")

	self._object:FireAllClients(...)
end

function RemoteSignal:FireExcept(ExceptionPlayer: Player, ...): ()
	assert(RemoteSignal.Is(self), ":FireExcept(ExceptionPlayer: Player, ...) -> void must be used on a RemoteSignal using :")
	assert(IsServer, "Tried using :FireExcept(ExceptionPlayer: Player, ...) -> void on a RemoteSignal from client.")
	assert(self._object and self._object.Parent, tostring(self) .. " was destroyed!")
	assert(typeof(ExceptionPlayer) == "Instance" and game.IsA(ExceptionPlayer, "Player"), "Passed wrong first argument into :FireExcept(ExceptionPlayer: Player, ...) -> void. Got "..typeof(ExceptionPlayer))

	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= ExceptionPlayer then
			self._object:FireClient(plr, ...)
		end
	end
end

function RemoteSignal:FireChosen(ChosenPlayers: {Player}, ...): ()
	assert(RemoteSignal.Is(self), ":FireChosen(ChosenPlayers: {Player}, ...) -> void must be used on a RemoteSignal using :")
	assert(IsServer, "Tried using :FireChosen(ChosenPlayers: {Player}, ...) -> void on a RemoteSignal from client.")
	assert(self._object and self._object.Parent, tostring(self) .. " was destroyed!")
	assert(typeof(ChosenPlayers) == "table" and (typeof(ChosenPlayers[1]) == "Instance" and game.IsA(ChosenPlayers[1], "Player")), "Passed wrong first argument into :FireChosen(ChosenPlayers: {Player}, ...) -> void. Got "..typeof(ChosenPlayers))

	for _, plr in pairs(ChosenPlayers) do
		self._object:FireClient(plr, ...)
	end
end

--// For debugging

function RemoteSignal:__tostring()
	return self.ClassName .. (self.Name and "(" .. self.Name .. ")" or "")
end

--// Export module

return RemoteSignal
