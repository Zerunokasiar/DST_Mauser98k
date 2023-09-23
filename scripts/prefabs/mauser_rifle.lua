PARAMS = MAUSER_PARAMS
local assets =
{
    Asset("ANIM","anim/player_actions_speargun.zip"),
	Asset("ANIM", "anim/mauser_rifle.zip"),
	Asset("ANIM", "anim/swap_mauser_rifle_m.zip"),
	Asset("ANIM", "anim/swap_mauser_rifle_r.zip"),
	Asset("SOUNDPACKAGE", "sound/rifle.fev"),
	Asset("SOUND", "sound/rifle.fsb"),
	Asset("ATLAS", "images/inventoryimages/mauser_rifle.xml"),
	Asset("IMAGE", "images/inventoryimages/mauser_rifle.tex"),
	Asset("ATLAS", "images/inventoryimages/mauser_switch.xml"),
	Asset("IMAGE", "images/inventoryimages/mauser_switch.tex"),
}

local prefabs =
{
	"impact",
}

local function OnAnimSet(inst, owner)
	owner.AnimState:OverrideSymbol("swap_object", inst.AnimSet, "swap_rifle")
end

local function OnAnimReset(inst, owner)
	owner.AnimState:OverrideSymbol("swap_object", inst.AnimReset, "swap_rifle")
end

local function OnEquip(inst, owner)
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
	inst:BoostOff(owner)
	if inst.components.finiteuses_mauser:GetUses("ammo") > 0 then
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
	inst:BoostOff(owner)
	inst:OnDefault()
end

local function CanReloadfn(inst)
	inst.canReloadfn = {}

	inst.canReloadfn['mauser_gunstock'] = function(inst, item)
		local input1 = inst.components.finiteuses_mauser:GetUses("rifle")
		local input2 = item.components.finiteuses:GetUses()
		local max = inst.components.finiteuses_mauser:GetMaxUses("rifle")
		local result = max < (input1 + input2)
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
		local result = max < (input1 + input2)
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
		return true
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
		local prefab = SpawnPrefab("mauser_rifleb")
		local ammo = inst.components.finiteuses_mauser:GetUses("ammo")
		local rifle = inst.components.finiteuses_mauser:GetUses("rifle")
		local bayonet = item.components.finiteuses:GetPercent()
		prefab.components.finiteuses_mauser:SetUses("ammo", ammo)
		prefab.components.finiteuses_mauser:SetUses("rifle", rifle)
		prefab.components.finiteuses_mauser:SetPercent("bayonet", bayonet, true)
		prefab.Transform:SetPosition(inst.Transform:GetWorldPosition())

		local owner = inst.components.inventoryitem.owner
		owner = owner and (owner.components.inventory or owner.components.container)
		local slot = owner and owner:GetItemSlot(inst)
		local fn = slot and owner.GiveItem or owner and owner.Equip
		if fn then fn(owner, prefab, slot) end
		inst:Remove()
	end
end

local function OnReload(inst, giver, item)
	local fn = inst.onReloadfn[item.prefab]
	if fn then fn(inst, giver, item) end
	inst:onUpdate()
end

local function OnBreak(inst)
	if inst.components.finiteuses_mauser:GetUses("rifle") > 0 then
		inst:onUpdate()
		return
	end
	local owner = inst.components.inventoryitem.owner

	for i = 1, inst.components.finiteuses_mauser:GetUses("ammo") do
		local ammo = SpawnPrefab("mauser_ammo")
		owner = owner or inst
		ammo.Transform:SetPosition(owner.Transform:GetWorldPosition())
		ammo.components.inventoryitem:OnDropped(true, 1.0)
	end
	local gears = SpawnPrefab("gears")
	owner = owner or inst
	gears.Transform:SetPosition(owner.Transform:GetWorldPosition())
	gears.components.inventoryitem:OnDropped(true, 1.0)
	inst:Remove()
