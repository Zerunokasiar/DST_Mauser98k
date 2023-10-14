PARAMS = MAUSER_PARAMS
FUNCS = MAUSER_FUNCS
local assets =
{
    Asset("ANIM","anim/player_actions_speargun.zip"),
	Asset("ANIM", "anim/mauser_rifleb.zip"),
    Asset("ANIM", "anim/swap_mauser_rifleb_m.zip"),
    Asset("ANIM", "anim/swap_mauser_rifleb_r.zip"),
	Asset("SOUNDPACKAGE", "sound/rifle.fev"),
	Asset("SOUND", "sound/rifle.fsb"),
	Asset("ATLAS", "images/inventoryimages/mauser_rifleb.xml"),
	Asset("IMAGE", "images/inventoryimages/mauser_rifleb.tex"),
	Asset("ATLAS", "images/inventoryimages/mauser_switch.xml"),
	Asset("IMAGE", "images/inventoryimages/mauser_switch.tex"),
}

local prefabs =
{
	"impact",
}

local function OnAnimSet(inst, owner)
	owner.AnimState:OverrideSymbol("swap_object", inst.AnimSet, "swap_rifleb")
end

local function OnAnimReset(inst, owner)
	owner.AnimState:OverrideSymbol("swap_object", inst.AnimReset, "swap_rifleb")
end

local function OnMounted(owner)
	local inst = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	if inst:HasTag("mauser_boost") then
		inst.components.boostable_mauser:BoostOff(owner)
	end
	inst:OnAnimSet(owner)
	inst:OnSwitch()
end

local function OnDismounted(owner)
	local inst = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	inst:OnAnimReset(owner)
	inst:OnDefault()
end

local function OnEquip(inst, owner)
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
	owner:ListenForEvent("mounted", OnMounted)
	owner:ListenForEvent("dismounted", OnDismounted)
	inst.components.boostable_mauser:BoostOff(owner)
	local rider = owner.components.rider:IsRiding()
	if rider then
		OnAnimSet(inst, owner)
		inst:OnSwitch()
	else
		OnAnimReset(inst, owner)
		inst:OnDefault()
	end
end

local function OnUnequip(inst, owner)
	owner.AnimState:Hide("ARM_carry")
	owner.AnimState:Show("ARM_normal")
	owner:RemoveEventCallback("mounted", OnMounted)
	owner:RemoveEventCallback("dismounted", OnDismounted)
	inst.components.boostable_mauser:BoostOff(owner)
	inst:OnDefault()
end

local function CanReloadfn(inst)
	inst.canReloadfn = {}

	inst.canReloadfn['mauser_gunstock'] = function(inst, item)
		local input1 = inst.components.finiteuses_mauser:GetUses("rifle")
		local input2 = item.components.finiteuses:GetUses()
		local max = inst.components.finiteuses_mauser:GetMaxUses("rifle")
		local result = max < input1 + input2
		if result then
			inst.components.finiteuses_mauser:SetUses("rifle", max)
			item.components.finiteuses:SetUses(input1 + input2 - max)
		else
			inst.components.finiteuses_mauser:SetUses("rifle", input1 + input2)
		end
		return not result
	end

	inst.canReloadfn['mauser_ammo'] = function(inst, item)
		if inst.components.finiteuses_mauser:GetFull("ammo") then
			return false
		end
		local input1 = inst.components.finiteuses_mauser:GetUses("ammo")
		local input2 = item.components.stackable:StackSize()
		local max = inst.components.finiteuses_mauser:GetMaxUses("ammo")
		local result = max < input1 + input2
		if result then
			inst.components.finiteuses_mauser:SetUses("ammo", max)
			item.components.stackable:SetStackSize(input1 + input2 - max + 1)
		else
			inst.components.finiteuses_mauser:SetUses("ammo", input1 + input2)
			item.components.stackable:SetStackSize(1)
		end
		return true
	end

	inst.canReloadfn['mauser_bayonet'] = function(inst, item)
		local input1 = inst.components.finiteuses_mauser:GetPercent("bayonet")
		local input2 = item.components.finiteuses:GetPercent()
		local result = 1 < input1 + input2
		if result then
			inst.components.finiteuses_mauser:SetPercent("bayonet", 1)
			item.components.finiteuses:SetPercent(input1 + input2 - 1)
		else
			inst.components.finiteuses_mauser:SetPercent("bayonet", input1 + input2, true)
		end
		return not result
	end
end

