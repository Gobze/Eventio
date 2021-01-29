--// BaseSignal: Signals and RemoteSignals inherit from this class

local BaseSignal = {}
BaseSignal.__index = BaseSignal

function BaseSignal:Fire(Player, ...): ()
	if self._checkForPlayer then
		assert(typeof(Player) == "Instance" and game.IsA(Player, "Player"), "Passed wrong first argument into :Fire(Player: Player, ...). Got " .. typeof(Player))
	end

	self._object[self._caller](self._object, Player, ...)
end

function BaseSignal:Connect(Callback): RBXScriptConnection
	assert(typeof(Callback) == "function", "Passed wrong first argument into :Connect(Callback: (...) -> void) -> RBXScriptConnection. Got " .. typeof(Callback))

	return self._signal:Connect(Callback)
end

function BaseSignal:ConnectCall(Callback, ...): RBXScriptConnection
	assert(typeof(Callback) == "function", "Passed wrong first argument into :ConnectCall(Callback: (...Args) -> void, ...Args) -> RBXScriptConnection. Got " .. typeof(Callback))
	local args = {...}

	return self._signal:Connect(function()
		return Callback(unpack(args))
	end)
end

function BaseSignal:Wait()
	return self._signal:Wait()
end

function BaseSignal:Once(Callback): RBXScriptConnection
	assert(typeof(Callback) == "function", "Passed wrong first argument into :Once(Callback: (...) -> void) -> RBXScriptConnection. Got " .. typeof(Callback))

	local connection
	connection = self._signal:Connect(function(...)
		connection:Disconnect()
		Callback(...)
	end)
	return connection
end

function BaseSignal:OnceCall(Callback, ...): RBXScriptConnection
	assert(typeof(Callback) == "function", "Passed wrong first argument into :OnceCall(Callback: (...Args) -> void, ...Args) -> RBXScriptConnection. Got " .. typeof(Callback))
	local args = {...}

	local connection
	connection = self._signal:Connect(function()
		connection:Disconnect()
		Callback(unpack(args))
	end)
	return connection
end

function BaseSignal:__call(...) --// Allows to create signals like Eventio.Signal()
	return self.new(...)
end

return BaseSignal
