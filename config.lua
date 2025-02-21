Config = {}

Config.Debug = true

Config.Language = "en" -- Language to use.

Config.RenderDistance = 100.0 -- Scenario display Radius.

Config.InteractDistance = 1.5 -- Interact Radius

Config.UseTarget = true -- When set to true, it'll use targeting instead of key-presses to interact.

Config.NoModelTargeting = true -- When set to true and using Target, it'll spawn a small invisible prop so you can third-eye when no entity is defined.

Config.XPEnabled = true -- Enables the XP feature for adding and checking XP Levels.

Config.InventoryLimit = false -- If using ESX 1.1, this must be on if using a limit-based inventory.

Config.ShowControl = { -- Set whether or not the controls display while performing a surgery.
    player = false, -- During player surgeries.
    training = true -- During training surgeries.
}

Config.Blood = {
    startingLevel = 4500, -- Amount of blood in millimeters the patient should have at the start.
    lossPerBleed = 100, -- This will lose x millimeters of blood each second, multiplied by the amount of untreated bleeds are on the patient.
}

Config.CancelSurgeryDeath = true -- This will cause the patient to die after a cancelled surgery by a surgeon. (If cancelled by the server, no death will be applied.)

Config.SurgeryJobs = { -- Restrictions for who can do surgeries, ["job_name"] = job_rank_minimum
    ["ems"] = 0,
    ["ambulance"] = 0,
    ["doctor"] = 0,
}

Config.TorsoSurgeryClothing = { -- Used for the open rib cage setting for torso surgery.
    male = {
        arms = {5, 0},
        torso = {15, 1},
        accessories = {15, 0},
    },
    female = {
        arms = {11, 0},
        torso = {-1, 1},
        accessories = {-1, 1},
    }
}

Config.SurgeryTables = {
    {
        center = {
            coords = vector3(255.8419, -1352.2913, 24.5195),
            heading = 138.9537
        },
        surgeonEnter = {
            coords = vector3(255.2560, -1351.6882, 23.5494),
            heading = 227.9790
        },
        patientExit = {
            coords = vector3(256.4954, -1352.7190, 23.5378),
            heading = 52.5028
        }
    }
}

