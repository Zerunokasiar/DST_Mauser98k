State = GLOBAL.State
FRAMES = GLOBAL.FRAMES
TimeEvent = GLOBAL.TimeEvent
EventHandler = GLOBAL.EventHandler
ActionHandler = GLOBAL.ActionHandler
TheSim = TheSim or GLOBAL.TheSim
FUNCS = GLOBAL.MAUSER_FUNCS

local function DoMountSound(inst, mount, sound, ispredicted)
    if mount ~= nil and mount.sounds ~= nil then
        inst.SoundEmitter:PlaySound(mount.sounds[sound], nil, nil, ispredicted)
    end
end
local RIFLE_ACTION = {}
RIFLE_ACTION.NAME = "rifle_action"
RIFLE_ACTION.TAGS = { "attack", "notalking", "abouttoattack", "autopredict" }
RIFLE_ACTION.TAGS_C = { "attack", "notalking", "abouttoattack" }
RIFLE_ACTION.ONENTER = function(inst)
	local buffaction = inst:GetBufferedAction()
	local target = buffaction and buffaction.target or nil
	local inventory = inst.components.inventory or inst.replica.inventory
	local equip = inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	local combat = inst.components.combat or inst.replica.combat
	if combat:InCooldown() then
		inst.sg:RemoveStateTag("abouttoattack")
		inst:ClearBufferedAction()
		inst.sg:GoToState("idle", true)
		return
	end
	if not combat:CanTarget(target) then
		if buffaction.pos then
			target = FUNCS.FindTarget(inst, buffaction:GetActionPoint())
		elseif target then
			target = FUNCS.FindTarget(inst, target:GetPosition())
		end
	end
	equip:OnAnimSet(inst)
	if inst.components.combat then
		inst.components.combat:SetTarget(target)
	end
	combat:StartAttack()
	inst.components.locomotor:Stop()
	inst.AnimState:PlayAnimation("speargun")
	inst.AnimState:SetTime(6 * FRAMES)
	inst.sg:SetTimeout(6 * FRAMES)
	if not inst.components.combat then
		inst:PerformPreviewBufferedAction()
	end
	if target ~= nil and target:IsValid() then
		inst:FacePoint(target.Transform:GetWorldPosition())
		inst.sg.statemem.attacktarget = target
	end
end
RIFLE_ACTION.ONTIMEOUT = function(inst)
	inst.sg:RemoveStateTag("attack")
	inst.sg:AddStateTag("idle")
end
RIFLE_ACTION.ONEXIT = function(inst)
	local inventory = inst.components.inventory or inst.replica.inventory
	local equip = inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	if equip and equip:HasTag("mauser_rifle") and not equip:HasTag("mauser_switch") then
		equip:OnAnimReset(inst)
	end
	if inst.components.combat then
		inst.components.combat:SetTarget(nil)
	end
	if inst.sg:HasStateTag("abouttoattack") then
		local combat = inst.components.combat or inst.replica.combat
		combat:CancelAttack()
	end
end
RIFLE_ACTION.TIMELINE = {
	TimeEvent(5 * FRAMES, function(inst)
		inst:PerformBufferedAction()
		inst.sg:RemoveStateTag("abouttoattack")
	end),
}
RIFLE_ACTION.TIMELINE_C = {
	TimeEvent(5 * FRAMES, function(inst)
		inst:ClearBufferedAction()
		inst.sg:RemoveStateTag("abouttoattack")
	end),
}
RIFLE_ACTION.EVENTS = {
	EventHandler("equip", function(inst) inst.sg:GoToState("idle") end),
	EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
	EventHandler("animqueueover", function(inst)
		if inst.AnimState:AnimDone() then
			inst.sg:GoToState("idle")
		end
	end),
}
RIFLE_ACTION.EVENTS_C = {
	EventHandler("animqueueover", function(inst)
		if inst.AnimState:AnimDone() then
			inst.sg:GoToState("idle")
		end
	end),
}
RIFLE_ACTION.STATE = State({
    name = RIFLE_ACTION.NAME,
    tags = RIFLE_ACTION.TAGS,
	onenter = RIFLE_ACTION.ONENTER,
	ontimeout = RIFLE_ACTION.ONTIMEOUT,
	onexit = RIFLE_ACTION.ONEXIT,
	timeline = RIFLE_ACTION.TIMELINE,
	events = RIFLE_ACTION.EVENTS,
})
RIFLE_ACTION.STATE_CLIENT = State({
	name = RIFLE_ACTION.NAME,
	tags = RIFLE_ACTION.TAGS_C,
	onenter = RIFLE_ACTION.ONENTER,
	ontimeout = RIFLE_ACTION.ONTIMEOUT,
	onexit = RIFLE_ACTION.ONEXIT,
	timeline = RIFLE_ACTION.TIMELINE_C,
	events = RIFLE_ACTION.EVENTS_C,
})
AddStategraphState("wilson", RIFLE_ACTION.STATE)
AddStategraphState("wilson_client", RIFLE_ACTION.STATE_CLIENT)