local function CanReload(inst, item)
	local fn = inst.canReloadfn[item.prefab]
	local result = fn and fn(inst, item) or false
	inst:onUpdate()
	return result
end

local function OnReloadfn(inst)
	inst.onReloadfn = {}

	inst.onReloadfn['mauser_gunstock'] = function(inst, giver, item)
	end

	inst.onReloadfn['mauser_ammo'] = function(inst, giver, item)
		giver.SoundEmitter:PlaySound("rifle/reload/reload_1")
	end

	inst.onReloadfn['mauser_bayonet'] = function(inst, giver, item)
	end
end

local function OnReload(inst, giver, item)
	local fn = inst.onReloadfn[item.prefab]
	if fn then fn(inst, giver, item) end
	inst:onUpdate()
end

local function OnBreak(inst)
	if inst.components.finiteuses_mauser:GetUses("bayonet") > 0 then
		inst:onUpdate()
		return
	end
	local prefab = SpawnPrefab("mauser_rifle")
	local ammo = inst.components.finiteuses_mauser:GetUses("ammo")
	local rifle = inst.components.finiteuses_mauser:GetUses("rifle")
	prefab.components.finiteuses_mauser:SetUses("ammo", ammo)
	prefab.components.finiteuses_mauser:SetUses("rifle", rifle)
	prefab:onUpdate()

	local owner = inst.components.inventoryitem.owner
	owner = owner and owner.components.inventory
	if owner then owner:Equip(prefab) end
	inst:Remove()
end

local function CanFire(inst, doer, target, pos)
	if not doer.components.combat:CanTarget(target) or doer.components.combat:IsAlly(target) then
		target = FUNCS.FindTarget(doer, pos or target:GetPosition())
	end
	local flag = target ~= nil
	flag = flag and not target:IsInLimbo()
	flag = flag and target.entity:IsVisible()
	flag = flag and target.components.health ~= nil
	flag = flag and not target.components.health:IsDead()
	flag = flag and inst.components.finiteuses_mauser:GetUses("ammo") > 0
	return flag
end

local function OnFire(inst, doer, target, pos, homing)
	if not doer.components.combat:CanTarget(target) or doer.components.combat:IsAlly(target) then
		target = FUNCS.FindTarget(doer, pos or target:GetPosition())
	end
	local proj = SpawnPrefab("mauser_bullet")
	local damage = PARAMS.RIFLE_DMG_R * TUNING[PARAMS.RIFLE_R]
	local multiplier = FUNCS.GetMultiplier(inst)
	proj.components.weapon:SetDamage(damage * multiplier)
    proj:AddComponent("inventoryitem")
	proj.Transform:SetPosition(doer.Transform:GetWorldPosition())
	proj.components.inventoryitem.owner = doer
	proj._effect = SpawnPrefab("lanternlight") or SpawnPrefab("lanternfire")
	proj._effect.Transform:SetPosition(doer.Transform:GetWorldPosition())
	proj._effect.Light:Enable(true)
	proj._effect.Light:SetRadius(1)
	proj._effect.Light:SetFalloff(4)
	proj._effect.Light:SetIntensity(0.25)
	proj._effect:DoPeriodicTask(0.1,proj._effect.Remove)
	proj.components.projectile:SetHoming(homing)
	proj.components.projectile:Throw(proj, target, doer)
	proj:Show()
	inst.components.finiteuses_mauser:Uses("ammo")
	doer.SoundEmitter:PlaySound("rifle/fire/fire_1")
end

local function Firefn(inst, doer, target, pos)
	if CanFire(inst, doer, target, pos) then
		OnFire(inst, doer, target, pos, true)
	elseif doer and doer.components.talker then
		if not doer.components.combat:CanTarget(target) or doer.components.combat:IsAlly(target) then
			doer.components.talker:Say("Cannot fired target!")
		else
			doer.components.talker:Say("Run out of ammo!")
		end
	end
end

local function OnHit(inst, doer, target, pos)
	inst.components.finiteuses_mauser:Uses("bayonet")
end

local function OnDefault(inst)
	inst.name = "Rifle With Bayonet"
	inst:RemoveTag("mauser_switch")
	inst:RemoveTag("rangedweapon")
	inst:inventoryitem_default()
	inst:finiteuses_default()
	inst:weapon_default()
end

local function OnSwitch(inst)
	inst.name = "Rifle With Bayonet (Ranged)"
	inst:AddTag("mauser_switch")
	inst:AddTag("rangedweapon")
	inst:inventoryitem_switch()
	inst:finiteuses_switch()
	inst:weapon_switch()
