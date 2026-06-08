if (SERVER) then
    AddCSLuaFile( "shared.lua" )
end

---@class weapon_frag : SWEP
---@field StoredAmmo integer
local SWEP = SWEP

if (CLIENT) then
    language.Add( "ent_frag_grenade", "Frag Grenade" ) --wtf

    SWEP.DrawCrosshair   = true
    SWEP.ViewModelFOV    = 70
    SWEP.ViewModelFlip   = true
    SWEP.CSMuzzleFlashes = false
    SWEP.PrintName       = "Frag Grenade"
    SWEP.Slot            = WEAPON_GRENADE
    SWEP.SlotPos         = 0
end

SWEP.Spawnable             = false
SWEP.AdminSpawnable        = false
SWEP.HoldType              = "grenade"
--SWEP.ViewModel 					= "models/weapons/cstrike/c_eq_fraggrenade.mdl"
SWEP.ViewModel             = "models/weapons/v_eq_fraggrenade.mdl"
SWEP.WorldModel            = "models/weapons/w_eq_fraggrenade.mdl"
SWEP.UseHands              = true
SWEP.Primary.ClipSize      = 1
SWEP.Primary.DefaultClip   = 1
SWEP.Primary.Automatic     = false
SWEP.Primary.Ammo          = "none"
SWEP.Primary.Delay         = 1

SWEP.Secondary.ClipSize    = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic   = false
SWEP.Secondary.Ammo        = "none"

SWEP.AllowDrop             = true
SWEP.Kind                  = WEAPON_GRENADE
SWEP.KGWeight              = 2
SWEP.AutoSpawnable         = true
SWEP.StoredAmmo            = 0
--SWEP.UseHands = true

function SWEP:Think()
end

function SWEP:Initialize()
    self:SetHoldType( self.HoldType )
end

function SWEP:Deploy()
    self:SendWeaponAnim( ACT_VM_DRAW )
    self:SetHoldType( self.HoldType )

    if SERVER then
        local owner = self:GetOwner()
        if owner ~= nil and owner:IsValid() then
            ---@cast owner Player

            owner:DrawWorldModel( false )

            local ent = ents.Create( "ent_frag" )
            ent:SetOwner( owner )
            ent:SetParent( owner )
            ent:SetPos( owner:GetPos() )
            ent:SetColor( owner:GetColor() )
            ent:SetMaterial( owner:GetMaterial() )
            ent:Spawn()
        end
    end

    return true
end

function SWEP:Reload()
end

function SWEP:PrimaryAttack()
    local owner = self:GetOwner()
    if owner == nil or not owner:IsValid() then return end

    ---@cast owner Player

    self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
    self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )

    self:TakePrimaryAmmo( 1 )

    self:SendWeaponAnim( ACT_VM_THROW )  -- View model animation
    owner:SetAnimation( PLAYER_ATTACK1 ) -- 3rd Person Animation

    if SERVER then
        local ent = ents.Create( "ent_frag_grenade" )

        ent.GrenadeOwner = owner
        ent:SetPos( owner:GetShootPos() )
        ent:SetAngles( Angle( 1, 0, 0 ) )
        ent:Spawn()

        local phys = ent:GetPhysicsObject()
        if phys ~= nil and phys:IsValid() then
            phys:SetVelocity( owner:GetAimVector() * 1000 )
            phys:AddAngleVelocity( Vector( math.random( -50, 50 ), math.random( -50, 50 ), math.random( -50, 50 ) ) )
        end
    end

    local gender = owner:GetNWInt( "gender" )
    if gender == 1 then
        self:EmitSound( "vo/npc/male01/watchout.wav", 100, math.random( 95, 105 ) )
    else
        self:EmitSound( "vo/npc/Alyx/watchout02.wav", 100, math.random( 95, 105 ) )
    end

    self:SendWeaponAnim( ACT_VM_DRAW )

    local checkAlien = owner:IsAlien()

    if self:Clip1() < 1 and SERVER then
        for _, v in ipairs( ents.FindInSphere( owner:GetPos(), 0.6 ) ) do
            if v:GetClass() == "ent_frag" and v:GetOwner() == owner then
                v:Remove()
            end
        end

        owner:StripWeapon( "weapon_frag" )

        if checkAlien then
            owner:SelectWeapon( "weapon_mor_crowbar" )
        else
            RunConsoleCommand( "invprev" )
        end
    end