local RIFLE_INSTANT_ACTION = {}
RIFLE_INSTANT_ACTION.NAME = "rifle_instant_action"
RIFLE_INSTANT_ACTION.TAGS = { "attack", "notalking", "abouttoattack", "autopredict" }
RIFLE_INSTANT_ACTION.TAGS_C = { "attack", "notalking", "abouttoattack" }
RIFLE_INSTANT_ACTION.ONENTER = function(inst)
	local buffaction = inst:GetBufferedAction()
	local target = buffaction and buffaction.target or nil
	local inventory = inst.components.inventory or inst.replica.inventory
	local equip = inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	local combat = inst.components.combat or inst.replica.combat
	if combat:InCooldown() then
		inst.sg:RemoveStateTag("abouttoattack")
		inst:ClearBufferedAction()
		inst.sg:GoToState("idle", true)
		return
	end
	if not combat:CanTarget(target) then
		if buffaction.pos then
			target = FUNCS.FindTarget(inst, buffaction:GetActionPoint())
		elseif target then
			target = FUNCS.FindTarget(inst, target:GetPosition())
		end
	end
	equip:OnAnimSet(inst)
	if inst.components.combat then
		inst.components.combat:SetTarget(target)
	end
	combat:StartAttack()
	inst.components.locomotor:Stop()
	inst.AnimState:PlayAnimation("speargun")
	inst.sg:SetTimeout(12 * FRAMES)
	if not inst.components.combat then
		inst:PerformPreviewBufferedAction()
	end
	if target ~= nil and target:IsValid() then
		inst:FacePoint(target.Transform:GetWorldPosition())
		inst.sg.statemem.attacktarget = target
	end
end
RIFLE_INSTANT_ACTION.ONTIMEOUT = function(inst)
	inst.sg:RemoveStateTag("attack")
	inst.sg:AddStateTag("idle")
end
RIFLE_INSTANT_ACTION.ONEXIT = function(inst)
	local inventory = inst.components.inventory or inst.replica.inventory
	local equip = inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	if equip and equip:HasTag("mauser_rifle") and not equip:HasTag("mauser_switch") then
		equip:OnAnimReset(inst)
	end
	if inst.components.combat then
		inst.components.combat:SetTarget(nil)
	end
	if inst.sg:HasStateTag("abouttoattack") then
		local combat = inst.components.combat or inst.replica.combat
		combat:CancelAttack()
	end
