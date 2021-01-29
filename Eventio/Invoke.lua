--// Invoke class - BindableFunction wrapper

local BaseInvoke = require(script.Parent:WaitForChild("Bases"):WaitForChild("BaseInvoke"))
local Invoke = setmetatable({}, BaseInvoke)
Invoke.__index = Invoke

local storage = script.Parent:WaitForChild("Storage"):WaitForChild("Invokes")

--// Constructor

function Invoke.new(Data: string | BindableFunction | nil)
	local t = typeof(Data)
	assert((t == "nil") or (t == "string") or (t == "Instance" and game.IsA(Data, "BindableFunction")), "Passed wrong first argument into .new(Data: string | BindableFunction | nil). Got " .. t)

	local self = setmetatable({
		_invoker = "Invoke",
		_callback = "OnInvoke"
	}, Invoke)

	if t == "Instance" then
		self._object = Data
	elseif t == "nil" then
		self._object = Instance.new("BindableFunction", storage)
	else
		self.Name = Data
		self._object = storage:FindFirstChild(Data)
		if not self._object then
			self._object = Instance.new("BindableFunction", storage)
			self._object.Name = Data
		end
	end

	return self
end

--// Type checker

function Invoke.Is(Anything: any): boolean
	return typeof(Anything) == "table" and getmetatable(Anything) == Invoke
end

--// Export module

return Invoke
