include("shared.lua")

function ENT:Initialize()
end

function ENT:Draw()
	self.Entity:DrawModel()
	if self:GetPos():Distance(LocalPlayer():GetPos()) < 4000 then
    local dlight = DynamicLight( self:EntIndex() )
	if ( dlight ) then
		local r, g, b, a = self:GetColor()
		dlight.Pos = self:GetPos()
		dlight.r = 0
		dlight.g = 95
		dlight.b = 255
		dlight.Brightness = 1
		dlight.Size = 650
		dlight.Decay = 450
		dlight.DieTime = CurTime() + 90
	end 
	end
end
