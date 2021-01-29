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

local isServer = game:GetService("RunService"):IsServer()

if isServer and (not script:FindFirstChild("Storage")) then --// Create storage
	local Storage = Instance.new("Folder")
	Storage.Parent = script
	Storage.Name = "Storage"

	for _, name in pairs({"Signals", "RemoteSignals", "Invokes", "RemoteInvokes"}) do
		local Folder = Instance.new("Folder")
		Folder.Parent = script
		Folder.Name = name
	end
end

Eventio.Signal = require(script.Signal) --// BindableEvent
Eventio.RemoteSignal = require(script.RemoteSignal) --// RemoteEvent
Eventio.Invoke = require(script.Invoke) --// BindableFunction
Eventio.RemoteInvoke = require(script.RemoteInvoke) --// RemoteFunction

return Eventio
