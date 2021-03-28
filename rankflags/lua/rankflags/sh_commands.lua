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

if RankFlags.Config.UseULX then
    function ulx.addrankflag(caller, target, flag)
        if SERVER then
            target:AssignRankFlag(flag)
        end

        caller:ChatPrint("Added rank flag '" .. flag .. "' to " .. target:GetName() .. ".")
    end

    local addrankflag_command = ulx.command("User Management", "ulx addrankflag", ulx.addrankflag, "!addrankflag")
    addrankflag_command:addParam{ type = ULib.cmds.PlayersArg }
    addrankflag_command:addParam{ type = ULib.cmds.StringArg }
    addrankflag_command:defaultAccess(ULib.ACCESS_SUPERADMIN)
    addrankflag_command:help("Adds a rank flag to a user (Rank Flags).")
    addrankflag_command:logString("#1s added rank flag '#3s' to #2s.")

    ulx.addToMenu(ulx.ID_MCLIENT, "Add Rank Flag", "ulx addrankflag")

    function ulx.removerankflag(caller, target, flag)
        if SERVER then
            target:RemoveRankFlag(flag)
        end

        caller:ChatPrint("Removed rank flag '" .. flag .. "' from " .. target:GetName() .. ".")
    end

    local removerankflag_command = ulx.command("User Management", "ulx removerankflag", ulx.removerankflag, "!removerankflag")
    removerankflag_command:addParam{ type = ULib.cmds.PlayersArg }
    removerankflag_command:addParam{ type = ULib.cmds.StringArg }
    removerankflag_command:defaultAccess(ULib.ACCESS_SUPERADMIN)
    removerankflag_command:help("Removes a rank flag from a user (Rank Flags).")
    removerankflag_command:logString("#1s removed rank flag '#3s' to #2s.")

    ulx.addToMenu(ulx.ID_MCLIENT, "Remove Rank Flag", "ulx removerankflag")

    function ulx.listrankflags(caller, target)
        local flags = target:GetRankFlags()

        if table.Empty(flags) then
            caller:ChatPrint(target:GetName() .. " has no rank flags.")
        else
            caller:ChatPrint(target:GetName() .. "'s Flags: " .. table.concat(flags, ", "))
        end
    end

    local listrankflags_command = ulx.command("User Management", "ulx listrankflags", ulx.listrankflags, "!listrankflags")
    listrankflags_command:addParam{ type = ULib.cmds.PlayersArg }
    listrankflags_command:defaultAccess(ULib.ACCESS_USER)
    listrankflags_command:help("Lists a user's rank flags (Rank Flags).")

    ulx.addToMenu(ulx.ID_MCLIENT, "List User Rank Flags", "ulx listrankflags")
else
    if SERVER then
        RankFlags.Commands = {}

        function RankFlags.AddCommand(identifier, admin_only, func)
            RankFlags.Commands[identifier] = {
                admin_only = admin_only,
                call = func
            }
        end

        function RankFlags.DispatchCommand(identifier, ply, ...)
            local command = RankFlags.Commands[identifier]
        
            if command then
                if command.admin_only and not RankFlags.Config.IsAdmin(ply) then
                    ply:ChatPrint("This command is restricted to administrators only.")
                    return true
                end
        
                command.call(ply, {...} or {})
        
                return true
            else
                return false
            end
        end

        hook.Add("PlayerSay", "RankFlags.CommandDispatch", function (ply, text, team)
            if string.StartWith(text, "/") then
                local line = string.sub(text, 2)
        
                local args = string.Split(line, " ")            
                local identifier = table.remove(args, 1)
                
                if RankFlags.DispatchCommand(identifier, ply, unpack(args)) then
                    return ""
                end
            end
        end)

        RankFlags.AddCommand("addrankflag", true, function (ply, args)
            if #args >= 2 then
                for ply in ents.GetAll() do
                    if string.find(ply:GetName(), args[1]) then
                        local flag = table.concat(args, " ", 2)
                        ply:AssignRankFlag(flag)
                        caller:ChatPrint("Added rank flag '" .. flag .. "' to " .. target:GetName() .. ".")
                        return
                    end
                end

                ply:ChatPrint("User could not be found.")
            else
                ply:ChatPrint("Invalid amount of arguments. Requires one player argument and another for the flag.")
            end
        end)

        RankFlags.AddCommand("removerankflag", true, function (ply, args)
            if #args >= 2 then
                for ply in ents.GetAll() do
                    if string.find(ply:GetName(), args[1]) then
                        local flag = table.concat(args, " ", 2)
                        ply:RemoveRankFlag(flag)
                        caller:ChatPrint("Removed rank flag '" .. flag .. "' from " .. target:GetName() .. ".")
                        return
                    end
                end

                ply:ChatPrint("User could not be found.")
            else
                ply:ChatPrint("Invalid amount of arguments. Requires one player argument and another for the flag.")
            end
        end)

        RankFlags.AddCommand("listrankflags", false, function (ply, args)
            if #args >= 1 then
                for ply in ents.GetAll() do
                    if string.find(ply:GetName(), args[1]) then
                        local flags = ply:GetRankFlags()

                        if table.Empty(flags) then
                            caller:ChatPrint(target:GetName() .. " has no rank flags.")
                        else
                            caller:ChatPrint(target:GetName() .. "'s Flags: " .. table.concat(flags, ", "))
                        end

                        return
                    end
                end

                ply:ChatPrint("User could not be found.")
            else
                ply:ChatPrint("Invalid amount of arguments. Requires one player argument.")
            end
        end)
    end
end