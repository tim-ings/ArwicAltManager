local events = {}

function ARWIC_AAM_MIGRATE_DATA()
    print("Migrating character data...")
    for realmKey, realmVal in pairs(ArwicAltManagerDB.Realms) do
        local chars = {}
        for charKey, charVal in pairs(realmVal) do
            print("Found " .. charKey .. "-" .. realmKey)
            chars[charKey] = charVal
            chars[charKey].Display = true
            realmVal[charKey] = nil
        end
        realmVal.Characters = chars
        realmVal.Display = true
    end
end

local function InitDB()
    if not ArwicAltManagerDB then 
        ArwicAltManagerDB = {} 
    end
    if not ArwicAltManagerDB.Realms then 
        ArwicAltManagerDB.Realms = {} 
    end
    if not ArwicAltManagerDB.Realms[GetRealmName()] then 
        ArwicAltManagerDB.Realms[GetRealmName()] = {} 
        ArwicAltManagerDB.Realms[GetRealmName()].Display = true 
        ArwicAltManagerDB.Realms[GetRealmName()].Characters = {} 
    end
    if not ArwicAltManagerDB.Realms[GetRealmName()].Characters then
        local keyCount = 0
        for _, _ in pairs(ArwicAltManagerDB.Realms[GetRealmName()]) do
            keyCount = keyCount + 1
        end
        if keyCount > 0 then
            ARWIC_AAM_MIGRATE_DATA()
        end
    end
    if not ArwicAltManagerDB.Realms[GetRealmName()].Characters[UnitName("player")] then 
        ArwicAltManagerDB.Realms[GetRealmName()].Characters[UnitName("player")] = {} 
        ArwicAltManagerDB.Realms[GetRealmName()].Characters[UnitName("player")].Display = true 
    end
    if not ArwicAltManagerDB.Account then
        ArwicAltManagerDB.Account = {}
    end
end

local function CurrentChar()
    InitDB()
    return ArwicAltManagerDB.Realms[GetRealmName()].Characters[UnitName("player")]
end

local function CurrentAccount()
    InitDB()
    return ArwicAltManagerDB.Account
end

local function GetArmorClass(className)
    local armorClasses = {
        ["WARRIOR"] = 4,
        ["PALADIN"] = 4,
        ["HUNTER"] = 3,
        ["ROGUE"] = 2,
        ["PRIEST"] = 1,
        ["DEATHKNIGHT"] = 4,
        ["SHAMAN"] = 3,
        ["MAGE"] = 1,
        ["WARLOCK"] = 1,
        ["MONK"] = 2,
        ["DRUID"] = 2,
        ["DEMONHUNTER"] = 2,
    }
    return armorClasses[className]
end

