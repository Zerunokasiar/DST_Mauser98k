PrefabFiles = 
{
	"mauser_ammo",
	"mauser_bayonet",
	"mauser_bullet",
	"mauser_gunstock",
	"mauser_gunstockb",
	"mauser_parts",
	"mauser_rifle",
	"mauser_rifleb",
}

Assets = 
{
	Asset("ATLAS", "images/inventoryimages/mauser_ammo.xml"),
	Asset("ATLAS", "images/inventoryimages/mauser_bayonet.xml"),
	Asset("ATLAS", "images/inventoryimages/mauser_rifle.xml"),
	Asset("ATLAS", "images/inventoryimages/mauser_rifleb.xml"),
	Asset("ATLAS", "images/inventoryimages/mauser_parts.xml"),
	Asset("IMAGE", "images/inventoryimages/mauser_ammo.tex"),
	Asset("IMAGE", "images/inventoryimages/mauser_bayonet.tex"),
	Asset("IMAGE", "images/inventoryimages/mauser_rifle.tex"),
	Asset("IMAGE", "images/inventoryimages/mauser_rifleb.tex"),
	Asset("IMAGE", "images/inventoryimages/mauser_parts.tex"),
}

local env = GLOBAL.getfenv(1)
local mod_config = GLOBAL.loadfile("scripts/mod_config") or GLOBAL.loadfile("scripts/mod_config.lua")
local mod_function = GLOBAL.loadfile("scripts/mod_function") or GLOBAL.loadfile("scripts/mod_function.lua")
local new_action = GLOBAL.loadfile("scripts/new_action") or GLOBAL.loadfile("scripts/new_action.lua")
local new_recipe = GLOBAL.loadfile("scripts/new_recipe") or GLOBAL.loadfile("scripts/new_recipe.lua")
local new_stategraph = GLOBAL.loadfile("scripts/new_stategraph") or GLOBAL.loadfile("scripts/new_stategraph.lua")

GLOBAL.setfenv(mod_config, env)
GLOBAL.setfenv(mod_function, env)
GLOBAL.setfenv(new_action, env)
GLOBAL.setfenv(new_recipe, env)
GLOBAL.setfenv(new_stategraph, env)

mod_config()
mod_function()
new_action()
new_recipe()
new_stategraph()
