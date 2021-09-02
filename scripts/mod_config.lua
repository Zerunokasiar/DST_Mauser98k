GLOBAL.MAUSER_PARAMS = {}
PARAMS = GLOBAL.MAUSER_PARAMS

PARAMS.DEBUG = GetModConfigData("mauser_debug.2_1_2") or false
PARAMS.MOVING_SPEED = GetModConfigData("mauser_moving_speed.2_1_9") and true
PARAMS.AMMO = GetModConfigData("mauser_ammo_value.2_1_2") or 5
PARAMS.AUTOAIM = GetModConfigData("mauser_autoaim_value.2_1_2") or 4
PARAMS.RANGE = GetModConfigData("mauser_range_factor.2_1_2") or 15
PARAMS.RIFLE_DMG_R = GetModConfigData("mauser_rifle_2_dmg_factor.2_1_2") or 1
PARAMS.RIFLE_DMG_M = GetModConfigData("mauser_rifle_1_dmg_factor.2_1_2") or 1
PARAMS.BAYONET_DMG_2 = GetModConfigData("mauser_bayonet_2_dmg_factor.2_1_2") or 1
PARAMS.BAYONET_DMG_1 = GetModConfigData("mauser_bayonet_1_dmg_factor.2_1_2") or 1
PARAMS.RIFLE_HP = GetModConfigData("mauser_rifle_hp_value.2_1_2") or 75
PARAMS.BAYONET_HP_2 = GetModConfigData("mauser_bayonet_2_hp_value.2_1_9") or 100
PARAMS.BAYONET_HP_1 = GetModConfigData("mauser_bayonet_1_hp_value.2_1_9") or 400

PARAMS.RIFLE_R = "MAX_FIRE_DAMAGE_PER_SECOND"
PARAMS.RIFLE_M = "SPEAR_DAMAGE"
PARAMS.BAYONET_2 = "NIGHTSWORD_DAMAGE"
PARAMS.BAYONET_1 = "HAMMER_DAMAGE"

if PARAMS.DEBUG then
	PARAMS.RIFLE_HP = math.ceil(math.sqrt(PARAMS.RIFLE_HP))
	PARAMS.BAYONET_HP_2 = math.ceil(math.sqrt(PARAMS.BAYONET_HP_2))
	PARAMS.BAYONET_HP_1 = math.ceil(math.sqrt(PARAMS.BAYONET_HP_1))
end