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
	Ingredient("goldnugget", 2),
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
	Ingredient("mauser_gunstock", 1, "images/inventoryimages/mauser_rifle.xml")
}
local tech_ammo			= {SCIENCE = 2, MAGIC = 0, ANCIENT = 0}
local tech_bayonet		= {SCIENCE = 1, MAGIC = 0, ANCIENT = 0}
local tech_gunstock		= {SCIENCE = 1, MAGIC = 0, ANCIENT = 0}
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

if GLOBAL.TheSim:GetGameID() == "DST" then
	AddRecipe("mauser_ammo",cost_ammo, RECIPETABS.WAR, tech_ammo,nil, nil, nil, 5, nil, "images/inventoryimages/mauser_ammo.xml")
	AddRecipe("mauser_bayonet",cost_bayonet,  RECIPETABS.WAR, tech_bayonet, nil, nil, nil, 1, nil, "images/inventoryimages/mauser_bayonet.xml")
	AddRecipe("mauser_gunstock",cost_gunstock,  RECIPETABS.WAR, tech_gunstock, nil, nil, nil, 1, nil, "images/inventoryimages/mauser_rifle.xml")
	AddRecipe("mauser_rifle",cost_rifle,  RECIPETABS.WAR, tech_rifle, nil, nil, nil, 1, nil, "images/inventoryimages/mauser_rifle.xml")
else
	local function AddRecipe(_recName, _ingrList, _tab, _techLevel, _recType, _placer, _spacing, _proxyLock, _amount)
		if GLOBAL.CAPY_DLC and GLOBAL.IsDLCEnabled(GLOBAL.CAPY_DLC) then
			return GLOBAL.Recipe(_recName, _ingrList , _tab, _techLevel, _recType, _placer, _spacing, _proxyLock, _amount)
		else
			return GLOBAL.Recipe(_recName, _ingrList , _tab, _techLevel, _placer, _spacing, _proxyLock, _amount)
		end
	end

	local mauser_ammo = AddRecipe("mauser_ammo",cost_ammo, RECIPETABS.WAR, tech_ammo, "common", nil, nil, nil, 5)
	local mauser_bayonet = AddRecipe("mauser_bayonet",cost_bayonet,  RECIPETABS.WAR, tech_bayonet, "common", nil, nil, nil, 1)
	local mauser_gunstock = AddRecipe("mauser_gunstock",cost_gunstock,  RECIPETABS.WAR, tech_gunstock, "common", nil, nil, nil, 1)
	local mauser_rifle = AddRecipe("mauser_rifle",cost_rifle,  RECIPETABS.WAR, tech_rifle, "common", nil, nil, nil, 1)

	mauser_ammo.atlas = "images/inventoryimages/mauser_ammo.xml"
	mauser_bayonet.atlas = "images/inventoryimages/mauser_bayonet.xml"
	mauser_gunstock.atlas = "images/inventoryimages/mauser_rifle.xml"
	mauser_rifle.atlas = "images/inventoryimages/mauser_rifle.xml"
end
