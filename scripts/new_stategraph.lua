State = GLOBAL.State
FRAMES = GLOBAL.FRAMES
TimeEvent = GLOBAL.TimeEvent
EventHandler = GLOBAL.EventHandler
ActionHandler = GLOBAL.ActionHandler

local function CloseTarget(doer, pos)
	local x, y, z = pos:Get()
	local ents = TheSim:FindEntities(x, y, z, PARAMS.AUTOAIM)
	local minDist = nil;
	local target = nil;
	for k,v in pairs(ents) do
		local flag = doer.components.combat or doer.replica.combat
		flag = flag and flag:CanTarget(v)
		if flag then
			local tmpDist = (pos - v:GetPosition()).magnitude
			if not minDist or tmpDist < minDist then
				minDist = tmpDist
				target = v
			end
		end
	end
	return target
end

local RIFLE_ACTION = State({
	name = "rifle_action",
	tags = { "attack", "notalking", "abouttoattack", "autopredict" },

	onenter = function(inst)
		local buffaction = inst:GetBufferedAction()
		local target = buffaction ~= nil and buffaction.target or inst.components.combat.target or nil
		local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		inst.AnimState:OverrideSymbol("swap_object", equip.AnimSet, equip.AnimBase)
		if not inst.components.combat:CanTarget(target) then
			if buffaction and buffaction.pos then
				target = CloseTarget(inst, buffaction.pos)--:GetActionPoint())
			elseif target ~= nil then
				target = CloseTarget(inst, target:GetPosition())
			end
		end
		inst.sg.statemem.target = target
		inst.components.combat:SetTarget(target)
		inst.components.combat:StartAttack()
		inst.components.locomotor:Stop()
		inst.AnimState:PlayAnimation("speargun")
		if inst.sg.laststate == inst.sg.currentstate then
			inst.sg.statemem.chained = true
			inst.AnimState:SetTime(6 * FRAMES)
		end
		
		local cooldown = inst.components.combat.min_attack_period
		cooldown = cooldown + (inst.sg.statemem.chained and 8 or 14) * FRAMES
		inst.sg:SetTimeout(cooldown)

		if target ~= nil and target:IsValid() then
			inst:FacePoint(target.Transform:GetWorldPosition())
			inst.sg.statemem.attacktarget = target
		end
	end,

	timeline =
	{
		TimeEvent(6 * FRAMES, function(inst)
			if inst.sg.statemem.chained then
				inst:PerformBufferedAction()
				inst.sg:RemoveStateTag("abouttoattack")
			end
		end),
		TimeEvent(12 * FRAMES, function(inst)
			if not inst.sg.statemem.chained then
				inst:PerformBufferedAction()
				inst.sg:RemoveStateTag("abouttoattack")
			end
		end),
	},

	ontimeout = function(inst)
		local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		if equip then
			inst.AnimState:OverrideSymbol("swap_object", equip.AnimReset, equip.AnimBase)
		end
		inst.sg.statemem.action = nil
		inst.components.combat:SetTarget(nil)
		if inst.sg:HasStateTag("abouttoattack") then
			inst.components.combat:CancelAttack()
		end
		inst.sg:RemoveStateTag("attack")
		inst.sg:AddStateTag("idle")
		inst.sg:GoToState("idle", true)
	end,

	events =
	{
		EventHandler("equip", function(inst) inst.sg:GoToState("idle") end),
		EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
		EventHandler("animqueueover", function(inst)
			if inst.AnimState:AnimDone() then
				inst.sg:GoToState("idle")
			end
		end),
	},

	onexit = function(inst)
		local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		if equip then
			inst.AnimState:OverrideSymbol("swap_object", equip.AnimReset, equip.AnimBase)
		end
		inst.sg.statemem.action = nil
		inst.components.combat:SetTarget(nil)
		if inst.sg:HasStateTag("abouttoattack") then
			inst.components.combat:CancelAttack()
		end
		inst.sg:RemoveStateTag("attack")
		inst.sg:AddStateTag("idle")
	end,
})

