-- Quarter second impulse

local IMPULSE = {}

function IMPULSE.QUARTER_SECOND()
    for k, v in pairs( GetBroodList() ) do
        IMPULSE.INVISIBLE( k, v )
    end
end

hook.Add( "Impulse_Quarter_Second", "QSec_Impulse", IMPULSE.QUARTER_SECOND )

local function Send_Cloak( ply )
    umsg.Start( "Send_Cloaking", ply )
    umsg.End()
end

function Cancel_Cloak( ply )
    umsg.Start( "Cancel_Cloaking", ply )
    umsg.End()
end

function IMPULSE.INVISIBLE( k, v )
    if v:Team() == TEAM_GAME and v:Alive() and IsValid( v ) then
        if v:GetNWBool( "alienform", false ) then
            -- set brood speed, brood jump
            GAMEMODE:SetPlayerSpeed( v, BROOD_SPEED + (v.Upgrades[ UPGRADE.SPRINT ] or 0) * UPGRADE.SPRINT_AMOUNT, BROOD_SPEED + (v.Upgrades[ UPGRADE.SPRINT ] or 0) * UPGRADE.SPRINT_AMOUNT )
            v:SetJumpPower( DEFAULT_JUMP + (v.Upgrades[ UPGRADE.JUMP ] or 0) * UPGRADE.JUMP_AMOUNT )
        end

        -- takes care of invis in brood form and human form
        if v.Upgrades[ UPGRADE.INVISIBLE ] and (v:GetNWBool( "alienform", false ) or v.Upgrades[ UPGRADE.INVISIBLE_EXTRA ]) then
            -- if moving or attacked, uncloak
            if v.Moving or v:Health() < v.PreviousHealth then
                v.Cloaked = 0
                v.CloakStart = 0
                v.Cloaking = false
                v:SetNWBool( "cloaked", v.Cloaking )
                v.PreviousHealth = v:Health()
                Cancel_Cloak( v )
                v:SetColor( Color( 255, 255, 255, 255 ) )
                v:SetNoDraw( false )
                v:DrawWorldModel( true )
                -- if not moving and had previously stopped
            elseif v.Cloaked ~= 0 then
                -- check if player is currently cloaking
                if v.Cloaking then
                    -- make invis if player has stood long enough
                    if v.Cloaked <= CurTime() then
                        v:SetColor( Color( 255, 255, 255, 0 ) )
                        v:SetNoDraw( true )
                        v:DrawWorldModel( false )
                        Send_Cloak( v )
                        v.PreviousHealth = v:Health()
                        v.Cloaked = 0
                    end
                end
            else
                -- If they are not cloaked and not moving, then in 4 - INVISIBLE UPGRADES seconds player will be cloaked
                if not v.Cloaking then
                    v.Cloaked = CurTime() + (4 - v.Upgrades[ UPGRADE.INVISIBLE ])
                    v.CloakStart = CurTime()
                    v.Cloaking = true
                    v.PreviousHealth = v:Health()
                    v:SetNWBool( "cloaked", v.Cloaking )
                end
            end
        end
    end
end
