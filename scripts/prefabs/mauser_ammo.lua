local assets =
{
	 Asset("ANIM", "anim/mauser_ammo.zip"),
	 Asset("ATLAS", "images/inventoryimages/mauser_ammo.xml"),
	 Asset("IMAGE", "images/inventoryimages/mauser_ammo.tex"),
}

local function CanReload(inst, doer)
	local inven = doer and doer.components.inventory
	local equip = inven and inven:GetEquippedItem(EQUIPSLOTS.HANDS)
	local finit = equip and equip.components.finiteuses_mauser
	local stack = inst.components.stackable
	return finit
end

local function OnReload(inst, doer)
	local inven = doer and doer.components.inventory
	local equip = inven and inven:GetEquippedItem(EQUIPSLOTS.HANDS)
	local finit = equip and equip.components.finiteuses_mauser
	local stack = inst.components.stackable

	if finit:GetFull("ammo") then
		doer.components.talker:Say("Already Full!")
		return true
	end
	stack:Get():Remove()

	equip.components.finiteuses_mauser:AddUses("ammo")
	doer.SoundEmitter:PlaySound("rifle/reload/reload_1")
	equip:onUpdate()
	return true
end

local function fn()
	local inst = CreateEntity()

   	inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("ammo")
    inst.AnimState:SetBuild("mauser_ammo")
    inst.AnimState:PlayAnimation("idle")

	MakeInventoryPhysics(inst)
	
	if TheSim:GetGameID() == "DST" then
		if MakeInventoryFloatable then
			MakeInventoryFloatable(inst, "med", 0.05, {0.75, 0.4, 0.75})
		end
	end

	if TheSim:GetGameID() == "DST" then
		inst.entity:AddNetwork()
		inst.entity:SetPristine()
		if not TheWorld.ismastersim then return inst end
		MakeHauntableLaunch(inst)
	end
	inst:AddComponent("inspectable")
	
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "mauser_ammo"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/mauser_ammo.xml"
	
	inst:AddComponent("tradable")
	
	inst:AddComponent("activatable_mauser")
	inst.components.activatable_mauser:SetCanActivate(CanReload)
	inst.components.activatable_mauser:SetDoActivate(OnReload)

    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
	
    return inst
end

STRINGS.NAMES.MAUSER_AMMO							= "Rifle Ammo"
STRINGS.RECIPE_DESC.MAUSER_AMMO						= "7.92 × 57 mm"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.MAUSER_AMMO		= "Ammo for Mauser Rifle"

return Prefab( "mauser_ammo", fn, assets) 