local Config <const>, Inventory = require 'config'

if Config.Inventory == "qb" then
    Inventory = exports["qb-inventory"]
elseif Config.Inventory == "esx" then
    Inventory = exports["es_extended"]:getSharedObject()
elseif Config.Inventory == "ox" then
    Inventory = exports.ox_inventory
end

if not Inventory then
    return error("Inventory script not found (esx/qb/ox)", 2)
end

RegisterNetEvent('src-weed:server:interact', function(key, i)
    local _source = source
    if not i or not key then return DropPlayer(_source, Config.Ui.HackNotify.text) end

    local ped = GetPlayerPed(_source)
    local pedCoords = GetEntityCoords(ped)
    local coords = Config.Locations[key][i]
    local distance = #(pedCoords - coords)

    if distance > Config.Distance then return DropPlayer(_source, Config.Ui.HackNotify.text) end

    if Config.Inventory == 'esx' then
        local player = Inventory.GetPlayerFromId(_source)
        if player then
            if key == 'WeedLocations' then
                if player.canCarryItem(Config.Weed.WeedPick.Item, Config.Weed.WeedPick.amount) then
                    player.addInventoryItem(Config.Weed.WeedPick.Item, Config.Weed.WeedPick.amount)
                    TriggerClientEvent('ox_lib:notify', _source, Config.Ui.Notify)
                else
                    TriggerClientEvent('ox_lib:notify', _source, Config.Ui.NotifyErrorFull)
                end
            elseif key == 'Procces' then
                if player.getInventoryItem(Config.Weed.WeedPick.Item).count < Config.Weed.WeedProccess.ProccessItem then
                    return TriggerClientEvent('ox_lib:notify', _source, Config.Ui.NotifyError)
                end
                player.removeInventoryItem(Config.Weed.WeedPick.Item, Config.Weed.WeedProccess.ProccessItem)
                Wait(300)
                player.addInventoryItem(Config.Weed.WeedProccess.Item, Config.Weed.WeedProccess.amount)
                TriggerClientEvent('ox_lib:notify', _source, Config.Ui.NotifyProccess)
            end
        end
    else
        if key == 'WeedLocations' then
            if Inventory:AddItem(_source, Config.Weed.WeedPick.Item, Config.Weed.WeedPick.amount) then
                TriggerClientEvent('ox_lib:notify', _source, Config.Ui.Notify)
            else
                TriggerClientEvent('ox_lib:notify', _source, Config.Ui.NotifyErrorFull)
            end
        elseif key == 'Procces' then
            if Config.Inventory == 'qb' then
                if not Inventory:HasItem(_source, Config.Weed.WeedPick.Item, Config.Weed.WeedProccess.ProccessItem) then
                    return TriggerClientEvent('ox_lib:notify', _source, Config.Ui.NotifyError)
                end
            elseif Config.Inventory == 'ox' then
                if Inventory:GetItemCount(_source, Config.Weed.WeedPick.Item, Config.Weed.WeedProccess.ProccessItem) < Config.Weed.WeedProccess.ProccessItem then
                    return TriggerClientEvent('ox_lib:notify', _source, Config.Ui.NotifyError)
                end
            end
            Inventory:RemoveItem(_source, Config.Weed.WeedPick.Item, Config.Weed.WeedProccess.ProccessItem)
            Wait(300)
            Inventory:AddItem(_source, Config.Weed.WeedProccess.Item, Config.Weed.WeedProccess.amount)
            TriggerClientEvent('ox_lib:notify', _source, Config.Ui.NotifyProccess)
        end
    end
end)