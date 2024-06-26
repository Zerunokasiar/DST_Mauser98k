PARAMS = MAUSER_PARAMS
local assets =
{
	Asset("ANIM", "anim/mauser_rifleb.zip"),
    Asset("ANIM", "anim/swap_mauser_rifleb.zip"),
	Asset("ATLAS", "images/inventoryimages/mauser_rifleb.xml"),
	Asset("IMAGE", "images/inventoryimages/mauser_rifleb.tex"),
}

local prefabs =
{
	"emote_fx", "wx78_musicbox_fx"
}

local function OnEquip(inst, owner)
	owner.AnimState:OverrideSymbol("swap_object", "swap_mauser_rifleb", "swap_melee")
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
		owner:ListenForEvent("startstarving", FUNCS.OnStartStarving)
		owner:ListenForEvent("stopstarving", FUNCS.OnStopStarving)
		owner:ListenForEvent("mounted", OnMounted)
    end
	FUNCS.BoostTaskOff(owner)
	FUNCS.BoostTaskOn(owner)
end

local function BoostOff(inst, owner)
	inst:RemoveTag("mauser_boost")
	inst.components.equippable.walkspeedmult = 1.0
    if owner.components.hunger ~= nil then
        owner.components.hunger.burnratemodifiers:RemoveModifier(inst)
		inst.components.boostable_mauser:DebuffOff(owner)
		owner:RemoveEventCallback("startstarving", FUNCS.OnStartStarving)
		owner:RemoveEventCallback("stopstarving", FUNCS.OnStopStarving)
		owner:RemoveEventCallback("mounted", OnMounted)
	end
	FUNCS.BoostTaskOff(owner)
end

local function DebuffOn(inst, owner)
	owner.components.combat.externaldamagemultipliers:SetModifier(inst, 1.0 / (PARAMS.MOVING_SPEED ^ 2), "MauserDebuff")
	inst:RemoveTag("bayonet_action")
end

local function DebuffOff(inst, owner)
	owner.components.combat.externaldamagemultipliers:RemoveModifier(inst, "MauserDebuff")
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
	inst:AddTag("mauser_action")
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

	inst:AddComponent("boostable_mauser")
	inst.components.boostable_mauser:SetBoostOn(BoostOn)
	inst.components.boostable_mauser:SetBoostOff(BoostOff)
	inst.components.boostable_mauser:SetDebuffOn(DebuffOn)
	inst.components.boostable_mauser:SetDebuffOff(DebuffOff)

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
	local value = PARAMS.BAYONET_DMG_2 * TUNING[PARAMS.RIFLE_M]
	inst.components.weapon:SetDamage(value)
	inst.components.weapon:SetRange(2, 2)
	inst.components.weapon:SetOnAttack(OnHit)
    return inst
end

STRINGS.NAMES.MAUSER_GUNSTOCKB  = "Gunstock With Bayonet"
STRINGS.RECIPE_DESC.MAUSER_GUNSTOCKB  = "Long and Sharp Gunstock"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.MAUSER_GUNSTOCKB	= "This is Gunstock with Long and Powerful Bayonet!"

return Prefab( "mauser_gunstockb", fn, assets, prefabs)