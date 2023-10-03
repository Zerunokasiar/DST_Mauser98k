Action = GLOBAL.Action
EQUIPSLOTS = GLOBAL.EQUIPSLOTS
STRINGS = GLOBAL.STRINGS
ACTIONS = GLOBAL.ACTIONS
TheSim = TheSim or GLOBAL.TheSim

local MAUSER_CHARGE = Action({ priority = -10, rmb=true, mount_valid=true, distance=math.huge})
MAUSER_CHARGE.str = "Mauser Charge"
MAUSER_CHARGE.id = "MAUSER_CHARGE"
MAUSER_CHARGE.fn = function(act)
	local weapon = act.invobject
	if weapon and weapon.BoostOn then
        weapon:BoostOn(act.doer)
		return true
    end
end

local MAUSER_RANGED = Action({priority=2, rmb=true, distance=PARAMS.RANGE * PARAMS.AUTORANGE, mount_valid=true})
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
	local pos = act:GetActionPoint()
	local flag = staff
	flag = flag and staff.CanFire
	flag = flag and staff:CanFire(act.doer, act.target, pos)
	flag = flag and staff.OnFire

	if flag then
		staff:OnFire(act.doer, act.target, pos, act.target ~= nil)
		staff:onUpdate()
		return true
	end
end

local MAUSER_RELOAD = Action({ rmb=true, mount_valid=true, canforce=true })
MAUSER_RELOAD.str = "Mauser Reload"
MAUSER_RELOAD.id = "MAUSER_RELOAD"
MAUSER_RELOAD.fn = function(act)
	if act.invobject and
	act.invobject.components.activatable_mauser and
	act.invobject.components.activatable_mauser:CanActivate(act.invobject, act.doer) then
		return act.invobject.components.activatable_mauser:DoActivate(act.invobject, act.doer)
    end
end

AddAction(MAUSER_CHARGE)
AddAction(MAUSER_RANGED)
AddAction(MAUSER_RELOAD)
STRINGS.ACTIONS.MAUSER_CHARGE = {GENERIC = "Charge!"}
STRINGS.ACTIONS.MAUSER_RANGED = {GENERIC = "Fire!"}
STRINGS.ACTIONS.MAUSER_RELOAD = {GENERIC = "Reload"}

local function autoaim_point(inst, doer, pos, actions, right)
	if not right then return end
	-- if inst:HasTag("mauser_switch") then return end
	local x, y, z = pos:Get()
	local range = PARAMS.AUTOAIM
	if doer.components.playercontroller.isclientcontrollerattached then
		range = PARAMS.RANGE * PARAMS.AUTORANGE
	end
	local ents = TheSim:FindEntities(x, y, z, range)
	for k,v in pairs(ents) do
		local flag = doer.replica.combat
		flag = flag and flag:CanTarget(v)
		if flag then
			actions.target = v
			table.insert(actions, ACTIONS.MAUSER_RANGED)
			return
		end
	end
end

local function autoaim_target(inst, doer, target, actions, right)
	if not right then return end
	-- if inst:HasTag("mauser_switch") then return end
	local flag = doer.replica.combat
	flag = flag and flag:CanTarget(target)
	if flag then
		table.insert(actions, ACTIONS.MAUSER_RANGED)
		return
	end
	autoaim_point(inst, doer, target:GetPosition(), actions, right)
end

local function boost_point(inst, doer, pos, actions, right)
	if not right then return end
	-- if inst:HasTag("mauser_boost") then return end
	table.insert(actions, ACTIONS.MAUSER_CHARGE)
end

local function boost_equipped(inst, doer, target, actions, right)
	if not right then return end
	-- if inst:HasTag("mauser_boost") then return end
	table.insert(actions, ACTIONS.MAUSER_CHARGE)
end

local function inventory_ammo(inst, doer, actions)
	if doer.replica.inventory and doer.replica.inventory:IsOpenedBy(doer) then
		table.insert(actions, ACTIONS.MAUSER_RELOAD)
	end
end

AddComponentAction("POINT", "boostable_mauser", boost_point)
AddComponentAction("EQUIPPED", "boostable_mauser", boost_equipped)
AddComponentAction("POINT", "finiteuses_mauser", autoaim_point)
AddComponentAction("EQUIPPED", "finiteuses_mauser", autoaim_target)
AddComponentAction("INVENTORY", "activatable_mauser", inventory_ammo)