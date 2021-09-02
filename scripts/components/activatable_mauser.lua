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

-- ds only
function Activatable_Mauser:CollectInventoryActions(doer, actions)
	if doer.components.inventory and doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
		table.insert(actions, ACTIONS.MAUSER_RELOAD)
	end
end

return Activatable_Mauser
