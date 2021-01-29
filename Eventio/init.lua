--// Eventio
--// Event management library
--// By Gobzen

--// Uses Promise module by evaera

--[[
	Code example:

	--// Server
	
	local Eventio = require(game.ReplicatedStorage.Eventio)
	local mySignal = Eventio.RemoteSignal.new("mySignal")
	
	mySignal:Connect(print)
	
	--// Client
	
	local Eventio = require(game.ReplicatedStorage.Eventio)
	local mySignal = Eventio.RemoteSignal.new("mySignal")
	
	mySignal:Fire("hi!") --> hi!

]]

local Eventio = {}

Eventio.Signal = require(script.Signal) --// BindableEvent
Eventio.RemoteSignal = require(script.RemoteSignal) --// RemoteEvent
Eventio.Invoke = require(script.Invoke) --// BindableFunction
Eventio.RemoteInvoke = require(script.RemoteInvoke) --// RemoteFunction

return Eventio