end

local function OnChange(inst)
	local prefab = SpawnPrefab("mauser_rifleb")
	local ammo = inst.components.finiteuses_mauser:GetUses("ammo")
	local bayonet = inst.components.finiteuses_mauser:GetUses("bayonet")
	local rifle = inst.components.finiteuses_mauser:GetUses("rifle")
	prefab.components.finiteuses_mauser:SetUses("ammo", ammo)
	prefab.components.finiteuses_mauser:SetUses("bayonet", bayonet)
	prefab.components.finiteuses_mauser:SetUses("rifle", rifle)

	local flag = inst:HasTag("mauser_switch")
	flag = flag or inst.components.finiteuses_mauser:GetUses("ammo") == 0

	local owner = inst.components.inventoryitem.owner
	local slot = owner and owner.components.inventory
	slot:Equip(prefab)

	if flag then
		OnAnimReset(inst, owner)
		OnDefault(prefab)
	else
		OnAnimSet(inst, owner)
		OnSwitch(prefab)
	end
	inst:Remove()
end

local function OnStartStarving(owner)
	local inst = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	if inst:HasTag("mauser_boost") then
		inst.components.boostable_mauser:DebuffOn(owner)
	end
end

local function OnStopStarving(owner)
	local inst = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	if inst:HasTag("mauser_boost") then
		inst.components.boostable_mauser:DebuffOff(owner)
	end
end

local function BoostOn(inst, owner)
	inst:AddTag("mauser_boost")
	local mult = PARAMS.MOVING_SPEED
	inst.components.equippable.walkspeedmult = mult
	local mult2 = mult * mult
	if owner.components.hunger ~= nil then
        owner.components.hunger.burnratemodifiers:SetModifier(inst, mult)
		if owner.components.hunger:IsStarving() then
			inst.components.boostable_mauser:DebuffOn(owner)
		end
		owner:ListenForEvent("startstarving", OnStartStarving)
		owner:ListenForEvent("stopstarving", OnStopStarving)
    end
end

local function BoostOff(inst, owner)
	inst:RemoveTag("mauser_boost")
	inst.components.equippable.walkspeedmult = 1.0
    if owner.components.hunger ~= nil then
        owner.components.hunger.burnratemodifiers:RemoveModifier(inst)
		inst.components.boostable_mauser:DebuffOff(owner)
		owner:RemoveEventCallback("startstarving", OnStartStarving)
		owner:RemoveEventCallback("stopstarving", OnStopStarving)
	end
end

local function DebuffOn(inst, owner)
	local value = PARAMS.BAYONET_DMG_2 * TUNING[PARAMS.BAYONET_2]
	local mult = PARAMS.MOVING_SPEED
	local mult2 = mult * mult
	inst.components.weapon:SetDamage(value / mult2)
	inst:RemoveTag("bayonet_action")
end

local function DebuffOff(inst, owner)
	local value = PARAMS.BAYONET_DMG_2 * TUNING[PARAMS.BAYONET_2]
	inst.components.weapon:SetDamage(value)
	inst:AddTag("bayonet_action")
