AddCSLuaFile( "shared.lua" )
SWEP.PrintName = "Crowbar"

if (CLIENT) then
    SWEP.PrintName     = "Crowbar"
    SWEP.ViewModelFOV  = 70
    SWEP.ViewModelFlip = false
    SWEP.Slot          = WEAPON_MELEE
    SWEP.SlotPos       = 1
    SWEP.IconLetter    = "y"

end

SWEP.Base                  = "weapon_mor_base"
SWEP.DrawWeaponInfoBox     = false

SWEP.ViewModel             = "models/weapons/v_crowbar.mdl"
SWEP.WorldModel            = "models/weapons/w_crowbar.mdl"

SWEP.Primary.ClipSize      = -1
SWEP.Primary.DefaultClip   = -1
SWEP.Primary.Automatic     = true
SWEP.Primary.Ammo          = "none"

SWEP.Secondary.ClipSize    = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic   = false
SWEP.Secondary.Ammo        = "none"

SWEP.SwingSound            = "Weapon_Crowbar.Single"
SWEP.HitSound              = "Weapon_Crowbar.Melee_Hit"

SWEP.HoldType              = "melee"

SWEP.AllowDrop             = false
SWEP.Kind                  = WEAPON_MELEE

SWEP.Delay                 = 0.7
SWEP.Range                 = 75
SWEP.Damage                = 20
SWEP.AutoSpawnable         = false

function SWEP:Initialize()
    self:SetHoldType( self.HoldType )
end

function SWEP:Deploy()
    self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
    return true
end

function SWEP:PrimaryAttack()
    self.Weapon:SetNextPrimaryFire( CurTime() + self.Delay )

    local pos = self.Owner:GetShootPos()
    local aim = self.Owner:GetAimVector()
    local owner = self.Owner
    local vec = Vector( 1, 1, 0.5 )

    local trace = {}
    trace.start = pos
    trace.endpos = trace.start + (aim * self.Range)
    trace.filter = owner
    trace.mins = vec * -13
    trace.maxs = vec * 13
    trace.mask = CONTENTS_MONSTER + CONTENTS_HITBOX

    local trace2 = {}
    trace2.start = pos
    trace2.endpos = trace2.start + (aim * self.Range)
    trace2.filter = owner
    trace2.mins = vec * -11
    trace2.maxs = vec * 11

    self.Owner:LagCompensation( true )
    trace = util.TraceHull( trace )
    trace2 = util.TraceHull( trace2 )
    self.Owner:LagCompensation( false )

    if trace2.Fraction * 1.3 < trace.Fraction then
        if SERVER then self.Owner:EmitSound( self.SwingSound, 300, 100 ) end

        trace = {}
        trace.start = pos
        trace.endpos = trace.start + (aim * self.Range)
        trace.filter = owner
        trace = util.TraceLine( trace )
        if trace.Fraction < 1 and trace.HitNonWorld and trace.Entity and not trace.Entity:IsPlayer() then
            if SERVER then
                local dmg = self.Damage * 2
                trace.Entity:TakeDamage( dmg, owner, self.Weapon )
            end

            self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )
        else
            self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER )
        end

        self.Owner:SetAnimation( PLAYER_ATTACK1 )
        self.HolsterTime = CurTime() + 1.5
        return
    end

    if SERVER then self.Owner:EmitSound( self.SwingSound ) end

    if trace.Fraction < 1 and trace.HitNonWorld and trace.Entity:IsPlayer() then
        if SERVER then
            local a1, a2 = trace.Entity:GetAngles().y, self.Owner:GetAngles().y

            local dmg = self.Damage
            trace.Entity:TakeDamage( dmg, owner, self.Weapon )

            local ent = trace.Entity

            self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )
            self.Owner:EmitSound( self.HitSound, 300, 100 )
        end

        self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )
    else
        self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER )
    end

    self.Owner:SetAnimation( PLAYER_ATTACK1 )

    self.HolsterTime = CurTime() + 1

end

function SWEP:Reload()
    return false
end

function SWEP:Think()
    return false
end

function SWEP:SecondaryAttack()
    return false
end
