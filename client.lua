vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP", "xmq_garage")

function DrawText3Ds(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.35, 0.35)
    SetTextFont(6)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextOutline()
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
end

HT = nil
Citizen.CreateThread(function()
  while HT == nil do
      TriggerEvent('HT_base:getBaseObjects', function(obj) HT = obj end)
      Citizen.Wait(0)
  end
end)

---############ KODE ############---


--[[function xmqGarageMenu()
  HT.TriggerServerCallback('openGarageMenu', function(result)
    local elements = {}
    if result ~= false then
        for k,v in pairs(result) do
          table.insert(elements, {label  = firstToUpper(v.vehicle_name).. " - ⛽" ..v.fuel.."%    ❤️" ..v.hp2.."%", value = v.vehicle_model, fuel = v.fuel, hp = v.hp})
        end
    else
      table.insert(elements, {label  = "Ingen biler"})
    end
    HT.UI.Menu.Open('default', GetCurrentResourceName(), 'xmq_garage', {
        title    = "Garage - "..garagename,
        align    = 'left',
        elements = elements
    }, function(data, menu)
        local action = data.current.value
        local actionfuel = data.current.fuel
        local actionhp = data.current.hp
        print(data.current.hp)
        menu.close()
        TriggerEvent('pogressBar:drawBar', 3000, 'Klargører køretøj..')
        Citizen.Wait(2850)
        SetEntityCoords(PlayerPedId(),coordsx,coordsy,coordsz,false,false,false,true)
        SetEntityHeading(PlayerPedId(),coordsh)
        TriggerServerEvent("xmq:spawngarageveh", action)
        Citizen.Wait(2000)
        SetVehicleFuelLevel(GetVehiclePedIsIn(PlayerPedId(),false), actionfuel-2.0)
        SetVehicleEngineHealth(GetVehiclePedIsIn(PlayerPedId(),false), actionhp-2.0)
    end, function(data, menu)
        menu.close()
        Citizen.Wait(100)
    end)
  end)
end]]

for i = 1, #cfg do
  local blip = AddBlipForCoord(cfg[i].garage[1],cfg[i].garage[2])

  SetBlipSprite(blip, 225)
  SetBlipDisplay(blip, 2)
  SetBlipScale(blip, 0.9)
  SetBlipColour(blip, 2)
  SetBlipAsShortRange(blip,true)
  BeginTextCommandSetBlipName("STRING")
  AddTextComponentString("Garage")
  EndTextCommandSetBlipName(blip)
end

CreateThread(function()
  while true do
    Wait(1500)
    local ped = PlayerPedId()
    for i = 1, #cfg do
      local distance = #(GetEntityCoords(ped) - vector3(cfg[i].garage[1], cfg[i].garage[2], cfg[i].garage[3]))
      if distance < 20 then
        if not cfg[i].thread then
          cfg[i].thread = true
          garagethread(i)
          Wait(250)
        end
      else
        if cfg[i].thread then
          cfg[i].thread = false
          Wait(250)
        end
      end
    end
    RemoveVehiclesFromGeneratorsInArea(246.72555541992,-801.61901855469,30.272598266602, 200.11772155762,-805.75476074219,31.074621200562)
  end
end)

