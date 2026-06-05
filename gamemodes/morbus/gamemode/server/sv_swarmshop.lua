-- SwarmShop v2 -- Public Release --
-- Created by Demonkush -- www.xmpstudios.com --

-- Buy Command
concommand.Add( "SwarmBuyMod", function( ply, cmd, args )
    if not ply:IsSwarm() then
        ply:PrintMessage( HUD_PRINTTALK, "You aren't a Swarm Alien!" )
        return
    end

    local id = tonumber( args[ 1 ] )

    local vipgroups = { "vip", "donor", "donator" }
    local admingroups = { "admin", "superadmin", "owner" }

    local isvip = false
    local isadmin = false

    if table.HasValue( vipgroups, ply:GetUserGroup() ) then
        isvip = true
    end

    if table.HasValue( admingroups, ply:GetUserGroup() ) then
        isadmin = true
    end

    local name = ""
    local cost = 0

    local old = ply:GetSwarmMod()
    local oldcost = 0

    -- Matches given ID to table for security.
    for a, b in pairs( SwarmShop.Abilities ) do
        if b.id == id then
            name = b.name
            cost = b.price
        end

        if b.id == old then
            oldcost = b.price
        end
    end

    local function SwarmRefund()
        local refund = oldcost
        if SwarmShop.RefundMultiplier > 0 then
            if oldcost == 0 then
                -- do nothing
            else
                refund = math.Round( refund * SwarmShop.RefundMultiplier )
                if SwarmShop.RefundMultiplier == 1 then
                    refund = oldcost
                end
            end
        end
    end

    -- Reset mod
    if id == 0 then
        ply:SetSwarmMod( 0 )
        ply:PrintMessage( HUD_PRINTTALK, "[Swarm Shop] Ability reset." )
        SwarmRefund()
        return
    end

    -- Already have this mod
    if ply:GetSwarmMod() == id then
        ply:PrintMessage( HUD_PRINTTALK, "[Swarm Shop] You already have this ability!" )
        return
    end

    -- Not enough points
    if (GetConVar( "morbus_roundtime" ):GetInt() * 60) - ((GetGlobalFloat( "morbus_round_end", 0 )) - CurTime()) < cost then
        ply:PrintMessage( HUD_PRINTTALK, "[Swarm Shop] You don't have enough Swarm Points!" )
        return
    end

    -- Successful purchase
    if (GetConVar( "morbus_roundtime" ):GetInt() * 60) - (GetGlobalFloat( "morbus_round_end", 0 ) - CurTime()) >= cost then
        --ply:SetSwarmPoints( ply:GetSwarmPoints() - cost )
        ply:SetSwarmMod( id )
        ply:PrintMessage( HUD_PRINTTALK, "[Swarm Shop] Successfully purchased: " .. name .. "!" )
    end

    SwarmRefund()
end )
