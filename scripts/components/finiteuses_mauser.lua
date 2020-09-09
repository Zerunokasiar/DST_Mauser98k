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

function FiniteUses_Mauser:SetPercent(target, value)
    self:SetUses(target, self:GetMaxUses(target) * value)
end

function FiniteUses_Mauser:GetFull(target)
    return self:GetUses(target) >= self:GetMaxUses(target)
end

return FiniteUses_Mauser