function garagethread(i)
  CreateThread(function()
    TriggerServerEvent('xmq:updateVeh')
    while cfg[i].thread == true do
      Wait(1)

      if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), cfg[i].garage[1],cfg[i].garage[2],cfg[i].garage[3]) < 10 then
        DrawMarker(36, cfg[i].garage[1],cfg[i].garage[2],cfg[i].garage[3], 0,0,0,0,0,0, 1.5, 1.5, 1.5001, 0, 200, 50, 200, 0, 1, 0, 50)
      end
      if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), cfg[i].garage[1],cfg[i].garage[2],cfg[i].garage[3]) < 1.7 then
        DrawText3Ds(cfg[i].garage[1],cfg[i].garage[2],cfg[i].garage[3], "~r~[E]~w~ - Garage")
        if IsControlJustPressed(0,38) then
          coordsx = cfg[i].tp[1]
          coordsy = cfg[i].tp[2]
          coordsz = cfg[i].tp[3]
          coordsh = cfg[i].tp[4]
          garagename = cfg[i].name
          TriggerServerEvent("openGarageMenu")
        end
      end
      if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), cfg[i].parker[1],cfg[i].parker[2],cfg[i].parker[3]) < 55 then
        if IsPedInVehicle(PlayerPedId(), GetVehiclePedIsIn(PlayerPedId(), false), false) then
          DrawMarker(1, cfg[i].parker[1],cfg[i].parker[2],cfg[i].parker[3]-1, 0,0,0,0,0,0, 3.0,3.0,1.0,255,255,255, 200,false,false,0,false)
          if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), cfg[i].parker[1],cfg[i].parker[2],cfg[i].parker[3]) < 3 then
            DrawText3Ds(cfg[i].parker[1],cfg[i].parker[2],cfg[i].parker[3], "~r~[E]~w~ - Parker køretøj")
            if IsControlJustPressed(0,38) then
              model = GetDisplayNameFromVehicleModel(GetEntityModel(GetVehiclePedIsIn(PlayerPedId(), false)))
              bil = GetVehiclePedIsIn(PlayerPedId(), false)
              fuel = (GetVehicleFuelLevel(GetVehiclePedIsIn(PlayerPedId()),false)+0.0)
              hp = GetVehicleEngineHealth(GetVehiclePedIsIn(PlayerPedId(), false))
              TriggerServerEvent("xmq:updatefuel", model, fuel)
              TriggerServerEvent("xmq:updatehp", model, hp)
              TriggerServerEvent("xmq:parkveh", model)
              local delVeh = GetVehiclePedIsIn(PlayerPedId(), false)
              TaskLeaveAnyVehicle(PlayerPedId(),1,1)
              TriggerEvent('pogressBar:drawBar', 3000, 'Parkerer køretøj')
              Wait(3000)
              DeleteEntity(delVeh)
            end
          end
        end
      end
    end
  end)
end

RegisterNetEvent("xmq:closeNUI", function()
  SendNUIMessage({
    type = "close"
  })
end)

RegisterNUICallback("luk", function()
  SetNuiFocus(false, false)
end)

RegisterNUICallback("tagud", function(data)
  HT.TriggerServerCallback('xmq:checkspawn', function(result)
    if result then
      SetNuiFocus(false, false)
      TriggerEvent('pogressBar:drawBar', 3000, 'Klargører køretøj')
      Citizen.Wait(3000)
      SetEntityCoords(PlayerPedId(), coordsx, coordsy, coordsz)
      SetEntityHeading(PlayerPedId(), coordsh)
      TriggerServerEvent("xmq:spawngarageveh", data.veh)
      TriggerEvent("advancedFuel:setEssence", data.fuel+0.0, GetVehicleNumberPlateText(data.vehicle_plate), GetDisplayNameFromVehicleModel(GetEntityModel(data.veh)))
    else
      exports['mythic_notify']:SendAlert('error', "Du kan kun have et køretøj ude", 5000)
    end
  end, data.veh)
end)

RegisterNUICallback("info", function(veh)
  SetNuiFocus(false, false)
end)

