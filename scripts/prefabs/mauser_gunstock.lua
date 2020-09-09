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

local function onEquip(inst, owner)
	owner.AnimState:OverrideSymbol("swap_object", "swap_mauser_rifle_m", "swap_rifle")
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
end

local function onUnequip(inst, owner)
	owner.AnimState:Hide("ARM_carry")
	owner.AnimState:Show("ARM_normal")
end

local function canReload(inst, item)
	if item.prefab ~= "mauser_gunstock" then
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
	inst.AnimState:SetBank("rifle")
	inst.AnimState:SetBuild("mauser_rifle")
	inst.AnimState:PlayAnimation("idle")
	
	MakeInventoryPhysics(inst)
	if MakeInventoryFloatable then
		MakeInventoryFloatable(inst, "med", 0.05, {0.75, 0.4, 0.75})
	end
	
	if TheSim:GetGameID() == "DST" then
		inst.entity:AddNetwork()
		inst.entity:SetPristine()
		if not TheWorld.ismastersim then return inst end
		MakeHauntableLaunch(inst)
	end

	inst:AddComponent("inspectable")

	inst:AddComponent("equippable")
	inst.components.equippable:SetOnEquip(onEquip)
	inst.components.equippable:SetOnUnequip(onUnequip)

	inst:AddComponent("trader")
	inst.components.trader:SetAcceptTest(canReload)
	inst.components.trader.onaccept = onReload

	inst:AddComponent("tradable")

	inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "mauser_rifle"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/mauser_rifle.xml"

	inst:AddComponent("finiteuses")
	inst.components.finiteuses:SetMaxUses(PARAMS.RIFLE_HP)
	inst.components.finiteuses:SetUses(PARAMS.RIFLE_HP)
	inst.components.finiteuses:SetOnFinished(onBreak)

	inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(PARAMS.RIFLE_DMG_M * TUNING[PARAMS.RIFLE_M])

	return inst
end

STRINGS.NAMES.MAUSER_GUNSTOCK	= "Dummy Rifle"
STRINGS.RECIPE_DESC.MAUSER_GUNSTOCK	= "Dummy Mauser 98k"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.MAUSER_GUNSTOCK	= "It is Dummy Rifle!"

return Prefab( "mauser_gunstock", fn, assets, prefabs) 