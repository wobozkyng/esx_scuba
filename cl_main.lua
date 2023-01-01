local has_tank = false
local oxy_tank = false
local oxy_value = 0
local diving_swim = false
local ox_inventory = GetResourceState('ox_inventory') == 'started' or GetResourceState('ox_inventory') == 'starting'

Config.OxInventory = ox_inventory

RegisterNetEvent('esx_scuba:oxygenHandle', function(type, value) --event to handle tank refill
    local itemcount = getScubaItemCount(Config.scubaItemName)
    if itemcount < 1 then
        return sendnotification(TranslateCap('no_tank'))
    end
    if type == 'refill' then
        oxy_value = value and value*4 or 400
        sendnotification(TranslateCap('tank_loaded', oxy_value/Config.fulltank*100, '%'))
    end
    if type == 'check' then
        sendnotification(TranslateCap('tank_capacity', oxy_value/Config.fulltank*100, '%'))
    end
    if type == 'pay' then
        TriggerServerEvent('esx_scuba:oxygenRefillPay')
    end
end)

RegisterNetEvent('esx_scuba:wear', function(name)
    local playerPed = PlayerPedId()
    local pedModel = GetEntityModel(playerPed)
    local handle = applyScuba(name, playerPed, pedModel)
    if not handle.getScuba() then
        handle.setScuba()
    else
        if not Config.drop_to_reset then
            handle.resetScuba()
        end
    end
end)

ESX.RegisterInput('scubalight', 'Turn Scuba Light On/Off', 'keyboard', Config.scubalightKeybind, function()
    local playerPed = PlayerPedId()
    local pedModel = GetEntityModel(playerPed)
    local LightEnabled = IsScubaGearLightEnabled(playerPed)
    if isWearingScuba(playerPed, pedModel) then
        if LightEnabled then
            SetEnableScubaGearLight(playerPed, false)
        else
            SetEnableScubaGearLight(playerPed, true)
        end
    end
end, function()
    
end)

if Config.OxInventory then
    -- exports for ox_inventory
    exports('wear', function(data, slot)
        TriggerEvent('esx_scuba:wear', data.name)
    end)

    -- ox_inventory updates check
    AddEventHandler('ox_inventory:updateInventory', function(changes)
        local playerPed = PlayerPedId()
        local pedModel = GetEntityModel(playerPed)
        if isWearingScuba(playerPed, pedModel) or isWearingScuba(playerPed, pedModel, true) then
            local equipment = {
                Config.scubaItemName,
                Config.finsItemName
            }
            local items = exports.ox_inventory:Search('count', equipment)
            for i = 1, #equipment do
                local name = equipment[i]
                if items[name] < 1 then
                    applyScuba(name, playerPed, pedModel).resetScuba()
                end
            end
        end
    end)

    AddEventHandler('onResourceStop', function(resourceName)
        if resourceName ~= GetCurrentResourceName() then
            return
        end
        local playerPed = PlayerPedId()
        local pedModel = GetEntityModel(playerPed)
        if isWearingScuba(playerPed, pedModel) or isWearingScuba(playerPed, pedModel, true) then
            local equipment = {
                Config.scubaItemName,
                Config.finsItemName
            }
            for i = 1, #equipment do
                local name = equipment[i]
                applyScuba(name, playerPed, pedModel).resetScuba(true)
            end
        end
    end)
else
    -- usable item client event
    RegisterNetEvent('esx_scuba:useItem', function(name)
        TriggerEvent('esx_scuba:wear', name)
    end)

    -- esx inventory remove item check
    RegisterNetEvent('esx:removeInventoryItem')
	AddEventHandler('esx:removeInventoryItem', function(item, count, showNotification)
        local playerPed = PlayerPedId()
        local pedModel = GetEntityModel(playerPed)
        if isWearingScuba(playerPed, pedModel) or isWearingScuba(playerPed, pedModel, true) then
            local equipment = {
                Config.scubaItemName,
                Config.finsItemName
            }

            local items = ESX.SearchInventory(equipment, true)
            if items[item] and count < 1 then
                applyScuba(item, playerPed, pedModel).resetScuba()
            end
        end
    end)

    AddEventHandler('onResourceStop', function(resourceName)
        if resourceName ~= GetCurrentResourceName() then
            return
        end
        local playerPed = PlayerPedId()
        local pedModel = GetEntityModel(playerPed)
        if isWearingScuba(playerPed, pedModel) or isWearingScuba(playerPed, pedModel, true) then
            local equipment = {
                Config.scubaItemNsendNotificationame,
                Config.finsItemName
            }
            for i = 1, #equipment do
                local name = equipment[i]
                applyScuba(name, playerPed, pedModel).resetScuba(true)
            end
        end
    end)
end

CreateThread(function()
    if Config.EnableBlip then
        CreateBlips()
    end

    while true do
        local playerPed = PlayerPedId()
        local pcoords = GetEntityCoords(playerPed)
        if IsPedSwimmingUnderWater(playerPed) then
            if oxy_tank and oxy_value > 0.0 then
                oxy_value -= 1
                if tankAlert(oxy_value) then
                    sendnotification(TranslateCap('tank_remaining', oxy_value/Config.fulltank*100, '%'))
                end
            else
                SetPedConfigFlag(playerPed, 3, true)
            end
        end
        for k, v in ipairs(Config.Locations) do
            local distance = #(pcoords - v)
            if distance <= 2.0 then
                if not inMarkerZone then
                    inMarkerZone = true
                    DrawMarkerThread(v)
                end
                break
            end
        end
        Wait(1000) --each seconds
    end
end)

CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local pedModel = GetEntityModel(playerPed)
        if isWearingScuba(playerPed, pedModel) then
            has_tank = true
            if not oxy_tank and oxy_value > 1 then
                oxy_tank = true
                SetPedConfigFlag(playerPed, 3, false)
                sendnotification(TranslateCap('tank_available', oxy_value/Config.fulltank*100, '%'))
            end
        else
            has_tank = false
            if IsScubaGearLightEnabled(playerPed) then
                SetEnableScubaGearLight(playerPed, false)
            end
            if oxy_tank then
                oxy_tank = false
                SetPedConfigFlag(playerPed, 3, true)
                sendnotification(TranslateCap('tank_not_available'))
            end
        end
        if isWearingScuba(playerPed, pedModel, true) then
            if not diving_swim then
                diving_swim = true
                SetEnableScuba(playerPed, true)
                sendnotification(TranslateCap('diving_fins'))
            end
        else
            if diving_swim then
                diving_swim = false
                SetEnableScuba(playerPed, false)
                sendnotification(TranslateCap('diving_no_fins'))
            end
        end
        Wait(500)
    end
end)