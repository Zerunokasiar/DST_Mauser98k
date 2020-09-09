local Activatable_Mauser = Class(function(self, inst)
    self.inst = inst
    self.CanActivateFn = nil
    self.DoActivateFn = nil
end)

function Activatable_Mauser:SetCanActivate(fn)
	self.CanActivateFn = fn
end

function Activatable_Mauser:SetDoActivate(fn)
	self.DoActivateFn = fn
end

function Activatable_Mauser:CanActivate(inst, doer)
    return self.CanActivateFn and self.CanActivateFn(inst, doer)
end

function Activatable_Mauser:DoActivate(inst, doer)
	return self.DoActivateFn and self.DoActivateFn(inst, doer)
end

return Activatable_Mauser