end

local function CloseTarget(doer, pos)
	local x, y, z = pos:Get()
	local range = PARAMS.AUTOAIM
	if doer.components.playercontroller.isclientcontrollerattached then
		range = PARAMS.RANGE * PARAMS.AUTORANGE
	end
	local ents = TheSim:FindEntities(x, y, z, range)
	local minDist = nil;
	local target = nil;
	for k,v in pairs(ents) do
		local flag = doer.components.combat
		flag = flag and doer.components.combat:CanTarget(v)
		if flag then
			local tmpDist = (pos - v:GetPosition()).magnitude
			if not minDist or tmpDist < minDist then
				minDist = tmpDist
				target = v
			end
		end
	end
	return target
end

local function CanFire(inst, doer, target, pos)
	if not doer.components.combat:CanTarget(target) then
		target = CloseTarget(doer, pos or target:GetPosition())
	end
	local flag = target ~= nil
	flag = flag and not target:IsInLimbo()
	flag = flag and target.entity:IsVisible()
	flag = flag and target.components.health ~= nil
	flag = flag and not target.components.health:IsDead()
	flag = flag and inst.components.finiteuses_mauser:GetUses("ammo") > 0
	return flag
end

local function GetMultiplier(inst)
	local owner = inst.components.inventoryitem.owner
	local combat = owner.components.combat
	local multiplier = combat.damagemultiplier or 1
	multiplier = multiplier * combat.externaldamagemultipliers:Get()
	if multiplier > 1 then
		multiplier = multiplier - 1
		multiplier = multiplier / 2.0 + 1
	end
	return 1.0 / multiplier
end

local function OnFire(inst, doer, target, pos, homing)
	if not doer.components.combat:CanTarget(target) then
		target = CloseTarget(doer, pos or target:GetPosition())
	end
	local proj = SpawnPrefab("mauser_bullet")
	local damage = PARAMS.RIFLE_DMG_R * TUNING[PARAMS.RIFLE_R]
	local multiplier = GetMultiplier(inst)
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
		doer.components.talker:Say("Run out of ammo!")
		if inst:HasTag("mauser_switch") then inst.components.finiteuses:SetUses(1) end
	end
end

local function OnHit(inst, doer, target, pos)
	if not target then target = CloseTarget(doer, pos) end
	inst.components.finiteuses_mauser:Uses("rifle")
end

local function OnDefault(inst)
	inst.name = "Mauser Rifle"
	inst:RemoveTag("mauser_switch")
	inst:equippable_default()
	inst:inventoryitem_default()
	inst:finiteuses_default()
	inst:weapon_default()
end

local function OnSwitch(inst)
	inst.name = "Mauser Rifle (Ranged)"
	inst:AddTag("mauser_switch")
	inst:equippable_switch()
	inst:inventoryitem_switch()
	inst:finiteuses_switch()
	inst:weapon_switch()
end

local function OnChange(inst, flag)
	local prefab = SpawnPrefab("mauser_rifle")
	local ammo = inst.components.finiteuses_mauser:GetUses("ammo")
	local rifle = inst.components.finiteuses_mauser:GetUses("rifle")
	prefab.components.finiteuses_mauser:SetUses("ammo", ammo)
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

local function OnDebuffSet(inst, owner)
	local value = PARAMS.RIFLE_DMG_M * TUNING[PARAMS.RIFLE_M]
	local mult = PARAMS.MOVING_SPEED
	local mult2 = mult * mult
	inst.components.weapon:SetDamage(value / mult2)
end

local function OnDebuffReset(inst, owner)
	local value = PARAMS.BAYONET_DMG_2 * TUNING[PARAMS.BAYONET_2]
	inst.components.weapon:SetDamage(value)
end

local function OnStartStarving(owner)
	local inst = owner.components.combat:GetWeapon()
	OnDebuffSet(inst)
end

