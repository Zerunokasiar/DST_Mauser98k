PARAMS = MAUSER_PARAMS
local assets =
{
	Asset("ANIM", "anim/mauser_rifle.zip"),
	Asset("ANIM", "anim/swap_mauser_rifle_m.zip"),
	Asset("ATLAS", "images/inventoryimages/mauser_rifle.xml"),
	Asset("IMAGE", "images/inventoryimages/mauser_rifle.tex"),
}

local prefabs =
{
}

local function OnEquip(inst, owner)
	owner.AnimState:OverrideSymbol("swap_object", "swap_mauser_rifle_m", "swap_rifle")
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
	inst.components.boostable_mauser:BoostOff(owner)
end

local function OnUnequip(inst, owner)
	owner.AnimState:Hide("ARM_carry")
	owner.AnimState:Show("ARM_normal")
	inst.components.boostable_mauser:BoostOff(owner)
end

local function CanReloadfn(inst)
	inst.canReloadfn = {}

	inst.canReloadfn['mauser_gunstock'] = function(inst, item)
		local input1 = inst.components.finiteuses:GetUses()
		local input2 = item.components.finiteuses:GetUses()
		local max = inst.components.finiteuses:GetMaxUses()
		local result = max < (input1 + input2)
		if result then
			inst.components.finiteuses:SetUses(max)
			item.components.finiteuses:SetUses(input1 + input2 - max)
		else
			item.components.finiteuses:SetUses(input1 + input2)
		end
		return not result
	end
	inst.canReloadfn['mauser_bayonet'] = function(inst, item)
		return true
	end
	inst.canReloadfn['mauser_parts'] = function(inst, item)
		return true
	end
end

local function CanReload(inst, item)
	local fn = inst.canReloadfn[item.prefab]
	return fn and fn(inst, item) or false
end

local function OnReloadfn(inst)
	inst.onReloadfn = {}

	inst.onReloadfn['mauser_gunstock'] = function(inst, giver, item)
	end
	inst.onReloadfn['mauser_bayonet'] = function(inst, giver, item)
		local rifle = inst.components.finiteuses:GetUses()
		local bayonet = item.components.finiteuses:GetPercent()
		local prefab = SpawnPrefab("mauser_gunstockb")
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
	inst.onReloadfn['mauser_parts'] = function(inst, giver, item)
		local rifle = inst.components.finiteuses:GetUses()
		local prefab = SpawnPrefab("mauser_rifle")
		prefab.components.finiteuses_mauser:SetUses("rifle", rifle)
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
end

local function OnBreak(inst)
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

local function OnMounted(owner)
	local inst = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	if inst:HasTag("mauser_boost") then
		inst.components.boostable_mauser:BoostOff(owner)
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
		owner:ListenForEvent("mounted", OnMounted)
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
		owner:RemoveEventCallback("mounted", OnMounted)
	end
end

local function DebuffOn(inst, owner)
	local value = PARAMS.RIFLE_DMG_M * TUNING[PARAMS.RIFLE_M]
	local mult = PARAMS.MOVING_SPEED
	local mult2 = mult * mult
	inst.components.weapon:SetDamage(value / mult2)
end

local function DebuffOff(inst, owner)
	local value = PARAMS.RIFLE_DMG_M * TUNING[PARAMS.RIFLE_M]
	inst.components.weapon:SetDamage(value)
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

	inst:AddTag("allow_action_on_impassable")
	inst:AddTag(PARAMS.MAUSER_CHARGE_MOTION)

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

	inst:AddComponent("tradable")

	inst:AddComponent("boostable_mauser")
	inst.components.boostable_mauser:SetBoostOn(BoostOn)
	inst.components.boostable_mauser:SetBoostOff(BoostOff)
	inst.components.boostable_mauser:SetDebuffOn(DebuffOn)
	inst.components.boostable_mauser:SetDebuffOff(DebuffOff)

	inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "mauser_rifle"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/mauser_rifle.xml"

	inst:AddComponent("finiteuses")
	inst.components.finiteuses:SetMaxUses(PARAMS.RIFLE_HP)
	inst.components.finiteuses:SetUses(PARAMS.RIFLE_HP)
	inst.components.finiteuses:SetOnFinished(OnBreak)

	inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(PARAMS.RIFLE_DMG_M * TUNING[PARAMS.RIFLE_M])
	inst.components.weapon:SetRange(1, 1)

	return inst
end

STRINGS.NAMES.MAUSER_GUNSTOCK	= "Mauser Gunstock"
STRINGS.RECIPE_DESC.MAUSER_GUNSTOCK	= "Gunstock of Mauser 98k"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.MAUSER_GUNSTOCK	= "It is Gunstock!"

return Prefab( "mauser_gunstock", fn, assets, prefabs) 