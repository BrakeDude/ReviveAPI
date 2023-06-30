-- Coded by BrakeDude
-- Initial inspiration + a litte bit of code - dsju (Go download Red Baby mod https://steamcommunity.com/sharedfiles/filedetails/?id=2992868259. NOW!)
-- Because of RNG nature of Guppy's Collar and Broken Ankh make is not work as wanted they are excluded (i hope temporarily)

ModCallbacks.MC_PRE_PLAYER_REVIVE = "MC_PRE_PLAYER_REVIVE"
ModCallbacks.MC_POST_PLAYER_REVIVE = "MC_POST_PLAYER_REVIVE"

local currentVerssion = 1.0

local function load(newversion)
    local mod = RegisterMod("Revive API", 1)
    mod.Version = currentVerssion
    ReviveAPI = mod

    mod.CallbackRevivalPriority = 
    {
        LOST_BIRTHRIGHT = -1,
        MISSING_POSTER = -2,
        JUDAS_SHADOW = -3,
        BROKEN_ANKH = -4,
        ANKH = -5,
        LAZARUS_RAGS = -6,
        GUPPYS_COLLAR = -7,
        INNER_CHILD = -8,
        DEAD_CAT = -9,
        LAZARUS = -10,
        MUSHROOM_1UP = -11,
        SOUL_LAZARUS = -12,
    }

    local wasDeadPlayer = {}

    local revivePriorityTable = {
        function(player)
            return player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and player:GetPlayerType() == PlayerType.PLAYER_THELOST_B
        end,
        
        function(player)
            return player:HasTrinket(TrinketType.TRINKET_MISSING_POSTER)
        end,
        
        function(player)
            return player:HasCollectible(CollectibleType.COLLECTIBLE_JUDAS_SHADOW)
        end,
        
        --[[function(player)
            return player:HasTrinket(TrinketType.TRINKET_BROKEN_ANKH) and player:WillPlayerRevive()
        end,]]
        function(player)
            return player:HasCollectible(CollectibleType.COLLECTIBLE_ANKH)
        end,

        function(player)
            return player:HasCollectible(CollectibleType.COLLECTIBLE_LAZARUS_RAGS)
        end,

        --[[function(player)
            return player:HasCollectible(CollectibleType.COLLECTIBLE_GUPPYS_COLLAR) and player:WillPlayerRevive()
        end,]]
        function(player)
            return player:HasCollectible(CollectibleType.COLLECTIBLE_INNER_CHILD)
        end,
        function(player)
            return player:HasCollectible(CollectibleType.COLLECTIBLE_DEAD_CAT)
        end,

        function(player)
            return player:GetPlayerType() == PlayerType.PLAYER_LAZARUS
        end,

        function(player)
            return player:HasCollectible(CollectibleType.COLLECTIBLE_1UP)
        end,

        function(player)
            for i = 0, 3 do
                if player:GetCard(i) == Card.CARD_SOUL_LAZARUS then
                    return true
                end
            end
            return false
        end
    }

    ---@param card Card | integer
    ---@param player EntityPlayer
    ---@param flags UseFlag | integer
    mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, card, player, flags)
        player:GetData().UsedLazarusSoul = true
    end, Card.CARD_SOUL_LAZARUS)

    ---@param player EntityPlayer
    mod:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, CallbackPriority.LATE, function(_, player)
        local playerDataId = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_SAD_ONION):GetSeed()
        if player:GetPlayerType() == PlayerType.PLAYER_LAZARUS2_B then
            playerDataId = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_INNER_EYE):GetSeed()
        end
        if not wasDeadPlayer[playerDataId] then
            wasDeadPlayer[playerDataId] = {}
        end
        local effects = player:GetEffects()
        if not player:GetData().UsedLazarusSoul then    
            if not effects:HasNullEffect(NullItemID.ID_LAZARUS_SOUL_REVIVE) then
                effects:AddNullEffect(NullItemID.ID_LAZARUS_SOUL_REVIVE)
            end
            
            if not wasDeadPlayer[playerDataId].Dead then
                local callbacks = Isaac.GetCallbacks(ModCallbacks.MC_PRE_PLAYER_REVIVE, true)
                for _,callback in ipairs(callbacks) do
                    local priority = callback.Priority
                    local param = callback.Param or -1
                    param = math.max(-1, param)
                    if param == 0 then param = -1 end
                    local vanillaRevive = false
                    if priority > -(#revivePriorityTable + 1) then
                        for i = #revivePriorityTable, math.abs(math.min(priority, -1)), -1 do
                            vanillaRevive = vanillaRevive or revivePriorityTable[i](player)
                        end
                    end
                    if param == -1 or param > 0 and player:HasCollectible(param) then
                        local callbackRes = callback.Function(callback.Mod, player)
                        if not vanillaRevive and callbackRes then
                            wasDeadPlayer[playerDataId].Revive = param
                            break
                        end
                    end
                end
            end
            
            if wasDeadPlayer[playerDataId].Revive == nil then
                effects:RemoveNullEffect(NullItemID.ID_LAZARUS_SOUL_REVIVE)
            end
        end

        if not player:IsDead() and wasDeadPlayer[playerDataId].Dead then
            if player:GetData().UsedLazarusSoul then
                player:GetData().UsedLazarusSoul = nil
            elseif wasDeadPlayer[playerDataId].Revive then
                local callbacks = Isaac.GetCallbacks(ModCallbacks.MC_POST_PLAYER_REVIVE, true)
                local collectible = wasDeadPlayer[playerDataId].Revive
                if collectible == -1 then collectible = CollectibleType.COLLECTIBLE_NULL end
                for _,callback in ipairs(callbacks) do
                    callback.Function(callback.Mod, player, wasDeadPlayer[playerDataId].Revive)
                end
                wasDeadPlayer[playerDataId].Revive = nil
            end
        end

        wasDeadPlayer[playerDataId].Dead = player:IsDead()
    end, 0)

    if newversion then
        print("New version "..mod.Version.." loaded.")
    else
        print("["..mod.Name.."] version "..mod.Version.." loaded.")
    end

end

if not ReviveAPI then
    load()
elseif ReviveAPI.Version < currentVerssion then
    print("Found newer version of ["..ReviveAPI.Name.."]. Unloading old version.")
    ReviveAPI = nil
    load(true)
end
