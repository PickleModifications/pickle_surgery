local inSurgery = false
local isSurgeryPatient = false
local currentSurgeryTable = nil
local blood = 0
local patientCenter, patientBody = nil, nil
local SurgeryTables = {}
local LocalSurgeryTables = {}

function IsSurgeryActive()
    return inSurgery
end

function IsSurgeryPatient()
    return isSurgeryPatient
end

function StopSurgery()
    local tableId = currentSurgeryTable
    inSurgery = false
    currentSurgeryTable = nil
    blood = 0
    SendNUIMessage({
        type = "hideHud"
    })
    StopHandTarget()
    SetEntityAlpha(PlayerPedId(), 255)
end

function StartSurgery(tableId, surgeryIndex, targetId)
    local tbl = SurgeryTables[tableId]
    if not tbl then return end
    local coords = tbl.center.coords
    local heading = tbl.center.heading
    local standCoords = tbl.surgeonEnter.coords
    local standHeading = tbl.surgeonEnter.heading
    FreezeEntityPosition(PlayerPedId(), true)
    SetEntityCoords(PlayerPedId(), standCoords.x, standCoords.y, standCoords.z)
    SetEntityHeading(PlayerPedId(), standHeading)
    SetEntityAlpha(PlayerPedId(), 0)
    inSurgery = true 
    currentSurgeryTable = tableId
    blood = Config.Blood.startingLevel
    DoScreenFadeOut(1000)
    Wait(1050)
    local showInfo = false
    if (targetId ~= -1 and Config.ShowControl.player) or (targetId == -1 and Config.ShowControl.training) then
        showInfo = true
    end
    SendNUIMessage({
        type = "showHud",
        data = {
            blood = blood,
            showInfo = showInfo
        }
    })
    
    CreateThread(function()
        while inSurgery do
            local bleedingCount = GetBleedingCount()
            blood = blood - (bleedingCount * Config.Blood.lossPerBleed)
            SendNUIMessage({
                type = "updateHud",
                data = {
                    blood = (blood > 0 and blood or 0),
                }
            })
            if blood <= 0 then
                blood = 0
                FailSurgery(_L("bled_out"), true)
                break
            end
            if not IsEntityPlayingAnim(PlayerPedId(), "mini@repair", "fixing_a_ped", 13) then
                ClearPedTasksImmediately(PlayerPedId(), true)
                PlayAnim(PlayerPedId(), "mini@repair", "fixing_a_ped", -8.0, 8.0, -1, 1, 1.0) 
            end
            Wait(1000)
        end
    end)

    CreateThread(function()
        while inSurgery do
            if IsControlJustPressed(1, 202) then
                FailSurgery(_L("cancelled_surgery"), true)
            end
            Wait(0)
        end
    end)
    local cfgSurgery = Config.SurgeryTypes[surgeryIndex]
    StartHandTarget(coords, heading - 180.0, vector3(0.2, 0.8, 0.0), 1, 0.28, function()
        cfgSurgery.endSurgery()
    end)
    cfgSurgery.startSurgery(coords, heading, targetId ~= -1)
    Wait(200)
    DoScreenFadeIn(1000)
end

function FailSurgery(reason, cancelled)
    TriggerServerEvent("pickle_surgery:finishSurgery", false, reason, "surgeon")
end

function CompleteSurgery(reason)
    TriggerServerEvent("pickle_surgery:finishSurgery", true)
end

-- Menu

function SurgeryTargetMenu(index, surgeryIndex)
    local tbl = SurgeryTables[index]
    if not tbl then return end
    if tbl.activeSurgery then return ShowNotification(_L("surgery_in_progress")) end
    if not CanAccessGroup(Config.SurgeryJobs) then return ShowNotification(_L("no_permission")) end
    local players = GetPlayersInArea()
    local players_list = {}
    for i=1, #players do
        local id = GetPlayerServerId(players[i])
        players_list[#players_list + 1] = {
            title = _L("surgery_target_player", id, GetPlayerName(players[i])), 
            onSelect = function() 
                TriggerServerEvent("pickle_surgery:startSurgery", index, surgeryIndex, id)
            end
        }
    end

    players_list[#players_list + 1] = {
        title = _L("surgery_target_npc"), 
        description = _L("surgery_target_npc_desc"), 
        onSelect = function()
            TriggerServerEvent("pickle_surgery:startSurgery", index, surgeryIndex, -1)
        end
    }
    lib.registerContext({
        id = 'surgery_target_menu',
        title = _L("surgery_target_menu_title"),
        options = players_list,
        onExit = function()
            SetTimeout(250, function()
                SurgeryMenu(index)
            end)
        end
    })
    
    lib.showContext('surgery_target_menu')
