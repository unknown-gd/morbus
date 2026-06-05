AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:Initialize()
    self:SetModel( "models/weapons/W_missile_launch.mdl" )
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetColor( Color( 55, 155, 255, 0 ) )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetGravity( 0.2 )
    self:SetSolid( SOLID_VPHYSICS )
    self:DrawShadow( false )

    self:SetCollisionGroup( COLLISION_GROUP_PROJECTILE )

    -- Sprite Trail Effect
    if SERVER then
        util.SpriteTrail( self.Entity, 0, Color( 55, 155, 255, 255 ), false, 55, 1, 0.5, 45, "trails/plasma.vmt" )
    end

    if SERVER then
        local phys = self:GetPhysicsObject()
        if phys:IsValid() then
            phys:Wake()
        end
    end
end

--[[function ENT:Think()
    if SERVER then
        self.tes = ents.Create( "point_tesla" )
        self.tes:SetPos( self:GetPos() )
        self.tes:SetKeyValue( "m_SoundName", "" )
        self.tes:SetKeyValue( "texture", "sprites/bluelight1.spr" )
        self.tes:SetKeyValue( "m_Color", "55 255 215" )
        self.tes:SetKeyValue( "m_flRadius", "255" )
        self.tes:SetKeyValue( "beamcount_min", "1" )
        self.tes:SetKeyValue( "beamcount_max", "2" )
        self.tes:SetKeyValue( "thick_min", "8" )
        self.tes:SetKeyValue( "thick_max", "16" )
        self.tes:SetKeyValue( "lifetime_min", "0.3" )
        self.tes:SetKeyValue( "lifetime_max", "0.5" )
        self.tes:SetKeyValue( "interval_min", "0.1" )
        self.tes:SetKeyValue( "interval_max", "0.3" )
        self.tes:Spawn()
        self.tes:Fire( "DoSpark", "", 0 )
        self.tes:Fire( "kill", "", 0.3 )
    end
end--]]

function ENT:Explode()
    local fx = EffectData()
    fx:SetOrigin( self:GetPos() )
    util.Effect( "mor_bfg_b", fx )
    ParticleEffect( "h_plasma_imp_b", self:GetPos(), Angle( 0, 0, 1 ), nil )
    self.Entity:EmitSound( "ambient/levels/labs/electric_explosion3.wav", 100, math.random( 125, 135 ) )

    util.BlastDamage( self, self.Owner, self:GetPos(), 125, 255 )

    -- Damage in sphere
    for _, v in ipairs( ents.FindInSphere( self:GetPos(), 128 ) ) do
        if v ~= self:GetOwner() then
            local dmginfo = DamageInfo()
            dmginfo:SetAttacker( self:GetOwner() )
            dmginfo:SetInflictor( self )
            dmginfo:SetDamage( 25 )
            v:TakeDamageInfo( dmginfo )
        end
    end

    -- Extra cone
    for _, v in ipairs( ents.FindInSphere( self:GetPos(), 348 ) ) do
        if v ~= self:GetOwner() then
            local dmginfo = DamageInfo()
            dmginfo:SetAttacker( self:GetOwner() )
            dmginfo:SetInflictor( self )
            dmginfo:SetDamage( 10 )
            v:TakeDamageInfo( dmginfo )
        end
    end

    if SERVER then
        local tesla = ents.Create( "point_tesla" )
        self.tes = tesla

        tesla:SetPos( self:GetPos() )
        tesla:SetKeyValue( "m_SoundName", "" )
        tesla:SetKeyValue( "texture", "sprites/bluelight1.spr" )
        tesla:SetKeyValue( "m_Color", "55 255 215" )
        tesla:SetKeyValue( "m_flRadius", "1000" )
        tesla:SetKeyValue( "beamcount_min", "10" )
        tesla:SetKeyValue( "beamcount_max", "15" )
        tesla:SetKeyValue( "thick_min", "16" )
        tesla:SetKeyValue( "thick_max", "32" )
        tesla:SetKeyValue( "lifetime_min", "0.8" )
        tesla:SetKeyValue( "lifetime_max", "1.2" )
        tesla:SetKeyValue( "interval_min", "0.2" )
        tesla:SetKeyValue( "interval_max", "0.4" )
        tesla:Spawn()
        tesla:Fire( "DoSpark", "", 0 )
        tesla:Fire( "DoSpark", "", 0.1 )
        tesla:Fire( "DoSpark", "", 0.3 )
        tesla:Fire( "DoSpark", "", 0.7 )
        tesla:Fire( "kill", "", 0.8 )
    end

    self:Remove()
end

function ENT:PhysicsCollide( data, phys )
    self:Explode()
end

function ENT:OnRemove()
end
