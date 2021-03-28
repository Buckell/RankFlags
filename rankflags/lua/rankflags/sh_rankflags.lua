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
    return RankFlags.Cache[ply:SteamID64()] or {}
end

function RankFlags.PlayerHasFlag(ply, flag)
    return table.HasValue(ply:GetRankFlags(), flag)
end

function RankFlags.PlayerHasAllFlags(ply, flags)
    local ply_flags = ply:GetRankFlags()

    for _,flag in ipairs(flags) do
        if not table.HasValue(ply_flags, flag) then
            return false
        end
    end

    return true
end

function RankFlags.PlayerHasAnyFlags(ply, flags)
    local ply_flags = ply:GetRankFlags()

    for flag in flags do
        if table.HasValue(ply_flags, flag) then
            return true
        end
    end

    return false
end

if SERVER then
    util.AddNetworkString("RankFlags.UpdateCache")

    if not sql.TableExists("RankFlags") then
        sql.Query("CREATE TABLE RankFlags (id BIGINT, flags TEXT)")
    end

    function RankFlags.RefreshCache()
        local query = sql.Query("SELECT * FROM RankFlags")

        for row in query do
            RankFlags.Cache[row["id"]] = util.JSONToTable()
        end

        net.Start("RankFlags.UpdateCache")
        net.WriteTable(RankFlags.Cache)
        net.Broadcast()
    end

    function RankFlags.SetPlayerFlags(ply, flags)
        if sql.QueryValue("SELECT * FROM RankFlags WHERE id='" .. ply:SteamID64() .. "'") then
            sql.Query("UPDATE RankFlags SET flags='" .. SQLStr(util.TableToJSON(flags)) .. "' WHERE id='" .. ply:SteamID64() .. "'")
        else
            sql.Query("INSERT INTO RankFlags VALUES ('" .. ply:SteamID64() .. "', '" .. SQLStr(util.TableToJSON(flags)) .. "')")
        end

        RankFlags.RefreshCache()
    end

    function RankFlags.AssignPlayerFlag(ply, flag)
        local flags = ply:GetRankFlags()

        if not table.HasValue(flags, flag) then
            table.insert(flags, flag)
            ply:SetRankFlags(flags)
        end
    end

    function RankFlags.RemovePlayerFlag(ply, flag)
        local flags = ply:GetRankFlags()
        table.RemoveByValue(flags, flag)
        ply:SetRankFlags(ply, flags)
    end

    function RankFlags.AssignPlayerFlags(ply, flags)
        local pflags = ply:GetRankFlags()

        for flag in flags do
            if not table.HasValue(pflags, flag) then
                table.insert(flags, flag)
            end
        end

        ply:SetRankFlags(flags)
    end
else
    net.Receive("RankFlags.UpdateCache", function ()
        RankFlags.Cache = net.ReadTable()
    end)
end