end
RIFLE_INSTANT_ACTION.TIMELINE = {
	TimeEvent(11 * FRAMES, function(inst)
		inst:PerformBufferedAction()
		inst.sg:RemoveStateTag("abouttoattack")
	end),
}
RIFLE_INSTANT_ACTION.TIMELINE_C = {
	TimeEvent(11 * FRAMES, function(inst)
		inst:ClearBufferedAction()
		inst.sg:RemoveStateTag("abouttoattack")
	end),
}
RIFLE_INSTANT_ACTION.EVENTS = {
	EventHandler("equip", function(inst) inst.sg:GoToState("idle") end),
	EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
	EventHandler("animqueueover", function(inst)
		if inst.AnimState:AnimDone() then
			inst.sg:GoToState("idle")
		end
	end),
}
RIFLE_INSTANT_ACTION.EVENTS_C = {
	EventHandler("animqueueover", function(inst)
		if inst.AnimState:AnimDone() then
			inst.sg:GoToState("idle")
		end
	end),
}
RIFLE_INSTANT_ACTION.STATE = State({
    name = RIFLE_INSTANT_ACTION.NAME,
    tags = RIFLE_INSTANT_ACTION.TAGS,
	onenter = RIFLE_INSTANT_ACTION.ONENTER,
	ontimeout = RIFLE_INSTANT_ACTION.ONTIMEOUT,
	onexit = RIFLE_INSTANT_ACTION.ONEXIT,
	timeline = RIFLE_INSTANT_ACTION.TIMELINE,
	events = RIFLE_INSTANT_ACTION.EVENTS,
})
RIFLE_INSTANT_ACTION.STATE_CLIENT = State({
	name = RIFLE_INSTANT_ACTION.NAME,
	tags = RIFLE_INSTANT_ACTION.TAGS_C,
	onenter = RIFLE_INSTANT_ACTION.ONENTER,
	ontimeout = RIFLE_INSTANT_ACTION.ONTIMEOUT,
	onexit = RIFLE_INSTANT_ACTION.ONEXIT,
	timeline = RIFLE_INSTANT_ACTION.TIMELINE_C,
	events = RIFLE_INSTANT_ACTION.EVENTS_C,
})
AddStategraphState("wilson", RIFLE_INSTANT_ACTION.STATE)
AddStategraphState("wilson_client", RIFLE_INSTANT_ACTION.STATE_CLIENT)

local RIFLE_CAV_ACTION = {}
RIFLE_CAV_ACTION.NAME = "rifle_cav_action"
RIFLE_CAV_ACTION.TAGS = { "attack", "notalking", "abouttoattack", "autopredict" }
RIFLE_CAV_ACTION.TAGS_C = { "attack", "notalking", "abouttoattack" }
RIFLE_CAV_ACTION.ONENTER = function(inst)
	local buffaction = inst:GetBufferedAction()
	local target = buffaction and buffaction.target or nil
	local inventory = inst.components.inventory or inst.replica.inventory
	local equip = inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	local combat = inst.components.combat or inst.replica.combat
	if combat:InCooldown() then
		inst.sg:RemoveStateTag("abouttoattack")
		inst:ClearBufferedAction()
		inst.sg:GoToState("idle", true)
		return
	end
	if not combat:CanTarget(target) then
		if buffaction.pos then
			target = FUNCS.FindTarget(inst, buffaction:GetActionPoint())
		elseif target then
			target = FUNCS.FindTarget(inst, target:GetPosition())
		end
	end
	equip:OnAnimSet(inst)
	if inst.components.combat then
		inst.components.combat:SetTarget(target)
	else
		inst:PerformPreviewBufferedAction()
	end
	combat:StartAttack()
	inst.components.locomotor:Stop()

	inst.AnimState:PlayAnimation("dart_pre")
	inst.AnimState:PushAnimation("hit", false)
	
	if target and target:IsValid() then
		inst:FacePoint(target.Transform:GetWorldPosition())
		inst.sg.statemem.attacktarget = target
	end
	inst.sg:SetTimeout(15 * FRAMES)
end
RIFLE_CAV_ACTION.ONTIMEOUT = function(inst)
	inst.sg:RemoveStateTag("attack")
	inst.sg:AddStateTag("idle")
end
RIFLE_CAV_ACTION.ONEXIT = function(inst)
	local inventory = inst.components.inventory or inst.replica.inventory
	local equip = inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	if equip and equip:HasTag("mauser_rifle") and not equip:HasTag("mauser_switch") then
		equip:OnAnimReset(inst)
	end
	if inst.components.combat then
		inst.components.combat:SetTarget(nil)
	end
	if inst.sg:HasStateTag("abouttoattack") then
		local combat = inst.components.combat or inst.replica.combat
		combat:CancelAttack()
	end
