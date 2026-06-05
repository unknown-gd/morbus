-- Morbus - morbus.remscar.com
-- Developed by Remscar and the Morbus dev team
--[[
PLAYER HUD
--]]

local trans = 0
local maxtrans = 140

function ScaleH( num )
    return num * (ScrH() / 2048)
end

function ScaleW( num )
    return num * (ScrW() / 2560)
end

function ScaleH( num )
    return num * (ScrH() / 2048)
end

function IScaleW( num )
    return num * (2560 / ScrW())
end

function IScaleH( num )
    return num * (2048 / ScrH())
end

local fonts = {}

local function get_font( size, font, weight )
    font = "DeadSpaceTitleFont" -- font or "morbus"
    fonts[ font ] = fonts[ font ] or {}
    size = ScaleH( size )

    local id = size .. (weight or "normal")
    if fonts[ font ][ id ] then
        return fonts[ font ][ id ]
    end

    font = "DeadSpaceTitleFont"
    local name = font .. id
    surface.CreateFont( name, {
        font = font,
        size = size,
        weight = weight
    } )

    fonts[ font ][ id ] = name

    return name
end

local tex = surface.GetTextureID( "vgui/morbus/HPBar" )
local tex2 = surface.GetTextureID( "vgui/morbus/HPBarCover" )
hook.Add( "HUDPaint", "HUDPaint_DrawABox", function()
    local ply = LocalPlayer()
    -- Scoreboard stuff
    if SB_status then return end

    local status = not SB_status

    if status and trans < maxtrans then
        trans = math.Clamp( trans + 9, 0, maxtrans )
    elseif status == false and trans > 0 then
        trans = math.Clamp( trans - 9, 0, maxtrans )
    end

    local ftrans = 0
    local mul = math.sin( RealTime() ) / 6 + math.cos( RealTime() ) / 6
    if trans > 0 then
        ftrans = math.Clamp( trans + (trans * (mul)), trans - 50, trans + 50 )
    end

    if status == false then
        ftrans = trans
    end

    local HumanR, HumanG, HumanB = 40, 220, 235

    local oneW = ScaleW( 1 )
    local twoW = ScaleW( 2 )
    local fourW = ScaleW( 4 )

    local oneH = ScaleH( 1 )
    local twoH = ScaleH( 2 )
    local fourH = ScaleH( 4 )
    local base = 1948

    local x = ScaleW( 00 )
    local y = ScaleH( base )
    local w = ScaleW( 500 )
    local h = ScaleH( 50 )

    surface.SetDrawColor( HumanR, HumanG, HumanB, ftrans )
    surface.SetTexture( tex )
    surface.DrawTexturedRect( x, y, w, h )

    local hp = ply:Health()
    local ah = 0

    if ply:IsBrood() and ply:GetNWBool( "alienform", false ) then
        if Morbus.Upgrades[ UPGRADE.HEALTH ] then
            ah = Morbus.Upgrades[ UPGRADE.HEALTH ] or 0
        end
    end

    local health = 100

    if ply:IsSwarm() then
        health = 80
    end

    local hpmax = health + (ah * UPGRADE.HEALTH_AMOUNT)
    local ratio = math.Clamp( hp / hpmax, 0, 1 )
    surface.SetDrawColor( 0, 255, 0, ftrans + 100 )
    surface.DrawRect( x + twoW, y + twoH, w * ratio - fourW, h - fourH )
    surface.SetDrawColor( HumanR, HumanG, HumanB, 100 )
    surface.SetTexture( tex2 )
    surface.DrawTexturedRect( x + oneW, y + oneH, w - twoW, h - twoH )

    draw.SimpleTextOutlined( ply:GetFName() or "", get_font( 45, "morbus_small", "normal" ), x + (w / 2), y + (h / 2),
        Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color( 0, 0, 0, 200 ) )


    --------------STATUS BAR
    -- w = ScaleW(500)
    -- h = ScaleH(50)
    --x,y =ScaleW(50), ScaleH(1850)

    y = ScaleH( base + 50 )
    surface.SetDrawColor( HumanR, HumanG, HumanB, ftrans )
    surface.SetTexture( tex )
    surface.DrawTexturedRect( x, y, w, h )


    if GetRoundState() == ROUND_WAIT then
        draw.SimpleTextOutlined( "Deathmatch", get_font( 45, "morbus_small", "normal" ), x + (w / 2), y + (h / 2),
            Color( 200, 55, 55, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color( 95, 50, 50, 255 ) )
    else
        draw.SimpleTextOutlined( ply:GetRoleName(), get_font( 65, "morbus_small", "normal" ), x + (w / 2), y + (h / 2),
            Color( 55, 255, 55, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color( 50, 50, 50, 255 ) )
    end

    -------------- BATTERY

    -- w = ScaleW(500)
    -- h = ScaleH(50)
    -- x,y =ScaleW(50), ScaleH(1750) -- *(ScrH()/2048)

    y = ScaleH( base - 50 )
    surface.SetDrawColor( 0, 240, 240, ftrans )
    surface.SetTexture( tex )
    surface.DrawTexturedRect( x, y, w, h )


    ratio = math.Clamp( ply.Battery / LIGHT_BATTERY, 0, 1 )

    surface.SetDrawColor( 200, 220, 35, ftrans )
    surface.SetTexture( tex )
    surface.DrawRect( x + twoW, y + twoH, ratio * w - fourW, h - fourH )

    surface.SetDrawColor( HumanR, HumanG, HumanB, ftrans - 20 )
    surface.SetTexture( tex2 )
    surface.DrawTexturedRect( x + oneW, y + oneH, w - twoW, h - twoH )

    -- TIMER

    w = ScaleW( 200 )
    h = ScaleH( 100 )
    x, y = ScaleW( 2560 / 2 ) - w / 2, ScaleH( 2 )
    surface.SetDrawColor( HumanR, HumanG, HumanB, ftrans )
    surface.SetTexture( tex )
    surface.DrawTexturedRect( x, y, w, h )
    local rawend = GetGlobalFloat( "morbus_round_end", 0 )
    local roundend = string.FormattedTime( rawend - CurTime(), "%02i:%02i" )
    if not rawend or (rawend and rawend <= CurTime()) then roundend = "00:00" end

    draw.SimpleTextOutlined( roundend, get_font( 65, "morbus_small", "normal" ), x + (w / 2), y + (h / 2) - twoH,
        Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color( 50, 50, 50, 255 ) )


    -- ROUND STATE
    w = ScaleW( 200 )
    h = ScaleH( 75 )
    x, y = ScaleW( 2560 / 2 ) - w / 2, ScaleH( 100 + 4 )

    surface.SetDrawColor( HumanR, HumanG, HumanB, ftrans )
    surface.SetTexture( tex )
    surface.DrawTexturedRect( x, y, w, h )
    draw.SimpleTextOutlined( ROUND_TEXT[ GetRoundState() ], get_font( 25, "morbus_tiny", "normal" ), x + (w / 2),
        y + (h / 2) - oneH, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color( 50, 50, 50, 255 ) )


    -- MISSION BAR @ TOP
    w = ScaleW( 400 )
    h = ScaleH( 125 )

    x, y = ScaleW( 0 ), ScaleH( 2 )

    surface.SetDrawColor( HumanR, HumanG, HumanB, ftrans )
    surface.SetTexture( tex )
    surface.DrawTexturedRect( x, y, w, h )
    local Mission_End = Morbus.Mission_End - CurTime()
    local Mission_Color = Color( 255, 255, 255, 255 )
    if Mission_End < 0 and Morbus.Mission ~= MISSION_NONE and Morbus.Mission ~= MISSION_KILL and Morbus.Mission ~= MISSION_PURGE then
        Mission_Color = Color( 255, 20, 20, 255 )
    end

    draw.SimpleTextOutlined( GetMissionTitle( Morbus.Mission ), get_font( 50, "morbus_small", "normal" ), x + (w * 1.3 / 3),
        y + (h / 2) - fourH, Mission_Color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color( 50, 50, 50, 255 ) )

    Mission_End = math.ceil( Mission_End )
    if Mission_End < 0 then Mission_End = "" else Mission_End = math.abs( Mission_End ) end

    if Morbus.Mission == 0 then Mission_End = "" end

    if ply:GetRole() ~= ROLE_HUMAN then Mission_End = "" end

    draw.SimpleTextOutlined( Mission_End, get_font( 50, "morbus_small", "normal" ), x + (w * 4.1 / 5), y + (h / 2) - fourH,
        Mission_Color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color( 50, 50, 50, 255 ) )

    w = ScaleW( 64 )
    h = ScaleH( 64 )

    x, y = ScaleW( 8 ), ScaleH( 2 )

    if not ply:IsBrood() or (ply:IsBrood() and Morbus.CanTransform) then
        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetTexture( MissionIcon[ Morbus.Mission + 1 ] )
        surface.DrawTexturedRect( x, y + h / 2 - ScaleH( 1 ), w, h )
    end
end )


local function MainPlayerHud()
    if not HUD_DEBUG[ 2 ] then return end

    local ply = LocalPlayer()


    -- Scoreboard stuff

    local status = not SB_status

    if status and trans < maxtrans then
        trans = math.Clamp( trans + 9, 0, maxtrans )
    elseif status == false and trans > 0 then
        trans = math.Clamp( trans - 9, 0, maxtrans )
    end

    local ftrans = 0
    local mul = math.sin( RealTime() ) / 6 + math.cos( RealTime() ) / 6
    if trans > 0 then
        ftrans = math.Clamp( trans + (trans * (mul)), trans - 50, trans + 50 )
    end

    --Positioning

    -- local HumanR, HumanG, HumanB = 40, 220, 235
    -- local AlienR, AlienG, AlienB = 255, 55, 55

    -- if not GetConVar( "morbus_alienhud_purple" ):GetBool() then
    --     AlienR = 255
    --     AlienG = 55
    --     AlienB = 55
    -- else
    --     AlienR = 215
    --     AlienG = 55
    --     AlienB = 255
    -- end

    local ang = EyeAngles()
    -- local pos = EyePos() + ang:Forward() * 50

    if trans > 0 then
        ang:RotateAroundAxis( ang:Right(), 90 )
        ang:RotateAroundAxis( ang:Up(), -90 )
        ang:RotateAroundAxis( ang:Right(), -20 )



        -- if not (ply:Team() == TEAM_SPEC) then

        -- cam.Start3D2D( pos, ang, 0.0585 )
        -- cam.IgnoreZ(true)


        -- --------------HP BAR

        -- local wt = 336
        -- local h = 34
        -- local x = -wt-130
        -- local y = 310
        -- if ply:IsAlien() then
        -- if not GetConVar("morbus_alienhud_disable"):GetBool() then
        -- surface.SetDrawColor( AlienR, AlienG, AlienB, ftrans )
        -- surface.SetTexture( tex )
        -- surface.DrawTexturedRect( x,y, wt, h )
        -- else
        -- surface.SetDrawColor( HumanR, HumanG, HumanB, ftrans )
        -- surface.SetTexture( tex )
        -- surface.DrawTexturedRect( x,y, wt, h )
        -- end
        -- else
        -- surface.SetDrawColor( HumanR, HumanG, HumanB, ftrans )
        -- surface.SetTexture( tex )
        -- surface.DrawTexturedRect( x,y, wt, h )
        -- end
        -- local hp = ply:Health()
        -- local ah = 0

        -- if ply:IsBrood() and ply:GetNWBool("alienform",false) then
        -- if Morbus.Upgrades[UPGRADE.HEALTH] then
        -- ah = Morbus.Upgrades[UPGRADE.HEALTH] or 0
        -- end
        -- end
        -- health = 100
        -- if ply:IsSwarm() then
        -- health=80
        -- end
        -- local hpmax = health+( ah * UPGRADE.HEALTH_AMOUNT)
        -- local ratio = math.Clamp(hp/hpmax,0,1)

        -- surface.SetDrawColor( 0, 255, 0, ftrans+100 );
        -- surface.DrawRect(x+2,y+2,wt*ratio-4,h-4)

        -- if ply:IsAlien() then
        -- if not GetConVar("morbus_alienhud_disable"):GetBool() then
        -- surface.SetDrawColor( AlienR, AlienG, AlienB, 100 )
        -- surface.SetTexture( tex )
        -- surface.DrawTexturedRect( x,y, wt, h )
        -- else
        -- surface.SetDrawColor( HumanR, HumanG, HumanB, 100 )
        -- surface.SetTexture( tex )
        -- surface.DrawTexturedRect( x,y, wt, h )
        -- end
        -- else
        -- surface.SetDrawColor( HumanR, HumanG, HumanB, 100 )
        -- surface.SetTexture( tex2 )
        -- surface.DrawTexturedRect(x+1,y+1,wt-2,h-2)
        -- end

        -- wt = 336

        -- draw.SimpleTextOutlined(ply:GetFName() or "","DSMedium",x+(wt/2),y+(h/2)-2,Color(125,125,125, trans),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,2,Color(0,0,0,200))




        -- --------------STATUS BAR
        -- w = 336
        -- h = 34
        -- x,y = -w-130,345

        -- if ply:IsAlien() then
        -- if not GetConVar("morbus_alienhud_disable"):GetBool() then
        -- surface.SetDrawColor( AlienR, AlienG, AlienB, ftrans )
        -- surface.SetTexture( tex )
        -- surface.DrawTexturedRect( x,y, w, h )
        -- else
        -- surface.SetDrawColor( HumanR, HumanG, HumanB, ftrans )
        -- surface.SetTexture( tex )
        -- surface.DrawTexturedRect( x,y, w, h )
        -- end
        -- else
        -- surface.SetDrawColor( HumanR, HumanG, HumanB, ftrans )
        -- surface.SetTexture( tex )
        -- surface.DrawTexturedRect( x,y, w, h )
        -- end

        -- if GetRoundState() == ROUND_WAIT then
        -- draw.SimpleTextOutlined("Deathmatch","DSHuge",x+(w/2),y+(h/2)-2,Color(200,55,55, trans),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,2,Color(95,50,50,255))
        -- else
        -- draw.SimpleTextOutlined(ply:GetRoleName(),"DSHuge",x+(w/2),y+(h/2)-2,Color(55,255,55, trans),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,2,Color(50,50,50,255))
        -- end
        -- w = 240
        -- h = 22
        -- x,y = -w-190,285



        -- -------------- BATTERY

        -- if not GetGlobalBool("mutator_nightmare",false) and not ply:IsSwarm() then

        -- surface.SetDrawColor( 0, 240, 240, ftrans );
        -- surface.SetTexture( tex );
        -- surface.DrawTexturedRect( x,y, w, h );


        -- local ratio = math.Clamp(ply.Battery/LIGHT_BATTERY,0,1)

        -- surface.SetDrawColor( 200, 220, 35, ftrans );
        -- surface.SetTexture( tex );
        -- surface.DrawRect( x+2,y+2, ratio*w-4, h-4 );

        -- if ply:IsAlien() then
        -- if not GetConVar("morbus_alienhud_disable"):GetBool() then
        -- surface.SetDrawColor( AlienR, AlienG, AlienB, ftrans )
        -- surface.SetTexture( tex2 );
        -- surface.DrawTexturedRect(x+1,y+1,w-2,h-2)
        -- else
        -- surface.SetDrawColor( HumanR, HumanG, HumanB, ftrans )
        -- surface.SetTexture( tex2 );
        -- surface.DrawTexturedRect(x+1,y+1,w-2,h-2)
        -- end
        -- else
        -- surface.SetDrawColor( HumanR, HumanG, HumanB, ftrans-20 )
        -- surface.SetTexture( tex2 );
        -- surface.DrawTexturedRect(x+1,y+1,w-2,h-2)
        -- if LocalPlayer():IsCyborg() then
        -- draw.SimpleTextOutlined( "INFINITE", "DSSmall", x+125, y+10, Color(0,0,0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 5, Color(155,255,155,155) )
        -- end
        -- end
        -- end


        -- cam.End3D2D()
        -- end



        local ang = EyeAngles()
        local pos = EyePos() + ang:Forward() * 50

        ang:RotateAroundAxis( ang:Right(), 110 )
        ang:RotateAroundAxis( ang:Up(), -90 )

        -- cam.Start3D2D(pos,ang,0.0585)
        -- cam.IgnoreZ(true)


        -- w = 180
        -- h = 34
        -- x,y = -90,-414

        -- if ply:IsAlien() then
        -- if not GetConVar("morbus_alienhud_disable"):GetBool() then
        -- surface.SetDrawColor( AlienR, AlienG, AlienB, ftrans )
        -- surface.SetTexture( tex )
        -- surface.DrawTexturedRect( x,y, w, h )
        -- else
        -- surface.SetDrawColor( HumanR, HumanG, HumanB, ftrans )
        -- surface.SetTexture( tex )
        -- surface.DrawTexturedRect( x,y, w, h )
        -- end
        -- else
        -- surface.SetDrawColor( HumanR, HumanG, HumanB, ftrans )
        -- surface.SetTexture( tex )
        -- surface.DrawTexturedRect( x,y, w, h )
        -- end
        -- local rawend = GetGlobalFloat("morbus_round_end", 0)
        -- local roundend = string.FormattedTime(rawend - CurTime(), "%02i:%02i")
        -- if not rawend or ( rawend and rawend <= CurTime()) then roundend = "00:00" end

        -- draw.SimpleTextOutlined(roundend,"DSHuge",x+(w/2),y+(h/2)-2,Color(200,200,200, trans),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,2,Color(50,50,50,trans))


        -- w = 128
        -- h = 16
        -- x,y = -64,-379

        -- if ply:IsAlien() then
        -- if not GetConVar("morbus_alienhud_disable"):GetBool() then
        -- surface.SetDrawColor( AlienR, AlienG, AlienB, ftrans )
        -- surface.SetTexture( tex )
        -- surface.DrawTexturedRect( x,y, w, h )
        -- else
        -- surface.SetDrawColor( HumanR, HumanG, HumanB, ftrans )
        -- surface.SetTexture( tex )
        -- surface.DrawTexturedRect( x,y, w, h )
        -- end
        -- else
        -- surface.SetDrawColor( HumanR, HumanG, HumanB, ftrans )
        -- surface.SetTexture( tex )
        -- surface.DrawTexturedRect( x,y, w, h )
        -- end
        -- draw.SimpleTextOutlined(ROUND_TEXT[GetRoundState()],"DSTiny",x+(w/2),y+(h/2)-1,Color(200,200,200, trans),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,2,Color(50,50,50, trans))


        -- if not (ply:Team() == TEAM_SPEC) and not (ply:IsSwarm()) then
        -- -- MISSION BAR @ TOP
        -- w = 220
        -- h = 34

        -- x,y = -400,-414

        -- if ply:IsAlien() then
        -- if not GetConVar("morbus_alienhud_disable"):GetBool() then
        -- surface.SetDrawColor( AlienR, AlienG, AlienB, ftrans )
        -- surface.SetTexture( tex )
        -- surface.DrawTexturedRect( x,y, w, h )
        -- else
        -- surface.SetDrawColor( HumanR, HumanG, HumanB, ftrans )
        -- surface.SetTexture( tex )
        -- surface.DrawTexturedRect( x,y, w, h )
        -- end
        -- else
        -- surface.SetDrawColor( HumanR, HumanG, HumanB, ftrans )
        -- surface.SetTexture( tex )
        -- surface.DrawTexturedRect( x,y, w, h )
        -- end

        -- local Mission_End = Morbus.Mission_End - CurTime()
        -- local Mission_Color = Color(255,255,255, trans)
        -- if Mission_End < 0 and Morbus.Mission ~= MISSION_NONE and Morbus.Mission ~= MISSION_KILL  and Morbus.Mission ~= MISSION_PURGE then Mission_Color = Color(255,20,20,255)
        -- end

        -- draw.SimpleTextOutlined(GetMissionTitle(Morbus.Mission),"DSLarge",x+(w*1.2/3),y+(h/2)-1,Mission_Color,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,2,Color(50,50,50,255))

        -- Mission_End = math.ceil(Mission_End)
        -- if Mission_End < 0 then Mission_End = "" else Mission_End = math.abs(Mission_End) end
        -- if Morbus.Mission == 0 then Mission_End = "" end
        -- if ply:GetRole() ~= ROLE_HUMAN then Mission_End = "" end

        -- draw.SimpleTextOutlined(Mission_End,"DSMedium",x+(w*4/5),y+(h/2)-1,Color(200,200,200, ftrans),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,2,Color(50,50,50, trans))

        -- if (ply:IsBrood()) then
        -- local respawns = tostring(GetGlobalInt("morbus_swarm_spawns",0))

        -- draw.SimpleTextOutlined(respawns,"DSMedium",x+(w*4/5),y+(h/2)-1,Color(200,200,200, ftrans),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,2,Color(50,50,50, trans))
        -- end

        -- w = 32
        -- h = 31
        -- x,y = -400+4,-412

        -- if not ply:IsBrood() or (ply:IsBrood() and Morbus.CanTransform) then
        -- surface.SetDrawColor( 255, 255, 255, ftrans );
        -- surface.SetTexture( MissionIcon[Morbus.Mission+1]);
        -- surface.DrawTexturedRect( x,y, w, h );
        -- end

        -- else
        -- w = 220
        -- h = 34

        -- x,y = -400,-414


        -- if ply:IsAlien() then
        -- if not GetConVar("morbus_alienhud_disable"):GetBool() then
        -- surface.SetDrawColor( AlienR, AlienG, AlienB, trans )
        -- surface.SetTexture( tex )
        -- surface.DrawTexturedRect( x,y, w, h )
        -- else
        -- surface.SetDrawColor( HumanR, HumanG, HumanB, trans )
        -- surface.SetTexture( tex )
        -- surface.DrawTexturedRect( x,y, w, h )
        -- end
        -- else
        -- surface.SetDrawColor( HumanR, HumanG, HumanB, trans )
        -- surface.SetTexture( tex )
        -- surface.DrawTexturedRect( x,y, w, h )
        -- end
        -- draw.SimpleTextOutlined("LIVES:","DSLarge",x+(w*1.2/3),y+(h/2)-1,Mission_Color,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,2,Color(50,50,50,255))

        -- local respawns = tostring(GetGlobalInt("morbus_swarm_spawns",0))

        -- draw.SimpleTextOutlined(respawns,"DSMedium",x+(w*4/5),y+(h/2)-1,Color(200,200,200, trans),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,2,Color(50,50,50, ftrans))

        -- w = 32
        -- h = 31
        -- x,y = -400+4,-412

        -- surface.SetDrawColor( 255, 255, 255, ftrans );
        -- surface.SetTexture( MissionIcon[6]);
        -- surface.DrawTexturedRect( x,y, w, h );
        -- end


        -- cam.IgnoreZ(false)
        -- cam.End3D2D()
    end
end

hook.Add( "PostDrawTranslucentRenderables", "HoloHud", MainPlayerHud )
