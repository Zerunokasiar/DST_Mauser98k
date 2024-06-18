GLOBAL.MAUSER_FUNCS = {}
FUNCS = GLOBAL.MAUSER_FUNCS

FUNCS.CheckTarget = function(combat, target)
	return combat and combat:CanTarget(target) and not combat:IsAlly(target) and not target:HasTag("wall")
end

FUNCS.FindTarget = function(doer, pos)
	local x, y, z = pos:Get()
	local range = PARAMS.AUTOAIM
	if doer.components.playercontroller.isclientcontrollerattached then
		range = PARAMS.RANGE
	end
	local minDist = nil;
	local target = nil;
	for k,v in pairs(TheSim:FindEntities(x, y, z, range, nil, {"wall"})) do
		if FUNCS.CheckTarget(doer.replica.combat, v) then
			local tmpDist = (pos - v:GetPosition()).magnitude
			if not minDist or tmpDist < minDist then
				minDist = tmpDist
				target = v
			end
		end
	end
	return target
end

FUNCS.GetMultiplier = function(inst)
	local inventoryitem = inst.components.inventoryitem
	local owner = inventoryitem and inventoryitem.owner
	local combat = owner and owner.components.combat
	local damagemultiplier = combat and combat.damagemultiplier or 1
	local externaldamagemultipliers = combat and combat.externaldamagemultipliers:Get() or 1
	local multiplier = damagemultiplier * externaldamagemultipliers
	if multiplier > 1 then
		multiplier = multiplier - 1
		multiplier = multiplier / 2.0 + 1
	end
	return 1.0 / multiplier
end

FUNCS.OnStartStarving = function(owner)
	local inst = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	if inst:HasTag("mauser_boost") then
		inst.components.boostable_mauser:DebuffOn(owner)
	end
end

FUNCS.OnStopStarving = function(owner)
	local inst = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	if inst:HasTag("mauser_boost") then
		inst.components.boostable_mauser:DebuffOff(owner)
	end
end

FUNCS.BoostTaskOn = function(owner)
	owner.components.talker:Say("Charge!", 1)
	local fx = GLOBAL.SpawnPrefab("emote_fx")
	fx.Transform:SetPosition(0, 3, 0)
	fx.entity:SetParent(owner.entity)
	owner.boosting = owner:DoPeriodicTask(0.5, function(inst)
		local fx = GLOBAL.SpawnPrefab("wx78_musicbox_fx")
		fx.Transform:SetPosition(owner.Transform:GetWorldPosition())
	end)
end

FUNCS.BoostTaskOff = function(owner)
	if owner.boosting then
		owner.boosting:Cancel()
		owner.boosting = nil
	end
end
