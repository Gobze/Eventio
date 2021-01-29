--// BaseInvoke: Invokes and RemoteInvokes inherit from this class

local BaseInvoke = {}
BaseInvoke.__index = BaseInvoke

local Promise = require(script.Parent.Parent:WaitForChild("Util"):WaitForChild("Promise"))

function BaseInvoke:Connect(Callback): ()
	assert(typeof(Callback) == "function", "Passed wrong first argument into :Connect(Callback: (...) -> (...)). Got " .. typeof(Callback))

	self._object[self._callback] = Callback
end

function BaseInvoke:Invoke(Player, ...) --> Promise
	if self._checkForPlayer then
		assert(typeof(Player) == "Instance" and game.IsA(Player, "Player"), "Passed wrong first argument into :Invoke(Player: Player, ...). Got " .. typeof(Player))
	end
	local args = {Player, ...}
	return Promise.new(function(resolve)
		resolve(self._object[self._invoker](self._object, unpack(args)))
	end)
end

function BaseInvoke:InvokeAsync(Player, ...) --// If you feel like yielding
	if self._checkForPlayer then
		assert(typeof(Player) == "Instance" and game.IsA(Player, "Player"), "Passed wrong first argument into :InvokeAsync(Player: Player, ...). Got " .. typeof(Player))
	end
	return self._object[self._invoker](self._object, Player, ...)
end

function BaseInvoke:__call(...) --// Allows to create invokes like Eventio.Invoke()
	return self.new(...)
end

return BaseInvoke
