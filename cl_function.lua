GUI = {}
GUI.Time = 0
inMarkerZone = false
menuIsShowed = false
saved_components = {}

function tankAlert(value)
    if value % 100 == 0 then --75%, 50%, 25%
        return true
    end
    if value == 40 then --10%
        return true
    end
    if value <= 20 and value % 4 == 0 then --5%
        return true
    end
    return false
end

function isWearingScuba(playerPed, pedModel, fins)
    local isMale = Config.pedsMale[pedModel] or false
    local isFemale = Config.pedsFemale[pedModel] or false
    local WearingScuba = (isMale and GetPedDrawableVariation(playerPed, 8) == Config.maleScubaVariation) or (isFemale and GetPedDrawableVariation(playerPed, 8) == Config.femaleScubaVariation) or false
    local WearingSwimFins = (isMale and GetPedDrawableVariation(playerPed, 6) == Config.maleSwimFins) or (isFemale and GetPedDrawableVariation(playerPed, 6) == Config.femaleSwimFins) or false
    if fins then
        return WearingSwimFins
    end
    return WearingScuba
end

function applyScuba(name, playerPed, pedModel)
    local self = {}
    local isMale = Config.pedsMale[pedModel] or false
    local isFemale = Config.pedsFemale[pedModel] or false
    local anim = {
		[Config.scubaItemName] = {
			dict = 'clothingtie',
			clip = 'try_tie_negative_a',
			flags = 51,
		},
        [Config.finsItemName] = {
			dict = 'random@domestic',
			clip = 'pickup_low',
			flags = 51,
		}
    }
    if name == Config.scubaItemName then
        function self.playAnim()
            ESX.Streaming.RequestAnimDict(anim[name].dict)
            TaskPlayAnim(playerPed, anim[name].dict, anim[name].clip, 3.0, 3.0, 1200, anim[name].flags, 0.0, false, false, false)
            RemoveAnimDict(anim[name].dict)
            Wait(1200)
        end
        function self.getScuba()
            return isWearingScuba(playerPed, pedModel)
        end
        function self.setScuba()
            saved_components[name] = {
                GetPedDrawableVariation(playerPed, 8),
                GetPedTextureVariation(playerPed, 8),
                GetPedPropIndex(playerPed, 1),
                GetPedPropTextureIndex(playerPed, 1)
            }
            self.playAnim(playerPed)
            SetPedComponentVariation(playerPed, 8, isMale and Config.maleScubaVariation or isFemale and Config.femaleScubaVariation or 0, 0, 0)
            SetPedPropIndex(playerPed, 1, isMale and Config.maleScubaMaskVariation or isFemale and Config.femaleScubaMaskVariation or 0, 0, 0)
        end
        function self.resetScuba(hard)
            if saved_components[name] then
                if not hard then
                    self.playAnim(playerPed)
                end
                SetPedComponentVariation(playerPed, 8, saved_components[name][1], saved_components[name][2], 0)
                SetPedPropIndex(playerPed, 1, saved_components[name][3], saved_components[name][4], 0)
            end
        end
    end
    if name == Config.finsItemName then
        function self.playAnim()
            ESX.Streaming.RequestAnimDict(anim[name].dict)
            TaskPlayAnim(playerPed, anim[name].dict, anim[name].clip, 3.0, 3.0, 1200, anim[name].flags, 0.0, false, false, false)
            RemoveAnimDict(anim[name].dict)
            Wait(1200)
        end
        function self.getScuba()
            return isWearingScuba(playerPed, pedModel, true)
        end
        function self.setScuba()
            saved_components[name] = {
                GetPedDrawableVariation(playerPed, 6),
                GetPedTextureVariation(playerPed, 6)
            }
            self.playAnim(playerPed)
            SetPedComponentVariation(playerPed, 6, isMale and Config.maleSwimFins or isFemale and Config.femaleSwimFins or 0, 0, 0)
        end
        function self.resetScuba(hard)
            if saved_components[name] then
                if not hard then
                    self.playAnim(playerPed)
                end
                SetPedComponentVariation(playerPed, 6, saved_components[name][1], saved_components[name][2], 0)
            end
        end
    end
    return self
end

function getScubaItemCount(name)
    if Config.OxInventory then
        return exports.ox_inventory:Search('count', name)
    end
    return ESX.SearchInventory(name, true)
end

function DrawMarkerThread(coords)
    local playerPed = PlayerPedId()
    CreateThread(function()
        while inMarkerZone do
            local pcoords = GetEntityCoords(playerPed)
            local distance = #(pcoords - coords)
            if distance > 2.0 then
                inMarkerZone = false
            end
            Wait(1000)
        end
    end)
    CreateThread(function()
        while inMarkerZone do
            local pcoords = GetEntityCoords(playerPed)
            local distance = #(pcoords - coords)
            DrawMarker(3, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.2, 0.2, 0.2, 251, 108, 1, 204, false, true, 2, true, false, false, false)
            if distance <= 1.0 then
                if not menuIsShowed then
                    ESX.TextUI(TranslateCap('push_refill'))
                    menuIsShowed = true
                end
                if IsControlJustPressed(0, 38) and (GetGameTimer() - GUI.Time) > 2000 then
                    TriggerEvent('esx_scuba:oxygenHandle', 'pay')
                    GUI.Time = GetGameTimer()
                end
                goto skip1
            end
            if menuIsShowed then
                ESX.HideUI()
                menuIsShowed = false
            end
            ::skip1::
            Wait()
        end
    end)
end

function CreateBlips()
    for k,v in ipairs(Config.Locations) do
        local blip = AddBlipForCoord(v.x, v.y, v.z)

        SetBlipSprite (blip, 597)
        SetBlipScale  (blip, 0.5)
        SetBlipColour (blip, 3)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(Config.BlipsName)
        EndTextCommandSetBlipName(blip)
    end
end
