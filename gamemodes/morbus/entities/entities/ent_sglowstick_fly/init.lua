AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include( 'shared.lua' )

function ENT:Initialize()
    self:SetModel( "models/glowstick/stick_rng.mdl" )
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

    local ent = ents.Create( "ent_sglowstick_fly" )
    ent:SetPos( tr.HitPos + tr.HitNormal * 16 )
    ent:Spawn()
    ent:Activate()

    return ent
end

-- function testProp( ply )
--     local ent = ents.Create( "prop_physics" )
--     ent:SetPos( ply:GetPos() + Vector( 5, 0, 0 ) )
--     ent:SetModel( "models/hunter/blocks/cube1x2x1.mdl" )
--     ent:Spawn()
-- end

-- concommand.Add( "testprop", testProp )

function ENT:PhysicsCollide( data, physobj )
    if IsValid( self:GetParent() ) then return end

    if data.HitEntity then
        ent = data.HitEntity
        if ent:IsWorld() then
            self:SetMoveType( MOVETYPE_NONE )
            self:SetPos( data.HitPos - data.HitNormal * 1.2 )
            flip = 1
            if data.HitNormal.y > 0 then
                flip = -1
            end

            self:SetAngles( Angle( 0, data.HitNormal.y + data.HitNormal.x, -data.HitNormal.z * flip ) * 90 )
        elseif ent:IsPlayer() and not ent:IsWeapon() then

            self:SetPos( data.HitPos - data.HitNormal )
            flip = 1
            if data.HitNormal.y > 0 then
                flip = -1
            end

            self:SetParent( ent )
            self:SetAngles( Angle( 0, data.HitNormal.y + data.HitNormal.x, -data.HitNormal.z * flip ) * 90 )
            self:SetSolid( SOLID_NONE )
            if CLIENT then
                self:Draw()
            end

        end
    end
end

function ENT:OnRemove()
end

function ENT:Use( activator, caller )
    self.Entity:Remove()
end
