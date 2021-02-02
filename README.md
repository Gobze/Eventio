# Eventio

Eventio - Enhance your Events. A Library for Roblox.

More information about the library here: https://devforum.roblox.com/t/eventio-enhance-your-events/1020659

Shortly, Eventio wraps Bindable/Remote Events and Functions which greatly simplifies their usage.
Example code:

*Server:*
`local Eventio = require(game.ReplicatedStorage.Eventio) --// Get the library
local myRemote = Eventio.RemoteSignal.new("myRemote") --// Get "myRemote" RemoteSignal

game.Players.PlayerAdded:Connect(function(player)
    wait(1) --// Making sure they loaded
    myRemote:Fire(player, "Hi!")
end)`

*Client:*
`local Eventio = require(game.ReplicatedStorage.Eventio)
local myRemote = Eventio.RemoteSignal.new("myRemote")

myRemote:Connect(print) --> Hi!`
