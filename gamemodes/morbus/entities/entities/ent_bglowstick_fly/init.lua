AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include( 'shared.lua' )

function ENT:Initialize()
    local pd = 20
    local pr = pd / 2

    self:SetModel( "models/glowstick/stick_lblu.mdl" )
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
    self:SetSolid( SOLID_VPHYSICS )

    self:PhysicsInitSphere( pr )
    self:SetCollisionBounds( Vector( -pr, -pr, -pr ), Vector( pr, pr, pr ) )

    if SERVER then
        local phys = self:GetPhysicsObject()
        if phys:IsValid() then
            phys:Wake()
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

    local ent = ents.Create( "ent_bglowstick_fly" )
    ent:SetPos( tr.HitPos + tr.HitNormal * 16 )
    ent:Spawn()
    ent:Activate()

    return ent
end

function ENT:OnRemove()
end

function ENT:Use( activator, caller )

end
