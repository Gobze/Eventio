--// Signal class - BindableEvent wrapper

local BaseSignal = require(script.Parent:WaitForChild("Bases"):WaitForChild("BaseSignal"))
local Signal = setmetatable({}, BaseSignal) --// We inherit from BaseSignal class
Signal.__index = Signal
Signal.ClassName = "Signal"

local storage = script.Parent:WaitForChild("Storage"):WaitForChild("Signals")

--// Constructor

function Signal.new(Data: string | BindableEvent | nil)
	local t = typeof(Data)
	assert((t == "nil") or (t == "string") or (t == "Instance" and game.IsA(Data, "BindableEvent")), "Passed wrong first argument into .new(Data: string | BindableEvent | nil). Got " .. t)

	local self = setmetatable({
		_connections = {},
		_caller = "Fire",
		_signal = "Event"
	}, Signal)

	if t == "Instance" then
		self._object = Data
	elseif t == "nil" then
		self._object = Instance.new("BindableEvent", storage)
	else
		self.Name = Data
		self._object = storage:FindFirstChild(Data)
		if not self._object then
			self._object = Instance.new("BindableEvent", storage)
			self._object.Name = Data
		end
	end

	return self
end

--// Type checker

function Signal.Is(Anything: any): boolean
	return typeof(Anything) == "table" and getmetatable(Anything) == Signal
end

--// For debugging

function Signal:__tostring()
	return self.ClassName .. (self.Name and "(" .. self.Name .. ")" or "")
end

--// Export module

return Signal
