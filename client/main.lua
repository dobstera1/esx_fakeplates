ESX                           = nil
local plates = {}
local oldPlate
local placed 
local HasAlreadyEnteredMarker = false
local LastZone                = nil
local CurrentAction           = nil
local CurrentActionMsg        = ''
local CurrentActionData       = {}

Citizen.CreateThread(function()
  while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    Citizen.Wait(0)
  end
end)

function OpenMainMenu()
  ESX.UI.Menu.CloseAll()
  ESX.UI.Menu.Open(
    'default', GetCurrentResourceName(), 'wea_cat',
    {
      title = "Mechanic",
	  align    = 'bottom-right',
      elements = {
        { label = "Get a new license plate", value = 'fakeplate' },
        { label = "Remove the fake license plate", value = 'remove' },
      }
    },
    function (data, menu)
      
      local value = data.current.value
      local rvalue = value

      if data.current.value == 'fakeplate' then
        TriggerServerEvent("esx_fakeplates:buy")
      elseif data.current.value == 'remove' then
        if (not placed) then 
          exports['mythic_notify']:DoHudText ('error', 'You do not have a fake plate on.')
        else 
        TriggerServerEvent("esx_fakeplates:return")
        end 
	  end
      
      menu.close()
    end,
    function (data, menu)
      menu.close()
    end
  )
end


AddEventHandler('esx_fakeplates:hasEnteredMarker', function()

  CurrentAction     = 'shop_menu'
  CurrentActionMsg  = _U('shop_menu')
  CurrentActionData = {zone = zone}

end)

AddEventHandler('esx_fakeplates:hasExitedMarker', function(zone)

  CurrentAction = nil
  ESX.UI.Menu.CloseAll()

end)

-- Create Blips
Citizen.CreateThread(function()
 -- for k,v in pairs(Config.Zones) do
  --if v.legal==0 then
    --for i = 1, #v.Pos, 1 do
    local blip = AddBlipForCoord(Config.Pos.x, Config.Pos.y,Config.Pos.z)
    SetBlipSprite (blip, 72)
    SetBlipDisplay(blip, 4)
    SetBlipScale  (blip, 1.0)
    SetBlipColour (blip, 1)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(_U('map_blip'))
    EndTextCommandSetBlipName(blip)
   -- end
   -- end
  --end
end)

-- Display markers
Citizen.CreateThread(function()
  while true do
    Wait(0)
    local coords = GetEntityCoords(GetPlayerPed(-1))
    --for k,v in pairs(Config.Zones) do
     -- for i = 1, #v.Pos, 1 do
        if(Config.Type ~= -1 and GetDistanceBetweenCoords(coords,Config.Pos.x,Config.Pos.y,Config.Pos.z, true) < Config.DrawDistance) then
          DrawMarker(Config.Type,Config.Pos.x,Config.Pos.y,Config.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.Size.x, Config.Size.y, Config.Size.z, Config.Color.r, Config.Color.g, Config.Color.b, 100, false, true, 2, false, false, false, false)
        end
      --end
    --end
  end
end)

-- Enter / Exit marker events
Citizen.CreateThread(function()
  while true do
    Wait(0)
    local coords      = GetEntityCoords(GetPlayerPed(-1))
    local isInMarker  = false
    local currentZone = nil

    for k,v in pairs(Config.Zones) do
      --for i = 1, #v.Pos, 1 do
        if(GetDistanceBetweenCoords(coords, Config.Pos.x, Config.Pos.y, Config.Pos.z, true) < Config.Size.x) then
          isInMarker  = true
          ShopItems   = v.Items
          currentZone = k
          LastZone    = k
        end
     -- end
    end
    if isInMarker and not HasAlreadyEnteredMarker then
      HasAlreadyEnteredMarker = true
      TriggerEvent('esx_fakeplates:hasEnteredMarker', currentZone)
    end
    if not isInMarker and HasAlreadyEnteredMarker then
      HasAlreadyEnteredMarker = false
      TriggerEvent('esx_fakeplates:hasExitedMarker', LastZone)
    end
  end
end)

RegisterNetEvent('esx_fakeplates:RemoveFakePlate')
AddEventHandler('esx_fakeplates:RemoveFakePlate', function()
    local InVeh = IsPedInAnyVehicle(PlayerPedId(), true)
    if (InVeh ~= 1) then
      exports['mythic_notify']:DoHudText ('error', 'You are not in a vehicle.')
        return
    end
    if (not placed) then
        return
    end
    SetVehicleNumberPlateText(GetVehiclePedIsUsing(GetPlayerPed(-1)), oldPlate)
    exports['mythic_notify']:DoHudText ('inform', 'You put your real plate back on!')
    placed = false
end)

RegisterNetEvent('esx_fakeplates:setFakePlate')
AddEventHandler('esx_fakeplates:setFakePlate', function()
    local firstlatter = string.upper(ESX.GetRandomString(Config.PlateLetters))
    local plate = firstlatter  .. ' ' .. math.random(100, 900)
    oldPlate = GetVehicleNumberPlateText(GetVehiclePedIsUsing(GetPlayerPed(-1)))
    SetVehicleNumberPlateText(GetVehiclePedIsUsing(GetPlayerPed(-1)), plate)
    exports['mythic_notify']:DoHudText ('inform', 'Your Fake Plate is '.. plate)
    placed = true
end)


RegisterNetEvent('esx_fakeplates:applyFake')
AddEventHandler('esx_fakeplates:applyFake', function()
    if (placed) then
      exports['mythic_notify']:DoHudText ('error', 'You can only have one fake plate on one car of yours!')
        return
    end
    local InVeh = IsPedInAnyVehicle(PlayerPedId(), true)
    if (InVeh == 1) then
      ProgBarFakeSet()
    else
      exports['mythic_notify']:DoHudText ('error', 'You are not in a vehicle!')
    end
end)

function ProgBarFakeSet()
  TriggerEvent("mythic_progbar:client:progress", {
    name = "fake_plate_replace",
    duration = 10000,
    label = "Replacing The Plate",
    useWhileDead = false,
    canCancel = true,
    controlDisables = {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    },
    animation = {
        animDict = "missheistdockssetup1clipboard@idle_a",
        anim = "idle_a",
    },
    prop = {
        model = "",
    }
}, function(status)
    if not status then
      TriggerEvent('esx_fakeplates:setFakePlate')
    end
end)
end

-- Key Controls
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
    if CurrentAction ~= nil then

      SetTextComponentFormat('STRING')
      AddTextComponentString(CurrentActionMsg)
      DisplayHelpTextFromStringLabel(0, 0, 1, -1)

      if IsControlJustReleased(0, 38) then
        if CurrentAction == 'shop_menu' then
            OpenMainMenu()
        end
        CurrentAction = nil
      end
    end
  end
end)