end

function SurgeryMenu(index)
    local tbl = SurgeryTables[index]
    if not tbl then return end
    if tbl.activeSurgery then return ShowNotification(_L("surgery_in_progress")) end
    if not CanAccessGroup(Config.SurgeryJobs) then return ShowNotification(_L("no_permission")) end
    local options = {}
    for i=1, #Config.SurgeryTypes do 
        options[#options + 1] = {
            title = Config.SurgeryTypes[i].title,
            description = Config.SurgeryTypes[i].description,
            onSelect = function() 
                SetTimeout(250, function()
                    SurgeryTargetMenu(index, i)
                end)
            end
        }
    end
    lib.registerContext({
        id = 'surgery_menu',
        title = _L("surgery_menu_title"),
        options = options
    })
    
    lib.showContext('surgery_menu')
end

function RefreshInventory(inventory)
end

RegisterNetEvent("pickle_surgery:syncTables", function(data)
    SurgeryTables = data
    for k,v in pairs(SurgeryTables) do
        if not LocalSurgeryTables[k] then
            LocalSurgeryTables[k] = {
                interact = CreateInteraction({
                    label = _L("surgery_interact"),
                    coords = v.center.coords,
                    heading = v.center.heading
                }, function(selected)
                    SurgeryMenu(k)
                end)
            }
        end
        if v.activeSurgery then
            DeleteInteraction(LocalSurgeryTables[k].interact)
            LocalSurgeryTables[k] = nil
        end
    end
end)

RegisterNetEvent("pickle_surgery:updateTable", function(index, data)
    SurgeryTables[index] = data
    if data.activeSurgery and LocalSurgeryTables[index] then
        DeleteInteraction(LocalSurgeryTables[index].interact)
        LocalSurgeryTables[index] = nil
    elseif not data.activeSurgery and not LocalSurgeryTables[index] and data then
        LocalSurgeryTables[index] = {
            interact = CreateInteraction({
                label = _L("surgery_interact"),
                coords = data.center.coords,
                heading = data.center.heading
            }, function(selected)
                SurgeryMenu(index)
            end)
        }
    end
end)

RegisterNetEvent("pickle_surgery:startSurgery:surgeon", function(index, surgeryIndex, targetId)
    StartSurgery(index, surgeryIndex, targetId)
end)

RegisterNetEvent("pickle_surgery:startSurgery:patient", function(index, surgeryIndex, targetId)  
    local tbl = SurgeryTables[index]
    if not tbl then return end
    Revive()
    local coords = tbl.center.coords
    local heading = tbl.center.heading     
    currentSurgeryTable = index
    isSurgeryPatient = true
    DoScreenFadeOut(1000)
    Wait(1050)
    patientCenter, patientBody = StartSurgeryAttachment(PlayerPedId(), Config.SurgeryTypes[surgeryIndex].bodyType, coords, heading)
    sceneCam = CreateSceneCam(coords  + vec3(0.0, 0.0, 2.0), vector3(-90.0, 0.0, heading - 180.0), 90.0)
    Wait(200)
    DoScreenFadeIn(1000)
end)

RegisterNetEvent("pickle_surgery:stopSurgery:surgeon", function(tableId)
    local tbl = SurgeryTables[tableId]
    if not tbl then return end
    local coords = tbl.surgeonEnter.coords
    local heading = tbl.surgeonEnter.heading
    SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z)
    SetEntityHeading(PlayerPedId(), heading)
    StopSurgery()
end)

RegisterNetEvent("pickle_surgery:stopSurgery:patient", function(tableId, success, cancelled)
    Wait(1050)
    EndSurgeryAttachment(PlayerPedId(), patientCenter, patientBody)
    if not success then
        if not cancelled or (cancelled == "surgeon" and Config.CancelSurgeryDeath) then
            Kill()
        end
    end
    local tbl = SurgeryTables[tableId]
    if not tbl then return end
    local coords = tbl.patientExit.coords
    local heading = tbl.patientExit.heading
    SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z)
    SetEntityHeading(PlayerPedId(), heading)
    DeleteSceneCam(sceneCam)
    currentSurgeryTable = nil
    isSurgeryPatient = false
end)

AddEventHandler("onResourceStart", function(name)
    Wait(1000)
    TriggerServerEvent("pickle_surgery:requestSyncTables")
end)

AddEventHandler("onResourceStop", function(name)
    if name ~= GetCurrentResourceName() then return end
    for k,v in pairs(Config.SurgeryTypes) do 
        v.endSurgery()
    end
    EndSurgeryAttachment(PlayerPedId(), patientCenter, patientBody)
    SetEntityAlpha(PlayerPedId(), 255)
end)
