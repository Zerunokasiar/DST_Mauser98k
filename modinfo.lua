name 						= "Mauser Rifle & Bayonet"
version 					= "2.4.17"
description 				= "author : Snipe\nOriginal version : 1.13\nAdds Mauser 98K to the base game.\n"..version
author 						= "Zerunokasiar"
forumthread 				= ""
api_version					= 6
api_version_dst				= 10
priority 					= 4
dont_starve_compatible		= true
reign_of_giants_compatible	= true
shipwrecked_compatible		= true
dst_compatible 				= true
client_only_mod 			= false
all_clients_require_mod 	= true

icon_atlas 					= "modicon.xml"
icon 						= "modicon.tex"

local RIFLE_R = "Max Fire per Second"
local RIFLE_M = "Spear"

local function GetAmmountTable(name, size, text)
	local table = {}
	for i = 1, size do
		table[#table + 1] = {
			description = name .. " x" .. i,
			data = i,
			hover = text and text[i]
		}
	end
	return table
end

local function GetDamageTable(name, damage, delta, size)
	local text = {}
	text[10] = " = Hammer"
	text[16] = " = Axe"
	text[25] = " = Battle Spear"
	text[30] = " = Spike"
	text[35] = " = Ham Bat"
	text[40] = " = Dark Sword"
	local table = {}
	for i = 1, size do
		table[#table + 1] = {
			description = "x" .. (delta * i),
			data = delta * i,
			hover = name .. " " .. (100 * delta * i) .. "% Damage (" .. (damage * delta * i) .. ")" .. (text[i] and text[i] or "")
		}
	end
	return table
end

local function GetDurabilityTable(delta, size)
	local text = {}
	text[25] = "Shovel"
	text[75] = "Hammer"
	text[100] = "Axe"
	text[150] = "Spear"
	text[200] = "Battle Spear"
	text[400] = "Golden Tool"
	local table = {}
	for i = 1, size do
		table[#table + 1] = {
			description = delta * i,
			data = delta * i,
			hover = text[delta * i]
		}
	end
	return table
end

