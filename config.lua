Config  = {}

Config.scubaItemName = 'scuba_set'
Config.finsItemName = 'scuba_fins'

Config.pedsMale = {
    [`mp_m_freemode_01`] = true, -- hash
    --
}

Config.pedsFemale = {
    [`mp_f_freemode_01`] = true, -- hash
    --
}

Config.EnableBlip = true -- enable blips for oxygen refill station

Config.BlipsName = 'Scuba Oxy Station' -- blips name if enabled

Config.Locations = { -- locations of oxygen refill station
    vec3(-1156.63, -2023.58, 13.15)
    -- may add more locations
}

Config.Currency = '$'
Config.refillPrice = 1000

-- ped component variations configuration
-- below is default ped assets, only added streamed scuba asset files
-- some may different if server have other replaced ped assets
Config.maleScubaVariation = 124 -- the scuba component number of the included stream file
Config.femaleScubaVariation = 154 -- the scuba component number of the included stream file
Config.maleScubaMaskVariation = 26
Config.femaleScubaMaskVariation = 28
Config.maleSwimFins = 67
Config.femaleSwimFins = 70

Config.fulltank = 400 -- full oxygen tank capacity, measure duration in seconds

Config.scubalightKeybind = 'H' -- default keybind to switch scuba flashlight on/off
Config.refillCommand = 'oxyrefill' -- command to manually refill oxygen tank capacity
Config.checkCommand = 'oxycheck' -- command to check oxygen tank capacity

Config.drop_to_reset = false -- need to drop scuba or fins to put off from ped

-- can be replaced with other notification function
if IsDuplicityVersion() then -- server notification
    sendnotification = function(xPlayer, text)
        if not xPlayer then
            return
        end
        xPlayer.showNotification(text)
    end
else -- client notification
    sendnotification = function(text)
        ESX.ShowNotification(text)
    end
end

Config.updateCheck = true -- check for updates