GLOBAL.MAUSER_PARAMS = {}
PARAMS = GLOBAL.MAUSER_PARAMS

PARAMS.DEBUG = GetModConfigData("mauser_debug.2_1_2") or false
PARAMS.AMMO_RECIPE_ITEM = GetModConfigData("mauser_ammo_recipe_item.2_4_4") or "goldnugget"
PARAMS.AMMO_RECIPE_ITEM_AMMOUNT = GetModConfigData("mauser_ammo_recipe_item_ammount.2_4_4") or 1
PARAMS.AMMO_RECIPE_GUNPOWDER_AMMOUNT = GetModConfigData("mauser_ammo_recipe_gunpowder_ammount.2_4_4") or 1
PARAMS.AMMO_RECIPE_PAPYRUS_AMMOUNT = GetModConfigData("mauser_ammo_recipe_papyrus_ammount.2_4_4") or 1
PARAMS.AMMO_RECIPE_OUTPUT = GetModConfigData("mauser_ammo_recipe_output.2_4_4") or 5
PARAMS.BAYONET_RECIPE_ITEM = GetModConfigData("mauser_bayonet_recipe_item.2_4_4") or "marble"
PARAMS.BAYONET_RECIPE_ITEM_AMMOUNT = GetModConfigData("mauser_bayonet_recipe_item_ammount.2_4_4") or 1
PARAMS.BAYONET_RECIPE_ROPE_AMMOUNT = GetModConfigData("mauser_bayonet_recipe_rope_ammount.2_4_4") or 1
PARAMS.BAYONET_RECIPE_TWIGS_AMMOUNT = GetModConfigData("mauser_bayonet_recipe_twigs_ammount.2_4_4") or 1
PARAMS.BAYONET_RECIPE_OUTPUT = GetModConfigData("mauser_bayonet_recipe_output.2_4_4") or 1
PARAMS.GUNSTOCK_RECIPE_BOARDS_AMMOUNT = GetModConfigData("mauser_gunstock_recipe_boards_ammount.2_4_4") or 5
PARAMS.GUNSTOCK_RECIPE_OUTPUT = GetModConfigData("mauser_gunstock_recipe_output.2_4_4") or 1
PARAMS.PARTS_RECIPE_GOLDNUGGET_AMMOUNT = GetModConfigData("mauser_parts_recipe_goldnugget_ammount.2_4_4") or 10
PARAMS.PARTS_RECIPE_GEARS_AMMOUNT = GetModConfigData("mauser_parts_recipe_gears_ammount.2_4_4") or 2
PARAMS.PARTS_RECIPE_OUTPUT = GetModConfigData("mauser_parts_recipe_output.2_4_4") or 1
PARAMS.MAUSER_CHARGE_MOTION = GetModConfigData("mauser_charge_motion.2_4_4") or "whistle"
PARAMS.MOVING_SPEED = GetModConfigData("mauser_moving_speed_factor.2_4_0") or 1.4
PARAMS.AMMO = GetModConfigData("mauser_ammo_value.2_1_2") or 5
PARAMS.AUTOAIM = GetModConfigData("mauser_autoaim_value.2_1_2") or 4
PARAMS.RANGE = GetModConfigData("mauser_range_factor.2_1_2") or 15
PARAMS.AUTORANGE = GetModConfigData("mauser_auto_range_factor.2_4_4") or 0.8
PARAMS.RIFLE_DMG_R = GetModConfigData("mauser_rifle_2_dmg_factor.2_5_0") or 1
PARAMS.RIFLE_DMG_M = GetModConfigData("mauser_rifle_1_dmg_factor.2_5_0") or 1.5
PARAMS.BAYONET_DMG_2 = GetModConfigData("mauser_bayonet_2_dmg_factor.2_5_0") or 1.25
PARAMS.BAYONET_DMG_1 = GetModConfigData("mauser_bayonet_1_dmg_factor.2_5_0") or 0.8
PARAMS.RIFLE_HP = GetModConfigData("mauser_rifle_hp_value.2_3_0") or 25
PARAMS.BAYONET_HP_2 = GetModConfigData("mauser_bayonet_2_hp_value.2_4_4") or 200
PARAMS.BAYONET_HP_1 = GetModConfigData("mauser_bayonet_1_hp_value.2_1_9") or 400

PARAMS.RIFLE_R = "MAX_FIRE_DAMAGE_PER_SECOND"
PARAMS.RIFLE_M = "SPEAR_DAMAGE"

if PARAMS.DEBUG then
	PARAMS.RIFLE_HP = math.ceil(math.sqrt(PARAMS.RIFLE_HP))
	PARAMS.BAYONET_HP_2 = math.ceil(math.sqrt(PARAMS.BAYONET_HP_2))
	PARAMS.BAYONET_HP_1 = math.ceil(math.sqrt(PARAMS.BAYONET_HP_1))
end