local function versionCheck(repository)
	local resource = GetInvokingResource() or GetCurrentResourceName()
	local repositorylink = "https://github.com/wobozkyng/esx_scuba"
	local currentVersion = GetResourceMetadata(resource, 'version', 0)
	if currentVersion then
		currentVersion = currentVersion:match('%d%.%d+%.%d+')
	end
	if not currentVersion then return print(("^1Unable to determine current resource version for '%s' ^0"):format(resource)) end
	SetTimeout(2500, function()
		PerformHttpRequest(('https://raw.githubusercontent.com/%s/main/fxmanifest.lua'):format(repository), function(status, response)
			if status ~= 200 then return end
			local latestVersion = response:match("%sversion \'(.-)\'")
			if not latestVersion or latestVersion == currentVersion then return print(('[INFO] ^2%s^0 is up to date (current version: ^2%s^0)'):format(resource, currentVersion)) end
            local cv = { string.strsplit('.', currentVersion) }
            local lv = { string.strsplit('.', latestVersion) }
            for i = 1, #cv do
                local current, minimum = tonumber(cv[i]), tonumber(lv[i])

                if current ~= minimum then
                    if current < minimum then
                        return print(('^3An update is available for %s (current version: %s)\r\n%s^0'):format(resource, currentVersion, repositorylink))
                    else break end
                end
            end
		end, 'GET')
	end)
end

if Config.updateCheck then
    versionCheck('wobozkyng/esx_scuba')
end