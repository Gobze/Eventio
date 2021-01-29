--// BaseSignal: Signals and RemoteSignals inherit from this class

local BaseSignal = {}
BaseSignal.__index = BaseSignal

function BaseSignal:Fire(Player, ...): ()
	if self._checkForPlayer then
		assert(typeof(Player) == "Instance" and game.IsA(Player, "Player"), self._errSrc .. "Passed wrong first argument into :Fire(Player: Player, ...). Got " .. typeof(Player))
	end
	
	self._object[self._caller](self._object, Player, ...)
end

function BaseSignal:Connect(Callback): ()
	assert(typeof(Callback) == "function", self._errSrc .. "Passed wrong first argument into :Connect(Callback: (...) -> void). Got " .. typeof(Callback))

	return self._signal:Connect(Callback)
end

function BaseSignal:Wait()
	return self._signal:Wait()
end

function BaseSignal:Once(Callback): ()
	assert(typeof(Callback) == "function", self._errSrc .. "Passed wrong first argument into :Connect(Callback: (...) -> void). Got " .. typeof(Callback))
	
	local connection
	connection = self._signal:Connect(function(...)
		connection:Disconnect()
		Callback(...)
	end)
	return connection
end

function BaseSignal:__call(...) --// Allows to create signals like Eventio.Signal()
	return self.new(...)
end

return BaseSignal
