PARAMS = MAUSER_PARAMS
local assets =
{
	Asset("ANIM", "anim/mauser_parts.zip"),
	Asset("ATLAS", "images/inventoryimages/mauser_parts.xml"),
	Asset("IMAGE", "images/inventoryimages/mauser_parts.tex"),
}

local prefabs =
{
}

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.AnimState:SetBank("mauser_parts")
	inst.AnimState:SetBuild("mauser_parts")
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

	inst:AddComponent("tradable")

	inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "mauser_parts"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/mauser_parts.xml"

	return inst
end

STRINGS.NAMES.MAUSER_PARTS	= "Parts of Rifle"
STRINGS.RECIPE_DESC.MAUSER_PARTS	= "Parts of Mauser 98k"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.MAUSER_PARTS	= "It is necessary to fire!"

return Prefab( "mauser_parts", fn, assets, prefabs) 