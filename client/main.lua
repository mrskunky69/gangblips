local RSGCore = exports['rsg-core']:GetCoreObject()
local blips = {}
local playerGang = nil

local function CreateOrUpdateBlip(playerId, blipData)
    if blipData.gang ~= playerGang then return end  -- Only create blips for players in the same gang
    
    if blips[playerId] then
        RemoveBlip(blips[playerId])
    end
    local blip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, blipData.coords.x, blipData.coords.y, blipData.coords.z)
    
    if blip then
        local blipSprite = Config.DefaultBlipSprite or GetHashKey("blip_ambient_ped_medium")
        Citizen.InvokeNative(0x74F74D3207ED525C, blip, blipSprite, 1) -- SetBlipSprite
        Citizen.InvokeNative(0xD3F08C6ECD625A16, blip, Config.DefaultBlipScale or 0.2) -- SetBlipScale
        Citizen.InvokeNative(0x662D364ABF16DE2F, blip, blipData.blipColor) -- SetBlipColor
        Citizen.InvokeNative(0x9CB1A1623062F402, blip, blipData.name) -- SetBlipName
        
        blips[playerId] = blip
    end
end

RegisterNetEvent('madv.gps:client:UpdateAllBlips', function(blipData)
    for playerId, data in pairs(blipData) do
        if tonumber(playerId) ~= GetPlayerServerId(PlayerId()) then
            CreateOrUpdateBlip(playerId, data)
        end
    end
    
    -- Remove blips for players no longer in the data or with different gangs
    for playerId, blip in pairs(blips) do
        if not blipData[playerId] or blipData[playerId].gang ~= playerGang then
            RemoveBlip(blip)
            blips[playerId] = nil
        end
    end
end)

RegisterNetEvent('RSGCore:Client:OnPlayerLoaded', function()
    RSGCore.Functions.TriggerCallback('madv.gps:server:GetAllBlipData', function(blipData, gang)
        playerGang = gang
        for playerId, data in pairs(blipData) do
            if tonumber(playerId) ~= GetPlayerServerId(PlayerId()) then
                CreateOrUpdateBlip(playerId, data)
            end
        end
    end)
end)

-- Add an event to update the player's gang when it changes
RegisterNetEvent('RSGCore:Client:OnGangUpdate', function(gang)
    playerGang = gang.name
    -- Remove all existing blips as the gang has changed
    for playerId, blip in pairs(blips) do
        RemoveBlip(blip)
        blips[playerId] = nil
    end
    -- Request updated blip data
    RSGCore.Functions.TriggerCallback('madv.gps:server:GetAllBlipData', function(blipData)
        for playerId, data in pairs(blipData) do
            if tonumber(playerId) ~= GetPlayerServerId(PlayerId()) then
                CreateOrUpdateBlip(playerId, data)
            end
        end
    end)
end)