end
RIFLE_CAV_ACTION.TIMELINE = {
	TimeEvent(11 * FRAMES, function(inst)
		inst:PerformBufferedAction()
		inst.sg:RemoveStateTag("abouttoattack")
	end),
}
RIFLE_CAV_ACTION.TIMELINE_C = {
	TimeEvent(11 * FRAMES, function(inst)
		inst:ClearBufferedAction()
		inst.sg:RemoveStateTag("abouttoattack")
	end),
}
RIFLE_CAV_ACTION.EVENTS = {
	EventHandler("equip", function(inst) inst.sg:GoToState("idle") end),
	EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
	EventHandler("animqueueover", function(inst)
		if inst.AnimState:AnimDone() then
			inst.sg:GoToState("idle")
		end
	end),
}
RIFLE_CAV_ACTION.EVENTS_C = {
	EventHandler("animqueueover", function(inst)
		if inst.AnimState:AnimDone() then
			inst.sg:GoToState("idle")
		end
	end),
}
RIFLE_CAV_ACTION.STATE = State({
    name = RIFLE_CAV_ACTION.NAME,
    tags = RIFLE_CAV_ACTION.TAGS,
	onenter = RIFLE_CAV_ACTION.ONENTER,
	ontimeout = RIFLE_CAV_ACTION.ONTIMEOUT,
	onexit = RIFLE_CAV_ACTION.ONEXIT,
	timeline = RIFLE_CAV_ACTION.TIMELINE,
	events = RIFLE_CAV_ACTION.EVENTS,
})
RIFLE_CAV_ACTION.STATE_CLIENT = State({
	name = RIFLE_CAV_ACTION.NAME,
	tags = RIFLE_CAV_ACTION.TAGS_C,
	onenter = RIFLE_CAV_ACTION.ONENTER,
	ontimeout = RIFLE_CAV_ACTION.ONTIMEOUT,
	onexit = RIFLE_CAV_ACTION.ONEXIT,
	timeline = RIFLE_CAV_ACTION.TIMELINE_C,
	events = RIFLE_CAV_ACTION.EVENTS_C,
})
AddStategraphState("wilson", RIFLE_CAV_ACTION.STATE)
AddStategraphState("wilson_client", RIFLE_CAV_ACTION.STATE_CLIENT)

local BAYONET_ACTION = {}
BAYONET_ACTION.NAME = "bayonet_action"
BAYONET_ACTION.TAGS = { "attack", "notalking", "abouttoattack", "autopredict" }
BAYONET_ACTION.TAGS_C = { "attack", "notalking", "abouttoattack" }
BAYONET_ACTION.ONENTER = function(inst)
	local buffaction = inst:GetBufferedAction()
	local target = buffaction ~= nil and buffaction.target or nil
	local inventory = inst.components.inventory or inst.replica.inventory
	local equip = inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	local combat = inst.components.combat or inst.replica.combat
	if inst.components.combat then
		inst.components.combat:SetTarget(target)
	end
	combat:StartAttack()
	inst.components.locomotor:Stop()
	local cooldown = nil
	if combat.min_attack_period then
		cooldown = inst.components.combat.min_attack_period + .5 * FRAMES
	else
		cooldown = inst.replica.combat:MinAttackPeriod() + .5 * FRAMES
	end
	inst.AnimState:PlayAnimation("spearjab")
	cooldown = math.max(cooldown, 24 * FRAMES)
	inst.sg:SetTimeout(cooldown)
	if not inst.components.combat and buffaction then
		inst:PerformPreviewBufferedAction()
	end
	if target ~= nil then
		if inst.components.combat then
			inst.components.combat:BattleCry()
		end
		if target:IsValid() then
			inst:FacePoint(target:GetPosition())
			inst.sg.statemem.attacktarget = target
		end
	end
end
BAYONET_ACTION.ONTIMEOUT = function(inst)
	inst.sg:RemoveStateTag("attack")
	inst.sg:AddStateTag("idle")
end
BAYONET_ACTION.ONEXIT = function(inst)
	if inst.components.combat then
		inst.components.combat:SetTarget(nil)
	end
	if inst.sg:HasStateTag("abouttoattack") then
		local combat = inst.components.combat or inst.replica.combat
		combat:CancelAttack()
	end
