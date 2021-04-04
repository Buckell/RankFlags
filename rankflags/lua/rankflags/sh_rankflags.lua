--[[
Rank Flags
An addon for Garry's Mod allowing users to have multiple "usergroups." Useful for donation systems, extra permissions, and more.

Copyright (C) 2021 Max Goddard

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
]]--

AddCSLuaFile()

RankFlags.Cache = {}

function RankFlags.GetPlayerFlags(ply)
  	if not isstring(ply) then
    	return RankFlags.Cache[ply:SteamID()] or {}
    else
    	local query = sql.QueryValue("SELECT flags FROM RankFlags WHERE id='" .. ply .. "'")
    	return query and util.JSONToTable(query) or {}
   	end
end

function RankFlags.PlayerHasFlag(ply, flag)
    return table.HasValue(RankFlags.GetPlayerFlags(ply), flag)
end

function RankFlags.PlayerHasAllFlags(ply, flags)
    local ply_flags = RankFlags.GetPlayerFlags(ply)

    for _,flag in ipairs(flags) do
        if not table.HasValue(ply_flags, flag) then
            return false
        end
    end

    return true
end

function RankFlags.PlayerHasAnyFlags(ply, flags)
    local ply_flags = RankFlags.GetPlayerFlags(ply)

    for _,flag in ipairs(flags) do
        if table.HasValue(ply_flags, flag) then
            return true
        end
    end

    return false
end

if SERVER then
    util.AddNetworkString("RankFlags.UpdateCache")
  
    if not sql.TableExists("RankFlags") then
        sql.Query("CREATE TABLE RankFlags (id TINYTEXT, flags TEXT)")
    end

    function RankFlags.RefreshCache()
        local query = sql.Query("SELECT * FROM RankFlags") or {}

        for _, row in ipairs(query) do
            if player.GetBySteamID(row["id"]) then
                RankFlags.Cache[row["id"]] = util.JSONToTable(row["flags"])
            end
        end

        net.Start("RankFlags.UpdateCache")
        net.WriteTable(RankFlags.Cache)
        net.Broadcast()
    end

    function RankFlags.SetPlayerFlags(ply, flags)
        if sql.QueryValue("SELECT * FROM RankFlags WHERE id='" .. (isstring(ply) and ply or ply:SteamID()) .. "'") then
            sql.Query("UPDATE RankFlags SET flags=" .. SQLStr(util.TableToJSON(flags)) .. " WHERE id='" .. (isstring(ply) and ply or ply:SteamID()) .. "'")
    	else
            sql.Query("INSERT INTO RankFlags VALUES ('" .. (isstring(ply) and ply or ply:SteamID()) .. "', " .. SQLStr(util.TableToJSON(flags)) .. ")")
    	end

        RankFlags.RefreshCache()
    end

    function RankFlags.AssignPlayerFlag(ply, flag)
        local flags = RankFlags.GetPlayerFlags(ply)

        if not table.HasValue(flags, flag) then
            table.insert(flags, flag)
            RankFlags.SetPlayerFlags(ply, flags)
        end
    end

    function RankFlags.RemovePlayerFlag(ply, flag)
        local flags = RankFlags.GetPlayerFlags(ply)
        table.RemoveByValue(flags, flag)
    	RankFlags.SetPlayerFlags(ply, flags)
    end

    function RankFlags.AssignPlayerFlags(ply, flags)
        local pflags = RankFlags.GetPlayerFlags(ply)

        for _,flag in ipairs(flags) do
            if not table.HasValue(pflags, flag) then
                table.insert(pflags, flag)
            end
        end

    	RankFlags.SetPlayerFlags(ply, pflags)
    end
  
  	function RankFlags.RemovePlayerFlags(ply, flags)
        local pflags = RankFlags.GetPlayerFlags(ply)

        for _,flag in ipairs(flags) do
      		table.RemoveByValue(pflags, flag)
        end

    	RankFlags.SetPlayerFlags(ply, pflags)
    end

    hook.Add("PlayerInitialSpawn", "RankFlags.PlayerSpawn", function (ply, t)
        RankFlags.RefreshCache()
    end)
  
	RankFlags.RefreshCache()
else
    net.Receive("RankFlags.UpdateCache", function ()
        RankFlags.Cache = net.ReadTable()
    end)
end