local RIFLE_ACTION_AUTO = State({
	name = "rifle_action_auto",
	tags = { "attack", "notalking", "abouttoattack", "autopredict" },

	onenter = function(inst)
		local target = inst.components.combat.target
		local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

		inst.sg.statemem.target = target

		inst.components.locomotor:Stop()
		inst.components.combat:StartAttack()
		inst.AnimState:OverrideSymbol("swap_object", equip.AnimSet, equip.AnimBase)
		inst.AnimState:PlayAnimation("speargun")

		if inst.sg.laststate == inst.sg.currentstate then
			inst.sg.statemem.chained = true
			inst.AnimState:SetTime(6 * FRAMES)
		end
		
		local cooldown = inst.components.combat.min_attack_period
		cooldown = cooldown + (inst.sg.statemem.chained and 8 or 14) * FRAMES
		inst.sg:SetTimeout(cooldown)

		if target ~= nil and target:IsValid() then
			inst:FacePoint(target.Transform:GetWorldPosition())
			inst.sg.statemem.attacktarget = target
		end
	end,

	timeline =
	{
		TimeEvent(6 * FRAMES, function(inst)
			if inst.sg.statemem.chained then
				inst.components.combat:DoAttack(inst.sg.statemem.target) 
				inst.sg:RemoveStateTag("abouttoattack")
			end
		end),
		TimeEvent(12 * FRAMES, function(inst)
			if not inst.sg.statemem.chained then
				inst.components.combat:DoAttack(inst.sg.statemem.target) 
				inst.sg:RemoveStateTag("abouttoattack")
			end
		end),
	},

	ontimeout = function(inst)
		local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		if equip then
			inst.AnimState:OverrideSymbol("swap_object", equip.AnimReset, equip.AnimBase)
		end
		inst.sg.statemem.action = nil
		inst.components.combat:SetTarget(nil)
		if inst.sg:HasStateTag("abouttoattack") then
			inst.components.combat:CancelAttack()
		end
		inst.sg:RemoveStateTag("attack")
		inst.sg:AddStateTag("idle")
		inst.sg:GoToState("idle", true)
	end,

	events =
	{
		EventHandler("equip", function(inst) inst.sg:GoToState("idle") end),
		EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
		EventHandler("animqueueover", function(inst)
			if inst.AnimState:AnimDone() then
				inst.sg:GoToState("idle")
			end
		end),
	},

	onexit = function(inst)
		local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		if equip and equip:HasTag("mauser_rifle") then
			inst.AnimState:OverrideSymbol("swap_object", equip.AnimReset, equip.AnimBase)
		end
		inst.sg.statemem.action = nil
		inst.components.combat:SetTarget(nil)
		if inst.sg:HasStateTag("abouttoattack") then
			inst.components.combat:CancelAttack()
		end
		inst.sg:RemoveStateTag("attack")
		inst.sg:AddStateTag("idle")
	end,
})
-- local RIFLE_ACTION_CLIENT = State({
-- 	name = "rifle_action",
-- 	tags = { "attack", "notalking", "abouttoattack"},

-- 	onenter = function(inst)
-- 		local buffaction = inst:GetBufferedAction()
-- 		local target = buffaction ~= nil and buffaction.target or nil
-- 		local equip = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
-- 		inst.AnimState:OverrideSymbol("swap_object", equip.AnimSet, equip.AnimBase)
-- 		if not inst.replica.combat:CanTarget(target) then
-- 			if buffaction.pos then
-- 				target = CloseTarget(inst, buffaction:GetActionPoint())
-- 			else
-- 				target = CloseTarget(inst, target:GetPosition())
-- 			end
-- 		end 
-- 		inst.replica.combat:StartAttack()
-- 		inst.components.locomotor:Stop()
-- 		inst.AnimState:PlayAnimation("speargun")
-- 		if inst.sg.laststate == inst.sg.currentstate then
-- 			inst.sg.statemem.chained = true
-- 			inst.AnimState:SetTime(6 * FRAMES)
-- 		end
		
-- 		local cooldown = inst.replica.combat:MinAttackPeriod()
-- 		cooldown = cooldown + (inst.sg.statemem.chained and 8 or 14) * FRAMES
-- 		inst.sg:SetTimeout(cooldown)

-- 		inst:PerformPreviewBufferedAction()
-- 		if target ~= nil and target:IsValid() then
-- 			inst:FacePoint(target.Transform:GetWorldPosition())
-- 			inst.sg.statemem.attacktarget = target
-- 		end
-- 	end,

-- 	timeline =
-- 	{
-- 		TimeEvent(6 * FRAMES, function(inst)
-- 			if inst.sg.statemem.chained then
-- 				inst:ClearBufferedAction()
-- 				inst.sg:RemoveStateTag("abouttoattack")
-- 			end
-- 		end),
-- 		TimeEvent(12 * FRAMES, function(inst)
-- 			if not inst.sg.statemem.chained then
-- 				inst:ClearBufferedAction()
-- 				inst.sg:RemoveStateTag("abouttoattack")
-- 			end
-- 		end),
-- 	},

-- 	ontimeout = function(inst)
-- 		inst.sg:RemoveStateTag("attack")
-- 		inst.sg:AddStateTag("idle")
-- 	end,

-- 	events =
-- 	{
-- 		EventHandler("animqueueover", function(inst)
-- 			if inst.AnimState:AnimDone() then
-- 				inst.sg:GoToState("idle")
-- 			end
-- 		end),
-- 	},

-- 	onexit = function(inst)
-- 		local equip = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
-- 		if equip then
-- 			inst.AnimState:OverrideSymbol("swap_object", equip.AnimReset, equip.AnimBase)
-- 		end
-- 		if inst.sg:HasStateTag("abouttoattack") then
-- 			inst.replica.combat:CancelAttack()
-- 		end
-- 	end,
-- })

