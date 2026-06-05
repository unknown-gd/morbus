-- Morbus - morbus.remscar.com
-- Developed by Remscar and the Morbus dev team


--[[
MORBUS COMMUNICATION SYSTEM
--]]
function ChangeMuteState( ply, cmd, args )
    if #args < 1 then
        SendMsg( ply, "0-None 1-Alive Only 2-Spectators Only 3-No Spectators 4-No Alien Chat + Alive Only" )
        return
    end

    local n = tonumber( args[ 1 ] or 0 ) or 0
    ply:SetNWInt( "Mute_Status", n )
end

concommand.Add( "morbus_mute_status", ChangeMuteState )

ISLOCALCHAT = true
NO_OOCCHAT = false

--[[
CHAT FUNCTIONS
--]]
function SendOOCChat( ply, text )
    if NO_OOCCHAT and (GetRoundState() == ROUND_ACTIVE) then
        SendMsg( ply, "OOC Chat is disabled!" )
        return
    end

    umsg.Start( "SendOOCChat" )
    umsg.String( ply:Nick() )
    umsg.String( ply:GetFName() )
    umsg.String( text )
    umsg.End()
end

function SendLocalChat( ply, text )
    local filter = RecipientFilter()
    for k, v in player.Iterator() do
        if (v:GetShootPos():Distance( ply:GetShootPos() ) < 900) then
            filter:AddPlayer( v )
        end
    end

    umsg.Start( "SendLocalChat", filter )
    umsg.String( ply:GetFName() )
    umsg.String( text )
    umsg.End()
end

function SendSpecChat( ply, text )
    local filter = RecipientFilter()
    for k, v in pairs( GetSpectatorList() ) do
        if v:Team() == TEAM_SPEC then
            filter:AddPlayer( v )
        end
    end

    umsg.Start( "SendSpecChat", filter )
    umsg.String( ply:GetFName() )
    umsg.String( text )
    umsg.End()
end

-- work on this
function GM:PlayerSay( ply, text, to_all ) -- Shitty chat shit
    --TODO: REDO THIS
    if not IsValid( ply ) then return end

    if ply.Gagged then return "" end -- for later use

    to_all = not to_all

    if not to_all and GetRoundState() == ROUND_ACTIVE then
        if ply:IsAlien() and ply:Team() ~= TEAM_SPEC then
            AlienChatMsg( ply, text )
        end

        return ""
    end

    if ply:Alive() ~= true then
        if string.sub( text, 0, 2 ) == "--" then
            SendOOCChat( ply, string.sub( text, 0, 2 ) )
            return ""
        end

        if string.sub( text, 0, 3 ) == "ooc" then
            SendOOCChat( ply, string.sub( text, 4 ) )
            return ""
        end

        if string.sub( text, 0, 4 ) == "/ooc" then
            SendOOCChat( ply, string.sub( text, 5 ) )
            return ""
        end

        if text == "/rtv" then
            RTV( ply )
            return ""
        end

        if text == "/spec" then
            ToggleSpec( ply )
            return ""
        end

        if text == "/light" then
            GAMEMODE:PlayerSwitchFlashlight( ply, true )
            return ""
        end

        if text == "/version" then
            ShowVersion( ply )
            return ""
        end

        if text == "/forcertv" then
            ForceMap( ply )
            return ""
        end

        if text == "/remscar" then
            WhoIsRemscar()
            return ""
        end

        if text == "/nightmare" then
            ChangeNightmare( ply )
            return ""
        end

        if GetRoundState() ~= ROUND_ACTIVE then
            SendOOCChat( ply, " " .. text )
            return ""
        end

        if not (ply:Team() == TEAM_SPEC) then
        else
            SendSpecChat( ply, " " .. text )
            return ""
        end

        SendMsg( ply, "You can't talk when your dead!" )
        return ""
    end

    if text == "/version" then
        ShowVersion( ply )
        return ""
    end

    if text == "/spec" then
        ToggleSpec( ply )
        return ""
    end

    if text == "/light" then
        GAMEMODE:PlayerSwitchFlashlight( ply, true )
        return ""
    end

    if text == "/forcertv" then
        ForceMap( ply )
        return ""
    end

    if text == "/remscar" then
        WhoIsRemscar()
        return ""
    end

    if text == "/nightmare" then
        ChangeNightmare( ply )
        return ""
    end

    if string.sub( text, 0, 2 ) == "--" then
        SendOOCChat( ply, string.sub( text, 3 ) )
        return ""
    end

    if string.sub( text, 0, 3 ):lower() == "ooc" then
        SendOOCChat( ply, string.sub( text, 4 ) )
        return ""
    end

    if string.sub( text, 0, 4 ):lower() == "/ooc" or string.sub( text, 0, 4 ):lower() == "/all" then
        SendOOCChat( ply, string.sub( text, 5 ) )
        return ""
    end

    if (GetRoundState() ~= ROUND_ACTIVE) then
        SendOOCChat( ply, " " .. text )
        return ""
    end

    if not (ply:Team() == TEAM_SPEC) then
        SendLocalChat( ply, " " .. text )
    else
        SendSpecChat( ply, " " .. text )
    end

    return ""
