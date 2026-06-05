--Utility

function SendAll( msg )
    for k, v in player.Iterator() do
        v:PrintMessage( 3, msg )
    end
end

function SendMsg( ply, msg )
    ply:PrintMessage( 3, msg )
end

function SendMsgCenter( ply, msg )
    ply:PrintMessage( 4, msg )
end

function WhoIsPlayer( name )
    if not name then return end

    local match = nil
    for k, v in player.Iterator() do
        if (v:GetFName() == name) then
            return match
        end
    end

    if not match then return false end
end

function util.AverageSanity()
    local cnt = player.GetCount()
    local sanity = 0
    for k, v in player.Iterator() do
        sanity = sanity + v:GetBaseSanity()
    end

    return sanity / cnt
end