local BAYONET_ACTION = State({
	name = "bayonet_action",
	tags = { "attack", "notalking", "abouttoattack", "autopredict", "busy" },

	onenter = function(inst)
		local target = inst.components.combat.target
		local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		
		inst.sg.statemem.target = target

		inst.components.locomotor:Stop()
		inst.components.combat:StartAttack()

		local cooldown = inst.components.combat.min_attack_period + .5 * FRAMES
		cooldown = math.max(cooldown, 24 * FRAMES)
		inst.sg:SetTimeout(cooldown)
		inst.AnimState:PlayAnimation("spearjab")


		if target ~= nil then
			inst.components.combat:BattleCry()
			if target:IsValid() then
				inst:FacePoint(target:GetPosition())
				inst.sg.statemem.attacktarget = target
			end
		end
	end,

	timeline =
	{
		TimeEvent(8 * FRAMES, function(inst)
			inst.components.combat:DoAttack(inst.sg.statemem.target) 
			inst.sg:RemoveStateTag("abouttoattack")
		end),
		TimeEvent(12*FRAMES, function(inst) 
			inst.sg:RemoveStateTag("busy")
		end),	
	},

	ontimeout = function(inst)
		inst.sg:RemoveStateTag("attack")
	end,

	events =
	{
		EventHandler("equip", function(inst) inst.sg:GoToState("idle") end),
		EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
		EventHandler("animqueueover", function(inst)
			if inst.AnimState:AnimDone() then
				inst.sg:GoToState("idle")
			end
		end),
	},

	onexit = function(inst)
		inst.sg:RemoveStateTag("attack")
		inst.sg:AddStateTag("idle")
	end,
})

