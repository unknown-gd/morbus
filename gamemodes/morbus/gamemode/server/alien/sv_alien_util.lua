-- Morbus - morbus.remscar.com
-- Developed by Remscar and the Morbus dev team

--[[
SEND ALIENS
--]]
function RevealAll()
    local brood = GetBroodList()
    local swarm = GetSwarmList()
    for k, v in pairs( brood ) do
        SendOtherPlayerRole( ROLE_BROOD, v, HumanFilter() )
    end

    for k, v in pairs( swarm ) do
        SendOtherPlayerRole( ROLE_SWARM, v, HumanFilter() )
    end
end

function RevealAllCyborgs()
    local cyborg = GetCyborgList()
    for k, v in pairs( cyborg ) do
        SendOtherPlayerRole( ROLE_CYBORG, v, PlayerFilter() )
    end
end

function UpdateAliens()
    local brood = GetBroodList()
    local swarm = GetSwarmList()

    for k, v in pairs( brood ) do
        SendOtherPlayerRole( ROLE_BROOD, v, AlienFilter() )
        v:SendEvoPoints()
        v:SendUpgrades()
    end

    --SEND SWARM ALIENS
    for k, v in pairs( swarm ) do
        SendOtherPlayerRole( ROLE_SWARM, v, AlienFilter() )
    end
end

function NewAlien( ply, role )
    if not IsValid( ply ) then return end

    if ply:Team() == TEAM_SPEC then
        ply:SetTeam( TEAM_GAME )
        ply:UnSpectate()
        ply:SpectateEntity( nil )
        ply:SetRole( ROLE_SWARM )
        ply:SetPos( GAMEMODE:PlayerSelectSpawn( ply ):GetPos() )
        ply:Spawn()
    else
        AlienMsg( AlienFilter(), ply:GetFName( true ) .. " is now a " .. GetRoleName( role ) )
    end

    if role then
        if ply:GetRole() ~= role then
            ply:SetRole( role )
        end
    end

    SendPlayerRole( role, ply )
    ply.Mission = MISSION_KILL
    ply:SendMission()
    UpdateAliens()

    if (role == ROLE_BROOD) then
        if (Swarm_Respawns < 0) then Swarm_Respawns = 0 end

        Swarm_Respawns = Swarm_Respawns + SWARM_SPAWNS_BONUS
        SetGlobalInt( "morbus_swarm_spawns", Swarm_Respawns )
    end

    if (role == ROLE_SWARM) then
        if (Swarm_Respawns > 0) or GetRoundState() == ROUND_EVAC then
            if GetRoundState() == ROUND_ACTIVE then
                Swarm_Respawns = Swarm_Respawns - 1
                SetGlobalInt( "morbus_swarm_spawns", Swarm_Respawns )
            end

            ply.NextSpawnTime = CurTime() + 6
        else
            ply:MakeSpec()
            ply.NextSpawnTime = CurTime() + 1
        end
    end
end

function BroodInfected( ply )
    local up = CalcUpgrade()
    Total_Evolution_Points = Total_Evolution_Points + up

    AlienMsg( BroodFilter(), "You have gained " .. (up) .. " upgrade points!" )

    for k, v in player.Iterator() do
        if IsValid( v ) and v:IsBrood() then
            v.Evo_Points = v.Evo_Points + up
        end
    end

    ply:LightReset()
    if ply:IsCyborg() then
        NewAlien( ply, ROLE_SWARM )
    else
        ply.Evo_Points = Total_Evolution_Points
        NewAlien( ply, ROLE_BROOD )
    end
end

function SwarmInfected( ply )
    NewAlien( ply, ROLE_SWARM )
end

function AlienFilter()
    return GetPlayerFilter( function( p ) return p:IsAlien() end )
end

function BroodFilter()
    return GetPlayerFilter( function( p ) return p:IsBrood() end )
end

function HumanFilter()
    return GetPlayerFilter( function( p ) return not p:IsAlien() end )
end

function CyborgFilter()
    return GetPlayerFilter( function( p ) return p:IsCyborg() end )
end

function PlayerFilter()
    return GetPlayerFilter( function( p ) return IsValid( p ) end )
end

---@return Player[]
function GetPlayerList()
    local trs = {}
    for k, v in player.Iterator() do
        if IsValid( v ) and v:IsGame() then table.insert( trs, v ) end
    end

    return trs
end

---@return Player[]
function GetAlienList()
    local trs = {}
    for k, v in player.Iterator() do
        if v:IsAlien() and v:IsGame() then table.insert( trs, v ) end
    end

    return trs
end

---@return Player[]
function GetHumanList()
    local trs = {}
    for k, v in player.Iterator() do
        if not v:IsAlien() and v:IsGame() then table.insert( trs, v ) end
    end

    return trs
end

---@return Player[]
function GetCyborgList()
    local trs = {}
    for k, v in player.Iterator() do
        if v:IsCyborg() and v:IsGame() then table.insert( trs, v ) end
    end

    return trs
end

---@return Player[]
function GetSpectatorList()
    local trs = {}
    for k, v in player.Iterator() do
        if not v:IsGame() then table.insert( trs, v ) end
    end

    return trs
end

---@return Player[]
function GetSwarmList()
    local trs = {}

    for k, v in player.Iterator() do
        if v:IsSwarm() and v:IsGame() then table.insert( trs, v ) end
    end

    return trs
end

---@return Player[]
function GetBroodList()
    local trs = {}
    for k, v in player.Iterator() do
        if v:IsBrood() then table.insert( trs, v ) end
    end

    return trs
end
