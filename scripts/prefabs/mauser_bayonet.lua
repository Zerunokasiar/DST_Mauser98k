PARAMS = MAUSER_PARAMS
local assets =
{
	Asset("ANIM", "anim/mauser_bayonet.zip"),
    Asset("ANIM", "anim/swap_mauser_bayonet.zip"),
	Asset("ATLAS", "images/inventoryimages/mauser_bayonet.xml"),
	Asset("IMAGE", "images/inventoryimages/mauser_bayonet.tex"),
}

local function onEquip(inst, owner) 
	owner.AnimState:OverrideSymbol("swap_object", "swap_mauser_bayonet", "swap_bayonet")
	owner.AnimState:Show("ARM_carry") 
	owner.AnimState:Hide("ARM_normal")
	inst:BoostOff(owner)
end

local function onUnequip(inst, owner) 
	owner.AnimState:Hide("ARM_carry") 
	owner.AnimState:Show("ARM_normal") 
	inst:BoostOff(owner)
end

local function canReload(inst, item)
	if item.prefab ~= "mauser_bayonet" then
		return false
	end
	local input1 = inst.components.finiteuses:GetUses()
	local input2 = item.components.finiteuses:GetUses()
	local max = inst.components.finiteuses:GetMaxUses()
	local result = max < (input1 + input2)
	if result then
		inst.components.finiteuses:SetUses(max)
		item.components.finiteuses:SetUses(input1 + input2 - max)
	else
		inst.components.finiteuses:SetUses(input1 + input2)
	end
	return not result
end

local function onReload(inst, giver, item)
end

local function onBreak(inst)
	inst:Remove()
end

local function OnDebuffSet(inst, owner)
	local value = PARAMS.BAYONET_DMG_1 * TUNING[PARAMS.BAYONET_1]
	local mult = PARAMS.MOVING_SPEED
	local mult2 = mult * mult
	inst.components.weapon:SetDamage(value / mult2)
end

local function OnDebuffReset(inst, owner)
	local value = PARAMS.BAYONET_DMG_1 * TUNING[PARAMS.BAYONET_1]
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
	inst.AnimState:SetBank("bayonet")
	inst.AnimState:SetBuild("mauser_bayonet")
	inst.AnimState:PlayAnimation("idle")
	
	MakeInventoryPhysics(inst)
	if MakeInventoryFloatable then
		MakeInventoryFloatable(inst, "med", 0.05, {0.75, 0.4, 0.75})
	end
	
	inst:AddTag("sharp")
	inst:AddTag(PARAMS.MAUSER_CHARGE_MOTION)
	inst.BoostOn = BoostOn
	inst.BoostOff = BoostOff
	
	if TheSim:GetGameID() == "DST" then
		inst.entity:AddNetwork()
		inst.entity:SetPristine()
		if not TheWorld.ismastersim then return inst end
		MakeHauntableLaunch(inst)
	end
	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "mauser_bayonet"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/mauser_bayonet.xml"
	
	inst:AddComponent("boostable_mauser")

	inst:AddComponent("equippable")
	inst.components.equippable:SetOnEquip(onEquip)
	inst.components.equippable:SetOnUnequip(onUnequip)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(PARAMS.BAYONET_HP_1)
    inst.components.finiteuses:SetUses(PARAMS.BAYONET_HP_1)
	inst.components.finiteuses:SetOnFinished(onBreak)

    inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(PARAMS.BAYONET_DMG_1 * TUNING[PARAMS.BAYONET_1])
	
	inst:AddComponent("trader")
	inst.components.trader:SetAcceptTest(canReload)
	inst.components.trader.onaccept = onReload
	
	inst:AddComponent("tradable")
	
    return inst
end

STRINGS.NAMES.MAUSER_BAYONET  = "Mauser Bayonet"
STRINGS.RECIPE_DESC.MAUSER_BAYONET  = "A Very Sharp Metal Weapon"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.MAUSER_BAYONET = "This Weapon can be Stronger."

return Prefab( "mauser_bayonet", fn, assets) 