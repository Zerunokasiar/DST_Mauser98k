Action = GLOBAL.Action
EQUIPSLOTS = GLOBAL.EQUIPSLOTS
STRINGS = GLOBAL.STRINGS
ACTIONS = GLOBAL.ACTIONS

local MAUSER_RANGED = Action({ mount_enabled=false, mount_valid=true }, 0, nil, true, PARAMS.RANGE)
MAUSER_RANGED.str = "Mauser Ranged"
MAUSER_RANGED.id = "MAUSER_RANGED"
MAUSER_RANGED.fn = function(act)
	local staff = act.invobject
	if not staff then
		local flag = act.doer
		flag = flag and flag.components.inventory
		flag = flag and flag:GetEquippedItem(EQUIPSLOTS.HANDS)
		if flag then
			staff = flag
		end
	end
	local pos = act.pos--:GetActionPoint()
	local flag = staff
	flag = flag and staff.CanFire
	flag = flag and staff:CanFire(act.doer, act.target, pos)
	flag = flag and staff.OnFire

	if flag then
		staff:OnFire(act.doer, act.target, pos)
		staff:onUpdate()
		return true
	end
end

local MAUSER_RANGED_AUTO = Action({ mount_enabled=false, mount_valid=true }, 0, nil, false, PARAMS.RANGE)
MAUSER_RANGED_AUTO.str = "Mauser Ranged Auto"
MAUSER_RANGED_AUTO.id = "MAUSER_RANGED_AUTO"
MAUSER_RANGED_AUTO.fn = function(act)
	print("auto")
	local staff = act.invobject
	if not staff then
		local flag = act.doer
		flag = flag and flag.components.inventory
		flag = flag and flag:GetEquippedItem(EQUIPSLOTS.HANDS)
		if flag then
			staff = flag
		end
	end
	local pos = act.pos--:GetActionPoint()
	local flag = staff
	flag = flag and staff.CanFire
	flag = flag and staff:CanFire(act.doer, act.target, pos)
	flag = flag and staff.OnFire

	print("flag")
	if flag then
		staff:OnFire(act.doer, act.target, pos)
		staff:onUpdate()
		return true
	end
end

local MAUSER_RELOAD = Action({ mount_enabled=true, mount_valid=true, canforce=true }, 0, nil, true, nil)
MAUSER_RELOAD.str = "Mauser Reload"
MAUSER_RELOAD.id = "MAUSER_RELOAD"
MAUSER_RELOAD.fn = function(act)
	if act.invobject and
	act.invobject.components.activatable_mauser and
	act.invobject.components.activatable_mauser:CanActivate(act.invobject, act.doer) then
		return act.invobject.components.activatable_mauser:DoActivate(act.invobject, act.doer)
	end
end

AddAction(MAUSER_RANGED)
AddAction(MAUSER_RANGED_AUTO)
AddAction(MAUSER_RELOAD)
STRINGS.ACTIONS.MAUSER_RANGED = {GENERIC = "Fire!"}
STRINGS.ACTIONS.MAUSER_RANGED_AUTO = {GENERIC = "Fire!"}
STRINGS.ACTIONS.MAUSER_RELOAD = {GENERIC = "Reload"}

if GLOBAL.TheSim:GetGameID() == "DST" then
	local function point_weapon(inst, doer, pos, actions, right)
		if not right then return end
		if not inst:HasTag("mauser_rifle") then return end
		local x, y, z = pos:Get()
		local ents = GLOBAL.TheSim:FindEntities(x, y, z, PARAMS.AUTOAIM)

		for k,v in pairs(ents) do
			local flag = doer.replica.combat
			flag = flag and flag:CanTarget(v)
			if flag then
				table.insert(actions, ACTIONS.MAUSER_RANGED)
				return
			end
		end
	end

	local function equipped_weapon(inst, doer, target, actions, right)
		if not right then return end
		if not inst:HasTag("mauser_rifle") then return end

		local flag = doer.replica.combat
		flag = flag and flag:CanTarget(target)
		if flag then
			table.insert(actions, ACTIONS.MAUSER_RANGED)
			return
		end
		point_weapon(inst, doer, target:GetPosition(), actions, right)
	end

	local function inventory_ammo(inst, doer, actions)
		if doer.replica.inventory and doer.replica.inventory:IsOpenedBy(doer) then
			table.insert(actions, ACTIONS.MAUSER_RELOAD)
		end
	end

	AddComponentAction("POINT", "finiteuses_mauser", point_weapon)
	AddComponentAction("EQUIPPED", "finiteuses_mauser", equipped_weapon)
	AddComponentAction("INVENTORY", "activatable_mauser", inventory_ammo)
end
