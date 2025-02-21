function GetPedGender(ped)
    if GetEntityModel(ped) == `mp_m_freemode_01` then
        return "male"
    else
        return "female"
    end
end

function IsTargetMovedAway(targetId, distance, surgeryBodyProps)
    local prop = GetHandTargetProp(targetId)
    if not prop then return end
    local entity = prop.entity
    local coords = GetEntityCoords(entity)
    local dist = #(coords - GetEntityCoords(surgeryBodyProps.center))
    if not IsSurgeryActive() then
        return true
    else
        return dist > (distance or 0.5)
    end
end

function StartSurgeryAttachment(ped, bodyType, coords, heading)
    local surgeryPed = ped
    local center = CreateProp(`prop_tennis_ball`, coords.x, coords.y, coords.z, true, true, true)
    FreezeEntityPosition(center, true)
    SetEntityHeading(center, heading)
    SetEntityCollision(center, false, false)
    SetEntityAlpha(center, 0, true)
    local body
    if bodyType == nil or bodyType == "openRib" then
        local clothing = Config.TorsoSurgeryClothing[GetPedGender(ped)]
        SetPedComponentVariation(surgeryPed, 3, clothing.arms[1], clothing.arms[2], 1)
        SetPedComponentVariation(surgeryPed, 11, clothing.torso[1], clothing.torso[2], 1)
        SetPedComponentVariation(surgeryPed, 8, clothing.accessories[1], clothing.accessories[2], 1)
        body = CreateSurgeryBody(coords, heading, true, bodyType, true)    
    elseif bodyType == "closed" then
    end

    FreezeEntityPosition(surgeryPed, true)
    SetEntityRotation(surgeryPed, 90.0, 0.0, heading, 2)
    AttachEntityToEntity(surgeryPed, center, -1, -0.02, 0.0, 0.85, 0.0, 0.0, -2.5, false, false, false, true, 0, 2)
    CreateThread(function()
        Wait(100)
        while IsSurgeryPatient() do 
            if not IsEntityPlayingAnim(surgeryPed, "anim@gangops@morgue@table@", "body_search", 13) then
                ClearPedTasksImmediately(surgeryPed, true)
                Wait(100)
                PlayAnim(surgeryPed, "anim@gangops@morgue@table@", "body_search", -8.0, 8.0, -1, 2, 1.0)
            end
            Wait(100)
        end
    end)
    return center, body
end

function EndSurgeryAttachment(ped, center, patientBody)
    ResetClothes()
    FreezeEntityPosition(ped, false)
    DetachEntity(ped, true, true)
    ClearPedTasksImmediately(ped)
    DeleteEntity(center)
    if patientBody then
        for k,v in pairs(patientBody) do 
            DeleteEntity(v)
        end
    end
end

function CreateSurgeryBody(coords, heading, patientPed, bodyType, isSync)    
    local center = CreateObject(`prop_tennis_ball`, coords.x, coords.y, coords.z, false, true, true)
    FreezeEntityPosition(center, true)
    SetEntityHeading(center, heading)
    SetEntityCollision(center, false, false)
    SetEntityAlpha(center, 0, true)
    if bodyType == nil or bodyType == "openRib" then
        local surgeryPed
        local torso
        local ribs
        if not patientPed then
            local clothing = Config.TorsoSurgeryClothing.male
            surgeryPed = CreateNPC(`mp_m_freemode_01`, coords.x, coords.y, coords.z, heading, false, true)
            FreezeEntityPosition(surgeryPed, true)
            SetEntityRotation(surgeryPed, 90.0, 0.0, heading, 2)
            SetBlockingOfNonTemporaryEvents(surgeryPed, true)
            SetPedComponentVariation(surgeryPed, 3, clothing.arms[1], clothing.arms[2], 1)
            SetPedComponentVariation(surgeryPed, 11, clothing.torso[1], clothing.torso[2], 1)
            SetPedComponentVariation(surgeryPed, 8, clothing.accessories[1], clothing.accessories[2], 1)
            FreezeEntityPosition(surgeryPed, true)
            SetEntityRotation(surgeryPed, 90.0, 0.0, heading, 2)
            AttachEntityToEntity(surgeryPed, center, -1, -0.02, 0.0, 0.85, 0.0, 0.0, -2.5, false, false, false, true, 0, 2)           
            ClearPedTasksImmediately(surgeryPed)
            CreateThread(function()
                PlayAnim(surgeryPed, "anim@gangops@morgue@table@", "body_search", -8.0, 8.0, -1, 2, 1.0)
                while IsSurgeryActive() do 
                    if not IsEntityPlayingAnim(surgeryPed, "anim@gangops@morgue@table@", "body_search", 13) then
                        ClearPedTasksImmediately(surgeryPed, true)
                        Wait(100)
                        PlayAnim(surgeryPed, "anim@gangops@morgue@table@", "body_search", -8.0, 8.0, -1, 2, 1.0)
                    else
                    end
                    Wait(100)
                end
            end)
        elseif isSync then
            local coords = GetOffsetFromEntityInWorldCoords(center, -0.01, -0.26, -0.16)
            torso = CreateObject(`mrc_torso`, coords.x, coords.y, coords.z, false, true, true)
            SetEntityHeading(torso, heading + 180.0)
            SetEntityCollision(torso, false, false)
            FreezeEntityPosition(torso, true)
            local coords = GetOffsetFromEntityInWorldCoords(center, -0.01, -0.30, -0.16)
            ribs = CreateObject(`ribs`, coords.x, coords.y, coords.z, false, true, true)
            SetEntityHeading(ribs, heading + 180.0)
            SetEntityCollision(ribs, false, false)
            FreezeEntityPosition(ribs, true)
        end
        local surgeryBodyProps = {
            center = center,
            torso = torso,
            ribs = ribs,
            surgeryPed = surgeryPed,
        }

        return surgeryBodyProps
    elseif bodyType == "closed" then
        local surgeryPed
        if not patientPed then
            surgeryPed = CreateNPC(`mp_m_freemode_01`, coords.x, coords.y, coords.z, heading, false, true)
            SetBlockingOfNonTemporaryEvents(surgeryPed, true)
            AttachEntityToEntity(surgeryPed, center, -1, 0.0, 0.0, 0.0, 90.0, 0.0, 0.0, false, false, false, true, 0, 2)
            ClearPedTasksImmediately(surgeryPed)
            FreezeEntityPosition(surgeryPed, true)
            SetEntityRotation(surgeryPed, 90.0, 0.0, heading, 2)
            AttachEntityToEntity(surgeryPed, center, -1, -0.02, 0.0, 0.85, 0.0, 0.0, -2.5, false, false, false, true, 0, 2)           
            ClearPedTasksImmediately(surgeryPed)
            CreateThread(function()
                PlayAnim(surgeryPed, "anim@gangops@morgue@table@", "body_search", -8.0, 8.0, -1, 2, 1.0)
                while IsSurgeryActive() do 
                    if not IsEntityPlayingAnim(surgeryPed, "anim@gangops@morgue@table@", "body_search", 13) then
                        ClearPedTasksImmediately(surgeryPed, true)
                        Wait(100)
                        PlayAnim(surgeryPed, "anim@gangops@morgue@table@", "body_search", -8.0, 8.0, -1, 2, 1.0)
                    end
                    Wait(100)
                end
            end)
        end
        local surgeryBodyProps = {
            center = center,
            surgeryPed = surgeryPed,
        }
        return surgeryBodyProps
    end
end
