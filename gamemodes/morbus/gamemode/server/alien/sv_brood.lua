-- Morbus - morbus.remscar.com
-- Developed by Remscar and the Morbus dev team

---@param aliens Player[]
function CheckAlien( aliens )
    for _, v in ipairs( aliens ) do
        if IsValid( v ) then
            if (v.NextTransform < CurTime()) and (v.CanTransform == false) then
                v.CanTransform = true
                Send_Transform( v, true )
            end

            if IsValid( v:GetActiveWeapon() ) then
                if (v:GetActiveWeapon():GetClass() == "weapon_mor_brood" and v.CanTransform and not v:GetNWBool( "alienform", false )) then
                    v:SetNWBool( "alienform", true )
                    Brood_Turn_Alien( v )
                elseif (v:GetActiveWeapon():GetClass() ~= "weapon_mor_brood" and v:GetNWBool( "alienform", false )) then
                    Brood_Turn_Human( v )
                end
            end
        end
    end
end

-- logic for turning a brood in human form into alien
function Brood_Turn_Alien( ply )
    ply.CanTransform = false
    Send_Transform( ply, false )
    ply.NextTransform = CurTime() + TRANSFORM_TIME
    LIGHT.TurnOff( ply )
    ply:SetModel( Models.Brood )
    Send_Blood( ply )
    ply:EmitSound( Sounds.Brood.Transform, 300, 100 )

    GAMEMODE:SetPlayerSpeed( ply, BROOD_SPEED + (ply.Upgrades[ UPGRADE.SPRINT ] or 0) * UPGRADE.SPRINT_AMOUNT,
        BROOD_SPEED + (ply.Upgrades[ UPGRADE.SPRINT ] or 0) * UPGRADE.SPRINT_AMOUNT )

    ply:SetJumpPower( DEFAULT_JUMP + ((ply.Upgrades[ UPGRADE.JUMP ] or 0) * UPGRADE.JUMP_AMOUNT) )

    if ply.Upgrades[ UPGRADE.HEALTH ] then
        local h = ply:Health()
        local hm = 110 + ply.Upgrades[ UPGRADE.HEALTH ] * UPGRADE.HEALTH_AMOUNT
        ply:SetHealth( (h / 100) * hm )
    end

    if ply.Upgrades[ UPGRADE.SCREAM ] then
        Send_Scream( ply, 800, 1.5, .5, 2 / math.tanh( 2 ), 0 )
    end

    -- possible I dont need this. Test later
    if not ply.Upgrades[ UPGRADE.INVISIBLE_EXTRA ] then
        Cancel_Human_Cloak( ply )
    end
end

-- logic for turning a brood in alien form to human
function Brood_Turn_Human( ply )
    LIGHT.TurnOff( ply )
    ply:SetModel( ply.WantedModel )
    GAMEMODE:SetPlayerSpeed( ply, HUMAN_SPEED, HUMAN_SPEED )
    ply:SetJumpPower( DEFAULT_JUMP )
    ply:CalcWeight()
    ply:SetNWBool( "alienform", false )

    if not ply.Upgrades[ UPGRADE.INVISIBLE_EXTRA ] then
        Cancel_Human_Cloak( ply )
    end

    if ply.Upgrades[ UPGRADE.HEALTH ] then
        local h = ply:Health()
        local hm = 110 + (ply.Upgrades[ UPGRADE.HEALTH ] * UPGRADE.HEALTH_AMOUNT)
        local hm = h / hm
        ply:SetHealth( 100 * hm )
    end
end

function Send_Fear( ply, int )
    umsg.Start( "Send_Fear", ply )
    umsg.Short( int )
    umsg.End()
end

-- blinds all players caught within the radius of a tranformed brood
function Send_Scream( ply, dist, a, b, c, d )
    local p1 = ply:GetShootPos()
    local p2
    for _, v in ipairs( GetHumanList() ) do
        p2 = v:GetShootPos()
        p2 = p1:Distance( p2 ) -- 3 R's
        if (p2 < dist) then
            -- thanks machine learning and deep learning research
            -- linear layer followed by non-linearity followed by output linear layer :P
            p2 = c * math.tanh( a * (dist - p2) / dist + b ) + d
            Send_Fear( v, p2 )
        end

        p2 = nil
    end
end

-- splatters blood everywhere
function Send_Blood( ply )
    for i = 1, 5 do
        for b = 1, 4 do
            local effectdata = EffectData()
            effectdata:SetOrigin( ply:GetPos() + Vector( 0, 0, i * 10 ) )
            effectdata:SetNormal( ply:GetVelocity():GetNormal() )
            util.Effect( "bloodstream", effectdata )
        end
    end

    for i = 2, 3 do
        local gib_effect = EffectData()
        gib_effect:SetOrigin( ply:GetPos() + Vector( 0, 0, 50 ) )
        gib_effect:SetNormal( ply:GetVelocity():GetNormal() )
        util.Effect( "goremod_gib", gib_effect )
    end
end

function Cancel_Human_Cloak( ply )
    Cancel_Cloak( ply )
    ply:SetColor( Color( 255, 255, 255, 255 ) )
    ply:SetNoDraw( false )
end
