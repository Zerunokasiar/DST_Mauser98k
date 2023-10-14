GLOBAL.MAUSER_FUNCS = {}
FUNCS = GLOBAL.MAUSER_FUNCS

FUNCS.FindTarget = function(doer, pos)
	local x, y, z = pos:Get()
	local range = PARAMS.AUTOAIM
	if doer.components.playercontroller.isclientcontrollerattached then
		range = PARAMS.RANGE * PARAMS.AUTORANGE
	end
	local minDist = nil;
	local target = nil;
	for k,v in pairs(TheSim:FindEntities(x, y, z, range)) do
		local flag = doer.components.combat or doer.replica.combat
		if flag and flag:CanTarget(v) and not flag:IsAlly(v) then
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
