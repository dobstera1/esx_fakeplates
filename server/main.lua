ESX               = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)



RegisterServerEvent('esx_fakeplates:buy')
AddEventHandler('esx_fakeplates:buy', function()
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.getMoney() >= Config.LicensePlatePrice then
		xPlayer.removeMoney(Config.LicensePlatePrice)

		TriggerClientEvent('esx_fakeplates:applyFake', source)
	else if  xPlayer.getMoney() < Config.LicensePlatePrice  then 
		TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = 'You dont have enough money!', style = { ['background-color'] = '#DC143C', ['color'] = '#000000' } })
		end
	  end
	end)

RegisterServerEvent('esx_fakeplates:return')
AddEventHandler('esx_fakeplates:return', function()
		local xPlayer = ESX.GetPlayerFromId(source)
	
		if xPlayer.getMoney() >= Config.ReturtnPrice then
			xPlayer.removeMoney(Config.ReturtnPrice)
	
			TriggerClientEvent('esx_fakeplates:RemoveFakePlate', source)

		else if  xPlayer.getMoney() < Config.ReturtnPrice then 
			TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = 'You dont have enough money!', style = { ['background-color'] = '#DC143C', ['color'] = '#000000' } })
			  end
			end
		end)


ESX.RegisterServerCallback('esx_fakeplate:isPlateTaken', function(source, cb, plate)
	MySQL.Async.fetchAll('SELECT 1 FROM owned_vehicles WHERE plate = @plate', {
		['@plate'] = plate
	}, function(result)
		cb(result[1] ~= nil)
	end)
end)