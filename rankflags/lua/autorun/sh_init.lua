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

RankFlags = {}

include("sh_config.lua")
include("sh_rankflag.lua")
include("sh_player.lua")
include("sh_commands.lua")