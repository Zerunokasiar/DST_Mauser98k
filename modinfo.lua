name 						= "Mauser Rifle & Bayonet"
description 				= "author : Snipe\nOriginal version : 1.13\nAdds Mauser 98K to the base game.\n2.1.8m"
author 						= "Zerunokasiar"
version 					= "2.1.9m"
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
local BAYONET_2 = "Tentacle Spike"
local BAYONET_1 = "Hammer"

configuration_options =
{
    {
		name 	= "mauser_debug.2_1_2",
        label 	= "Test Mode",
        options =
        {
			{description = "Disable", 			data = false},
			{description = "Enable", 			data = true},
		},
        default = false,
    },
	{
		name 	= "mauser_ammo_value.2_1_2",
		label 	= "Mauser Ammo Value",
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
		name 	= "mauser_rifle_2_dmg_factor.2_1_2",
		label 	= "Mauser Ranged Damage Factor",
		options =
		{
			{description = "x0.25",	data = 0.25,	hover = RIFLE_R.."  25% Damage"},
			{description = "x0.50",	data = 0.50,	hover = RIFLE_R.."  50% Damage"},
			{description = "x0.75",	data = 0.75,	hover = RIFLE_R.."  75% Damage"},
			{description = "x1.00",	data = 1.00,	hover = RIFLE_R.." 100% Damage (120)"},
			{description = "x1.25",	data = 1.25,	hover = RIFLE_R.." 125% Damage"},
			{description = "x1.50",	data = 1.50,	hover = RIFLE_R.." 150% Damage"},
			{description = "x1.75", data = 1.75,	hover = RIFLE_R.." 175% Damage"},
			{description = "x2.00", data = 2.00,	hover = RIFLE_R.." 200% Damage"},
			{description = "x2.25", data = 2.25,	hover = RIFLE_R.." 225% Damage"},
		},
        default = 1.00,
	},
	{
		name 	= "mauser_rifle_1_dmg_factor.2_1_2",
		label 	= "Mauser Melee Damage Factor",
		options =
		{
			{description = "x0.25",	data = 0.25,	hover = RIFLE_M.."  25% Damage"},
			{description = "x0.50",	data = 0.50,	hover = RIFLE_M.."  50% Damage"},
			{description = "x0.75",	data = 0.75,	hover = RIFLE_M.."  75% Damage"},
			{description = "x1.00",	data = 1.00,	hover = RIFLE_M.." 100% Damage (34)"},
			{description = "x1.25",	data = 1.25,	hover = RIFLE_M.." 125% Damage"},
			{description = "x1.50",	data = 1.50,	hover = RIFLE_M.." 150% Damage"},
			{description = "x1.75", data = 1.75,	hover = RIFLE_M.." 175% Damage"},
			{description = "x2.00", data = 2.00,	hover = RIFLE_M.." 200% Damage"},
			{description = "x2.25", data = 2.25,	hover = RIFLE_M.." 225% Damage"},
		},
        default = 1.00,
	},
	{
		name 	= "mauser_bayonet_2_dmg_factor.2_1_2",
		label 	= "Equipped Bayonet Damage Factor",
		options =
		{
			{description = "x0.25",	data = 0.25,	hover = BAYONET_2.."  25% Damage"},
			{description = "x0.50",	data = 0.50,	hover = BAYONET_2.."  50% Damage"},
			{description = "x0.75",	data = 0.75,	hover = BAYONET_2.."  75% Damage"},
			{description = "x1.00",	data = 1.00,	hover = BAYONET_2.." 100% Damage (68)"},
			{description = "x1.25",	data = 1.25,	hover = BAYONET_2.." 125% Damage"},
			{description = "x1.50",	data = 1.50,	hover = BAYONET_2.." 150% Damage"},
			{description = "x1.75", data = 1.75,	hover = BAYONET_2.." 175% Damage"},
			{description = "x2.00", data = 2.00,	hover = BAYONET_2.." 200% Damage"},
			{description = "x2.25", data = 2.25,	hover = BAYONET_2.." 225% Damage"},
		},
        default = 1.00,
	},
	{
		name 	= "mauser_bayonet_1_dmg_factor.2_1_2",
		label 	= "Standalone Bayonet Damage Factor",
		options =
		{
			{description = "x0.25",	data = 0.25,	hover = BAYONET_1.."  25% Damage"},
			{description = "x0.50",	data = 0.50,	hover = BAYONET_1.."  50% Damage"},
			{description = "x0.75",	data = 0.75,	hover = BAYONET_1.."  75% Damage"},
			{description = "x1.00",	data = 1.00,	hover = BAYONET_1.." 100% Damage (17)"},
			{description = "x1.25",	data = 1.25,	hover = BAYONET_1.." 125% Damage"},
			{description = "x1.50",	data = 1.50,	hover = BAYONET_1.." 150% Damage"},
			{description = "x1.75", data = 1.75,	hover = BAYONET_1.." 175% Damage"},
			{description = "x2.00", data = 2.00,	hover = BAYONET_1.." 200% Damage"},
			{description = "x2.25", data = 2.25,	hover = BAYONET_1.." 225% Damage"},
		},
        default = 1.00,
	},
	{
		name 	= "mauser_rifle_hp_value.2_1_2",
		label 	= "Mauser Durability Value",
		options =
		{
			{description = "25",	data = 25,	hover = "Shovel"},
			{description = "50",	data = 50,	hover = nil},
			{description = "75",	data = 75,	hover = "Hammer"},
			{description = "100",	data = 100,	hover = "Axe"},
			{description = "125",	data = 125,	hover = nil},
			{description = "150",	data = 150,	hover = "Spear"},
			{description = "175",	data = 175,	hover = nil},
			{description = "200",	data = 200,	hover = "Battle Spear"},
			{description = "225",	data = 225,	hover = nil},
			{description = "250",	data = 250,	hover = nil},
			{description = "275",	data = 275,	hover = nil},
			{description = "300",	data = 300,	hover = nil},
			{description = "325",	data = 325,	hover = nil},
			{description = "350",	data = 350,	hover = nil},
			{description = "375",	data = 375,	hover = nil},
			{description = "400",	data = 400,	hover = "Golden Tool"},
			{description = "450",	data = 450,	hover = nil},
			{description = "500",	data = 500,	hover = nil},
			{description = "550",	data = 550,	hover = nil},
			{description = "600",	data = 600,	hover = nil},
			{description = "650",	data = 650,	hover = nil},
			{description = "700",	data = 700,	hover = nil},
			{description = "750",	data = 750,	hover = nil},
			{description = "800",	data = 800,	hover = nil},
		},
        default = 75,
	},
	{
		name 	= "mauser_bayonet_2_hp_value.2_1_2",
		label 	= "Equipped Bayonet Durability Value",
		options =
		{
			{description = "25",	data = 25,	hover = "Shovel"},
			{description = "50",	data = 50,	hover = nil},
			{description = "75",	data = 75,	hover = "Hammer"},
			{description = "100",	data = 100,	hover = "Axe"},
			{description = "125",	data = 125,	hover = nil},
			{description = "150",	data = 150,	hover = "Spear"},
			{description = "175",	data = 175,	hover = nil},
			{description = "200",	data = 200,	hover = "Battle Spear"},
			{description = "225",	data = 225,	hover = nil},
			{description = "250",	data = 250,	hover = nil},
			{description = "275",	data = 275,	hover = nil},
			{description = "300",	data = 300,	hover = nil},
			{description = "325",	data = 325,	hover = nil},
			{description = "350",	data = 350,	hover = nil},
			{description = "375",	data = 375,	hover = nil},
			{description = "400",	data = 400,	hover = "Golden Tool"},
			{description = "450",	data = 450,	hover = nil},
			{description = "500",	data = 500,	hover = nil},
			{description = "550",	data = 550,	hover = nil},
			{description = "600",	data = 600,	hover = nil},
			{description = "650",	data = 650,	hover = nil},
			{description = "700",	data = 700,	hover = nil},
			{description = "750",	data = 750,	hover = nil},
			{description = "800",	data = 800,	hover = nil},
		},
        default = 100,
	},
	{
		name 	= "mauser_bayonet_1_hp_value.2_1_2",
		label 	= "Standalone Bayonet Durability Value",
		options =
		{
			{description = "25",	data = 25,	hover = "Shovel"},
			{description = "50",	data = 50,	hover = nil},
			{description = "75",	data = 75,	hover = "Hammer"},
			{description = "100",	data = 100,	hover = "Axe"},
			{description = "125",	data = 125,	hover = nil},
			{description = "150",	data = 150,	hover = "Spear"},
			{description = "175",	data = 175,	hover = nil},
			{description = "200",	data = 200,	hover = "Battle Spear"},
			{description = "225",	data = 225,	hover = nil},
			{description = "250",	data = 250,	hover = nil},
			{description = "275",	data = 275,	hover = nil},
			{description = "300",	data = 300,	hover = nil},
			{description = "325",	data = 325,	hover = nil},
			{description = "350",	data = 350,	hover = nil},
			{description = "375",	data = 375,	hover = nil},
			{description = "400",	data = 400,	hover = "Golden Tool"},
			{description = "450",	data = 450,	hover = nil},
			{description = "500",	data = 500,	hover = nil},
			{description = "550",	data = 550,	hover = nil},
			{description = "600",	data = 600,	hover = nil},
			{description = "650",	data = 650,	hover = nil},
			{description = "700",	data = 700,	hover = nil},
			{description = "750",	data = 750,	hover = nil},
			{description = "800",	data = 800,	hover = nil},
		},
        default = 400,
	},
}