RegisterNetEvent('xmq_garage:insert')
AddEventHandler('xmq_garage:insert', function(result)
  SetNuiFocus(true, true)
  newtable = {}
  for k,v in pairs(result) do
     newtable[#newtable + 1] = {["name"] = v.name, ["vehicle"] = v.vehicle, ["vehicle_plate"] = v.vehicle_plate, ["kmh"] = math.floor(GetVehicleModelEstimatedMaxSpeed(v.vehicle) *3.6 ), ["status"] = v.status, ["fuel"] = v.fuel, ["hp"] = v.hp}
  end
  SendNUIMessage({type = "garage", status = true, garage = newtable})
end)

vehicles = {}
RegisterNetEvent("spawnGarageVehicle", function(vtype, name, vehicle_plate, vehicle_colorprimary, vehicle_colorsecondary, vehicle_pearlescentcolor, vehicle_wheelcolor, vehicle_plateindex, vehicle_neoncolor1, vehicle_neoncolor2, vehicle_neoncolor3, vehicle_windowtint, vehicle_wheeltype, vehicle_mods0, vehicle_mods1, vehicle_mods2, vehicle_mods3, vehicle_mods4, vehicle_mods5, vehicle_mods6, vehicle_mods7, vehicle_mods8, vehicle_mods9, vehicle_mods10, vehicle_mods11, vehicle_mods12, vehicle_mods13, vehicle_mods14, vehicle_mods15, vehicle_mods16, vehicle_turbo, vehicle_tiresmoke, vehicle_xenon, vehicle_mods23, vehicle_mods24, vehicle_neon0, vehicle_neon1, vehicle_neon2, vehicle_neon3, vehicle_bulletproof, vehicle_smokecolor1, vehicle_smokecolor2, vehicle_smokecolor3, vehicle_modvariation) -- vtype is the vehicle type (one vehicle per type allowed at the same time)

  local vehicle = vehicles[vtype]
  if vehicle and not IsVehicleDriveable(vehicle[3]) then -- precheck if vehicle is undriveable
    -- despawn vehicle
    SetVehicleHasBeenOwnedByPlayer(vehicle[3],false)
    Citizen.InvokeNative(0xAD738C3085FE7E11, vehicle[3], false, true) -- set not as mission entity
    SetVehicleAsNoLongerNeeded(Citizen.PointerValueIntInitialized(vehicle[3]))
    Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(vehicle[3]))
    TriggerEvent("vrp_garages:setVehicle", vtype, nil)
  end

  vehicle = vehicles[vtype]
  if vehicle == nil then
    -- load vehicle model
    local mhash = GetHashKey(name)

    local i = 0
    while not HasModelLoaded(mhash) and i < 10000 do
      RequestModel(mhash)
      Citizen.Wait(10)
      i = i+1
    end

    -- spawn car
    if HasModelLoaded(mhash) then
      local x,y,z = vRP.getPosition({})
      local nveh = CreateVehicle(mhash, x,y,z+0.5, GetEntityHeading(PlayerPedId()), true, false) -- added player heading
      SetVehicleOnGroundProperly(nveh)
      SetEntityInvincible(nveh,false)
      SetPedIntoVehicle(PlayerPedId(),nveh,-1) -- put player inside
      SetVehicleNumberPlateText(nveh, "P " .. vRP.getRegistrationNumber({}))
      Citizen.InvokeNative(0xAD738C3085FE7E11, nveh, true, true) -- set as mission entity
      SetVehicleHasBeenOwnedByPlayer(nveh,true)
      vehicle_migration = false
      if not vehicle_migration then
        local nid = NetworkGetNetworkIdFromEntity(nveh)
        SetNetworkIdCanMigrate(nid,false)
      end

      TriggerEvent("vrp_garages:setVehicle", vtype, {vtype,name,nveh})

      SetModelAsNoLongerNeeded(mhash)
      --kralle sutter mega meget
      --grabbing customization
      local plate = plate
      local primarycolor = tonumber(vehicle_colorprimary)
      local secondarycolor = tonumber(vehicle_colorsecondary)
      local pearlescentcolor = vehicle_pearlescentcolor
      local wheelcolor = vehicle_wheelcolor
      local plateindex = tonumber(vehicle_plateindex)
      local neoncolor = {vehicle_neoncolor1,vehicle_neoncolor2,vehicle_neoncolor3}
      local windowtint = vehicle_windowtint
      local wheeltype = tonumber(vehicle_wheeltype)
      local mods0 = tonumber(vehicle_mods0)
      local mods1 = tonumber(vehicle_mods1)
      local mods2 = tonumber(vehicle_mods2)
      local mods3 = tonumber(vehicle_mods3)
      local mods4 = tonumber(vehicle_mods4)
      local mods5 = tonumber(vehicle_mods5)
      local mods6 = tonumber(vehicle_mods6)
      local mods7 = tonumber(vehicle_mods7)
      local mods8 = tonumber(vehicle_mods8)
      local mods9 = tonumber(vehicle_mods9)
      local mods10 = tonumber(vehicle_mods10)
      local mods11 = tonumber(vehicle_mods11)
      local mods12 = tonumber(vehicle_mods12)
      local mods13 = tonumber(vehicle_mods13)
      local mods14 = tonumber(vehicle_mods14)
      local mods15 = tonumber(vehicle_mods15)
      local mods16 = tonumber(vehicle_mods16)
      local turbo = vehicle_turbo
      local tiresmoke = vehicle_tiresmoke
      local xenon = vehicle_xenon
      local mods23 = tonumber(vehicle_mods23)
      local mods24 = tonumber(vehicle_mods24)
      local neon0 = vehicle_neon0
      local neon1 = vehicle_neon1
      local neon2 = vehicle_neon2
      local neon3 = vehicle_neon3
      local bulletproof = vehicle_bulletproof
      local smokecolor1 = vehicle_smokecolor1
      local smokecolor2 = vehicle_smokecolor2
      local smokecolor3 = vehicle_smokecolor3
      local variation = vehicle_modvariation

      --setting customization
      SetVehicleColours(nveh, primarycolor, secondarycolor)
      SetVehicleExtraColours(nveh, tonumber(pearlescentcolor), tonumber(wheelcolor))
      SetVehicleNumberPlateTextIndex(nveh,plateindex)
      SetVehicleNeonLightsColour(nveh,tonumber(neoncolor[1]),tonumber(neoncolor[2]),tonumber(neoncolor[3]))
      SetVehicleTyreSmokeColor(nveh,tonumber(smokecolor1),tonumber(smokecolor2),tonumber(smokecolor3))
      SetVehicleModKit(nveh,0)
      SetVehicleMod(nveh, 0, mods0)
      SetVehicleMod(nveh, 1, mods1)
      SetVehicleMod(nveh, 2, mods2)
      SetVehicleMod(nveh, 3, mods3)
      SetVehicleMod(nveh, 4, mods4)
      SetVehicleMod(nveh, 5, mods5)
      SetVehicleMod(nveh, 6, mods6)
      SetVehicleMod(nveh, 7, mods7)
      SetVehicleMod(nveh, 8, mods8)
      SetVehicleMod(nveh, 9, mods9)
      SetVehicleMod(nveh, 10, mods10)
      SetVehicleMod(nveh, 11, mods11)
      SetVehicleMod(nveh, 12, mods12)
      SetVehicleMod(nveh, 13, mods13)
      SetVehicleMod(nveh, 14, mods14)
      SetVehicleMod(nveh, 15, mods15)
      SetVehicleMod(nveh, 16, mods16)
      if turbo == "on" then
        ToggleVehicleMod(nveh, 18, true)
      else
        ToggleVehicleMod(nveh, 18, false)
      end
      if tiresmoke == "on" then
        ToggleVehicleMod(nveh, 20, true)
      else
        ToggleVehicleMod(nveh, 20, false)
      end
      if xenon == "on" then
        ToggleVehicleMod(nveh, 22, true)
      else
        ToggleVehicleMod(nveh, 22, false)
      end
      SetVehicleWheelType(nveh, tonumber(wheeltype))
      SetVehicleMod(nveh, 23, mods23)
      SetVehicleMod(nveh, 24, mods24)
      if neon0 == "on" then
        SetVehicleNeonLightEnabled(nveh,0, true)
      else
        SetVehicleNeonLightEnabled(nveh,0, false)
      end
      if neon1 == "on" then
        SetVehicleNeonLightEnabled(nveh,1, true)
      else
        SetVehicleNeonLightEnabled(nveh,1, false)
      end
      if neon2 == "on" then
        SetVehicleNeonLightEnabled(nveh,2, true)
      else
        SetVehicleNeonLightEnabled(nveh,2, false)
      end
      if neon3 == "on" then
        SetVehicleNeonLightEnabled(nveh,3, true)
      else
        SetVehicleNeonLightEnabled(nveh,3, false)
      end
      if bulletproof == "on" then
        SetVehicleTyresCanBurst(nveh, false)
      else
        SetVehicleTyresCanBurst(nveh, true)
      end
      --if variation == "on" then
      --  SetVehicleModVariation(nveh,23)
      --else
      --  SetVehicleModVariation(nveh,23, false)
      --end
      SetVehicleWindowTint(nveh,tonumber(windowtint))
    end
  else
    vRP.notify({"Du kan kun have et køretøj ude."})
  end
end)

RegisterNetEvent('vrp_garages:setVehicle')
AddEventHandler('vrp_garages:setVehicle', function(vtype, vehicle)
  vehicles[vtype] = vehicle
end)