# ReviveAPI

This small API aims to give easier way of reviving charaters with effects after revival.

## How to setup

First, add "ReviveAPI.lua" to your project via include or require:

      include("[path_to_file].ReviveAPI")
      
or
      
      require("[path_to_file].ReviveAPI")

Then add callbacks as described next.

## New callbacks

API adds 2 new callbacks to [ModCallbacks](https://moddingofisaac.com/docs/rep/enums/ModCallbacks.html): MC_PRE_PLAYER_REVIVE and MC_POST_PLAYER_REVIVE.
MC_PRE_PLAYER_REVIVE determines if player should be revived if it returns value true. Example:

```lua

YourMod:AddCallback(ModCallbacks.MC_PRE_PLAYER_REVIVE, function(mod, player)
      --some code
      return true
end)
```

or

```lua
function YourMod:ShoulRevive(player)
      --some code
      if (condition) then
            --some code
            return true
      else
            --some code
            return false
      end
end
YourMod:AddCallback(ModCallbacks.MC_PRE_PLAYER_REVIVE, YourMod.ShoulRevive, collectible)
```

Parameter collectible takes [CollectibleType](https://moddingofisaac.com/docs/rep/enums/CollectibleType.html) and makes player revive if he has that collectible.
You can use AddPriorityCallback (either from [ModReference](https://moddingofisaac.com/docs/rep/ModReference.html#addprioritycallback) or [Isaac](https://moddingofisaac.com/docs/rep/Isaac.html#addprioritycallback) classes) to determine order of reviving function.

MC_POST_PLAYER_REVIVE determines effect after revival. Example:

```lua
YourMod:AddCallback(ModCallbacks.MC_POST_PLAYER_REVIVE, function(mod, player, collectible)
      --some code
      return true
end)
```

or

```lua
function YourMod:PostReviveEffect(player, collectible)
      --some code
end
YourMod:AddCallback(ModCallbacks.MC_POST_PLAYER_REVIVE, YourMod.PostReviveEffect)
```

"collectible" argument is [CollectibleType](https://moddingofisaac.com/docs/rep/enums/CollectibleType.html) that is equal to the parameter of the first returned MC_PRE_PLAYER_REVIVE callback. If there wasn't a parameter, it equals to CollectibleType.COLLECTIBLE_NULL.

## Enums

ReviveAPI.CallbackRevivalPriority - priority enum for vanilla revival effects:

 - LOST_BIRTHRIGHT = -1
 - MISSING_POSTER = -2
 - JUDAS_SHADOW = -3
 - BROKEN_ANKH = -4
 - ANKH = -5
 - LAZARUS_RAGS = -6
 - GUPPYS_COLLAR = -7
 - INNER_CHILD = -8
 - DEAD_CAT = -9
 - LAZARUS = -10
 - MUSHROOM_1UP = -11
 - SOUL_LAZARUS = -12

Priorities take in consideration [vanilla revival items](https://bindingofisaacrebirth.fandom.com/wiki/Category:Revival_items) and function will run after in-game revival effect of the same priority didn't go.
SOUL_LAZARUS means that you have [Soul of Lazarus](https://bindingofisaacrebirth.fandom.com/wiki/Cards_and_Runes) in your card/pill slot. Using it will always be earliest revival effect.

## Limitations

 - Because of [Guppy's Collar](https://bindingofisaacrebirth.fandom.com/wiki/Guppy%27s_Collar) and [Broken Ankh](https://bindingofisaacrebirth.fandom.com/wiki/Broken_Ankh)'s RNG they are temporarily exluded from API for now.
 - API uses [NullItemID.ID_LAZARUS_SOUL_REVIVE](https://moddingofisaac.com/docs/rep/enums/NullItemID.html) and other mods that change it probably can break it (not sure on that one though).
