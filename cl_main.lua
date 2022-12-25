local malePed = `mp_m_freemode_01`
local femalePed = `mp_f_freemode_01`
local maleScubaVariation = 123
local femaleScubaVariation = 153
local maleSwimFins = 67
local femaleSwimFins = 70
local fulltank = 400 --in seconds

local has_tank = false
local oxy_tank = false
local oxy_value = 0
local diving_swim = false

local function notification(text) --can be replaced with other notification function
    print(text)
end

local function tankAlert(value)
    if math.fmod(value, 100) == 0 then --75%, 50%, 25%
        return true
    end
    if value == 40 then --10%
        return true
    end
    if value == 20 then --5%
        return true
    end
    return false
end

RegisterNetEvent('brc-hud:oxygenRefill', function(value) --event to handle tank refill
    oxy_value = value
    notification(("Tank loaded %s %s"):format(oxy_value/fulltank*100, '%'))
end)

Citizen.CreateThread(function()
    while true do
        if IsPedSwimmingUnderWater(PlayerPedId()) then
            if oxy_tank and oxy_value > 0 then
                oxy_value = oxy_value - 1
                if tankAlert(oxy_value) then
                    notification(('Tank capacity %s %s'):format(oxy_value/fulltank*100, '%'))
                end
            else
                SetPedConfigFlag(PlayerPedId(), 3, true)
            end
        end
        Citizen.Wait(1000) --each seconds
    end
end)

Citizen.CreateThread(function()
    while true do
        local player = PlayerPedId()
        local isMale = GetEntityModel(player) == malePed
        if ( isMale and GetPedDrawableVariation(player, 8) == maleScubaVariation ) or ( not isMale and GetPedDrawableVariation(player, 8) == femaleScubaVariation ) then
            has_tank = true
            if not oxy_tank and oxy_value > 1 then
                oxy_tank = true
                SetPedConfigFlag(player, 3, false)
                notification('oxy tank available')
            end
        else
            has_tank = false
            if IsScubaGearLightEnabled(player) then
                SetEnableScubaGearLight(player, false)
            end
            if oxy_tank then
                oxy_tank = false
                SetPedConfigFlag(player, 3, true)
                notification('oxy tank not available')
            end
        end
        if ( isMale and GetPedDrawableVariation(player, 6) == maleSwimFins ) or ( not isMale and GetPedDrawableVariation(player, 6) == femaleSwimFins ) then
            if not diving_swim then
                diving_swim = true
                SetEnableScuba(player, true)
                notification('diving swim mode')
            end
        else
            if diving_swim then
                diving_swim = false
                SetEnableScuba(player, false)
                notification('non diving swim mode')
            end
        end
        Citizen.Wait(500)
    end
end)

RegisterCommand('+scubalight', function()
    local playerPed = PlayerPedId()
    local isMale = GetEntityModel(playerPed) == malePed
    local isFemale = GetEntityModel(playerPed) == femalePed
    if ( isMale and GetPedDrawableVariation(playerPed, 8) == maleScubaVariation ) or ( isFemale and GetPedDrawableVariation(playerPed, 8) == femaleScubaVariation ) then
        if IsScubaGearLightEnabled(playerPed) then
            SetEnableScubaGearLight(playerPed, false)
        else
            SetEnableScubaGearLight(playerPed, true)
        end
    end
end)

RegisterCommand('-scubalight', function()

end)

RegisterKeyMapping('+scubalight', 'Turn Scuba Light On/Off', 'keyboard', '')

--for development assistance
RegisterCommand('oxyrefill', function(source, args, raw)
    local refill = fulltank
    if args and args[1] and tonumber(args[1]) then
        refill = tonumber(args[1])
    end
    TriggerEvent('brc-hud:oxygenRefill', refill)
end)