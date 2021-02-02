--// BaseSignal: Signals and RemoteSignals inherit from this class

local BaseSignal = {}
BaseSignal.__index = BaseSignal

function BaseSignal:Fire(Player, ...): ()
	assert(typeof(self) == "table" and (self.ClassName == "Signal" or self.ClassName == "RemoteSignal"), ":Fire(...) -> void must be used on a Signal/RemoteSignal using :")
	assert(self._object and self._object.Parent, tostring(self) .. " was destroyed!")
	if self._assertPlrArg then
		assert(typeof(Player) == "Instance" and game.IsA(Player, "Player"), "Passed wrong first argument into :Fire(Player: Player, ...). Got " .. typeof(Player))
	end

	self._object[self._caller](self._object, Player, ...)
end

function BaseSignal:Connect(Callback): RBXScriptConnection
	assert(typeof(self) == "table" and (self.ClassName == "Signal" or self.ClassName == "RemoteSignal"), ":Connect(Callback: (...) -> void) -> RBXScriptConnection must be used on a Signal/RemoteSignal using :")
	assert(self._object and self._object.Parent, tostring(self) .. " was destroyed!")
	assert(typeof(Callback) == "function", "Passed wrong first argument into :Connect(Callback: (...) -> void) -> RBXScriptConnection. Got " .. typeof(Callback))

	local connection = self._object[self._signal]:Connect(Callback)
	self._connections[#self._connections + 1] = connection
	return connection
end

function BaseSignal:ConnectCall(Callback, ...): RBXScriptConnection
	assert(typeof(self) == "table" and (self.ClassName == "Signal" or self.ClassName == "RemoteSignal"), ":ConnectCall(Callback: (...Args) -> void, ...Args) -> RBXScriptConnection must be used on a Signal/RemoteSignal using :")
	assert(self._object and self._object.Parent, tostring(self) .. " was destroyed!")
	assert(typeof(Callback) == "function", "Passed wrong first argument into :ConnectCall(Callback: (...Args) -> void, ...Args) -> RBXScriptConnection. Got " .. typeof(Callback))
	local args = {...}

	local connection = self._object[self._signal]:Connect(function()
		return Callback(unpack(args))
	end)
	self._connections[#self._connections + 1] = connection
	return connection
end

function BaseSignal:Wait()
	assert(typeof(self) == "table" and (self.ClassName == "Signal" or self.ClassName == "RemoteSignal"), ":Wait() -> (...) must be used on a Signal/RemoteSignal using :")
	assert(self._object and self._object.Parent, tostring(self) .. " was destroyed!")
	return self._object[self._signal]:Wait()
end

function BaseSignal:Once(Callback): RBXScriptConnection
	assert(typeof(self) == "table" and (self.ClassName == "Signal" or self.ClassName == "RemoteSignal"), ":Once(Callback: (...) -> void) -> RBXScriptConnection must be used on a Signal/RemoteSignal using :")
	assert(self._object and self._object.Parent, tostring(self) .. " was destroyed!")
	assert(typeof(Callback) == "function", "Passed wrong first argument into :Once(Callback: (...) -> void) -> RBXScriptConnection. Got " .. typeof(Callback))

	local connection
	connection = self._object[self._signal]:Connect(function(...)
		connection:Disconnect()
		Callback(...)
	end)
	self._connections[#self._connections + 1] = connection
	return connection
end

function BaseSignal:OnceCall(Callback, ...): RBXScriptConnection
	assert(typeof(self) == "table" and (self.ClassName == "Signal" or self.ClassName == "RemoteSignal"), ":OnceCall(Callback: (...Args) -> void, ...Args) -> RBXScriptConnection must be used on a Signal/RemoteSignal using :")
	assert(self._object and self._object.Parent, tostring(self) .. " was destroyed!")
	assert(typeof(Callback) == "function", "Passed wrong first argument into :OnceCall(Callback: (...Args) -> void, ...Args) -> RBXScriptConnection. Got " .. typeof(Callback))
	local args = {...}

	local connection
	connection = self._object[self._signal]:Connect(function()
		connection:Disconnect()
		Callback(unpack(args))
	end)
	self._connections[#self._connections + 1] = connection
	return connection
end

function BaseSignal:DisconnectAll(): () --// Disconnects all the connections gathered on the current signal
	assert(typeof(self) == "table" and (self.ClassName == "Signal" or self.ClassName == "RemoteSignal"), ":DisconnectAll() -> void must be used on a Signal/RemoteSignal using :")
	for index, conn in pairs(self._connections) do
		conn:Disconnect()
		self._connections[index] = nil
	end
end

function BaseSignal:Destroy(): () --// Destroys the instance associated with the signal, blocks the usage of all signals connected to the destroyed bindablevent
	assert(typeof(self) == "table" and (self.ClassName == "Signal" or self.ClassName == "RemoteSignal"), ":Destroy() -> void must be used on a Signal/RemoteSignal using :")
	assert(self._object and self._object.Parent, tostring(self) .. " was already destroyed!")
	self._object:Destroy()
end

function BaseSignal:__call(...) --// Allows to create signals like Eventio.Signal()
	return self.new(...)
end

return BaseSignal
