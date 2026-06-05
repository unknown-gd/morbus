SWEP.PrintName = "Alien Form"

if (SERVER) then
    AddCSLuaFile( "shared.lua" )
end

SWEP.PrintName = "Alien Form"
if (CLIENT) then
    SWEP.PrintName     = "Alien Form"
    SWEP.ViewModelFOV  = 70
    SWEP.ViewModelFlip = false
    SWEP.Slot          = WEAPON_ROLE
    SWEP.DrawCrosshair = true
    SWEP.SlotPos       = 1
    SWEP.IconLetter    = "y"

end

SWEP.Weight                = 0
SWEP.Base                  = "weapon_mor_melee"
SWEP.DrawWeaponInfoBox     = false

SWEP.ViewModel             = "models/Zed/weapons/v_Banshee.mdl"
SWEP.WorldModel            = "models/weapons/w_fists.mdl"

SWEP.AllowDrop             = false
SWEP.Primary.ClipSize      = -1
SWEP.Primary.DefaultClip   = -1
SWEP.Primary.Automatic     = true
SWEP.Primary.Ammo          = "none"

SWEP.Secondary.ClipSize    = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic   = false
SWEP.Secondary.Ammo        = "none"

sound.Add( {
    name = "brood.swing",
    channel = CHAN_ITEM,
    volume = 0.9,
    sound = "npc/fast_zombie/claw_miss2.wav"
} )

sound.Add( {
    name = "brood.hit",
    channel = CHAN_ITEM,
    volume = 0.9,
    sound = "hellknight/hit1.wav"
} )

SWEP.SwingSound = Sound( "brood.swing" )
SWEP.HitSound = Sound( "brood.hit" )


SWEP.HoldType = "melee"

SWEP.Delay = 0.55
SWEP.Range = 92
SWEP.Damage = 11
SWEP.Kind = WEAPON_ROLE
SWEP.AutoSpawnable = false
SWEP.RightClickType = 0
SWEP.Reloading = false

function SWEP:Initialize()
    self:SetHoldType( self.HoldType )
end

function SWEP:Reload()
    if (IsFirstTimePredicted()) and not self.Reloading then
        self.Reloading = true
        if self.RightClickType == 3 then
            if CLIENT then
                self.Owner:ChatPrint( tostring( "Switching to no right click ability" ) )
            end

            self.RightClickType = 0
        elseif self.RightClickType == 2 then
            if CLIENT then
                self.Owner:ChatPrint( tostring( "Switching to Tier 3 defense upgrade" ) )
            end

            self.RightClickType = self.RightClickType + 1
        elseif self.RightClickType == 1 then
            if CLIENT then
                self.Owner:ChatPrint( tostring( "Switching to Tier 3 attack upgrade" ) )
            end

            self.RightClickType = self.RightClickType + 1
        elseif self.RightClickType == 0 then
            if CLIENT then
                self.Owner:ChatPrint( tostring( "Switching to screech" ) )
            end

            self.RightClickType = self.RightClickType + 1
        end
    end
end

function SWEP:PrimaryAttack()
    self:SetHoldType( self.HoldType )
    self.HolsterTime = CurTime() + 1.5
    if SERVER then
        if self.Owner.Upgrades[ UPGRADE.ATKSPEED ] then
            self.Weapon:SetNextPrimaryFire( CurTime() + self.Delay - (((self.Owner.Upgrades[ UPGRADE.ATKSPEED ] * UPGRADE.ATKSPEED_AMOUNT) / 100) * self.Delay) )
        else
            self.Weapon:SetNextPrimaryFire( CurTime() + self.Delay )
        end
    else
        if Morbus.Upgrades[ UPGRADE.ATKSPEED ] then
            self.Weapon:SetNextPrimaryFire( CurTime() + self.Delay - (((Morbus.Upgrades[ UPGRADE.ATKSPEED ] * UPGRADE.ATKSPEED_AMOUNT) / 100) * self.Delay) )
        else
            self.Weapon:SetNextPrimaryFire( CurTime() + self.Delay )
        end
    end

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
        if SERVER then self.Owner:EmitSound( self.SwingSound, 400, 100 ) end

        trace = {}
        trace.start = pos
        trace.endpos = trace.start + (aim * self.Range)
        trace.filter = owner
        trace = util.TraceLine( trace )
        if trace.Fraction < 1 and trace.HitNonWorld and trace.Entity and not trace.Entity:IsPlayer() then
            self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
            if SERVER then
                local dmg = self.Damage + (UPGRADE.CLAW_AMOUNT * (self.Owner.Upgrades[ UPGRADE.CLAWS ] or 0))
                trace.Entity:TakeDamage( dmg * 50, self.Owner, self.Weapon )
            end
        else
            self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
        end

        self.Owner:SetAnimation( PLAYER_ATTACK1 )
        self.HolsterTime = CurTime() + 1.5
        return
    end

    if SERVER then self.Owner:EmitSound( self.SwingSound ) end

    if trace.Fraction < 1 and trace.HitNonWorld and trace.Entity:IsPlayer() then
        if SERVER then
            local a1, a2 = trace.Entity:GetAngles().y, self.Owner:GetAngles().y
            local diff = a1 - a2

            local dmg = self.Damage

            if (diff <= 60 and diff >= -60) then
                dmg = dmg * 1.75 + (UPGRADE.CLAW_AMOUNT * (self.Owner.Upgrades[ UPGRADE.CLAWS ] or 0))
                trace.Entity:TakeDamage( dmg, self.Owner, self.Weapon )
            else
                dmg = dmg + (UPGRADE.CLAW_AMOUNT * (self.Owner.Upgrades[ UPGRADE.CLAWS ] or 0)) + self.Owner.T3Attack * 10
                trace.Entity:TakeDamage( dmg, self.Owner, self.Weapon )
            end

            local ent = trace.Entity

            self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
            self.Owner:EmitSound( self.HitSound, 500, 100 )
        end

        self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
    else
        self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
    end

    self.Owner:SetAnimation( PLAYER_ATTACK1 )

    self.HolsterTime = CurTime() + 1