Config.SurgeryTypes = {
    {
        title = "Heart Surgery",
        description = "Replace the patient's heart with a new one.",
        surgeryType = "heart", -- Set this to a unique value.
        bodyType = "openRib",
        requiredItems = { -- Only checked for and removed during player surgeries. Training mode is free to perform.
            --{ name = "heart", amount = 1, remove = true }, -- Set remove to false if you want it to be required, but not removed.
        },
        rewards = { -- List of rewards to grant after successfuly performing a surgery on a player.
            { type = "cash", amount = 500 },
            -- { type = "item", name = "water",  amount = 1 },
            -- { type = "xp", name = "surgery", label = "Surgery", amount = 200 },
        }, 
        trainingRewards = { -- List of rewards to grant after successfuly performing a surgery in training mode.
            -- { type = "cash", amount = 500 },
            -- { type = "item", name = "water",  amount = 1 },
            -- { type = "xp", name = "surgery", label = "Surgery", amount = 200 },
        },
        -- Don't modify the below unless you understand how to code your own surgeries.
        -- canStartSurgery = function(source) return true end, -- This function is called to check if the surgery can be started. Return true if it can, false if it can't.
        startSurgery = function(...) StartHeartSurgery(...) end,
        endSurgery = function(...) CleanupHeartSurgery(...) end,
    },
    {
        title = "Kidney Surgery",
        description = "Replace the patient's kidneys with a new set.",
        surgeryType = "kidney", -- Set this to a unique value.
        bodyType = "openRib",
        requiredItems = { -- Only checked for and removed during player surgeries. Training mode is free to perform.
            --{ name = "kidney", amount = 1, remove = true }, -- Set remove to false if you want it to be required, but not removed.
        },
        rewards = { -- List of rewards to grant after successfuly performing a surgery on a player.
            { type = "cash", amount = 500 },
            -- { type = "item", name = "water",  amount = 1 },
            -- { type = "xp", name = "surgery", label = "Surgery", amount = 200 },
        }, 
        trainingRewards = { -- List of rewards to grant after successfuly performing a surgery in training mode.
            -- { type = "cash", amount = 500 },
            -- { type = "item", name = "water",  amount = 1 },
            -- { type = "xp", name = "surgery", label = "Surgery", amount = 200 },
        },
        -- Don't modify the below unless you understand how to code your own surgeries.
        -- canStartSurgery = function(source) return true end, -- This function is called to check if the surgery can be started. Return true if it can, false if it can't.
        startSurgery = function(...) StartKidneySurgery(...) end,
        endSurgery = function(...) CleanupKidneySurgery(...) end,
    },
    {
        title = "Lung Surgery",
        description = "Replace the patient's lungs with a new set.",
        surgeryType = "lung", -- Set this to a unique value.
        bodyType = "openRib",
        requiredItems = { -- Only checked for and removed during player surgeries. Training mode is free to perform.
            --{ name = "lung", amount = 1, remove = true }, -- Set remove to false if you want it to be required, but not removed.
        },
        rewards = { -- List of rewards to grant after successfuly performing a surgery on a player.
            { type = "cash", amount = 500 },
            -- { type = "item", name = "water",  amount = 1 },
            -- { type = "xp", name = "surgery", label = "Surgery", amount = 200 },
        }, 
        trainingRewards = { -- List of rewards to grant after successfuly performing a surgery in training mode.
            -- { type = "cash", amount = 500 },
            -- { type = "item", name = "water",  amount = 1 },
            -- { type = "xp", name = "surgery", label = "Surgery", amount = 200 },
        },
        -- Don't modify the below unless you understand how to code your own surgeries.
        -- canStartSurgery = function(source) return true end, -- This function is called to check if the surgery can be started. Return true if it can, false if it can't.
        startSurgery = function(...) StartLungSurgery(...) end,
        endSurgery = function(...) CleanupLungSurgery(...) end,
    },
    {
        title = "Arm Surgery",
        description = "Repair the patient's arms to full health using implanted rods.",
        surgeryType = "arm", -- Set this to a unique value.
        bodyType = "closed",
        startSurgery = function(...) StartArmSurgery(...) end,
        endSurgery = function(...) CleanupArmSurgery(...) end,
        requiredItems = { -- Only checked for and removed during player surgeries. Training mode is free to perform.
            --{ name = "example_item", amount = 1, remove = true }, -- Set remove to false if you want it to be required, but not removed.
        },
        rewards = { -- List of rewards to grant after successfuly performing a surgery on a player.
            { type = "cash", amount = 500 },
            -- { type = "item", name = "water",  amount = 1 },
            -- { type = "xp", name = "surgery", label = "Surgery", amount = 200 },
        }, 
        trainingRewards = { -- List of rewards to grant after successfuly performing a surgery in training mode.
            -- { type = "cash", amount = 500 },
            -- { type = "item", name = "water",  amount = 1 },
            -- { type = "xp", name = "surgery", label = "Surgery", amount = 200 },
        },
        -- Don't modify the below unless you understand how to code your own surgeries.
        -- canStartSurgery = function(source) return true end, -- This function is called to check if the surgery can be started. Return true if it can, false if it can't.
        startSurgery = function(...) StartArmSurgery(...) end,
        endSurgery = function(...) CleanupArmSurgery(...) end,
    },
    {
        title = "Leg Surgery",
        description = "Repair the patient's legs to full health using implanted rods.",
        surgeryType = "leg", -- Set this to a unique value.
        bodyType = "closed",
        startSurgery = function(...) StartLegSurgery(...) end,
        endSurgery = function(...) CleanupLegSurgery(...) end,
        requiredItems = { -- Only checked for and removed during player surgeries. Training mode is free to perform.
            --{ name = "example_item", amount = 1, remove = true }, -- Set remove to false if you want it to be required, but not removed.
        },
        rewards = { -- List of rewards to grant after successfuly performing a surgery on a player.
            { type = "cash", amount = 500 },
            -- { type = "item", name = "water",  amount = 1 },
            -- { type = "xp", name = "surgery", label = "Surgery", amount = 200 },
        }, 
        trainingRewards = { -- List of rewards to grant after successfuly performing a surgery in training mode.
            -- { type = "cash", amount = 500 },
            -- { type = "item", name = "water",  amount = 1 },
            -- { type = "xp", name = "surgery", label = "Surgery", amount = 200 },
        },
        -- Don't modify the below unless you understand how to code your own surgeries.
        -- canStartSurgery = function(source) return true end, -- This function is called to check if the surgery can be started. Return true if it can, false if it can't.
        startSurgery = function(...) StartLegSurgery(...) end,
        endSurgery = function(...) CleanupLegSurgery(...) end,
    },
}