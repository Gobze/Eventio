--// BaseInvoke: Invokes and RemoteInvokes inherit from this class

local BaseInvoke = {}
BaseInvoke.__index = BaseInvoke

local Promise = require(script.Parent.Parent:WaitForChild("Util"):WaitForChild("Promise"))

function BaseInvoke:Connect(Callback): ()
	assert(self._object and self._object.Parent, self.ClassName .. (self.Name and "(" .. self.Name .. ")" or "") .. " was destroyed!")
	assert(typeof(Callback) == "function", "Passed wrong first argument into :Connect(Callback: (...) -> (...)). Got " .. typeof(Callback))

	self._object[self._callback] = Callback
end

function BaseInvoke:Invoke(Player, ...) --> Promise
	assert(self._object and self._object.Parent, self.ClassName .. (self.Name and "(" .. self.Name .. ")" or "") .. " was destroyed!")
	if self._assertPlrArg then
		assert(typeof(Player) == "Instance" and game.IsA(Player, "Player"), "Passed wrong first argument into :Invoke(Player: Player, ...). Got " .. typeof(Player))
	end
	local args = {Player, ...}
	return Promise.new(function(resolve)
		resolve(self._object[self._invoker](self._object, unpack(args)))
	end)
end

function BaseInvoke:InvokeAsync(Player, ...) --// If you feel like yielding
	assert(self._object and self._object.Parent, self.ClassName .. (self.Name and "(" .. self.Name .. ")" or "") .. " was destroyed!")
	if self._assertPlrArg then
		assert(typeof(Player) == "Instance" and game.IsA(Player, "Player"), "Passed wrong first argument into :InvokeAsync(Player: Player, ...). Got " .. typeof(Player))
	end
	return self._object[self._invoker](self._object, Player, ...)
end

function BaseInvoke:Destroy(): ()
	assert(self._object and self._object.Parent, self.ClassName .. (self.Name and "(" .. self.Name .. ")" or "") .. " was already destroyed!")
	self._object:Destroy()
end

function BaseInvoke:__call(...) --// Allows to create invokes like Eventio.Invoke()
	return self.new(...)
end

return BaseInvoke