end

function SWEP:SecondaryAttack()
    if (SERVER and self and IsValid( self.Owner )) then
        if self.RightClickType == 0 then
            if self.Owner.Upgrades[ UPGRADE.ATTACK_T3 ] or self.Owner.Upgrades[ UPGRADE.DEFENSE_T3 ] then
                self.Owner:ChatPrint( tostring( "Please switch to your usable upgrades using the reload button" ) )
            else
                self.Owner:ChatPrint( tostring( "Please purchase a right click ability by pressing c" ) )
            end
        elseif self.RightClickType == 1 then
            if self.Owner.Upgrades[ UPGRADE.SCREAM ] then

                if self.Owner.NextTransform + 12 < CurTime() and self.Owner.NextScreech < CurTime() then
                    self.Owner:ChatPrint( "uRR" )
                    self.Owner:EmitSound( Sounds.Brood.Transform, 40, 100 )
                    self.Owner.NextScreech = CurTime() + 20
                    self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

                    trace = self.Owner:GetEyeTrace()

                    local humans = GetHumanList()
                    local p1 = trace.HitPos
                    local p2
                    local dist = 600
                    for k, v in pairs( humans ) do
                        p2 = v:GetShootPos()
                        p2 = p1:Distance( p2 ) -- 3 R's
                        if (p2 < dist) then
                            p2 = (1.5 * (dist - p2) / dist)
                            -- thanks machine learning and deep learning research
                            p2 = (3 / 2) * math.tanh( p2 )
                            Send_Fear( v, p2 )
                        end

                        p2 = nil
                    end

                else
                    self.Owner:ChatPrint( "Please wait " .. tostring( math.Round( (math.max( self.Owner.NextTransform + 12, self.Owner.NextScreech ) - CurTime()) ), 1 ) .. " seconds in order to use this ability" )
                end
            else
                self.Owner:ChatPrint( tostring( "Please purchase by pressing c" ) )
            end
        elseif self.RightClickType == 2 then
            if self.Owner.Upgrades[ UPGRADE.ATTACK_T3 ] then

                if self.Owner.T3AttackCoolDown < CurTime() and self.Owner.T3DefenseCoolDown < CurTime() then
                    self.Owner:EmitSound( "npc/zombie_poison/pz_call1.wav", 500, 100 )
                    self.Owner.T3AttackCoolDown = CurTime() + 80

                    self.Owner.T3Attack = 1
                    timer.Simple( 20, function()
                        if (IsValid( self ) and IsValid( self.Owner )) then
                            self.Owner.T3Attack = 0
                        end
                    end )
                    timer.Simple( 80, function()
                        if (IsValid( self ) and IsValid( self.Owner )) then
                            self.Owner:ChatPrint( "Tier 3 ability is now avaliable" )
                        end
                    end )
                else
                    self.Owner:ChatPrint( "Please wait " .. tostring( math.Round( (math.max( self.Owner.T3AttackCoolDown, self.Owner.T3DefenseCoolDown ) - CurTime()) ), 1 ) .. " seconds in order to use this ability" )
                end
            else
                self.Owner:ChatPrint( tostring( "Please purchase by pressing c" ) )
            end
        elseif self.RightClickType == 3 then
            if self.Owner.Upgrades[ UPGRADE.DEFENSE_T3 ] then

                if self.Owner.T3AttackCoolDown < CurTime() and self.Owner.T3DefenseCoolDown < CurTime() then
                    self.Owner:EmitSound( "npc/zombie_poison/pz_alert2.wav", 500, 100 )
                    self.Owner.T3DefenseCoolDown = CurTime() + 80

                    self.Owner.T3Defense = 1
                    timer.Simple( 20, function()
                        if (IsValid( self ) and IsValid( self.Owner )) then
                            self.Owner.T3Defense = 0
                        end
                    end )

                    timer.Simple( 80, function()
                        if (IsValid( self ) and IsValid( self.Owner )) then
                            self.Owner:ChatPrint( "Tier 3 ability is now avaliable" )
                        end
                    end )
                else
                    self.Owner:ChatPrint( "Please wait " .. tostring( math.Round( (math.max( self.Owner.T3AttackCoolDown, self.Owner.T3DefenseCoolDown ) - CurTime()) ), 1 ) .. " seconds in order to use this ability" )
                end
            else
                self.Owner:ChatPrint( tostring( "Please purchase by pressing c" ) )
            end
        end
    end
end

function SWEP:Think()
    if (self.Reloading and IsValid( self.Owner ) and not self.Owner:KeyDown( IN_RELOAD ) and IsFirstTimePredicted()) then
        self.Reloading = false
    end
end

-- function SWEP:Holster(wep)
-- if not IsFirstTimePredicted() then return end


-- return true
-- end

function SWEP:Deploy()
    if not IsFirstTimePredicted() then return end

    if IsFirstTimePredicted() and SERVER then
        if not self.Owner.CanTransform then
            RunConsoleCommand( "lastinv" )
            return true
            --else
            --	self.Owner:SetNWBool("alienform",true)
        end
    end

    self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
    return true
end
