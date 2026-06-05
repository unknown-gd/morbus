AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include( 'shared.lua' )

function ENT:Initialize()
    self:SetModel( "models/glowstick/stick.mdl" )
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
    self:SetSolid( SOLID_VPHYSICS )
    self:SetCollisionGroup( COLLISION_GROUP_PROJECTILE )
    if SERVER then
        local phys = self:GetPhysicsObject()
        if phys:IsValid() then
            phys:Wake()
            phys:AddGameFlag( FVPHYSICS_NO_IMPACT_DMG )
        end
    end

    timer.Simple( 120, function()
        if SERVER and self.Entity then
            self:Remove()
        end
    end )
end

function ENT:SpawnFunction( ply, tr )
    if (not tr.Hit) then return end

    local ent = ents.Create( "ent_glowstick_fly" )
    ent:SetPos( tr.HitPos + tr.HitNormal * 16 )
    ent:Spawn()
    ent:Activate()

    return ent
end

function ENT:OnRemove()
end

function ENT:Use( activator, caller )
    self.Entity:Remove()
end
