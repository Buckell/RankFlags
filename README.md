# Rank Flags
An addon for Garry's Mod allowing users to have multiple "usergroups." Useful for donation systems, extra permissions, and more.

## Installing
Simply drop the `rankflags` folder into your server's addons folder.

## Allowed Rank Flag Values
Flags can be any string. It can have spaces, special characters, etc. The only limit is what you're willing to type out. Flags work best when using simple single-case values like `MEDIC`, `POLICE`, etc.

## Using (ULX Commands)
The following are the primary ULX commands that are offered when ULX is enabled (using ULX is recommended). There are equivalent commands for using Steam IDs instead of players for setting offline players' rank flags. They are the exact same command with "id" appended at the end (e.g. !addrankflagid).

#### !addrankflag \<user\> \<flag\>
Adds a rank flag to the specified user.

#### !removerankflag \<user\> \<flag\>
Removes a rank flag from the specified user.

#### !listrankflags \<user\> \<flag\>
Lists the specified user's rank flags.

## Integrating With Other Addons
You'll need to do a little bit of work to use rank flags. Any "player" arguments can be replaced with a Steam ID. Be weary when using Steam IDs as they are not cached and require a database query; don't use them in "high performance" contexts. The following functions are the most useful:

#### (SHARED) RankFlags.PlayerHasFlag(\<player : Player/Steam ID\>, \<flag : String\>)
Returns a boolean depending on if the specified player has the specified flag.
<br>
**Equivalent Meta Function**: ` <player>:HasRankFlag(<flag>)`

#### (SHARED) RankFlags.PlayerHasAllFlags(\<player : Player/Steam ID\>, \<flags : Table\>)
Returns a boolean depending on if the specified player has all of the specified flags.
<br>
**Equivalent Meta Function**: ` <player>:HasAllRankFlags(<flags>)`

#### (SHARED) RankFlags.PlayerHasAnyFlags(\<player : Player/Steam ID\>, \<flags : Table\>)
Returns a boolean depending on if the specified player has any of the specified flags.
<br>
**Equivalent Meta Function**: ` <player>:HasAnyRankFlags(<flags>)`

#### (SERVER) RankFlags.AssignPlayerFlag(\<player : Player/Steam ID\>, \<flag : String\>)
Assigns the specified flag to the player.
<br>
**Equivalent Meta Function**: ` <player>:AssignRankFlag(<flags>)`

#### (SERVER) RankFlags.AssignPlayerFlags(\<player : Player/Steam ID\>, \<flags : Table\>)
Assigns the specified flags to the player.
<br>
**Equivalent Meta Function**: ` <player>:AssignRankFlags(<flags>)`

#### (SERVER) RankFlags.RemovePlayerFlag(\<player : Player/Steam ID\>, \<flag : String\>)
Removes the specified flag from the player.
<br>
**Equivalent Meta Function**: ` <player>:RemoveRankFlag(<flags>)`

#### (SERVER) RankFlags.RemovePlayerFlags(\<player : Player/Steam ID\>, \<flags : Table\>)
Removes the specified flags from the player.
<br>
**Equivalent Meta Function**: ` <player>:RemoveRankFlags(<flags>)`
<br><br><br>
**Note:** The functions related to removing flags will not throw any errors or cause any unexpected behavior when passed a flag that the player doesn't have. It will simply do nothing. The functions related to assigning flags will not add duplicate flags as well.

## Integration Example
The following is an example of a DarkRP job that requires a certain flag in order to join it.

```lua
TEAM_MEDIC = DarkRP.createJob("Medic", {
    color = Color(255, 0, 0, 255),
    model = {"models/player/Group03m/male_07.mdl"},
    description = [[You are a medic; heal people and save the day!]],
    weapons = {"weapon_medkit"},
    command = "medic",
    max = 3,
    salary = 50,
    admin = 0,
    vote = false,
    hasLicense = false,
    candemote = false,
    category = "Citizens",
    customCheck = function(ply)
    	return CLIENT or ply:HasRankFlag("MEDIC")
    end,
    CustomCheckFailMsg = "You do not have the necessary flags to join this job. Need: MEDIC."
})
```
