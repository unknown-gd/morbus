-- Morbus - morbus.remscar.com
-- Developed by Remscar and the Morbus dev team

----------------------------------INCLUDES
include( "shared.lua" )
for k, v in ipairs( file.Find( FOLDER_NAME .. "/gamemode/shared/*.lua", "LUA" ) ) do include( "shared/" .. v ) end

for k, v in ipairs( file.Find( FOLDER_NAME .. "/gamemode/client/vgui/*.lua", "LUA" ) ) do include( "client/vgui/" .. v ) end

for k, v in ipairs( file.Find( FOLDER_NAME .. "/gamemode/client/hud/*.lua", "LUA" ) ) do include( "client/hud/" .. v ) end

for k, v in ipairs( file.Find( FOLDER_NAME .. "/gamemode/client/sb/*.lua", "LUA" ) ) do include( "client/sb/" .. v ) end

for k, v in ipairs( file.Find( FOLDER_NAME .. "/gamemode/client/fx/*.lua", "LUA" ) ) do include( "client/fx/" .. v ) end

for k, v in ipairs( file.Find( FOLDER_NAME .. "/gamemode/client/*.lua", "LUA" ) ) do include( "client/" .. v ) end

------------------------------------------



----------------------------------DEFAULT VARIABLES
Morbus = {}
Morbus.Role = ROLE_NONE
Morbus.Weight = 0
Morbus.Mission = 0
Morbus.Mission_End = 0
Morbus.Mission_Doing = false
Morbus.Mission_Complete = 0
Morbus.Evo_Points = 0
Morbus.Upgrades = {}
Morbus.CanTransform = true

Round_Log = {}

---------------------------------------------------

ents.Create = ents.CreateClientProp


--[[
INIT
--]]
function GM:Initialize()
    game.AddParticles( "particles/xmp_morparts_9_2015.pcf" )
    MsgN( "Morbus Client Loading...\n" )
    ResetLog()
    GAMEMODE.Round_State = ROUND_WAIT
    SetupRoundHistory()
    concommand.Remove( "pp_pixelrender" )
    CreateConVar( "morbus_no_blood", 0 )
end

function GM:InitPostEntity()
    MsgN( "Morbus Client Post Init...\n" )
    RunConsoleCommand( "myinfo_bytes", "1024" )
    local ply = LocalPlayer()
    ply:ResetPlayer()
end

GMNextThink = 0
function GM:Think()
    if GMNextThink >= CurTime() then return end

    local client = LocalPlayer()
    WSWITCH:Think()

    if (client.NightVision == true and (client:IsSpec() or client:IsSwarm())) then
        NightVision()
    end

    if ((client:IsSwarm()) or (client:IsBrood()) == true) and client:Alive() then
        if HUD_DEBUG[ 10 ] then
            if (client.NightVision == true) or (client:GetNWBool( "alienform", false ) == true) then
                NightVision()
            end
        end
    end

    GMNextThink = CurTime() + 0.08
end

--[[
ROUND INFO
--]]
function GetRoundState()
    return GAMEMODE.Round_State
end

function SetupRoundHistory()
    RoundHistory = {}
    RoundHistory[ "Infect" ] = {}
    RoundHistory[ "Kill" ] = {}
    RoundHistory[ "First" ] = {}
end

function RoundStateChanged( old, new )
    if (new == ROUND_PREP) then
        GAMEMODE:ClearClientState()
        GAMEMODE:CleanUpMap()
        hook.Call( "MorbusPrepRound", GAMEMODE )
    elseif (new == ROUND_ACTIVE) then
        if RHISTORY_OBJ then
            RHISTORY_OBJ:Remove()
        end

        ResetLog()
        SetupRoundHistory()
        ActiveSound()
        hook.Call( "MorbusStartRound", GAMEMODE )
    elseif (new == ROUND_POST) then
        EndSound()
        hook.Call( "MorbusEndRound", GAMEMODE )
    end
end

function ActiveSound()
    if not GetConVar( "morbus_disable_music" ):GetBool() then
        local song = table.Random( MUSIC )
        local cur_round = GetGlobalInt( "morbus_rounds", 0 )
        surface.PlaySound( "music/" .. song[ 1 ] )
        timer.Simple( song[ 2 ], function()
            if cur_round == GetGlobalInt( "morbus_rounds", 0 ) then
                if GetRoundState() == ROUND_ACTIVE then
                    ActiveSound()
                end
            end
        end
        )
    end
end

function EndSound()
    if not GetConVar( "morbus_disable_music" ):GetBool() then
        if GetGlobalInt( "morbus_winner", WIN_HUMAN ) == WIN_HUMAN then
            surface.PlaySound( "music/" .. MUSIC_HUMAN_WIN )
        else
            surface.PlaySound( "music/" .. MUSIC_ALIEN_WIN )
        end
    end
end

--[[
Clean Up Map
--]]

-- Ragdolls sometimes stay around on clients. Deleting them can create issues
-- so all we can do is try to hide them.
function GM:CleanUpMap()
    for _, ent in ipairs( ents.FindByClass( "prop_ragdoll" ) ) do
        if IsValid( ent ) then
            ent:SetNoDraw( true )
            ent:SetSolid( SOLID_NONE )
            ent:SetColor( Color( 0, 0, 0, 0 ) )

            -- Horrible hack to make targetid ignore this ent, because we can't
            -- modify the collision group clientside.
            ent.NoTarget = true
        end
    end

    game.CleanUpMap()
end

function NoHudMode( ply, cmd, args )
    if #args == 1 then
        local a = tonumber( args[ 1 ] )
        if a == 1001 then
            for i = 1, 20 do
                HUD_DEBUG[ i ] = true
            end
        elseif a == 1002 then
            for i = 1, 20 do
                HUD_DEBUG[ i ] = false
            end
        else
            HUD_DEBUG[ a ] = not HUD_DEBUG[ a ]
        end
    elseif #args > 1 then
        for b = 1, #args do
            local a = tonumber( args[ b ] )
            HUD_DEBUG[ a ] = not HUD_DEBUG[ a ]
        end
    else
        MsgN( "1 - Effects" )
        MsgN( "2 - Main HUD" )
        MsgN( "3 - TargetID" )
        MsgN( "4 - Messages" )
        MsgN( "5 - Weapon Switch" )
        MsgN( "6 - Gun Display" )
        MsgN( "7 - Pickup History" )
        MsgN( "8 - Mission Alert" )
        MsgN( "9 - Round Alert" )
        MsgN( "10 - Night vision" )
        MsgN( "11 - Voice Windows" )
        MsgN( "12 - Spectator stuff" )
        MsgN( "13 - Alien Scent" )
        MsgN( "14 - Voice Indicators" )
        MsgN( "1001 - Show all HUD" )
        MsgN( "1002 - Hude all HUD" )
        MsgN( "Also morbus_mute_status for muting" )
        MsgN( "and morbus_toggle_chat" )
    end
end

concommand.Add( "morbus_toggle_hud", NoHudMode )


DChat = true
function TogChat()
    if DChat then
        hook.Add( "StartChat", "StartChat", function() return true end )
        hook.Add( "FinishChat", "FinishChat", function() return true end )
        MsgN(
            "The chat window will disapear soon, you can also press y/u and then enter to do it quickly.\nNote that if you press your chat button while chat is disabled, you will still be able to chat, you just dont see what you are saying." )
        DChat = false
    else
        hook.Remove( "StartChat", "StartChat" )
        hook.Remove( "FinishChat", "FinishChat" )
        DChat = true
    end
end

concommand.Add( "morbus_toggle_chat", TogChat )


--[[
TEST
--]]