configuration_options =
{
    {
		name 	= "mauser_debug.2_1_2",
        label 	= "Test Mode (Just Simple Recipe)",
        options =
        {
			{description = "Disable", 			data = false},
			{description = "Enable", 			data = true},
		},
        default = false,
    },
	{
		name 	= "mauser_ammo_recipe_item.2_4_4",
		label 	= "Ammo Recipe Item",
		options =
		{
			{description = "marble",	data = "marble",			hover = "marble + gunpowder + papyrus"},
			{description = "goldnugget",	data = "goldnugget",	hover = "goldnugget + gunpowder + papyrus"},
		},
        default = "goldnugget",
	},
	{
		name 	= "mauser_ammo_recipe_item_ammount.2_4_4",
		label 	= "Ammo Recipe Ammount",
		options = GetAmmountTable("item", 20, {[1] = "default"}),
        default = 1,
	},
	{
		name 	= "mauser_ammo_recipe_gunpowder_ammount.2_4_4",
		label 	= "Ammo Recipe Ammount",
		options = GetAmmountTable("gunpowder", 20, {[1] = "default"}),
        default = 1,
	},
	{
		name 	= "mauser_ammo_recipe_papyrus_ammount.2_4_4",
		label 	= "Ammo Recipe Ammount",
		options = GetAmmountTable("papyrus", 20, {[1] = "default"}),
        default = 1,
	},
	{
		name 	= "mauser_ammo_recipe_output.2_4_4",
		label 	= "Ammo Recipe Output",
		options = GetAmmountTable("output", 20, {[5] = "default"}),
        default = 5,
	},
	{
		name 	= "mauser_bayonet_recipe_item.2_4_4",
		label 	= "Bayonet Recipe Item",
		options =
		{
			{description = "marble",	data = "marble",			hover = "marble + rope + twigs"},
			{description = "goldnugget",	data = "goldnugget",	hover = "goldnugget + rope + twigs"},
		},
        default = "marble",
	},
	{
		name 	= "mauser_bayonet_recipe_item_ammount.2_4_4",
		label 	= "Bayonet Recipe Ammount",
		options = GetAmmountTable("item", 20, {[1] = "marble recommend", [2] = "goldnugget recommend"}),
        default = 1,
	},
	{
		name 	= "mauser_bayonet_recipe_rope_ammount.2_4_4",
		label 	= "Bayonet Recipe Ammount",
		options = GetAmmountTable("rope", 20, {[1] = "default"}),
        default = 1,
	},
	{
		name 	= "mauser_bayonet_recipe_twigs_ammount.2_4_4",
		label 	= "Bayonet Recipe Ammount",
		options = GetAmmountTable("twigs", 20, {[1] = "default"}),
        default = 1,
	},
	{
		name 	= "mauser_bayonet_recipe_output.2_4_4",
		label 	= "Bayonet Recipe Output",
		options = GetAmmountTable("output", 20, {[1] = "default"}),
        default = 1,
	},
	{
		name 	= "mauser_gunstock_recipe_boards_ammount.2_4_4",
		label 	= "Gunstock Recipe Ammount",
		options = GetAmmountTable("boards", 20, {[5] = "default"}),
        default = 5,
	},
	{
		name 	= "mauser_gunstock_recipe_output.2_4_4",
		label 	= "Gunstock Recipe Output",
		options = GetAmmountTable("output", 20, {[1] = "default"}),
        default = 1,
	},
	{
		name 	= "mauser_parts_recipe_goldnugget_ammount.2_4_4",
		label 	= "Parts Recipe Ammount",
		options = GetAmmountTable("goldnugget", 20, {[10] = "default"}),
        default = 10,
	},
	{
		name 	= "mauser_parts_recipe_gears_ammount.2_4_4",
		label 	= "Parts Recipe Ammount",
		options = GetAmmountTable("gears", 20, {[2] = "default"}),
        default = 2,
	},
	{
		name 	= "mauser_parts_recipe_output.2_4_4",
		label 	= "Parts Recipe Output",
		options = GetAmmountTable("output", 20, {[1] = "default"}),
        default = 1,
	},
	{
		name 	= "mauser_charge_motion.2_4_4",
		label 	= "Mauser Charge Motion",
		options =
		{
			{description = "whistle",	data = "whistle",	hover = "default"},
			{description = "bell",	data = "bell",	hover = nil},
			{description = "horn",	data = "horn",	hover = nil},
			{description = "flute",	data = "flute",	hover = nil},
			{description = "instant",	data = "instant",	hover = nil},
		},
        default = "whistle",
	},
    {
		name 	= "mauser_moving_speed_factor.2_4_0",
        label 	= "Moving Speed Factor of Rifle&Bayonet",
        options =
        {
			{description = "x1.00",	data = 1.00, hover = "not changed"},
			{description = "x1.05", data = 1.05, hover = "speed x1.05, hunger x1.10"},
			{description = "x1.10", data = 1.10, hover = "speed x1.10, hunger x1.21"},
			{description = "x1.15", data = 1.15, hover = "speed x1.15, hunger x1.32"},
			{description = "x1.20", data = 1.20, hover = "speed x1.20, hunger x1.44"},
			{description = "x1.25", data = 1.25, hover = "speed x1.25, hunger x1.56"},
			{description = "x1.30", data = 1.30, hover = "speed x1.30, hunger x1.69"},
			{description = "x1.35", data = 1.35, hover = "speed x1.35, hunger x1.82"},
			{description = "x1.40", data = 1.40, hover = "speed x1.40, hunger x1.96"},
			{description = "x1.45", data = 1.45, hover = "speed x1.45, hunger x2.10"},
			{description = "x1.50", data = 1.50, hover = "speed x1.50, hunger x2.25"},
			{description = "x1.55", data = 1.55, hover = "speed x1.55, hunger x2.40"},
			{description = "x1.60", data = 1.60, hover = "speed x1.60, hunger x2.56"},
			{description = "x1.65", data = 1.65, hover = "speed x1.65, hunger x2.72"},
			{description = "x1.70", data = 1.70, hover = "speed x1.70, hunger x2.89"},
			{description = "x1.75", data = 1.75, hover = "speed x1.75, hunger x3.06"},
			{description = "x1.80", data = 1.80, hover = "speed x1.80, hunger x3.24"},
			{description = "x1.85", data = 1.85, hover = "speed x1.85, hunger x3.42"},
			{description = "x1.90", data = 1.90, hover = "speed x1.90, hunger x3.61"},
			{description = "x1.95", data = 1.95, hover = "speed x1.95, hunger x3.80"},
			{description = "x2.00", data = 2.00, hover = "speed x2.00, hunger x4.00"},
		},
        default = 1.4,
    },
	{
		name 	= "mauser_ammo_value.2_1_2",
		label 	= "Mauser Clip Size",
		options =
		{
			{description = "1",	data = 1,	hover = "One Shot"},
			{description = "2",	data = 2,	hover = nil},
			{description = "3",	data = 3,	hover = nil},
			{description = "4",	data = 4,	hover = nil},
			{description = "5",	data = 5,	hover = "default"},
			{description = "6",	data = 6,	hover = nil},
			{description = "7",	data = 7,	hover = nil},
			{description = "8",	data = 8,	hover = nil},
			{description = "9",	data = 9,	hover = nil},
			{description = "10",data = 10,	hover = nil},
		},
        default = 5,
	},
	{
		name 	= "mauser_autoaim_value.2_1_2",
		label 	= "Mauser Auto Aim Value",
		options =
		{
			{description = "x1",	data = 1,	hover = nil},
			{description = "x2",	data = 2,	hover = nil},
			{description = "x3",	data = 3,	hover = nil},
			{description = "x4",	data = 4,	hover = nil},
			{description = "x5",	data = 5,	hover = nil},
			{description = "x6",	data = 6,	hover = nil},
			{description = "x7",	data = 7,	hover = nil},
			{description = "x8",	data = 8,	hover = nil},
			{description = "x9",	data = 9,	hover = nil},
		},
        default = 4,
	},
	{
		name 	= "mauser_range_factor.2_1_2",
		label 	= "Mauser Range Factor",
		options =
		{
			{description = "x1.0",	data = 10,	hover = "blow dart"},
			{description = "x1.1",	data = 11,	hover = nil},
			{description = "x1.2",	data = 12,	hover = nil},
			{description = "x1.3",	data = 13,	hover = nil},
			{description = "x1.4",	data = 14,	hover = nil},
			{description = "x1.5",	data = 15,	hover = "default"},
			{description = "x1.6",	data = 16,	hover = nil},
			{description = "x1.7",	data = 17,	hover = nil},
			{description = "x1.8",	data = 18,	hover = nil},
			{description = "x1.9",	data = 19,	hover = nil},
			{description = "x2.0",	data = 20,	hover = nil},
		},
        default = 15,
	},
	{
		name 	= "mauser_auto_range_factor.2_4_4",
		label 	= "Mauser Auto Range Factor",
		options =
		{
			{description = "x1.00",	data = 1.00,	hover = "Max Range"},
			{description = "x0.95",	data = 0.95,	hover = nil},
			{description = "x0.91",	data = 0.91,	hover = nil},
			{description = "x0.87",	data = 0.87,	hover = nil},
			{description = "x0.83",	data = 0.83,	hover = nil},
			{description = "x0.80",	data = 0.80,	hover = "default"},
			{description = "x0.77",	data = 0.77,	hover = nil},
			{description = "x0.74",	data = 0.74,	hover = nil},
			{description = "x0.71",	data = 0.71,	hover = nil},
			{description = "x0.69",	data = 0.69,	hover = nil},
			{description = "x0.67",	data = 0.67,	hover = nil},
		},
        default = 0.8,
	},
	{
		name 	= "mauser_rifle_2_dmg_factor.2_5_0",
		label 	= "Mauser Ranged Damage Factor",
		options = GetDamageTable(RIFLE_R, 120, 0.05, 40),
        default = 0.05 * 20, -- 120
	},
	{
		name 	= "mauser_rifle_1_dmg_factor.2_5_0",
		label 	= "Mauser Melee Damage Factor",
		options = GetDamageTable(RIFLE_M, 34, 0.05, 100),
        default = 0.05 * 30, -- 51
	},
	{
		name 	= "mauser_bayonet_2_dmg_factor.2_5_0",
		label 	= "Equipped Bayonet Damage Factor",
		options = GetDamageTable(RIFLE_M, 34, 0.05, 100),
        default = 0.05 * 25, -- 42.5
	},
	{
		name 	= "mauser_bayonet_1_dmg_factor.2_5_0",
		label 	= "Standalone Bayonet Damage Factor",
		options = GetDamageTable(RIFLE_M, 34, 0.05, 100),
        default = 0.05 * 16, -- 27.2
	},
	{
		name 	= "mauser_rifle_hp_value.2_3_0",
		label 	= "Mauser Durability Value",
		options = GetDurabilityTable(25, 40),
        default = 25,
	},
	{
		name 	= "mauser_bayonet_2_hp_value.2_4_4",
		label 	= "Equipped Bayonet Durability Value",
		options = GetDurabilityTable(25, 40),
        default = 200,
	},
	{
		name 	= "mauser_bayonet_1_hp_value.2_1_9",
		label 	= "Standalone Bayonet Durability Value",
		options = GetDurabilityTable(25, 40),
        default = 400,
	},
}