end

function SWEP:SecondaryAttack()
    local owner = self:GetOwner()
    if owner == nil or not owner:IsValid() then return end

    ---@cast owner Player

    self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
    self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )

    self:TakePrimaryAmmo( 1 )

    self:SendWeaponAnim( ACT_VM_THROW ) -- View model animation
    owner:SetAnimation( PLAYER_ATTACK1 )

    if SERVER then
        local ent = ents.Create( "ent_frag_grenade" )

        ent.GrenadeOwner = owner
        ent:SetPos( owner:GetShootPos() )
        ent:SetAngles( Angle( 1, 0, 0 ) )
        ent:Spawn()

        local phys = ent:GetPhysicsObject()
        phys:SetVelocity( owner:GetAimVector() * 30 )
        phys:AddAngleVelocity( Vector( 0, 0, 0 ) )
    end

    local gender = owner:GetNWInt( "gender" )
    if gender == 1 then
        self:EmitSound( "vo/npc/male01/watchout.wav", 100, math.random( 95, 105 ) )
    else
        self:EmitSound( "vo/npc/Alyx/watchout02.wav", 100, math.random( 95, 105 ) )
    end

    self:SendWeaponAnim( ACT_VM_DRAW )

    local checkAlien = owner:IsAlien()

    if self:Clip1() < 1 and SERVER then
        for k, v in ipairs( ents.FindInSphere( owner:GetPos(), 0.6 ) ) do
            if v:GetClass() == "ent_frag" and v:GetOwner() == owner then
                v:Remove()
            end
        end

        owner:StripWeapon( "weapon_frag" )

        if checkAlien then
            owner:SelectWeapon( "weapon_mor_crowbar" )
        else
            RunConsoleCommand( "invprev" )
        end
    end

end

function SWEP:Holster()
    local owner = self:GetOwner()
    if owner == nil or not owner:IsValid() then return end

    for _, v in ipairs( ents.FindInSphere( owner:GetPos(), 0.6 ) ) do
        if v:GetClass() == "ent_frag" and v:GetOwner() == owner then
            if SERVER then
                v:Remove()
            end
        end
    end

    return true
end

---@return integer
function SWEP:Ammo1()
    local owner = self:GetOwner()
    if owner == nil or not owner:IsValid() then return 0 end

    ---@cast owner Player

    return owner:GetAmmoCount( self.Primary.Ammo )
end

function SWEP:PreDrop()
    local owner = self:GetOwner()
    if owner == nil or not owner:IsValid() then return end

    ---@cast owner Player

    if SERVER and self.Primary.Ammo ~= "none" then
        local ammo = self:Ammo1()

        -- Do not drop ammo if we have another gun that uses this type
        for _, w in ipairs( owner:GetWeapons() ) do
            if IsValid( w ) and w ~= self and w:GetPrimaryAmmoType() == self:GetPrimaryAmmoType() then
                ammo = 0
            end
        end

        self.StoredAmmo = ammo

        if ammo > 0 then
            owner:RemoveAmmo( ammo, self.Primary.Ammo )
        end

    end

    for _, v in ipairs( ents.FindInSphere( owner:GetPos(), 0.6 ) ) do
        if v:GetClass() == "ent_frag" and v:GetOwner() == owner then
            v:Remove()
        end
    end
end

function SWEP:DampenDrop()
    local phys = self:GetPhysicsObject()
    if IsValid( phys ) then
        phys:SetVelocityInstantaneous( Vector( 0, 0, -75 ) + phys:GetVelocity() * 0.001 )
        phys:AddAngleVelocity( phys:GetAngleVelocity() * -0.99 )
    end
end

---@param newowner Player
function SWEP:Equip( newowner )
    if SERVER then
        if self:IsOnFire() then
            self:Extinguish()
        end
    end

    if SERVER and IsValid( newowner ) and self.StoredAmmo > 0 and self.Primary.Ammo ~= "none" then
        local ammo = newowner:GetAmmoCount( self.Primary.Ammo )
        local given = math.min( self.StoredAmmo, (self.Primary.ClipSize * 3) - ammo )

        newowner:GiveAmmo( given, self.Primary.Ammo )
        self.StoredAmmo = 0
    end
end

function SWEP:IsEquipment()
    return WEPS.IsEquipment( self )
end
