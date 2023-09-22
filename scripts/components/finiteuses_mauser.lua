local FiniteUses_Mauser = Class(function(self, inst)
    self.inst = inst
    self.current = {}
	self.total = {}
	self.onempty = nil
	self.onfinished = nil
end)

function FiniteUses_Mauser:OnSave()
	return self.current
end

function FiniteUses_Mauser:OnLoad(data)
	self.current = data
end

function FiniteUses_Mauser:GetMaxUses(target)
    return self.total[target] or 0
end

function FiniteUses_Mauser:SetMaxUses(target, value)
	if value < 0 then
		self.total[target] = 0
	else
		self.total[target] = value
	end
end

function FiniteUses_Mauser:GetUses(target)
    return self.current[target] or 0
end

function FiniteUses_Mauser:SetUses(target, value)
	if value < 0 then
		self.current[target] = 0
	else
		self.current[target] = value
	end
end

function FiniteUses_Mauser:AddUses(target, value)
	self:SetUses(target, self:GetUses(target) + (value or 1))
end

function FiniteUses_Mauser:Uses(target, value)
	self:SetUses(target, self:GetUses(target) - (value or 1))
end

function FiniteUses_Mauser:GetPercent(target)
    return self:GetUses(target) / self:GetMaxUses(target)
end

function FiniteUses_Mauser:SetPercent(target, value, ceil)
	value = self:GetMaxUses(target) * value
	if ceil then
		value = math.ceil(value)
	end
    self:SetUses(target, value)
end

function FiniteUses_Mauser:GetFull(target)
    return self:GetUses(target) >= self:GetMaxUses(target)
end

-- ds only
function FiniteUses_Mauser:CollectPointActions(doer, pos, actions, right)
	if not right then return end
	if not self.inst:HasTag("mauser_rifle") then return end
--	if inst:HasTag("mauser_switch") then return end
	local x, y, z = pos:Get()
	local ents = TheSim:FindEntities(x, y, z, PARAMS.AUTOAIM)

	for k,v in pairs(ents) do
		local flag = doer.components.combat
		flag = flag and flag:CanTarget(v)
		if flag then
			table.insert(actions, ACTIONS.MAUSER_RANGED)
			return
		end
	end
end

-- ds only
function FiniteUses_Mauser:CollectEquippedActions(doer, target, actions, right)
	if not right then return end
	if not self.inst:HasTag("mauser_rifle") then return end
--	if inst:HasTag("mauser_switch") then return end

	local flag = doer.components.combat
	flag = flag and flag:CanTarget(target)
	if flag then
		table.insert(actions, ACTIONS.MAUSER_RANGED)
		return
	end
	self:CollectPointActions(doer, target:GetPosition(), actions, right)
end

return FiniteUses_Mauser