end

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.AnimState:SetBank("rifleb")
	inst.AnimState:SetBuild("mauser_rifleb")
	inst.AnimState:PlayAnimation("idle")
	
	MakeInventoryPhysics(inst)
	if MakeInventoryFloatable then
		MakeInventoryFloatable(inst, "med", 0.05, {0.75, 0.4, 0.75})
	end
	
	inst:AddTag("allow_action_on_impassable")
	inst:AddTag("sharp")
    inst:AddTag("pointy")
    inst:AddTag("jab")
	inst:AddTag("mauser_rifle")
	inst:AddTag("mauser_action")
	inst:AddTag(PARAMS.MAUSER_CHARGE_MOTION)
	
	inst.AnimBase = "swap_rifleb"
	inst.AnimReset = "swap_mauser_rifleb_m"
	inst.AnimSet = "swap_mauser_rifleb_r"
	inst.OnAnimSet = OnAnimSet
	inst.OnAnimReset = OnAnimReset
	inst.OnDefault = OnDefault
	inst.OnSwitch = OnSwitch
	inst.CanFire = CanFire
	inst.OnFire = OnFire
	
	if TheSim:GetGameID() == "DST" then
		inst.entity:AddNetwork()
		inst.entity:SetPristine()
		if not TheWorld.ismastersim then return inst end
		MakeHauntableLaunch(inst)
	end

	inst:AddComponent("inspectable")
	
	inst:AddComponent("equippable")
	inst.components.equippable:SetOnEquip(OnEquip)
	inst.components.equippable:SetOnUnequip(OnUnequip)

	CanReloadfn(inst)
	OnReloadfn(inst)

	inst:AddComponent("trader")
	inst.components.trader:SetAcceptTest(CanReload)
	inst.components.trader.onaccept = OnReload

	inst:AddComponent("boostable_mauser")
	inst.components.boostable_mauser:SetBoostOn(BoostOn)
	inst.components.boostable_mauser:SetBoostOff(BoostOff)
	inst.components.boostable_mauser:SetDebuffOn(DebuffOn)
	inst.components.boostable_mauser:SetDebuffOff(DebuffOff)

	inst:AddComponent("finiteuses_mauser")
	inst.components.finiteuses_mauser:SetMaxUses("ammo", PARAMS.AMMO)
	inst.components.finiteuses_mauser:SetMaxUses("bayonet", PARAMS.BAYONET_HP_2)
	inst.components.finiteuses_mauser:SetMaxUses("rifle", PARAMS.RIFLE_HP)
	inst.components.finiteuses_mauser:SetUses("ammo", 0)
	inst.components.finiteuses_mauser:SetUses("bayonet", PARAMS.BAYONET_HP_2)
	inst.components.finiteuses_mauser:SetUses("rifle", PARAMS.RIFLE_HP)
	
	inst:AddComponent("useableitem")
	inst.components.useableitem:SetOnUseFn(OnChange)
	
	inst:AddComponent("inventoryitem")
	inst.inventoryitem_default = function(inst)
		local path = "images/inventoryimages/mauser_rifleb.xml"
		inst.components.inventoryitem.atlasname = path
	end
	inst.inventoryitem_switch = function(inst)
		local path = "images/inventoryimages/mauser_switch.xml"
		inst.components.inventoryitem.atlasname = path
	end
	inst:inventoryitem_default()

	inst:AddComponent("finiteuses")
	inst.finiteuses_default = function(inst)
		local max = inst.components.finiteuses_mauser:GetMaxUses("bayonet")
		local now = inst.components.finiteuses_mauser:GetUses("bayonet")
		inst.components.finiteuses:SetMaxUses(max)
		inst.components.finiteuses:SetUses(now)
		inst.components.finiteuses:SetOnFinished(OnBreak)
		inst.onUpdate = inst.finiteuses_default
	end
	inst.finiteuses_switch = function(inst)
		local max = inst.components.finiteuses_mauser:GetMaxUses("ammo")
		local now = inst.components.finiteuses_mauser:GetUses("ammo")
		inst.components.finiteuses:SetMaxUses(max)
		inst.components.finiteuses:SetUses(now)
		inst.components.finiteuses:SetOnFinished(nil)
		inst.onUpdate = inst.finiteuses_switch
	end
	inst:finiteuses_default()

	inst:AddComponent("weapon")
	inst.weapon_default = function(inst)
		local value = PARAMS.BAYONET_DMG_2 * TUNING[PARAMS.BAYONET_2]
		inst.components.weapon:SetDamage(value)
		inst.components.weapon:SetRange(2, 2)
		inst.components.weapon:SetProjectile(nil)
		inst.components.weapon:SetOnAttack(OnHit)
		inst.components.weapon:SetOnProjectileLaunch(nil)
			end
	inst.weapon_switch = function(inst)
		local value = PARAMS.RIFLE_DMG_R * TUNING[PARAMS.RIFLE_R]
		inst.components.weapon:SetDamage(value)
		inst.components.weapon:SetRange(PARAMS.RANGE, PARAMS.RANGE * 2)
		inst.components.weapon:SetProjectile("mauser_bullet")
		inst.components.weapon:SetOnAttack(nil)
		inst.components.weapon:SetOnProjectileLaunch(Firefn)
			end
	inst:weapon_default()
    return inst
end

STRINGS.NAMES.MAUSER_RIFLEB  = "Rifle With Bayonet"
STRINGS.RECIPE_DESC.MAUSER_RIFLEB  = "Long and Sharp Mauser 98k"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.MAUSER_RIFLEB	= "This is Rifle with Long and Powerful Bayonet!"

return Prefab( "mauser_rifleb", fn, assets, prefabs)