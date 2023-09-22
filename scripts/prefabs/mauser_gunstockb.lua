PARAMS = MAUSER_PARAMS
local assets =
{
	Asset("ANIM", "anim/mauser_rifleb.zip"),
    Asset("ANIM", "anim/swap_mauser_rifleb_m.zip"),
	Asset("ATLAS", "images/inventoryimages/mauser_rifleb.xml"),
	Asset("IMAGE", "images/inventoryimages/mauser_rifleb.tex"),
}

local prefabs =
{
}

local function OnEquip(inst, owner)
	owner.AnimState:OverrideSymbol("swap_object", "swap_mauser_rifleb_m", "swap_rifleb")
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
	inst:BoostOff(owner)
end

local function OnUnequip(inst, owner)
	owner.AnimState:Hide("ARM_carry")
	owner.AnimState:Show("ARM_normal")
	inst:BoostOff(owner)
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
	inst.canReloadfn['mauser_bayonet'] = function(inst, item)
		local input1 = inst.components.finiteuses_mauser:GetPercent("bayonet")
		local input2 = item.components.finiteuses:GetPercent()
		local result = 1 < (input1 + input2)
		if result then
			inst.components.finiteuses_mauser:SetPercent("bayonet", 1)
			item.components.finiteuses:SetPercent(input1 + input2 - 1)
		else
			inst.components.finiteuses_mauser:SetPercent("bayonet", input1 + input2, true)
		end
		return not result
	end
	inst.canReloadfn['mauser_parts'] = function(inst, item)
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
	inst.onReloadfn['mauser_bayonet'] = function(inst, giver, item)
	end
	inst.onReloadfn['mauser_parts'] = function(inst, giver, item)
		local rifle = inst.components.finiteuses_mauser:GetUses("rifle")
		local bayonet = inst.components.finiteuses_mauser:GetUses("bayonet")
		local prefab = SpawnPrefab("mauser_rifleb")
		prefab.components.finiteuses_mauser:SetUses("rifle", rifle)
		prefab.components.finiteuses_mauser:SetUses("bayonet", bayonet)
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
	local prefab = SpawnPrefab("mauser_gunstock")
	local rifle = inst.components.finiteuses_mauser:GetUses("rifle")
	prefab.components.finiteuses:SetUses(rifle)

	local owner = inst.components.inventoryitem.owner
	owner = owner and owner.components.inventory
	if owner then owner:Equip(prefab) end
	inst:Remove()
end

local function OnHit(inst, doer, target, pos)
	inst.components.finiteuses_mauser:Uses("bayonet")
end

local function OnDebuffSet(inst, owner)
	local value = PARAMS.BAYONET_DMG_2 * TUNING[PARAMS.BAYONET_2]
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
	inst.AnimState:SetBank("rifleb")
	inst.AnimState:SetBuild("mauser_rifleb")
	inst.AnimState:PlayAnimation("idle")
	
	MakeInventoryPhysics(inst)
	if MakeInventoryFloatable then
		MakeInventoryFloatable(inst, "med", 0.05, {0.75, 0.4, 0.75})
	end

	inst:AddTag("sharp")
	inst:AddTag("jab")
	inst:AddTag("pointy")
	inst:AddTag("whistle")
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

	CanReloadfn(inst)
	OnReloadfn(inst)

	inst:AddComponent("trader")
	inst.components.trader:SetAcceptTest(CanReload)
	inst.components.trader.onaccept = OnReload

	inst:AddComponent("boostable_mauser")

	inst:AddComponent("finiteuses_mauser")
	inst.components.finiteuses_mauser:SetMaxUses("bayonet", PARAMS.BAYONET_HP_2)
	inst.components.finiteuses_mauser:SetMaxUses("rifle", PARAMS.RIFLE_HP)
	inst.components.finiteuses_mauser:SetUses("bayonet", PARAMS.BAYONET_HP_2)
	inst.components.finiteuses_mauser:SetUses("rifle", PARAMS.RIFLE_HP)
	
	inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "mauser_rifleb"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/mauser_rifleb.xml"

	inst:AddComponent("finiteuses")
	inst.onUpdate = function(inst)
		local max = inst.components.finiteuses_mauser:GetMaxUses("bayonet")
		local now = inst.components.finiteuses_mauser:GetUses("bayonet")
		inst.components.finiteuses:SetMaxUses(max)
		inst.components.finiteuses:SetUses(now)
		inst.components.finiteuses:SetOnFinished(OnBreak)
	end
	inst:onUpdate()

	inst:AddComponent("weapon")
	local value = PARAMS.BAYONET_DMG_2 * TUNING[PARAMS.BAYONET_2]
	inst.components.weapon:SetDamage(value)
	inst.components.weapon:SetRange(1.75, 1.75)
	inst.components.weapon:SetOnAttack(OnHit)
    return inst
end

STRINGS.NAMES.MAUSER_GUNSTOCKB  = "Dummy Rifle With Bayonet"
STRINGS.RECIPE_DESC.MAUSER_GUNSTOCKB  = "Long and Sharp Dummy Mauser 98k"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.MAUSER_GUNSTOCKB	= "This is Dummy Rifle with Long and Powerful Bayonet!"

return Prefab( "mauser_gunstockb", fn, assets, prefabs)