-- Morbus - morbus.remscar.com
-- Developed by Remscar
-- and the Morbus dev team
--[[
ROLE SELECTION
--]]


local function GetBroodCount( ply_count )
    if ply_count < 12 then
        return 1
    elseif ply_count >= 12 and ply_count < 18 then
        return 2
    elseif ply_count >= 18 and ply_count < 25 then
        return 3
    else
        return 4
    end
end

local function GetCyborgCount( ply_count )
    if ply_count < 15 then
        return 1
    elseif ply_count >= 15 then
        return 2
    end
end

local function SendRoles()
    for k, v in player.Iterator() do
        if IsValid( v ) then
            SendPlayerRole( v:GetRole(), v )
        end
    end
end

LAST_ALIEN = {}
local Allow_Bots = true
function SelectRoles()
    local choices = {}
    local all_players = player.GetAll()
    local total = #all_players

    for k, v in pairs( all_players ) do
        if IsValid( v ) and v:IsGame() then
            if (Allow_Bots and v:IsBot()) or not v:IsBot() then
                if v:GetBaseSanity() > 500 then
                    table.insert( choices, v )
                end
            end
        end

        v:SetRole( ROLE_HUMAN )
    end

    local la = {}

    local brood_count = GetBroodCount( total )
    local cyborg_count = GetCyborgCount( total )

    if total == 0 then
        print( "Error in role selection. #001\n" )
        return
    end

    local ts = 0
    while ts < brood_count do
        local pick = math.random( 1, #choices )

        local pply = choices[ pick ]
        local pass = false

        if table.HasValue( LAST_ALIEN, pply ) then
            if math.random( 1, 5 ) < 2 then
                pass = true
            end
        else
            pass = true
        end

        if IsValid( pply ) and (pass == true) then
            pply:SetRole( ROLE_BROOD )
            pply.Mission = MISSION_KILL
            pply:SendMission()
            table.remove( choices, pick )
            ts = ts + 1
            RoundHistory[ "First" ][ ts ] = pply
            pply.Evo_Points = STARTING_EVOLUTION_QUEEN
            table.insert( la, pply )
        end
    end

    local ts_c = 0
    while ts_c < cyborg_count and total >= 5 do
        local npick = math.random( 1, #choices )
        local nply = choices[ npick ]
        -- Rare Cyborg Selection
        if not nply:IsBrood() then
            nply:Cyborgify()
            ts_c = ts_c + 1
        end

        table.remove( choices, npick )
    end

    for k, v in player.Iterator() do
        v:ChatPrint( "The game has started with " .. (ts_c) .. " Cyborgs, " .. (ts) .. " Brood mothers." )
    end

    LAST_ALIEN = table.Copy( la )

    SendRoles()
    RevealAllCyborgs()
    UpdateAliens( true )
end
