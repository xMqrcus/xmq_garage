local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRPgc = Tunnel.getInterface("vRP_garages","xmq_garage")

vRP = Proxy.getInterface("vRP", "xmq_garage")
vRPclient = Tunnel.getInterface("vRP","xmq_garage")

function Notify(id,msg,type,timeout)
  TriggerClientEvent('mythic_notify:client:SendAlert', id, { type = type, text = msg, length = timeout})
end

HT = nil
TriggerEvent('HT_base:getBaseObjects', function(obj) HT = obj end)

---############ KODE ############---

RegisterServerEvent('openGarageMenu')
AddEventHandler('openGarageMenu', function()
	local user_id = vRP.getUserId({source})
    local vehicles = MySQL.Sync.fetchAll('SELECT * FROM vrp_user_vehicles WHERE user_id = @user_id', {user_id = user_id})
    if vehicles[1] ~= nil then
        TriggerClientEvent("xmq_garage:insert", vRP.getUserSource({user_id}), vehicles)
    else
        Notify(vRP.getUserSource({user_id}),"Du ejer ikke noget køretøj", "error",tonumber(5000))
    end
end)

RegisterServerEvent("xmq:parkveh", function(vehicle)
  local user_id = vRP.getUserId({source})
  MySQL.Sync.execute('UPDATE vrp_user_vehicles SET status=@status WHERE user_id=@user_id AND vehicle = @vehicle', {user_id = user_id, status = "Ledig", vehicle = vehicle})
end)

HT.RegisterServerCallback('xmq:checkspawn', function(source, cb, vehicle)
  optaget = false
  local user_id = vRP.getUserId({source})
  local result = MySQL.Sync.fetchAll('SELECT * FROM vrp_user_vehicles WHERE user_id = @user_id', {user_id = user_id})
  for k,v in pairs(result) do
    if v.status == "Optaget" then
      optaget = true
      cb(false)
      break
    end
  end
  if optaget == false then
    cb(true)
    local result2 = MySQL.Sync.fetchAll('SELECT * FROM vrp_user_vehicles WHERE user_id = @user_id AND vehicle=@vehicle', {user_id = user_id, vehicle = vehicle})
    MySQL.Sync.execute('UPDATE vrp_user_vehicles SET status=@status WHERE user_id=@user_id AND vehicle = @vehicle', {user_id = user_id, status = "Optaget", vehicle = vehicle})
    Wait(3000)
    TriggerClientEvent("spawnGarageVehicle", source,result2[1].veh_type,vehicle,result2[1].vehicle_plate, result2[1].vehicle_colorprimary, result2[1].vehicle_colorsecondary, result2[1].vehicle_pearlescentcolor, result2[1].vehicle_wheelcolor, result2[1].vehicle_plateindex, result2[1].vehicle_neoncolor1, result2[1].vehicle_neoncolor2, result2[1].vehicle_neoncolor3, result2[1].vehicle_windowtint, result2[1].vehicle_wheeltype, result2[1].vehicle_mods0, result2[1].vehicle_mods1, result2[1].vehicle_mods2, result2[1].vehicle_mods3, result2[1].vehicle_mods4, result2[1].vehicle_mods5, result2[1].vehicle_mods6, result2[1].vehicle_mods7, result2[1].vehicle_mods8, result2[1].vehicle_mods9, result2[1].vehicle_mods10, result2[1].vehicle_mods11, result2[1].vehicle_mods12, result2[1].vehicle_mods13, result2[1].vehicle_mods14, result2[1].vehicle_mods15, result2[1].vehicle_mods16, result2[1].vehicle_turbo, result2[1].vehicle_tiresmoke, result2[1].vehicle_xenon, result2[1].vehicle_mods23, result2[1].vehicle_mods24, result2[1].vehicle_neon0, result2[1].vehicle_neon1, result2[1].vehicle_neon2, result2[1].vehicle_neon3, result2[1].vehicle_bulletproof, result2[1].vehicle_smokecolor1, result2[1].vehicle_smokecolor2, result2[1].vehicle_smokecolor3, result2[1].vehicle_modvariation)
  end
end)

RegisterServerEvent('xmq:updatefuel')
AddEventHandler('xmq:updatefuel', function(vehicle, fuel)
  local user_id = vRP.getUserId({source})
  MySQL.Sync.execute('UPDATE vrp_user_vehicles SET fuel=@fuel WHERE user_id=@user_id AND vehicle = @vehicle', {user_id = user_id, fuel = fuel, vehicle = vehicle})
end)

RegisterServerEvent('xmq:updatehp')
AddEventHandler('xmq:updatehp', function(vehicle, hp)
  local user_id = vRP.getUserId({source})
  MySQL.Sync.execute('UPDATE vrp_user_vehicles SET hp=@hp WHERE user_id=@user_id AND vehicle = @vehicle', {user_id = user_id, hp = hp, vehicle = vehicle})
end)

RegisterServerEvent('xmq:updateVeh')
AddEventHandler('xmq:updateVeh', function()
  local user_id = vRP.getUserId({source})
  local vehicles = MySQL.Sync.fetchAll('SELECT * FROM vrp_user_vehicles WHERE user_id = @user_id', {user_id = user_id})
  if vehicles[1] ~= nil then
    for k,v in pairs(vehicles) do
      if v.status ~= "Ledig" then
        MySQL.Sync.execute('UPDATE vrp_user_vehicles SET status=@status WHERE user_id=@user_id AND vehicle = @vehicle', {user_id = user_id, status = "Ledig", vehicle = v.vehicle})
      end
    end
  end
end)