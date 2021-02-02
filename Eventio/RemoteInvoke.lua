--// RemoteInvoke class - RemoteFunction wrapper

local BaseInvoke = require(script.Parent:WaitForChild("Bases"):WaitForChild("BaseInvoke"))
local RemoteInvoke = setmetatable({}, BaseInvoke)
RemoteInvoke.__index = RemoteInvoke
RemoteInvoke.ClassName = "RemoteInvoke"

local Players = game:GetService("Players")
local IsServer = game:GetService("RunService"):IsServer()
local Storage = script.Parent:WaitForChild("Storage"):WaitForChild("RemoteInvokes")

--// Constructor

function RemoteInvoke.new(Data: string | RemoteFunction)
	local t = typeof(Data)
	assert((t == "string") or (t == "Instance" and game.IsA(Data, "RemoteFunction")), "Passed wrong first argument into .new(Data: string | RemoteFunction). Got " .. t)

	local self = setmetatable({
		_assertPlrArg = IsServer,
		_invoker = IsServer and "InvokeClient" or "InvokeServer",
		_callback = IsServer and "OnServerInvoke" or "OnClientInvoke",
	}, RemoteInvoke)

	if t == "Instance" then
		self._object = Data
	else
		self.Name = Data
		self._object = Storage:FindFirstChild(Data)
		if not self._object then
			if IsServer then
				self._object = Instance.new("RemoteFunction", Storage)
				self._object.Name = Data
			else
				self._object = Storage:WaitForChild(Data) --// Client waits for the object to be made on server
			end
		end
	end

	return self
end

--// Type checker

function RemoteInvoke.Is(Anything: any): boolean
	return typeof(Anything) == "table" and getmetatable(Anything) == RemoteInvoke
end

--// Methods

function RemoteInvoke:InvokeAll(...)
	assert(RemoteInvoke.Is(self), ":InvokeAll(...) -> {Player: Promise} must be used on a RemoteInvoke using :")
	assert(IsServer, "Tried using :InvokeAll(...) -> {Player: Promise} on a RemoteInvoke from client.")
	assert(self._object and self._object.Parent, tostring(self) .. " was destroyed!")

	local promises = {}
	for _, plr in pairs(Players:GetPlayers()) do
		promises[plr] = self:Invoke(plr, ...)
	end
	return promises
end

function RemoteInvoke:InvokeExcept(ExceptionPlayer: Player, ...)
	assert(RemoteInvoke.Is(self), ":InvokeExcept(ExceptionPlayer: Player, ...) -> {Player: Promise} must be used on a RemoteInvoke using :")
	assert(IsServer, "Tried using :InvokeExcept(ExceptionPlayer: Player, ...) -> {Player: Promise} on a RemoteInvoke from client.")
	assert(self._object and self._object.Parent, tostring(self) .. " was destroyed!")
	assert(typeof(ExceptionPlayer) == "Instance" and game.IsA(ExceptionPlayer, "Player"), "Passed wrong first argument into :InvokeExcept(ExceptionPlayer: Player, ...) -> {Player: Promise}. Got "..typeof(ExceptionPlayer))

	local promises = {}
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= ExceptionPlayer then
			promises[plr] = self:Invoke(plr, ...)
		end
	end
	return promises
end

function RemoteInvoke:InvokeChosen(ChosenPlayers: {Player}, ...)
	assert(RemoteInvoke.Is(self), ":InvokeChosen(ChosenPlayers: {Player}, ...) -> {Player: Promise} must be used on a RemoteInvoke using :")
	assert(IsServer, "Tried using :InvokeChosen(ChosenPlayers: {Player}, ...) -> {Player: Promise} on a RemoteInvoke from client.")
	assert(self._object and self._object.Parent, tostring(self) .. " was destroyed!")
	assert(typeof(ChosenPlayers) == "table" and (typeof(ChosenPlayers[1]) == "Instance" and game.IsA(ChosenPlayers[1], "Player")), "Passed wrong first argument into :InvokeChosen(ChosenPlayers: {Player}, ...) -> {Player: Promise}. Got "..typeof(ChosenPlayers))

	local promises = {}
	for _, plr in pairs(ChosenPlayers) do
		promises[plr] = self:Invoke(plr, ...)
	end
	return promises
end

--// For debugging

function RemoteInvoke:__tostring()
	return self.ClassName .. (self.Name and "(" .. self.Name .. ")" or "")
end

--// Export module

return RemoteInvoke
