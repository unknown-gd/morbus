--[[
 * Weapon Information System
 * Created by Zignd (http://steamcommunity.com/id/zignd/)
 * Inspired by TTT Weapon Info created by Wolf Halez and available as paid stuff :(.
 * The Weapon Information System is not a source code copy of the TTT Weapon Info, I analysed how it works an built my own version from scratch.
 * The Weapon Information System is an open-source Garry's Mod addon and is available on Garry's Mod Workshop on Steam.
 *
 * Add me on Steam for contact.
 --]]

-- Modified by Demonkush
-- This is the MORBUS VARIANT: ONLY USE ON MORBUS

surface.CreateFont( "WpnInfoHead", {
    font = "Bebas Neue",
    size = 140,
    weight = 0,
    antialias = true
} )

surface.CreateFont( "WpnInfoBody", {
    font = "Bebas Neue",
    size = 100,
    weight = 0,
    antialias = true
} )

local wpninfo = {}
wpninfo.tttweaponnames =
{


}
wpninfo.fonts =
{

    head = "WpnInfoHead",
    body = "WpnInfoBody"

}
wpninfo.colors =
{

    background = Color( 5, 95, 175, 25 ),
    text = Color( 150, 200, 255, 255 )

}
wpninfo.infos =
{

    name = "N/A",
    damage = "N/A",
    clipsize = "N/A",
    storedammo = "N/A",
    spread = "0.00",
    recoil = "0",
    ammo = "N/A"


}

local function drawwpninfo()

    local x, y, width, height, panelwidth, panelheight, desc, padding, position, angle, scale, ammoname, wepammoname, togglestats, texture, color
    local ply = LocalPlayer()
    local wpn = ply:GetActiveWeapon()
    local ent = util.TraceLine(
        {

            start = ply:GetShootPos(),
            endpos = ply:GetShootPos() + (ply:GetAimVector() * 160),
            filter = ply,
            mask = MASK_SHOT_HULL

        } ).Entity

    local function getnewy( text )

        width, height = surface.GetTextSize( text )
        return y + height

    end

    if IsValid( ent ) then

        padding = 50
        angle = Angle( 0, ply:EyeAngles().y - 90, 90 )
        scale = 0.04
        if ent:IsWeapon() and ent:IsScripted() then

            -- Compatability
            togglestats = true
            lowinfo = GetConVar( "morbus_low_info" ):GetBool()
            if
                wpninfo.infos.name == "Glow Sticks" or
                wpninfo.infos.name == "Sticky Glow Sticks" or
                wpninfo.infos.name == "Grav Sticks" or
                wpninfo.infos.name == "Medkit" or
                wpninfo.infos.name == "Frag Grenade" or
                wpninfo.infos.name == "Vitamins"

            then
                togglestats = false

            end

            if wpninfo.tttweaponnames[ ent:GetPrintName() ] then
                wpninfo.infos.name = wpninfo.tttweaponnames[ ent:GetPrintName() ]

            else
                wpninfo.infos.name = ent:GetPrintName()

            end

            if togglestats == true then
                if ent.Primary.Damage ~= nil and ent.Primary.Damage > 1 then
                    wpninfo.infos.damage = ent.Primary.Damage or 0
                end

                if ent.Primary.ClipSize > 0 then
                    wpninfo.infos.clipsize = ent.Primary.ClipSize

                    if ent:Clip1() == -1 then
                        wpninfo.infos.currentclip = ent.Primary.ClipSize
                    else
                        wpninfo.infos.currentclip = ent:Clip1()
                    end

                end

                wpninfo.infos.storedammo = ent:GetNWInt( "StoredAmmo", 0 )
                wpninfo.infos.spread     = ent.Primary.Cone or 0
                wpninfo.infos.recoil     = ent.Primary.Recoil or 0
                wpninfo.infos.ammo       = ent.Primary.Ammo or 0
                wpninfo.infos.weight     = ent.KGWeight or 0

            end

            if string.len( wpninfo.infos.name ) > 14 then
                panelwidth = 700 + string.len( wpninfo.infos.name ) * 10

            else
                panelwidth = 700

            end

            if wpninfo.infos.ammo == "SMG1" then
                wepammoname = "SMG"

            elseif wpninfo.infos.ammo == "Buckshot" then
                wepammoname = "Shotgun"

            elseif wpninfo.infos.ammo == "357" then
                wepammoname = "what is this?"

            elseif wpninfo.infos.ammo == "AlyxGun" then
                wepammoname = "Rifle"

            elseif wpninfo.infos.ammo == "Battery" then
                wepammoname = "Battery"

            elseif wpninfo.infos.ammo == "Pistol" then
                wepammoname = "Pistol"

            end

            panelheight = 800
            texture = surface.GetTextureID "vgui/morbus/itemoverlay"
            color = Color( 25, 155, 255, 100 )
            if togglestats == false then
                panelheight = 150
                texture = surface.GetTextureID "vgui/morbus/hpbar"
                color = Color( 25, 155, 255, 25 )
            end

            if lowinfo then
                panelheight = 300
            end

            x = -panelwidth / 2
            y = 0
            position = ent:GetPos() + Vector( 0, 0, 37 + math.sin( CurTime() * 1.5 ) * 2 )

            cam.Start3D2D( position, angle, scale )
            draw.RoundedBox( 30, x, y, panelwidth, panelheight, wpninfo.colors.background )
            draw.TexturedQuad
            {
                texture = texture,
                color = color,
                x = x,
                y = y,
                w = panelwidth,
                h = panelheight
            }
            desc = wpninfo.infos.name
            draw.DrawText( desc, wpninfo.fonts.head, 0, y + 10, Color( 155, 200, 255, 255 ), TEXT_ALIGN_CENTER )

            if togglestats == true then
                if not lowinfo then

                    y = getnewy( desc )
                    desc = tostring( wpninfo.infos.currentclip ) .. "/" .. tostring( wpninfo.infos.clipsize ) .. "/" .. tostring( wpninfo.infos.storedammo )
                    draw.DrawText( desc, wpninfo.fonts.head, 0, y + 10, wpninfo.colors.text, TEXT_ALIGN_CENTER )

                    y = getnewy( desc )
                    desc = "Damage: "
                    draw.DrawText( desc, wpninfo.fonts.body, x + padding, y + 40, wpninfo.colors.text, TEXT_ALIGN_LEFT )
                    draw.DrawText( wpninfo.infos.damage, wpninfo.fonts.body, x + panelwidth - padding, y + 40, wpninfo.colors.text, TEXT_ALIGN_RIGHT )

                    y = getnewy( desc )
                    desc = "Weight: "
                    draw.DrawText( desc, wpninfo.fonts.body, x + padding, y + 40, wpninfo.colors.text, TEXT_ALIGN_LEFT )
                    draw.DrawText( wpninfo.infos.weight, wpninfo.fonts.body, x + panelwidth - padding, y + 40, wpninfo.colors.text, TEXT_ALIGN_RIGHT )

                    y = getnewy( desc )
                    desc = "Recoil: "
                    draw.DrawText( desc, wpninfo.fonts.body, x + padding, y + 40, wpninfo.colors.text, TEXT_ALIGN_LEFT )
                    draw.DrawText( wpninfo.infos.recoil, wpninfo.fonts.body, x + panelwidth - padding, y + 40, wpninfo.colors.text, TEXT_ALIGN_RIGHT )

                    y = getnewy( desc )
                    desc = "Spread: "
                    draw.DrawText( desc, wpninfo.fonts.body, x + padding, y + 40, wpninfo.colors.text, TEXT_ALIGN_LEFT )
                    draw.DrawText( wpninfo.infos.spread, wpninfo.fonts.body, x + panelwidth - padding, y + 40, wpninfo.colors.text, TEXT_ALIGN_RIGHT )

                else

                    y = getnewy( desc )
                    desc = tostring( wpninfo.infos.currentclip ) .. "/" .. tostring( wpninfo.infos.clipsize ) .. "/" .. tostring( wpninfo.infos.storedammo )
                    draw.DrawText( desc, wpninfo.fonts.head, 0, y + 10, wpninfo.colors.text, TEXT_ALIGN_CENTER )
                end

            end

            cam.End3D2D()

            -- Ammo identifier
        elseif ent.Type and ent.AmmoType and ent.Type == "anim" then

            width, height = surface.GetTextSize( ent.AmmoType )
            panelwidth = width + padding > 500 and width + padding * 4 or 500
            panelheight = 200

            -- Compatability
            if ent.AmmoType == "SMG1" then
                ammoname = "SMG Ammo"
            elseif ent.AmmoType == "Buckshot" then
                ammoname = "Shotgun Ammo"
                panelwidth = 600
            elseif ent.AmmoType == "357" then
                ammoname = "what is this?"
            elseif ent.AmmoType == "AlyxGun" then
                ammoname = "Rifle Ammo"
            elseif ent.AmmoType == "Battery" then
                ammoname = "Battery"
            elseif ent.AmmoType == "Pistol" then
                ammoname = "Pistol Ammo"
            end

            x = -panelwidth / 2
            y = 0
            position = ent:GetPos() + Vector( 0, 0, 30 + math.sin( CurTime() * 2 ) * 2 )

            cam.Start3D2D( position, angle, scale )
            -- Valid Ammo Highlight
            draw.RoundedBox( 30, x, y, panelwidth, panelheight, (wpn:IsWeapon() and wpn.Primary and (wpn.Primary.Ammo == ent.AmmoType) and Color( 41, 163, 255, 100 ) or wpninfo.colors.background) )
            draw.DrawText( ammoname, wpninfo.fonts.body, 0, y + padding, wpninfo.colors.text, TEXT_ALIGN_CENTER )

            cam.End3D2D()
        end
    end
end
hook.Add( "PostDrawOpaqueRenderables", "drawwpn", drawwpninfo )
