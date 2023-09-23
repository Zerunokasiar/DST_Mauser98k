Ingredient 	= GLOBAL.Ingredient
TECH		= GLOBAL.TECH
RECIPETABS 	= GLOBAL.RECIPETABS
Recipe 		= GLOBAL.Recipe

local output_ammo = PARAMS.AMMO_RECIPE_OUTPUT
local cost_ammo = {
	Ingredient(PARAMS.AMMO_RECIPE_ITEM, PARAMS.AMMO_RECIPE_ITEM_AMMOUNT),
	Ingredient("gunpowder", PARAMS.AMMO_RECIPE_GUNPOWDER_AMMOUNT),
	Ingredient("papyrus", PARAMS.AMMO_RECIPE_PAPYRUS_AMMOUNT)
}

local output_bayonet = PARAMS.BAYONET_RECIPE_OUTPUT
local cost_bayonet = {
	Ingredient(PARAMS.BAYONET_RECIPE_ITEM, PARAMS.BAYONET_RECIPE_ITEM_AMMOUNT),
	Ingredient("rope", PARAMS.BAYONET_RECIPE_ROPE_AMMOUNT),
	Ingredient("twigs", PARAMS.BAYONET_RECIPE_TWIGS_AMMOUNT)
}

local output_gunstock = PARAMS.GUNSTOCK_RECIPE_OUTPUT
local cost_gunstock = {
	Ingredient("boards", PARAMS.GUNSTOCK_RECIPE_BOARDS_AMMOUNT)
}

local output_parts = PARAMS.PARTS_RECIPE_OUTPUT
local cost_parts = {
	Ingredient("goldnugget", PARAMS.PARTS_RECIPE_GOLDNUGGET_AMMOUNT),
	Ingredient("gears", PARAMS.PARTS_RECIPE_GEARS_AMMOUNT)
}

local tech_ammo			= {SCIENCE = 2, MAGIC = 0, ANCIENT = 0}
local tech_bayonet		= {SCIENCE = 1, MAGIC = 0, ANCIENT = 0}
local tech_gunstock		= {SCIENCE = 1, MAGIC = 0, ANCIENT = 0}
local tech_parts		= {SCIENCE = 2, MAGIC = 0, ANCIENT = 0}

if PARAMS.DEBUG then
	cost_ammo			= {Ingredient("rocks", 1)}
	cost_bayonet		= {Ingredient("flint", 1)}
	cost_gunstock		= {Ingredient("twigs", 1)}
	cost_parts			= {Ingredient("twigs", 1)}
	tech_ammo			= {SCIENCE = 0, MAGIC = 0, ANCIENT = 0}
	tech_bayonet		= {SCIENCE = 0, MAGIC = 0, ANCIENT = 0}
	tech_gunstock		= {SCIENCE = 0, MAGIC = 0, ANCIENT = 0}
	tech_parts			= {SCIENCE = 0, MAGIC = 0, ANCIENT = 0}
end
AddRecipe("mauser_ammo", cost_ammo, RECIPETABS.WAR, tech_ammo, nil, nil, nil, output_ammo, nil, "images/inventoryimages/mauser_ammo.xml", "mauser_ammo.tex")
AddRecipe("mauser_bayonet", cost_bayonet, RECIPETABS.WAR, tech_bayonet, nil, nil, nil, output_bayonet, nil, "images/inventoryimages/mauser_bayonet.xml", "mauser_bayonet.tex")
AddRecipe("mauser_gunstock", cost_gunstock, RECIPETABS.WAR, tech_gunstock, nil, nil, nil, output_gunstock, nil, "images/inventoryimages/mauser_rifle.xml", "mauser_rifle.tex")
AddRecipe("mauser_parts", cost_parts, RECIPETABS.WAR, tech_parts, nil, nil, nil, output_parts, nil, "images/inventoryimages/mauser_parts.xml", "mauser_parts.tex")
