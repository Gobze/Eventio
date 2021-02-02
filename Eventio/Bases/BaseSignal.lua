--// BaseSignal: Signals and RemoteSignals inherit from this class

local BaseSignal = {}
BaseSignal.__index = BaseSignal

function BaseSignal:Fire(Player, ...): ()
	assert(self._object and self._object.Parent, tostring(self) .. " was destroyed!")
	if self._assertPlrArg then
		assert(typeof(Player) == "Instance" and game.IsA(Player, "Player"), "Passed wrong first argument into :Fire(Player: Player, ...). Got " .. typeof(Player))
	end

	self._object[self._caller](self._object, Player, ...)
end

function BaseSignal:Connect(Callback): RBXScriptConnection
	assert(self._object and self._object.Parent, tostring(self) .. " was destroyed!")
	assert(typeof(Callback) == "function", "Passed wrong first argument into :Connect(Callback: (...) -> void) -> RBXScriptConnection. Got " .. typeof(Callback))

	local connection = self._object[self._signal]:Connect(Callback)
	table.insert(self.Connections, connection)
	return connection
end

function BaseSignal:ConnectCall(Callback, ...): RBXScriptConnection
	assert(self._object and self._object.Parent, tostring(self) .. " was destroyed!")
	assert(typeof(Callback) == "function", "Passed wrong first argument into :ConnectCall(Callback: (...Args) -> void, ...Args) -> RBXScriptConnection. Got " .. typeof(Callback))
	local args = {...}

	local connection = self._object[self._signal]:Connect(function()
		return Callback(unpack(args))
	end)
	table.insert(self.Connections, connection)
	return connection
end

function BaseSignal:Wait()
	assert(self._object and self._object.Parent, tostring(self) .. " was destroyed!")
	return self._object[self._signal]:Wait()
end

function BaseSignal:Once(Callback): RBXScriptConnection
	assert(self._object and self._object.Parent, tostring(self) .. " was destroyed!")
	assert(typeof(Callback) == "function", "Passed wrong first argument into :Once(Callback: (...) -> void) -> RBXScriptConnection. Got " .. typeof(Callback))

	local connection
	connection = self._object[self._signal]:Connect(function(...)
		connection:Disconnect()
		Callback(...)
	end)
	table.insert(self.Connections, connection)
	return connection
end

function BaseSignal:OnceCall(Callback, ...): RBXScriptConnection
	assert(self._object and self._object.Parent, tostring(self) .. " was destroyed!")
	assert(typeof(Callback) == "function", "Passed wrong first argument into :OnceCall(Callback: (...Args) -> void, ...Args) -> RBXScriptConnection. Got " .. typeof(Callback))
	local args = {...}

	local connection
	connection = self._object[self._signal]:Connect(function()
		connection:Disconnect()
		Callback(unpack(args))
	end)
	table.insert(self.Connections, connection)
	return connection
end

function BaseSignal:DisconnectAll(): () --// Disconnects all the connections gathered on the current signal
	for index, conn in pairs(self.Connections) do
		if conn.Connected then
			conn:Disconnect()
		end
		table.remove(self.Connections, index)
	end
end

function BaseSignal:Destroy(): () --// Destroys the instance associated with the signal, blocks the usage of all signals connected to the destroyed bindablevent
	assert(self._object and self._object.Parent, tostring(self) .. " was already destroyed!")
	self._object:Destroy()
	self:DisconnectAll() --// Wipe out the Connections table
end

function BaseSignal:__call(...) --// Allows to create signals like Eventio.Signal()
	return self.new(...)
end

return BaseSignal
