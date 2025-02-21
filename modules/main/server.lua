local SurgeryTables = {}

function CreateSurgeryTable(data) 
    local index
    repeat
        index = math.random(1,999999) .. "_" .. math.random(1,999999)
    until not SurgeryTables[index]
    SurgeryTables[index] = {
        activeSurgery = nil,
        center = data.center,
        surgeonEnter = data.surgeonEnter,
        patientExit = data.patientExit,
    }
    return SurgeryTables[index]
end

function GetPlayerSurgeryTable(source)
    for k,v in pairs(SurgeryTables) do 
        if v.activeSurgery then
            if v.activeSurgery.surgeon == source then
                return k, "surgeon"
            elseif v.activeSurgery.patient == source then
                return k, "patient"
            end
        end
    end
end

function GivePlayerRewards(source, rewards)
    for i=1, #rewards do 
        local reward = rewards[i]
        if reward.type == "cash" then 
            AddMoney(source, reward.amount)
        elseif reward.type == "item" then
            Inventory.AddItem(source, reward.name, reward.amount, reward.metadata)
        elseif reward.type == "xp" then
            AddPlayerXP(source, reward.name, reward.amount)
        end
    end
end

function GetMissingItemsFromInventory(source, required)
    local missingString = nil
    for i=1, #required do 
        if Inventory.GetItemCount(source, required[i].name) < required[i].amount then
            local entry = required[i].name .. " (x" .. required[i].amount .. ")"
            if missingString then
                missingString = missingString .. ", " .. entry
            else
                missingString = entry
            end
        end
    end
    if missingString then
        missingString = missingString .. "."
    end
    return missingString
end

function ProcessRequiredItems(source, required)
    local missingString = GetMissingItemsFromInventory(source, required)
    if missingString then return end
    for i=1, #required do 
        if required[i].remove then
            Inventory.RemoveItem(source, required[i].name, required[i].amount)
        end
    end
    return 
end

function FinishSurgery(tableId, success, reason, cancelled)
    local tbl = SurgeryTables[tableId]
    if not tbl.activeSurgery then return end
    local source = tbl.activeSurgery.surgeon
    local targetId = tbl.activeSurgery.targetId
    if success then
        ShowNotification(source, _L("surgery_success"))
        if tbl.activeSurgery.targetId ~= -1 then
            GivePlayerRewards(source, Config.SurgeryTypes[tbl.activeSurgery.surgeryIndex].rewards or {})
        else
            GivePlayerRewards(source, Config.SurgeryTypes[tbl.activeSurgery.surgeryIndex].trainingRewards or {})
        end
    else
        ShowNotification(source, reason)
    end
    tbl.activeSurgery = nil
    SurgeryTables[tableId] = tbl 
    TriggerClientEvent("pickle_surgery:updateTable", -1, tableId, SurgeryTables[tableId])
    TriggerClientEvent("pickle_surgery:stopSurgery:surgeon", source, tableId)
    if targetId ~= -1 then
        TriggerClientEvent("pickle_surgery:stopSurgery:patient", targetId, tableId, success, cancelled)
    end
end

CreateThread(function()
    for i=1, #Config.SurgeryTables do 
        CreateSurgeryTable(Config.SurgeryTables[i])
    end
    TriggerClientEvent("pickle_surgery:syncTables", -1, SurgeryTables)
end)

RegisterNetEvent("pickle_surgery:requestSyncTables", function()
    local source = source
    TriggerClientEvent("pickle_surgery:syncTables", source, SurgeryTables)
end)

RegisterNetEvent("pickle_surgery:startSurgery", function(index, surgeryIndex, targetId) 
    local source = source
    local tbl = SurgeryTables[index]
    if not tbl then return end
    if tbl.activeSurgery then return ShowNotification(source, _L("surgery_in_progress")) end
    if not CanAccessGroup(source, Config.SurgeryJobs) then return ShowNotification(source, _L("no_permission")) end
    if Config.SurgeryTypes[surgeryIndex].canStartSurgery and not Config.SurgeryTypes[surgeryIndex].canStartSurgery(source) then return end
    if targetId == -1 then
        SurgeryTables[index].activeSurgery = {
            surgeryIndex = surgeryIndex,
            surgeon = source,
            targetId = targetId
        }
        TriggerClientEvent("pickle_surgery:startSurgery:surgeon", source, index, surgeryIndex, targetId)
        CreateThread(function()
            while SurgeryTables[index].activeSurgery do 
                local tbl = SurgeryTables[index]
                local activeSurgery = SurgeryTables[index].activeSurgery
                local surgeonPed = GetPlayerPed(activeSurgery.surgeon)
                local dist = #(GetEntityCoords(surgeonPed) - tbl.center.coords)
                if (not DoesEntityExist(surgeonPed) or dist > 5.0) then
                    FinishSurgery(index, false, _L("cancelled_surgery"), "server")
                end
                Wait(2000)
            end
        end)
    else
        local sourcePed = GetPlayerPed(source)
        local targetPed = GetPlayerPed(targetId)
        local required = Config.SurgeryTypes[surgeryIndex].requiredItems or {}
        local missing_items = GetMissingItemsFromInventory(source, required)
        if missing_items then
            return ShowNotification(source, _L("missing_items", missing_items))
        end
        ProcessRequiredItems(source, required)
        if not DoesEntityExist(targetPed) or #(GetEntityCoords(sourcePed) - GetEntityCoords(targetPed)) > 5.0 then return ShowNotification(source, _L("no_player_near")) end
        SurgeryTables[index].activeSurgery = {
            surgeryIndex = surgeryIndex,
            surgeon = source,
            targetId = targetId
        }
        TriggerClientEvent("pickle_surgery:startSurgery:surgeon", source, index, surgeryIndex, targetId)
        TriggerClientEvent("pickle_surgery:startSurgery:patient", targetId, index, surgeryIndex, targetId)
        CreateThread(function()
            while SurgeryTables[index].activeSurgery do 
                local tbl = SurgeryTables[index]
                local activeSurgery = SurgeryTables[index].activeSurgery
                local surgeonPed = GetPlayerPed(activeSurgery.surgeon)
                local targetPed = GetPlayerPed(activeSurgery.targetId)
                local dist = #(GetEntityCoords(surgeonPed) - tbl.center.coords)
                local dist2 = #(GetEntityCoords(targetPed) - tbl.center.coords)    
                if (not DoesEntityExist(surgeonPed) or dist > 5.0) or (not DoesEntityExist(targetPed) or dist2 > 5.0) then
                    FinishSurgery(index, false, _L("cancelled_surgery"), "server")
                end
                Wait(2000)
            end
        end)
    end
    TriggerClientEvent("pickle_surgery:updateTable", -1, index, SurgeryTables[index])
end)

RegisterNetEvent("pickle_surgery:finishSurgery", function(success, reason, cancelled) 
    local source = source
    local tableId, role = GetPlayerSurgeryTable(source)
    if not tableId or role ~= "surgeon" then return end
    FinishSurgery(tableId, success, reason, cancelled)
end)

RegisterNetEvent("pickle_surgery:initializePlayer", function()
    local source = source
    TriggerClientEvent("pickle_surgery:syncTables", source, SurgeryTables)
end)