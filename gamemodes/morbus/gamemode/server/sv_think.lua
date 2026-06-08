-- eh
-- to be done later

GMNextThink = 0


---@param aliens Player[]
local function CheckMovement( aliens )
    for _, v in ipairs( aliens ) do
        if v:KeyDown( IN_FORWARD ) or v:KeyDown( IN_BACK ) or v:KeyDown( IN_JUMP ) or v:KeyDown( IN_LEFT ) or v:KeyDown( IN_RIGHT ) or v:KeyDown( IN_ATTACK ) then
            if v:Crouching() and v.Upgrades[ UPGRADE.INVISIBLE_EXTRA ] and v.Upgrades[ UPGRADE.INVISIBLE_EXTRA_EXTRA ] then

            else
                v.Moving = true
                v.OldPos = v:GetPos()
                Cancel_Cloak( v )
            end
        elseif v:OnGround() then
            v.Moving = false
            v.OldPos = v:GetPos()
        end
    end
end


function GM:Think()
    if GMNextThink <= CurTime() then
        local aliens = GetBroodList()
        CheckAlien( aliens )           -- Found in sv_brood.lua
        CheckMission( GetHumanList() ) -- sv_missions.lua
        CheckMovement( aliens )        -- below
        GMNextThink = CurTime() + 0.08
    end
end
