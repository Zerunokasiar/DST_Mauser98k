local Boostable_Mauser = Class(function(self, inst)
    self.inst = inst
    self.BoostOnFn = nil
    self.BoostOffFn = nil
end)

function Boostable_Mauser:SetBoostOn(fn)
	self.BoostOnFn = fn
end

function Boostable_Mauser:SetBoostOff(fn)
	self.BoostOffFn = fn
end

function Boostable_Mauser:BoostOn(inst, owner)
    return self.BoostOnFn and self.BoostOnFn(inst, owner)
end

function Boostable_Mauser:BoostOff(inst, owner)
	return self.BoostOffFn and self.BoostOffFn(inst, owner)
end

return Boostable_Mauser
