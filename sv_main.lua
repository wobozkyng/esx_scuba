ESX.RegisterCommand(Config.refillCommand, 'admin', function(xPlayer, args, showError)
    if args.value > 100 then
        return xPlayer and xPlayer.showNotification('Max value is 100') or print('Max value is 100')
    end
	args.playerId.triggerEvent('esx_scuba:oxygenHandle', 'refill', args.value)
end, true, {help = 'Refill oxygen tank', validate = true, arguments = {
	{name = 'playerId', help = 'The player id', type = 'player'},
	{name = 'value', help = 'Value percentage of refill capacity', type = 'number'}
}})

ESX.RegisterCommand(Config.checkCommand, 'user', function(xPlayer, args, showError)
	xPlayer.triggerEvent('esx_scuba:oxygenHandle', 'check', args.value)
end, false, {help = 'Refill oxygen tank', validate = true, arguments = {}})

if not Config.OxInventory then
	ESX.RegisterUsableItem(Config.scubaItemName, function(source)
		local source = source
		local xPlayer = ESX.GetPlayerFromId(source)
		if not xPlayer then
			return
		end
		xPlayer.triggerEvent('esx_scuba:useItem', Config.scubaItemName)		
	end)

	ESX.RegisterUsableItem(Config.finsItemName, function(source)
		local source = source
		local xPlayer = ESX.GetPlayerFromId(source)
		if not xPlayer then
			return
		end
		xPlayer.triggerEvent('esx_scuba:useItem', Config.finsItemName)		
	end)
end

RegisterNetEvent('esx_scuba:oxygenRefillPay', function()
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then
		return
	end
	local canPay = xPlayer.getMoney() >= Config.refillPrice
	if not canPay then
		return xPlayer.showNotification(TranslateCap('no_money'))
	end
	xPlayer.removeMoney(Config.refillPrice)
	xPlayer.triggerEvent('esx_scuba:oxygenHandle', 'refill', 100)
	xPlayer.showNotification(TranslateCap('push_refill_pay').. Config.Currency .. Config.refillPrice)
end)
