PARAMS = MAUSER_PARAMS
local assets =
{
    Asset("ANIM","anim/player_actions_speargun.zip"),
	Asset("ANIM", "anim/mauser_rifleb.zip"),
    Asset("ANIM", "anim/swap_mauser_rifleb_m.zip"),
    Asset("ANIM", "anim/swap_mauser_rifleb_r.zip"),
	Asset("SOUNDPACKAGE", "sound/rifle.fev"),
	Asset("SOUND", "sound/rifle.fsb"),
	Asset("ATLAS", "images/inventoryimages/mauser_rifleb.xml"),
	Asset("ATLAS", "images/inventoryimages/mauser_switch.xml"),
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

local function OnEquip(inst, owner)
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
	OnAnimReset(inst, owner)
	inst:OnDefault()
end

local function OnUnequip(inst, owner)
	owner.AnimState:Hide("ARM_carry")
	owner.AnimState:Show("ARM_normal")
	inst:OnDefault()
end

local function CanReloadfn(inst)
	inst.canReloadfn = {}

	inst.canReloadfn['mauser_gunstock'] = function(inst, item)
		local input1 = inst.components.finiteuses_mauser:GetPercent("rifle")
		local input2 = item.components.finiteuses:GetPercent()
	
		if 1 < input1 + input2  then
			inst.components.finiteuses_mauser:SetPercent("rifle", 1)
			item.components.finiteuses:SetPercent(input1 + input2 - 1)
			item.components.finiteuses:SetUses(math.ceil(item.components.finiteuses:GetUses()))
		end
		return not inst.components.finiteuses_mauser:GetFull("rifle")
	end

	inst.canReloadfn['mauser_ammo'] = function(inst, item)
		return not inst.components.finiteuses_mauser:GetFull("ammo")
	end

	inst.canReloadfn['mauser_bayonet'] = function(inst, item)
		local input1 = inst.components.finiteuses_mauser:GetPercent("bayonet")
		local input2 = item.components.finiteuses:GetPercent()
	
		if 1 < input1 + input2  then
			inst.components.finiteuses_mauser:SetPercent("bayonet", 1)
			item.components.finiteuses:SetPercent(input1 + input2 - 1)
			item.components.finiteuses:SetUses(math.ceil(item.components.finiteuses:GetUses()))
			
			if not inst:HasTag("mauser_switch") then
				inst:finiteuses_default()
			end
		end
		return not inst.components.finiteuses_mauser:GetFull("bayonet")
	end
end

local function CanReload(inst, item)
	local fn = inst.canReloadfn[item.prefab]
	return fn and fn(inst, item) or false
end

local function OnReloadfn(inst)
	inst.onReloadfn = {}

	inst.onReloadfn['mauser_gunstock'] = function(inst, giver, item)
		local input1 = inst.components.finiteuses_mauser:GetPercent("rifle")
		local input2 = item.components.finiteuses:GetPercent()
		inst.components.finiteuses_mauser:SetPercent("rifle", input1 + input2)

		local value = math.ceil(inst.components.finiteuses_mauser:GetUses("rifle"))
		inst.components.finiteuses_mauser:SetUses("rifle", value)
	end

	inst.onReloadfn['mauser_ammo'] = function(inst, giver, item)
		local inven = giver.components.inventory
		local items = inven and inven:GetActiveItem()
		local stack = items and items.components.stackable
		local finit = inst.components.finiteuses_mauser

		finit:AddUses("ammo")
		if finit:GetFull("ammo") then return end

		local input1 = stack and stack:StackSize() or 0
		local input2 = finit:GetMaxUses("ammo")
		local input3 = finit:GetUses("ammo")
		local input4 = math.min(input1, input2 - input3)

		if input1 == input4 then inven:SetActiveItem(nil) end
		if input4 > 0 then stack:Get(input4):Remove() end
		
		finit:AddUses("ammo", input4)
		
		if inst:HasTag("mauser_switch") then
			inst:finiteuses_switch()
		end
		giver.SoundEmitter:PlaySound("rifle/reload/reload_1")
	end
	
	inst.onReloadfn['mauser_bayonet'] = function(inst, giver, item)
		local input1 = inst.components.finiteuses_mauser:GetPercent("bayonet")
		local input2 = item.components.finiteuses:GetPercent()
		inst.components.finiteuses_mauser:SetPercent("bayonet", input1 + input2)

		local value = math.ceil(inst.components.finiteuses_mauser:GetUses("bayonet"))
		inst.components.finiteuses_mauser:SetUses("bayonet", value)
		
		if not inst:HasTag("mauser_switch") then
			inst:finiteuses_default()
		end
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

local function CloseTarget(doer, pos)
	local x, y, z = pos:Get()
	local ents = TheSim:FindEntities(x, y, z, PARAMS.AUTOAIM)
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

local function OnFire(inst, doer, target, pos, action)
	if not doer.components.combat:CanTarget(target) then
		target = CloseTarget(doer, pos or target:GetPosition())
	end
	local proj = SpawnPrefab("mauser_bullet")
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
	proj.components.projectile:Throw(proj, target, doer)
	proj:Show()
	inst.components.finiteuses_mauser:Uses("ammo")
	doer.SoundEmitter:PlaySound("rifle/fire/fire_1")
end

local function Firefn(inst, doer, target, pos)
	if CanFire(inst, doer, target, pos) then
		OnFire(inst, doer, target, pos)
	elseif doer and doer.components.talker then
		doer.components.talker:Say("Run out of ammo!")
		if inst:HasTag("mauser_switch") then inst.components.finiteuses:SetUses(1) end
	end
end

local function OnHit(inst, doer, target, pos)
	if not target then target = CloseTarget(doer, pos) end
	inst.components.finiteuses_mauser:Uses("bayonet")
end

local function OnDefault(inst)
	inst.name = "Rifle With Bayonet"
	inst:RemoveTag("mauser_switch")
	inst:equippable_default()
	inst:inventoryitem_default()
	inst:finiteuses_default()
	inst:weapon_default()
end

local function OnSwitch(inst)
	inst.name = "Rifle With Bayonet (Ranged)"
	inst:AddTag("mauser_switch")
	inst:equippable_switch()
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

	inst:AddTag("sharp")
	inst:AddTag("mauser_rifle")
	inst:AddTag("bayonet_action")
	
	inst.AnimBase = "swap_rifleb"
	inst.AnimReset = "swap_mauser_rifleb_m"
	inst.AnimSet = "swap_mauser_rifleb_r"
	inst.OnDefault = OnDefault
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
	inst.equippable_default = function(inst)
		if PARAMS.MOVING_SPEED then
			inst.components.equippable.walkspeedmult = PARAMS.MOVING_SPEED
		end
	end
	inst.equippable_switch = function(inst)
		if PARAMS.MOVING_DEBUFF and PARAMS.MOVING_SPEED then
			inst.components.equippable.walkspeedmult = 1.0 / PARAMS.MOVING_SPEED
		else
			inst.components.equippable.walkspeedmult = 1.0
		end
	end
	inst:equippable_default()

	CanReloadfn(inst)
	OnReloadfn(inst)

	inst:AddComponent("trader")
	inst.components.trader:SetAcceptTest(CanReload)
	inst.components.trader.onaccept = OnReload

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
		inst.components.weapon:SetRange(1.75, 1.75)
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