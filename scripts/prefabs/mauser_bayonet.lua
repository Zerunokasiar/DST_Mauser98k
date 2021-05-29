PARAMS = TUNING.MAUSER_PARAMS
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
end

local function onUnequip(inst, owner) 
	owner.AnimState:Hide("ARM_carry") 
	owner.AnimState:Show("ARM_normal") 
end

local function canReload(inst, item)
	if item.prefab ~= "mauser_bayonet" then
		return false
	end

	local input1 = inst.components.finiteuses:GetPercent()
	local input2 = item.components.finiteuses:GetPercent()

	if 1 < input1 + input2  then
		inst.components.finiteuses:SetPercent(1)
		item.components.finiteuses:SetPercent(input1 + input2 - 1)
		item.components.finiteuses:SetUses(math.ceil(item.components.finiteuses:GetUses()))
	end
	return inst.components.finiteuses:GetPercent() < 1
end

local function onReload(inst, giver, item)
	local input1 = inst.components.finiteuses:GetPercent()
	local input2 = item.components.finiteuses:GetPercent()
	inst.components.finiteuses:SetPercent(input1 + input2)
	inst.components.finiteuses:SetUses(math.ceil(inst.components.finiteuses:GetUses()))
end

local function onBreak(inst)
	inst:Remove()
end

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.AnimState:SetBank("bayonet")
	inst.AnimState:SetBuild("mauser_bayonet")
	inst.AnimState:PlayAnimation("idle")
	
	MakeInventoryPhysics(inst)

	if TheSim:GetGameID() == "DST" then
		if MakeInventoryFloatable then
			MakeInventoryFloatable(inst, "med", 0.05, {0.75, 0.4, 0.75})
		end
	end
	
	inst:AddTag("sharp")
	
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