end
BAYONET_ACTION.TIMELINE = {
	TimeEvent(4 * FRAMES, function(inst)
		inst:PerformBufferedAction()
		inst.sg:RemoveStateTag("abouttoattack")
	end),
}
BAYONET_ACTION.TIMELINE_C = {
	TimeEvent(4 * FRAMES, function(inst)
		inst:ClearBufferedAction()
		inst.sg:RemoveStateTag("abouttoattack")
	end),
}
BAYONET_ACTION.EVENTS = {
	EventHandler("equip", function(inst) inst.sg:GoToState("idle") end),
	EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
	EventHandler("animqueueover", function(inst)
		if inst.AnimState:AnimDone() then
			inst.sg:GoToState("idle")
		end
	end),
}
BAYONET_ACTION.EVENTS_C = {
	EventHandler("animqueueover", function(inst)
		if inst.AnimState:AnimDone() then
			inst.sg:GoToState("idle")
		end
	end),
}
BAYONET_ACTION.STATE = State({
    name = BAYONET_ACTION.NAME,
    tags = BAYONET_ACTION.TAGS,
	onenter = BAYONET_ACTION.ONENTER,
	ontimeout = BAYONET_ACTION.ONTIMEOUT,
	onexit = BAYONET_ACTION.ONEXIT,
	timeline = BAYONET_ACTION.TIMELINE,
	events = BAYONET_ACTION.EVENTS,
})
BAYONET_ACTION.STATE_CLIENT = State({
	name = BAYONET_ACTION.NAME,
	tags = BAYONET_ACTION.TAGS_C,
	onenter = BAYONET_ACTION.ONENTER,
	ontimeout = BAYONET_ACTION.ONTIMEOUT,
	onexit = BAYONET_ACTION.ONEXIT,
	timeline = BAYONET_ACTION.TIMELINE_C,
	events = BAYONET_ACTION.EVENTS_C,
})
AddStategraphState("wilson", BAYONET_ACTION.STATE)
AddStategraphState("wilson_client", BAYONET_ACTION.STATE_CLIENT)

if PARAMS.MAUSER_CHARGE_MOTION ~= "instant" then
	local function ChargeAction(inst, action)
		if action.invobject ~= nil then
			return (action.invobject:HasTag("flute") and "play_flute")
				or (action.invobject:HasTag("horn") and "play_horn")
				or (action.invobject:HasTag("bell") and "play_bell")
				or (action.invobject:HasTag("whistle") and "play_whistle")
				or nil
		end
	end
	AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.MAUSER_CHARGE, ChargeAction))
	AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.MAUSER_CHARGE, ChargeAction))
end

local function RangedAction(inst, action)
	local playercontroller = inst.components.playercontroller
	local remote = playercontroller ~= nil
	remote = remote and playercontroller.remote_authority
	remote = remote and playercontroller.remote_predicting
	local tag = remote and "abouttoattack" or "attack"
	local health = inst.components.health or inst.replica.health
	if not inst.sg:HasStateTag(tag) and not health:IsDead() then
		local inventory = inst.components.inventory or inst.replica.inventory
		local equip = inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		if equip and equip:HasTag("mauser_rifle") then
			local rider = inst.components.rider or inst.replica.rider
			if rider and rider:IsRiding() then
				return "rifle_cav_action"
			elseif equip and equip:HasTag("mauser_switch") then
				return "rifle_action"
			else
				return "rifle_instant_action"
			end
		end
	end
end

AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.MAUSER_RANGED, RangedAction))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.MAUSER_RANGED, RangedAction))
AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.MAUSER_RELOAD, "give"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.MAUSER_RELOAD, "give"))

local function postinit(self)
	for k,v in pairs(self.actionhandlers) do
		if v.action.id == "ATTACK" then	
			local oldaction = v.deststate
			v.deststate = function(inst, action)
				local motion = oldaction(inst, action)
				if motion == "attack" then
					local inventory = inst.components.inventory or inst.replica.inventory
					local equip = inventory and inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
					local rider = inst.components.rider or inst.replica.rider
					local riding = rider and rider:IsRiding()
					if equip and equip:HasTag("mauser_action") and not riding then
						if equip:HasTag("mauser_switch") then return "rifle_action" end
						return equip:HasTag("bayonet_action") and equip:HasTag("mauser_boost") and "bayonet_action" or "attack"
					end
					if equip and equip:HasTag("mauser_switch") and riding then
						return "rifle_cav_action"
					end
				end
				return motion
			end
		end
	end
end
AddStategraphPostInit("wilson", postinit)
AddStategraphPostInit("wilson_client",postinit)