local fields = {
    ["Name"] = {
        Update = function()
            CurrentChar().Name = UnitName("player")
        end
    },
    ["Class"] = {
        Update = function()
            _, CurrentChar().Class = UnitClass("player")
        end
    },
    ["Realm"] = {
        Update = function()
            CurrentChar().Realm = GetRealmName()
        end
    },
    ["Faction"] = {
        Update = function()
            CurrentChar().Faction = UnitFactionGroup("player")
        end
    },
    ["Race"] = {
        Update = function()
            _, CurrentChar().Race = UnitRace("player")
        end
    },
    ["Gender"] = {
        Update = function()
            CurrentChar().Gender = UnitSex("player")
        end
    },
    ["Timestamp"] = {
        Update = function()
            CurrentChar().Timestamp = time()
        end
    },
    ["Money"] = {
        Update = function()
            CurrentChar().Money = GetMoney()
        end
    },
    ["ClassCampaign"] = {
        Update = function()
            local _, class = UnitClass("player")
            local quests = {
                ["DEATHKNIGHT"] = 43407,
                ["DEMONHUNTER"] = 43412,
                ["DRUID"] = 43409,
                ["HUNTER"] = 43423,
                ["MAGE"] = 43415,
                ["MONK"] = 43359,
                ["PALADIN"] = 43424,
                ["PRIEST"] = 43420,
                ["ROGUE"] = 43422,
                ["SHAMAN"] = 43418,
                ["WARLOCK"] = 43414,
                ["WARRIOR"] = 43425,
            }
            CurrentChar().ClassCampaign = IsQuestFlaggedCompleted(quests[class])
        end
    },
    ["BreachingTheTomb"] = {
        Update = function()
            _, _, _, _, _, _, _, _, _, _, _, _, 
            CurrentChar().BreachingTheTomb, _ = GetAchievementInfo(11546)
        end
    },
    ["ClassMount"] = {
        Update = function()
            local _, class = UnitClass("player")
            quests = {
                ["DEATHKNIGHT"] = 46813,
                ["DEMONHUNTER"] = 46334,
                ["DRUID"] = 46319,
                ["HUNTER"] = 46337,
                ["MAGE"] = 45354,
                ["MONK"] = 46350,
                ["PALADIN"] = 45770,
                ["PRIEST"] = 45789,
                ["ROGUE"] = 46089,
                ["SHAMAN"] = 46792,
                ["WARLOCK"] = 46243,
                ["WARRIOR"] = 46207,
            }
            CurrentChar().ClassMount = IsQuestFlaggedCompleted(quests[class])
        end
    },
    ["Level"] = {
        Update = function()
            CurrentChar().Level = UnitLevel("player")
        end
    },
    ["Currencies"] = {
        Update = function()
            curIDs = { 
                1220, -- Order Resources
                1508, -- Veiled Argunite
                1273, -- Seal of Broken Fate
                1533, -- Wakening Essence
            }
            local char = CurrentChar()
            char["Currencies"] = {}
            for _, cid in pairs(curIDs) do
                if not char["Currencies"][cid] then 
                    char["Currencies"][cid] = {} 
                end
                char["Currencies"][cid]["Name"], 
                char["Currencies"][cid]["CurrentAmount"], 
                _, 
                char["Currencies"][cid]["EarnedThisWeek"], 
                char["Currencies"][cid]["WeeklyMax"],
                char["Currencies"][cid]["TotalMax"],
                char["Currencies"][cid]["IsDiscovered"] = GetCurrencyInfo(cid)
            end
        end
    },
    ["MountSpeed"] = {
        Update = function()
            local spellIDs = { 
                [60] = 33388, 
                [100] = 33391, 
                [150] = 34090, 
                [280] = 34091, 
                [310] = 90265 
            }
            local char = CurrentChar()
            char["MountSpeed"] = 0
            for speed, id in pairs(spellIDs) do
                if IsSpellKnown(id) then
                    if char["MountSpeed"] < speed then
                        char["MountSpeed"] = speed
                    end
                end
            end
        end
    },
    ["OrderHallUpgrades"] = {
        Update = function()
            _, _, _, _, _, _, _, _, _, _, _, _, 
            CurrentChar().OrderHallUpgrades, _ = GetAchievementInfo(11223)
        end
    },
    ["BalanceOfPower"] = {
        Update = function()
            _, _, _, _, _, _, _, _, _, _, _, _, 
            CurrentChar().BalanceOfPower, _ = GetAchievementInfo(10459)
        end
    },
    ["Gear"] = {
        Update = function()
            local slotIDs = {
                1, -- head
                2, -- neck
                3, -- shoulders
                15, -- back
                5, -- chest
                4, -- shirt
                19, -- tabard
                9, -- wrist

                10, -- hands
                6, -- waist
                7, -- legs
                8, -- feet
                11, -- finger 1
                12, -- finger 2
                13, -- trinket 1
                14, -- trinket 2
                16, -- main hand
                17, -- off hand
            }
            local char = CurrentChar()
            char.Gear = {}
            char.Gear.Items = {}
            for _, sid in pairs(slotIDs) do
                local itemLink = GetInventoryItemLink("player", sid)
                if itemLink ~= nil then
                    local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType,
                        itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice  = GetItemInfo(itemLink)
                    local item = {}
                    item.Name = itemName
                    item.Link = itemLink
                    item.Rarity = itemRarity
                    item.ItemLevel = itemLevel
                    item.MinLevel = itemMinLevel
                    item.Type = itemType
                    item.SubType = itemSubType
                    item.StackCount = itemStackCount
                    item.EquipLoc = itemEquipLoc
                    item.Texture = itemTexture
                    item.SellPrice  = itemSellPrice
                    table.insert(char.Gear.Items, item)
                end
            end
            char.Gear.AvgItemLevelBags, char.Gear.AvgItemLevelEquipped = GetAverageItemLevel()
        end
    },
    ["Professions"] = {
        Update = function()
            local char = CurrentChar()
            char.Professions = {}
            char.Professions.Prof1 = {}
            char.Professions.Prof2 = {}
            char.Professions.Archaeology = {}
            char.Professions.Fishing = {}
            char.Professions.Cooking = {}
            char.Professions.FirstAid = {}
            char.Professions.Prof1.Index,
            char.Professions.Prof2.Index,
            char.Professions.Archaeology.Index,
            char.Professions.Fishing.Index,
            char.Professions.Cooking.Index,
            char.Professions.FirstAid.Index = GetProfessions()
            for k, v in pairs(char.Professions) do
                if v.Index then
                    v.Name, _, v.SkillLevel, v.MaxSkillLevel, _, _, v.SkillLine, 
                    v.SkillModifier, v.SpecializationIndex, _ = GetProfessionInfo(v.Index)
                end
            end
        end
    },
    ["MageTowerPrereq"] = {
        Update = function()
            local quests = {
                45864,
                45842,
                45861,
                45862,
                45865,
                45866,
                45863,
            }
            local char = CurrentChar()
            char.MageTowerPrereq = {}
            for k, v in pairs(quests) do
                char.MageTowerPrereq[v] = IsQuestFlaggedCompleted(v)
            end
        end
    },
    ["MageTower"] = {
        Update = function()
            local quests = {
                46065, -- An Impossible Foe
                44925, -- Closing the Eye
                46035, -- End of the Risen Threat
                45627, -- Feltotem's Fall
                45526, -- The God-Queen's Fury
                45416, -- The Highlord's Return
                46127, -- Thwarting the Twins
            }
            local char = CurrentChar()
            char.MageTower = {}
            for k, v in pairs(quests) do
                char.MageTower[v] = IsQuestFlaggedCompleted(v)
            end
        end
    },
    ["Orderhall"] = {
        Update = function()
            local missions = C_Garrison.GetAvailableMissions(LE_FOLLOWER_TYPE_GARRISON_7_0)
            CurrentChar().Missions = missions
        end     
    },
    ["Followers"] = {
        Update = function()
            CurrentChar().Followers = {}
            for _, v in pairs(C_Garrison.GetFollowers(LE_FOLLOWER_TYPE_GARRISON_7_0)) do
                if not v.isTroop and v.isCollected then
                    local follower = {}
                    follower.ItemLevel = v.iLevel
                    follower.Level = v.Level
                    follower.Quality = v.quality
                    follower.PortraitIconID = v.portraitIconID
                    follower.SoundKitID = v.slotSoundKitID
                    follower.XP = v.xp
                    follower.ClassName = v.className
                    follower.ClassSpec = v.classSpec
                    follower.IsMaxLevel = v.IsMaxLevel
                    follower.Name = v.name
                    follower.GUID = v.followerID
                    follower.GarrisonFollowerID = v.garrFollowerID
                    follower.Equipment = {}
                    follower.Equipment[1] = {}
                    follower.Equipment[1].ID = C_Garrison.GetFollowerTraitAtIndex(follower.GUID, 1)
                    follower.Equipment[2] = {}
                    follower.Equipment[2].ID = C_Garrison.GetFollowerTraitAtIndex(follower.GUID, 2)
                    follower.Equipment[3] = {}
                    follower.Equipment[3].ID = C_Garrison.GetFollowerTraitAtIndex(follower.GUID, 3)
                    table.insert(CurrentChar().Followers, follower)
                end
            end
        end
    },
    ["TimePlayed"] = {
        Update = function()
            local char = CurrentChar()
            if not char.TimePlayed then
                char.TimePlayed = {}
            end
        end,
        SpecialUpdate = function(total, thisLevel)
            local char = CurrentChar()
            char.TimePlayed = {}
            char.TimePlayed.Total = total
            char.TimePlayed.Level = thisLevel
        end
    },
    ["Artifacts"] = {
        Update = function()
            local char = CurrentChar()
            if not char.Artifacts then 
                char.Artifacts = {} 
            end
        end,
        SpecialUpdate = function()
            local char = CurrentChar()
            if not char.Artifacts then 
                char.Artifacts = {} 
            end
            local id, _, name, _, power, ranks, _, _, _, _, _, _ = C_ArtifactUI.GetArtifactInfo()
            char.Artifacts[id] = {}
            char.Artifacts[id].Name = name
            char.Artifacts[id].Power = power
            char.Artifacts[id].Ranks = ranks
        end
    },
    ["Mounts"] = {
        Update = function()
            local account = CurrentAccount()
            account.Mounts = {}
            local mountSpellIDs = {
                253639, -- violet spellwing
                243651, -- shackled urzul
                171827, -- hellfire infernal
                213134, -- felblaze infernal
                232519, -- abyss worm
                253088, -- antoran charhound
            }
            -- get collected mounts
            local mountIDs = C_MountJournal.GetMountIDs()
            for _, mid in pairs(mountIDs) do
                for _, sid in pairs(mountSpellIDs) do
                    local creatureName, spellID, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mid)
                    if sid == spellID then
                        account.Mounts[sid] = {}
                        account.Mounts[sid].Name = creatureName
                        account.Mounts[sid].IsCollected = isCollected
                    end
                end
            end
            -- populate data for mounts we cannot see
            for _, sid in pairs(mountSpellIDs) do
                if account.Mounts[sid] == nil then
                    account.Mounts[sid] = {}
                    account.Mounts[sid].Name = "Unknown"
                    account.Mounts[sid].IsCollected = isCollected
                    account.Mounts[sid].IsCollected = false
                end
            end
        end,
    },
    ["FieldMedic"] = {
        Update = function()
            _, _, _, CurrentAccount().FieldMedic = GetAchievementInfo(11139)
        end,
    },
    ["KeystoneMaster"] = {
        Update = function()
            _, _, _, _, _, _, _, _, _, _, _, _, 
            CurrentChar().KeystoneMaster, _ = GetAchievementInfo(11162)
        end,
    },
    ["ChosenTransmogs"] = {
        Update = function()
            local _, _, _, _, _, _, _, _, _, _, _, _, 
            wasEarnedByMe, _ = GetAchievementInfo(11387)
            local _, englishClass, _ = UnitClass("player")
            local armorClass = GetArmorClass(englishClass)
            local account = CurrentAccount()
            if not account.ChosenTransmogs then
                account.ChosenTransmogs = {}
            end
            account.ChosenTransmogs[armorClass] = wasEarnedByMe or account.ChosenTransmogs[armorClass]
        end,
    },
    ["FisherfriendOfTheIsles"] = {
        Update = function()
            _, _, _, CurrentAccount().FisherfriendOfTheIsles = GetAchievementInfo(11725)
        end,
    },
    ["Guild"] = {
        Update = function()
            
        end,
        SpecialUpdate = function()
            CurrentChar().GuildName = GetGuildInfo("player")
        end,
    }
}

function ARWIC_AAM_UpdateData()
    for k, v in pairs(fields) do
        v.Update()
    end
end

function events:PLAYER_ENTERING_WORLD(...)
    RequestTimePlayed()
    ARWIC_AAM_UpdateData()
end

function events:ARTIFACT_UPDATE(...)
    fields["Artifacts"].SpecialUpdate()
end

function events:TIME_PLAYED_MSG(...)
    local total, thisLevel = ...
    fields["TimePlayed"].SpecialUpdate(total, thisLevel)
end

function events:PLAYER_STARTED_MOVING(...)
    ARWIC_AAM_UpdateData()
end

function events:PLAYER_GUILD_UPDATE(...)
    fields["Guild"].SpecialUpdate()
end

function events:GUILD_ROSTER_UPDATE(...)
    fields["Guild"].SpecialUpdate()
end

local function RegisterEvents()
    local eventFrame = CreateFrame("FRAME", "AAM_eventFrame")
    eventFrame:SetScript("OnEvent", function(self, event, ...)
        events[event](self, ...)
    end)
    for k, v in pairs(events) do
        eventFrame:RegisterEvent(k)
    end
end

RegisterEvents()