-- local BAYONET_ACTION_CLIENT = State({
-- 	name = "bayonet_action",
-- 	tags = { "attack", "notalking", "abouttoattack"},

-- 	onenter = function(inst)
-- 		local cooldown = 0
-- 		if inst.replica.combat ~= nil then
-- 			inst.replica.combat:StartAttack()
-- 			cooldown = inst.replica.combat:MinAttackPeriod() + .5 * FRAMES
-- 		end
-- 		inst.components.locomotor:Stop()
-- 		local equip = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
-- 		local rider = inst.replica.rider
-- 		if rider ~= nil and rider:IsRiding() then
-- 			inst.AnimState:PlayAnimation("atk_pre")
-- 			inst.AnimState:PushAnimation("atk", false)
-- 			DoMountSound(inst, rider:GetMount(), "angry")
-- 			if cooldown > 0 then
-- 				cooldown = math.max(cooldown, 16 * FRAMES)
-- 			end
-- 		else
-- 			inst.AnimState:PlayAnimation("spearjab")
-- 			if cooldown > 0 then
-- 				cooldown = math.max(cooldown, 24 * FRAMES)
-- 			end
-- 		end

-- 		local buffaction = inst:GetBufferedAction()
-- 		if buffaction ~= nil then
-- 			inst:PerformPreviewBufferedAction()

-- 			if buffaction.target ~= nil and buffaction.target:IsValid() then
-- 				inst:FacePoint(buffaction.target:GetPosition())
-- 				inst.sg.statemem.attacktarget = buffaction.target
-- 			end
-- 		end

-- 		if cooldown > 0 then
-- 			inst.sg:SetTimeout(cooldown)
-- 		end
-- 	end,

-- 	timeline =
-- 	{
-- 		TimeEvent(6 * FRAMES, function(inst)
-- 			if not inst.replica.rider:IsRiding() then
-- 				inst:ClearBufferedAction()
-- 				inst.sg:RemoveStateTag("abouttoattack")
-- 			end
-- 		end),
-- 		TimeEvent(8 * FRAMES, function(inst)
-- 			if inst.replica.rider:IsRiding() then
-- 				inst:ClearBufferedAction()
-- 				inst.sg:RemoveStateTag("abouttoattack")
-- 			end
-- 		end),
-- 	},

-- 	ontimeout = function(inst)
-- 		inst.sg:RemoveStateTag("attack")
-- 		inst.sg:AddStateTag("idle")
-- 	end,

-- 	events =
-- 	{
-- 		EventHandler("animqueueover", function(inst)
-- 			if inst.AnimState:AnimDone() then
-- 				inst.sg:GoToState("idle")
-- 			end
-- 		end),
-- 	},

-- 	onexit = function(inst)
-- 		if inst.sg:HasStateTag("abouttoattack") and inst.replica.combat ~= nil then
-- 			inst.replica.combat:CancelAttack()
-- 		end
-- 	end,
-- })

AddStategraphState("wilson", RIFLE_ACTION)
AddStategraphState("wilson", RIFLE_ACTION_AUTO)
AddStategraphState("wilson", BAYONET_ACTION)
AddStategraphState("wilsonboating", RIFLE_ACTION)
AddStategraphState("wilsonboating", RIFLE_ACTION_AUTO)
AddStategraphState("wilsonboating", BAYONET_ACTION)
-- AddStategraphState("wilson_client", RIFLE_ACTION_CLIENT)
-- AddStategraphState("wilson_client", BAYONET_ACTION_CLIENT)
-- AddStategraphState("wilsonboating_client", RIFLE_ACTION_CLIENT)
-- AddStategraphState("wilsonboating_client", BAYONET_ACTION_CLIENT)

local function RangedAction(inst, action)
	inst.sg.mem.localchainattack = not action.forced or nil
	if not (inst.sg:HasStateTag("attack")
	and action.target == inst.sg.statemem.attacktarget
	or inst.components.health:IsDead())
	then
		local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
		local flag = equip and equip:HasTag("mauser_rifle")
--		flag = flag and not equip:HasTag("mauser_switch")
		return flag and "rifle_action" or nil
	end
end

-- local function RangedActionClient(inst, action)
-- 	if not (inst.sg:HasStateTag("attack")
-- 	and action.target == inst.sg.statemem.attacktarget
-- 	or inst.replica.health:IsDead())
-- 	then
-- 		local equip = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
-- 		local flag = equip:HasTag("mauser_rifle")
-- --		flag = flag and not equip:HasTag("mauser_switch")
-- 		return flag and "rifle_action" or nil
-- 	end
-- end

AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.MAUSER_RANGED, RangedAction))
AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.MAUSER_RELOAD, "give"))
AddStategraphActionHandler("wilsonboating", ActionHandler(ACTIONS.MAUSER_RANGED, RangedAction))
AddStategraphActionHandler("wilsonboating", ActionHandler(ACTIONS.MAUSER_RELOAD, "give"))
-- AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.MAUSER_RANGED, RangedActionClient))
-- AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.MAUSER_RELOAD, "give"))
-- AddStategraphActionHandler("wilsonboating_client", ActionHandler(ACTIONS.MAUSER_RANGED, RangedActionClient))
-- AddStategraphActionHandler("wilsonboating_client", ActionHandler(ACTIONS.MAUSER_RELOAD, "give"))
if GLOBAL.TheSim:GetGameID() == "DST" then
	local SGWils = GLOBAL.require "stategraphs/SGwilson"
	-- local SGWilsClient = GLOBAL.require "stategraphs/SGwilson_client"
	local OldAttackAction
	-- local OldAttackActionClient

	for k, v in pairs(SGWils.actionhandlers) do
		if v["action"]["id"] == "ATTACK" then	
			OldAttackAction = v["deststate"]
		end
	end
	-- for k, v in pairs(SGWilsClient.actionhandlers) do
	-- 	if v["action"]["id"] == "ATTACK" then
	-- 		OldAttackActionClient = v["deststate"]
	-- 	end
	-- end
end
-- local function NewAttackAction(oldAction)
-- 	return function(inst, action)
-- 		inst.sg.mem.localchainattack = not action.forced or nil
-- 		local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
-- 		if equip and equip:HasTag("mauser_rifle") then
-- 			if not (inst.sg:HasStateTag("attack") and action.target == inst.sg.statemem.attacktarget or inst.components.health:IsDead()) then
-- 				if equip:HasTag("mauser_switch") then return "rifle_action" end
-- 				return equip:HasTag("mauser_bayonet") and "bayonet_action" or "attack"
-- 			end
-- 		else
-- 			return oldAction(inst, action)
-- 		end
-- 	end
-- end
local function NewAttackAction(oldAction)
	return function(inst, action)
		inst.sg.mem.localchainattack = not action.forced or nil
		local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		if equip and equip:HasTag("mauser_rifle") then
			if not (inst.sg:HasStateTag("attack") and action.target == inst.sg.statemem.attacktarget or inst.components.health:IsDead()) then
				if inst.components.rider:IsRiding() then
					return oldAction(inst, action)
				end
				if equip:HasTag("mauser_switch") then
					print("rifle action auto")
					inst.sg:GoToState("rifle_action_auto") 
					return
				end
				if equip:HasTag("mauser_bayonet") then
					inst.sg:GoToState("bayonet_action")
				else
					print("normal action")
					inst.sg:GoToState("attack")
				end
				return
			end
		else
			return oldAction(inst, action)
		end
	end
end
-- local function NewAttackActionClient(inst, action)
-- 	if not (inst.sg:HasStateTag("attack") and action.target == inst.sg.statemem.attacktarget or inst.replica.health:IsDead()) then
-- 		local equip = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
-- 		if equip and equip:HasTag("mauser_rifle") then
-- 			if equip:HasTag("mauser_switch") then return "rifle_action" end
-- 			return equip:HasTag("mauser_bayonet") and "bayonet_action" or "attack"
-- 		end
-- 		return OldAttackActionClient(inst, action)
-- 	end
-- end

if GLOBAL.TheSim:GetGameID() ~= "DST" then
	AddStategraphPostInit("wilson", function(_sg)
		local OldAttackAction = _sg.events.doattack.fn
		_sg.events.doattack.fn = NewAttackAction(OldAttackAction)
	end)

	AddStategraphPostInit("wilsonboating", function(_sg)
		local OldAttackAction = _sg.events.doattack.fn
		_sg.events.doattack.fn = NewAttackAction(OldAttackAction)
	end)
end

-- AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.ATTACK, NewAttackAction(OldAttackAction)))
-- AddStategraphActionHandler("wilsonboating", ActionHandler(ACTIONS.ATTACK, NewAttackAction(OldAttackAction)))
-- AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.ATTACK, NewAttackActionClient))
-- AddStategraphActionHandler("wilsonboating_client", ActionHandler(ACTIONS.ATTACK, NewAttackActionClient))
if GLOBAL.TheSim:GetGameID() == "DST" then
	GLOBAL.package.loaded["stategraphs/SGwilson"] = nil
end
-- GLOBAL.package.loaded["stategraphs/SGwilson_client"] = nil  
