ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

--- COMMANDS

RegisterCommand("idban", function(source, args, rawCommand)
	if source ~= 0 then
  	local xPlayer = ESX.GetPlayerFromId(source)
	if yetkiliKontrol(xPlayer) then
	if args[1] and tonumber(args[1]) then
	local targetId = tonumber(args[1])
	local steamBan =  ESX.GetPlayerFromId(targetId).identifier
	

	MySQL.Async.execute('INSERT INTO bz_ban (identifier) VALUES (@identifier)', {
				['@identifier'] = steamBan
			}, function (rowsChanged)
				table.insert(BanList, steamBan)
				DropPlayer(targetId, 'Sunucudan Yasaklandın!')
				loadBanList()
				TriggerClientEvent('notification', source, 'Bir oyuncuyu yasakladın!', 1)
	end)
    		else
      			TriggerClientEvent('notification', source, 'Geçersiz ID!', 2)
    		end
			else
			TriggerClientEvent('notification', source, 'Bu komutu kullanmak için yetkin yok!', 2)
  		end
	end
end, false)

RegisterCommand("hexban", function(source, args, rawCommand)
	if source ~= 0 then
  	local xPlayer = ESX.GetPlayerFromId(source)
	if yetkiliKontrol(xPlayer) then
	local steamID = 'steam:' .. args[1]:lower()

	if string.len(steamID) ~= 21 then
		TriggerClientEvent('notification', source, 'Hex yanlış!', 2)
		return
	end

	MySQL.Async.execute('INSERT INTO bz_ban (identifier) VALUES (@identifier)', {
				['@identifier'] = steamID
			}, function (rowsChanged)
				table.insert(BanList, steamID)
				loadBanList()
				TriggerClientEvent('notification', source, steamID..' Hexli oyuncuyu yasakladın!', 1)
	end)
	else
	TriggerClientEvent('notification', source, 'Bu komutu kullanmak için yetkin yok!', 2)
end
end
end, false)

RegisterCommand("unhex", function(source, args, rawCommand)
	if source ~= 0 then
  	local xPlayer = ESX.GetPlayerFromId(source)
	if yetkiliKontrol(xPlayer) then
	local steamID = 'steam:' .. args[1]:lower()

	if string.len(steamID) ~= 21 then
		TriggerClientEvent('notification', source, 'Hex yanlış!', 2)
		return
	end

	MySQL.Async.fetchAll('DELETE FROM bz_ban WHERE identifier = @identifier', {
		['@identifier'] = steamID
	}, function(result)
		if steamID then
			TriggerClientEvent('notification', source, 'Oyuncunun banı açıldı!', 1)
			loadBanList()
		end
	end)
	else
	TriggerClientEvent('notification', source, 'Bu komutu kullanmak için yetkin yok!', 2)
end
end
end, false)


--- YETKI KONTROL


function yetkiliKontrol(xPlayer, exclude)
	if exclude and type(exclude) ~= 'table' then exclude = nil; end	

	local playerGroup = xPlayer.getGroup()
	for k,v in pairs(Config.AdminYetki) do
		if v == playerGroup then
			if not exclude then
				return true
			else
				for a,b in pairs(exclude) do
					if b == v then
						return false
					end
				end
				return true
			end
		end
	end
	return false
end


--- BAN KONTROL

function loadBanList(cb)
	BanList = {}

	MySQL.Async.fetchAll('SELECT identifier FROM bz_ban', {}, function (identifiers)
		for i=1, #identifiers, 1 do
			table.insert(BanList, tostring(identifiers[i].identifier):lower())
		end

		if cb ~= nil then
			cb()
		end
	end)
end

MySQL.ready(function()
	loadBanList()
end)

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
local src = source
local BanKontrol = false
deferrals.defer()
deferrals.update('Ban Listesi Kontrol Ediyor..')
Citizen.Wait(100)

local steamid = GetPlayerIdentifiers(src)[1]
loadBanList()
Wait(1000)

for i=1, #BanList do
	if tostring(BanList[i]) == tostring(steamid) then
		BanKontrol = true
		break
	end
end

if BanKontrol then
	deferrals.done('Bu sunucudan yasaklanmışsın!')
	return
end

if not BanKontrol then
	deferrals.done()
end

end)
