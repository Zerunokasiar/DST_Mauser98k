PARAMS = TUNING.MAUSER_PARAMS
local assets =
{
	 Asset("ANIM", "anim/mauser_bullet.zip"),
}

local function onThrown(inst, owner, target, attacker)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    if not inst.components.inventoryitem then
        owner.components.finiteuses:Use()
        inst:Remove()
    end
end

local function fn()
	local inst = CreateEntity()
   	inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst:Hide()

    inst.AnimState:SetBank("mauser_bullet")
    inst.AnimState:SetBuild("mauser_bullet")
    inst.AnimState:PlayAnimation("idle")
	
    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)

	if TheSim:GetGameID() == "DST" then
		inst.entity:AddNetwork()
		inst.entity:SetPristine()
		if not TheWorld.ismastersim then return inst end
	end
    inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(PARAMS.RIFLE_DMG_R * (TUNING[PARAMS.RIFLE_R] or 120))
--	inst.components.weapon:SetProjectile("mauser_bullet")
    inst.components.weapon:SetRange(PARAMS.RANGE,PARAMS.RANGE*2)

    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(60)
--    inst.components.projectile:SetHoming(false)
	inst.components.projectile:SetLaunchOffset(Vector3(1, 1, 0))
    inst.components.projectile:SetOnHitFn(inst.Remove)
    inst.components.projectile:SetOnMissFn(inst.Remove)
    inst.components.projectile:SetOnThrownFn(onThrown)

    inst:DoPeriodicTask(0.5,inst.Remove)
    return inst
end
return Prefab( "mauser_bullet", fn, assets) 