end

local mute_all = false
function MuteForRestart( state )
    mute_all = state
end

function GM:PlayerCanHearPlayersVoice( listener, speaker )
    if mute_all then
        return false, false
    end

    if (speaker:Team() == TEAM_SPEC and listener:Team() == TEAM_SPEC) and ((listener:GetNWInt( "Mute_Status", 0 ) == 0 or listener:GetNWInt( "Mute_Status", 0 ) == 2)) then
        return true, false
    end

    if not listener:Alive() then
        if not listener:IsSwarm() and GetRoundState() == ROUND_ACTIVE and listener:IsGame() then
            return false, false
        end
    end

    if speaker:IsAlien() and (speaker.alien_voice == false) then
        if listener:IsAlien() and (listener:GetNWInt( "Mute_Status", 0 ) == 0 or listener:GetNWInt( "Mute_Status", 0 ) == 3 or listener:GetNWInt( "Mute_Status", 0 ) == 1) then
            return true, false
        else
            return false, false
        end
    end

    if (listener:GetShootPos():Distance( speaker:GetShootPos() ) < 2000) and (listener:Team() == TEAM_SPEC) and (GetRoundState() == ROUND_ACTIVE) and (ISLOCALCHAT == true) and ((listener:GetNWInt( "Mute_Status", 0 ) == 0 or listener:GetNWInt( "Mute_Status", 0 ) == 1 or listener:GetNWInt( "Mute_Status", 0 ) == 4)) then
        return true, true
    end

    if (listener:GetShootPos():Distance( speaker:GetShootPos() ) < 750) and (speaker:Team() ~= TEAM_SPEC) and (GetRoundState() == ROUND_ACTIVE) and (ISLOCALCHAT == true) and ((listener:GetNWInt( "Mute_Status", 0 ) == 0 or listener:GetNWInt( "Mute_Status", 0 ) == 1 or listener:GetNWInt( "Mute_Status", 0 ) == 4)) then
        return true, true
    end

    if (ISLOCALCHAT == false) then
        return true, false
    end

    if (GetRoundState() ~= ROUND_ACTIVE) then
        return true, false
    end

    return false, false
end

function ShowVersion( ply )
    SendMsg( ply, "Morbus " .. GM_VERSION )
end

local function SwitchVoice( ply )
    if ply:IsSuperAdmin() then
        ISLOCALCHAT = not ISLOCALCHAT
        SendAll( "OOC Voice Chat Disabled: " .. tostring( ISLOCALCHAT ) )
    end
end
concommand.Add( "Switch_Voice", SwitchVoice )

local function SwitchChat( ply )
    if ply:IsSuperAdmin() then
        NO_OOCCHAT = not NO_OOCCHAT
        SendAll( "OOC Text Chat Disabled: " .. tostring( NO_OOCCHAT ) )
    end
end
concommand.Add( "Switch_Chat", SwitchChat )

local function SendAlienVoiceState( speaker, state )
    local rf = AlienFilter()

    umsg.Start( "avstate", rf )
    umsg.Short( speaker:EntIndex() )
    umsg.Bool( state )
    umsg.End()
end

function SetAlienVoiceState( ply, cmd, args )
    if not IsValid( ply ) or not ply:IsActiveAlien() then return end

    if not #args == 1 then return end

    local state = tonumber( args[ 1 ] )

    ply.alien_voice = (state == 1)

    SendAlienVoiceState( ply, ply.alien_voice )
end

concommand.Add( "morbus_alien_voice", SetAlienVoiceState )

function AlienChatMsg( sender, str )
    umsg.Start( "alien_chat", AlienFilter() )
    umsg.Entity( sender )
    umsg.String( str )
    umsg.End()
end

function ToggleSpec( ply )
    ply.WantsSpec = not ply.WantsSpec
    local msg = "You will now remain a spectator"

    if not ply.WantsSpec then
        msg = "You can now respawn"
    end

    ply:SetRole( ROLE_SWARM )
    SendMsg( ply, msg )
    ply:MakeSpec()
    ply:Kill()
end

function TestSpec( ply )
    ply:SetRole( ROLE_SWARM )
    ply:MakeSpec( true )
    ply:Kill()
end

--[[
UTILITY FILTERS
--]]
function GetPlayerFilter( req )
    local filter = RecipientFilter()
    for k, v in player.Iterator() do
        if IsValid( v ) and req( v ) then
            filter:AddPlayer( v )
        end
    end

    return filter
end
