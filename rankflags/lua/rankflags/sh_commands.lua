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
  	hook.Add("InitPostEntity", "RankFlags.ULX", function (ply)
        function ulx.addrankflag(caller, target, flag)
            target:AssignRankFlag(flag)
            ulx.fancyLogAdmin(caller, "#A added rank flag #s to #T", flag, target)
            return true
        end

        local addrankflag_command = ulx.command("User Management", "ulx addrankflag", ulx.addrankflag, "!addrankflag")
        addrankflag_command:addParam{ type = ULib.cmds.PlayerArg, hint = "target" }
        addrankflag_command:addParam{ type = ULib.cmds.StringArg, hint = "flag", ULib.cmds.takeRestOfLine }
        addrankflag_command:defaultAccess(ULib.ACCESS_SUPERADMIN)
        addrankflag_command:help("Adds a rank flag to a user (Rank Flags).")
      
        function ulx.addrankflagid(caller, targetid, flag)
            RankFlags.AssignPlayerFlag(targetid, flag)
            ulx.fancyLogAdmin(caller, "#A added rank flag #s to #s", flag, targetid)
            return true
        end

        local addrankflagid_command = ulx.command("User Management", "ulx addrankflagid", ulx.addrankflagid, "!addrankflagid")
        addrankflagid_command:addParam{ type = ULib.cmds.StringArg, hint = "target" }
        addrankflagid_command:addParam{ type = ULib.cmds.StringArg, hint = "flag", ULib.cmds.takeRestOfLine }
        addrankflagid_command:defaultAccess(ULib.ACCESS_SUPERADMIN)
        addrankflagid_command:help("Adds a rank flag to a user (Rank Flags).")

        function ulx.removerankflag(caller, target, flag)
            target:RemoveRankFlag(flag)
            ulx.fancyLogAdmin(caller, "#A removed rank flag #s from #T", flag, target)
            return true
        end

        local removerankflag_command = ulx.command("User Management", "ulx removerankflag", ulx.removerankflag, "!removerankflag")
        removerankflag_command:addParam{ type = ULib.cmds.PlayerArg, hint = "target" }
        removerankflag_command:addParam{ type = ULib.cmds.StringArg, hint = "flag", ULib.cmds.takeRestOfLine }
        removerankflag_command:defaultAccess(ULib.ACCESS_SUPERADMIN)
        removerankflag_command:help("Removes a rank flag from a user (Rank Flags).")

        function ulx.removerankflagid(caller, targetid, flag)
            RankFlags.RemovePlayerFlag(targetid, flag)
            ulx.fancyLogAdmin(caller, "#A removed rank flag #s from #s", flag, targetid)
            return true
        end

        local removerankflagid_command = ulx.command("User Management", "ulx removerankflagid", ulx.removerankflagid, "!removerankflagid")
        removerankflagid_command:addParam{ type = ULib.cmds.StringArg, hint = "target" }
        removerankflagid_command:addParam{ type = ULib.cmds.StringArg, hint = "flag", ULib.cmds.takeRestOfLine }
        removerankflagid_command:defaultAccess(ULib.ACCESS_SUPERADMIN)
        removerankflagid_command:help("Removes a rank flag from a user (Rank Flags).")
      
        function ulx.listrankflags(caller, target)
            local flags = target:GetRankFlags()

            if table.Count(flags) == 0 then
                ULib.tsay(ply, target:GetName() .. " has no rank flags.")
            else
                ULib.tsay(ply, target:GetName() .. "'s Flags: " .. table.concat(flags, ", "))
            end

            return true
        end

        local listrankflags_command = ulx.command("User Management", "ulx listrankflags", ulx.listrankflags, "!listrankflags")
        listrankflags_command:addParam{ type = ULib.cmds.PlayerArg, hint = "target" }
        listrankflags_command:defaultAccess(ULib.ACCESS_ALL)
        listrankflags_command:help("Lists a user's rank flags (Rank Flags).")
      
        function ulx.listrankflagsid(caller, target)
            local flags = RankFlags.GetPlayerFlags(target)

            if table.Count(flags) == 0 then
                ULib.tsay(ply, target .. " has no rank flags.")
            else
                ULib.tsay(ply, target .. "'s Flags: " .. table.concat(flags, ", "))
            end

            return true
        end

        local listrankflagsid_command = ulx.command("User Management", "ulx listrankflagsid", ulx.listrankflagsid, "!listrankflagsid")
        listrankflagsid_command:addParam{ type = ULib.cmds.StringArg, hint = "target" }
        listrankflagsid_command:defaultAccess(ULib.ACCESS_ALL)
        listrankflagsid_command:help("Lists a user's rank flags (Rank Flags).")
	end)
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