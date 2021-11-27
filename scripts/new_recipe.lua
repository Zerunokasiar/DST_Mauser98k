Ingredient 	= GLOBAL.Ingredient
TECH		= GLOBAL.TECH
RECIPETABS 	= GLOBAL.RECIPETABS
Recipe 		= GLOBAL.Recipe

local cost_ammo =
{
	Ingredient("goldnugget", 1),
	Ingredient("gunpowder", 1),
	Ingredient("papyrus", 1)
}
local cost_bayonet =
{
	Ingredient(PARAMS.BAYONET_RECIPE_ITEM, PARAMS.BAYONET_RECIPE_AMMOUNT),
	Ingredient("rope", 1),
	Ingredient("twigs", 1)
}
local cost_gunstock =
{
	Ingredient("boards", 5)
}
local cost_rifle =
{
	Ingredient("goldnugget", 10),
	Ingredient("gears", 2),
	Ingredient("mauser_gunstock", 1, "images/required/mauser_rifle.xml", "mauser_rifle.tex")
}
local tech_ammo			= {SCIENCE = 2, MAGIC = 0, ANCIENT = 0}
local tech_bayonet		= {SCIENCE = 1, MAGIC = 0, ANCIENT = 0}
local tech_gunstock		= {SCIENCE = 2, MAGIC = 0, ANCIENT = 0}
local tech_rifle		= {SCIENCE = 2, MAGIC = 0, ANCIENT = 0}

if PARAMS.DEBUG then
	cost_ammo			= {Ingredient("rocks", 1)}
	cost_bayonet		= {Ingredient("flint", 1)}
	cost_gunstock		= {Ingredient("twigs", 1)}
	cost_rifle			= {Ingredient("twigs", 1)}
	tech_ammo			= {SCIENCE = 0, MAGIC = 0, ANCIENT = 0}
	tech_bayonet		= {SCIENCE = 0, MAGIC = 0, ANCIENT = 0}
	tech_gunstock		= {SCIENCE = 0, MAGIC = 0, ANCIENT = 0}
	tech_rifle			= {SCIENCE = 0, MAGIC = 0, ANCIENT = 0}
end
AddRecipe("mauser_ammo",cost_ammo, RECIPETABS.WAR, tech_ammo,nil, nil, nil, 5, nil, "images/inventoryimages/mauser_ammo.xml", "mauser_ammo.tex")
AddRecipe("mauser_bayonet",cost_bayonet,  RECIPETABS.WAR, tech_bayonet, nil, nil, nil, 1, nil, "images/inventoryimages/mauser_bayonet.xml", "mauser_bayonet.tex")
AddRecipe("mauser_gunstock",cost_gunstock,  RECIPETABS.WAR, tech_gunstock, nil, nil, nil, 1, nil, "images/inventoryimages/mauser_rifle.xml", "mauser_rifle.tex")
AddRecipe("mauser_rifle",cost_rifle,  RECIPETABS.WAR, tech_rifle, nil, nil, nil, 1, nil, "images/inventoryimages/mauser_rifle.xml", "mauser_rifle.tex")
