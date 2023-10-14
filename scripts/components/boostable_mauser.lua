local Boostable_Mauser = Class(function(self, inst)
    self.inst = inst
    self.BoostOnFn = nil
    self.BoostOffFn = nil
    self.DebuffOnFn = nil
    self.DebuffOffFn = nil
end)

function Boostable_Mauser:SetBoostOn(fn)
	self.BoostOnFn = fn
end

function Boostable_Mauser:SetBoostOff(fn)
	self.BoostOffFn = fn
end

function Boostable_Mauser:BoostOn(owner)
    return self.BoostOnFn and self.BoostOnFn(self.inst, owner)
end

function Boostable_Mauser:BoostOff(owner)
	return self.BoostOffFn and self.BoostOffFn(self.inst, owner)
end

function Boostable_Mauser:SetDebuffOn(fn)
	self.DebuffOnFn = fn
end

function Boostable_Mauser:SetDebuffOff(fn)
	self.DebuffOffFn = fn
end

function Boostable_Mauser:DebuffOn(owner)
    return self.DebuffOnFn and self.DebuffOnFn(self.inst, owner)
end

function Boostable_Mauser:DebuffOff(owner)
	return self.DebuffOffFn and self.DebuffOffFn(self.inst, owner)
end

return Boostable_Mauser