local function OnStopStarving(owner)
	local inst = owner.components.combat:GetWeapon()
	OnDebuffReset(inst)
end

local function BoostOn(inst, owner)
	inst:AddTag("mauser_boost")
	local mult = PARAMS.MOVING_SPEED
	inst.components.equippable.walkspeedmult = mult
	local mult2 = mult * mult
	if owner.components.hunger ~= nil then
        owner.components.hunger.burnratemodifiers:SetModifier(inst, mult)
		if owner.components.hunger:IsStarving() then
			OnDebuffSet(inst)
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
		OnDebuffReset(inst)
		owner:RemoveEventCallback("startstarving", OnStartStarving)
		owner:RemoveEventCallback("stopstarving", OnStopStarving)
	end
end

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.AnimState:SetBank("rifle")
	inst.AnimState:SetBuild("mauser_rifle")
	inst.AnimState:PlayAnimation("idle")
	
	MakeInventoryPhysics(inst)
	if MakeInventoryFloatable then
		MakeInventoryFloatable(inst, "med", 0.05, {0.75, 0.4, 0.75})
	end
	
	inst:AddTag("mauser_rifle")
	inst:AddTag(PARAMS.MAUSER_CHARGE_MOTION)

	inst.AnimBase = "swap_rifle"
	inst.AnimReset = "swap_mauser_rifle_m"
	inst.AnimSet = "swap_mauser_rifle_r"
	inst.OnDefault = OnDefault
	inst.OnSwitch = OnSwitch
	inst.CanFire = CanFire
	inst.OnFire = OnFire
	inst.BoostOn = BoostOn
	inst.BoostOff = BoostOff

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
	inst.equippable_default = function(inst)
			inst.components.equippable.walkspeedmult = 1.0
	end
	inst.equippable_switch = function(inst)
			inst.components.equippable.walkspeedmult = 1.0
	end
	inst:equippable_default()

	CanReloadfn(inst)
	OnReloadfn(inst)

	inst:AddComponent("trader")
	inst.components.trader:SetAcceptTest(CanReload)
	inst.components.trader.onaccept = OnReload

	inst:AddComponent("boostable_mauser")

	inst:AddComponent("finiteuses_mauser")
	inst.components.finiteuses_mauser:SetMaxUses("ammo", PARAMS.AMMO)
	inst.components.finiteuses_mauser:SetMaxUses("rifle", PARAMS.RIFLE_HP)
	inst.components.finiteuses_mauser:SetUses("ammo", 0)
	inst.components.finiteuses_mauser:SetUses("rifle", PARAMS.RIFLE_HP)
	
	inst:AddComponent("useableitem")
	inst.components.useableitem:SetOnUseFn(OnChange)
	
	inst:AddComponent("inventoryitem")
	inst.inventoryitem_default = function(inst)
		local path = "images/inventoryimages/mauser_rifle.xml"
		inst.components.inventoryitem.atlasname = path
	end
	inst.inventoryitem_switch = function(inst)
		local path = "images/inventoryimages/mauser_switch.xml"
		inst.components.inventoryitem.atlasname = path
	end
	inst:inventoryitem_default()

	inst:AddComponent("finiteuses")
	inst.finiteuses_default = function(inst)
		local max = inst.components.finiteuses_mauser:GetMaxUses("rifle")
		local now = inst.components.finiteuses_mauser:GetUses("rifle")
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
		local value = PARAMS.RIFLE_DMG_M * TUNING[PARAMS.RIFLE_M]
		inst.components.weapon:SetDamage(value)
		inst.components.weapon:SetRange(1, 1)
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

STRINGS.NAMES.MAUSER_RIFLE	= "Mauser Rifle"
STRINGS.RECIPE_DESC.MAUSER_RIFLE	= "Handmade Mauser 98k"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.MAUSER_RIFLE	= "It is Powerful Rifle!"

return Prefab( "mauser_rifle", fn, assets, prefabs) 