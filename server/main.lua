local RSGCore = exports['rsg-core']:GetCoreObject()
-- Table to store player blips
local playerBlips = {}

-- Function to create or update a player's blip
local function UpdatePlayerBlip(playerId)
    local Player = RSGCore.Functions.GetPlayer(playerId)
    if not Player then return end
    
    local gangName = Player.PlayerData.gang.name
    local blipColor = Config.DefaultBlipColor or 0
    local isTracked = false
    
    if Config.Gangs[gangName] and Config.Gangs[gangName].tracked then
        blipColor = Config.Gangs[gangName].blipColor
        isTracked = true
    end
    
    if isTracked then
        local ped = GetPlayerPed(playerId)
        if DoesEntityExist(ped) then
            local coords = GetEntityCoords(ped)
            local firstName = Player.PlayerData.charinfo.firstname
            local lastName = Player.PlayerData.charinfo.lastname
            local blipName = string.format("%s %s (%s)", firstName, lastName, gangName)
            playerBlips[playerId] = {
                coords = coords,
                blipColor = blipColor,
                name = blipName,
                gang = gangName
            }
        end
    else
        playerBlips[playerId] = nil
    end
end

-- Function to update all player blips
local function UpdateAllPlayerBlips()
    for _, playerId in ipairs(GetPlayers()) do
        UpdatePlayerBlip(tonumber(playerId))
    end
end

-- Function to send blip data to all clients
local function SendBlipDataToAllClients()
    TriggerClientEvent('madv.gps:client:UpdateAllBlips', -1, playerBlips)
end

-- Update blips periodically
Citizen.CreateThread(function()
    while true do
        UpdateAllPlayerBlips()
        SendBlipDataToAllClients()
        Citizen.Wait(5000) -- Update every 5 seconds
    end
end)

-- Event handlers
RegisterNetEvent('RSGCore:Server:OnPlayerLoaded', function(source)
    UpdatePlayerBlip(source)
    SendBlipDataToAllClients()
end)

AddEventHandler('playerDropped', function(reason)
    playerBlips[source] = nil
    SendBlipDataToAllClients()
end)

RegisterNetEvent('madv.gps:server:UpdateGang', function()
    local src = source
    UpdatePlayerBlip(src)
    SendBlipDataToAllClients()
end)

-- Callback for initial blip data (in case a client needs it)
RSGCore.Functions.CreateCallback('madv.gps:server:GetAllBlipData', function(source, cb)
    local Player = RSGCore.Functions.GetPlayer(source)
    local playerGang = Player.PlayerData.gang.name
    local filteredBlips = {}
    
    for playerId, blipData in pairs(playerBlips) do
        if blipData.gang == playerGang then
            filteredBlips[playerId] = blipData
        end
    end
    
    cb(filteredBlips, playerGang)
end)