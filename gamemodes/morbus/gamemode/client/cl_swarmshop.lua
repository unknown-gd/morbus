-- SwarmShop v2 -- Public Release --
-- Created by Demonkush -- www.xmpstudios.com --

function CreateSwarmShop()
    if not LocalPlayer():IsSwarm() then return end

    if pSwarmShop then
        if pSwarmShop:IsValid() then
            pSwarmShop:Remove()
        end
    end

    UpdateSwarmShop()
end

function UpdateSwarmShop()

    local w              = ScrW()
    local h              = ScrH()

    local ww             = 600
    local wh             = 450

    local swarmimagepath = "VGUI/morbus/swarm/"
    local extension      = ".png"
    local defaulticon    = "VGUI/morbus/brood/icon_brood_locked2.png"

    local selected       = -1

    pSwarmShop           = vgui.Create( "DFrame" )
    pSwarmShop:SetSize( ww, wh )
    pSwarmShop:SetPos( (w / 2) - (ww / 2), (h / 2) - (wh / 2) )
    pSwarmShop:SetVisible( true )
    pSwarmShop:MakePopup()
    pSwarmShop:SetTitle( "" )
    pSwarmShop:SetKeyboardInputEnabled( false )
    pSwarmShop:SetMouseInputEnabled( true )
    function pSwarmShop:Paint()

        local cost = ""
        local currentTime = GetGlobalFloat( "morbus_round_time", 10 ) * 60 - (GetGlobalFloat( "morbus_round_end", 0 ) - CurTime())

        if currentTime < 150 then
            cost = "No Swarm abilities available yet"
        elseif ((currentTime >= 150) and (currentTime < 300)) then
            cost = "Tier 1 abilities are available"
        elseif ((currentTime >= 300) and (currentTime < 450)) then
            cost = "Tier 2 abilities are available"
        else
            cost = "Tier 3 abilities are available"
        end

        draw.RoundedBox( 8, 0, 0, pSwarmShop:GetWide(), pSwarmShop:GetTall(), Color( 25, 25, 25, 225 ) )
        draw.SimpleTextOutlined( cost, "DSMedium", pSwarmShop:GetWide() / 2, 13, Color( 225, 255, 55, 215 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, Color( 0, 0, 0, 255 ) )
    end

    -- LEFT PANEL -- ABILITY LIST
    local lpanel = vgui.Create( "DPanel", pSwarmShop )
    lpanel:SetKeyboardInputEnabled( false )
    lpanel:SetFocusTopLevel( true )
    lpanel:SetSize( ww / 2 - 20, wh - 45 )
    lpanel:SetPos( 15, 35 )
    function lpanel:Paint()
        draw.RoundedBox( 8, 0, 0, lpanel:GetWide(), lpanel:GetTall(), Color( 55, 85, 85, 55 ) )
    end

    -- SCROLL MENU
    local lpanel_menu = vgui.Create( "DScrollPanel", lpanel )
    lpanel_menu:SetKeyboardInputEnabled( false )
    lpanel_menu:SetFocusTopLevel( true )
    lpanel_menu:SetSize( ww / 2 - 25, wh - 55 )
    lpanel_menu:SetPos( 0, 5 )
    function lpanel_menu:Paint()
        draw.RoundedBox( 8, 0, 0, lpanel_menu:GetWide(), lpanel:GetTall(), Color( 0, 0, 0, 0 ) )
    end

    local sbar = lpanel_menu:GetVBar()

    function sbar:Paint( w, h )
        draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 155 ) )
    end

    function sbar.btnUp:Paint( w, h )
        draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 215, 55, 55 ) )
    end

    function sbar.btnDown:Paint( w, h )
        draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 215, 55, 55 ) )
    end

    function sbar.btnGrip:Paint( w, h )
        draw.RoundedBox( 0, 0, 0, w, h, Color( 155, 200, 55, 55 ) )
    end

    local lpanel_menutitle = vgui.Create( "DLabel", lpanel )
    lpanel_menutitle:SetKeyboardInputEnabled( false )
    lpanel_menutitle:SetFocusTopLevel( true )
    lpanel_menutitle:SetText( "Abilities" )
    lpanel_menutitle:SetFont( "DSSmall" )
    lpanel_menutitle:SetColor( Color( 245, 255, 155, 155 ) )
    lpanel_menutitle:SetPos( 85, 5 )
    lpanel_menutitle:SizeToContents()

    local newm = 25
    local newn = 10
    local nm = 0
    for a, b in pairs( SwarmShop.Abilities ) do

        local function UpdateInfos()
            rpanel_testicon:SetImage( swarmimagepath .. "" .. b.icon .. "" .. extension )
            rpanel_testtitle:SetText( b.name )
            rpanel_testtitle:SizeToContents()

            local cost = b.price
            local currentTime = GetGlobalFloat( "morbus_round_time", 10 ) * 60 - (GetGlobalFloat( "morbus_round_end", 0 ) - CurTime())

            if currentTime < cost then
                local timeToBuy = string.FormattedTime( cost - currentTime, "%01i:%02i" )
                cost = "Unlocked in " .. timeToBuy .. "\nseconds"
            else
                if cost == 0 then
                    cost = "Tier 0"
                elseif cost == 150 then
                    cost = "Tier 1"
                elseif cost == 300 then
                    cost = "Tier 2"
                else
                    cost = "Tier 3"
                end
            end

            rpanel_testprice:SetText( cost )
            rpanel_testprice:SizeToContents()

            rpanel_testdesc:SetText( b.desc )
            rpanel_testdesc:SizeToContents()

            selected = b.id
        end

        -- Ability Icon
        local lpanel_testicon = vgui.Create( "DImageButton", lpanel_menu )
        lpanel_testicon:SetKeyboardInputEnabled( false )
        lpanel_testicon:SetFocusTopLevel( true )
        lpanel_testicon:SetSize( 64, 64 )
        lpanel_testicon:SetImage( swarmimagepath .. "" .. b.icon .. "" .. extension )
        lpanel_testicon:SetPos( newn, newm )
        lpanel_testicon:SetTooltip( b.name )
        function lpanel_testicon:DoClick()
            surface.PlaySound( Sound( "buttons/button9.wav" ) )
            UpdateInfos()
        end

        nm = nm + 1
        newn = newn + 64
        if nm > 3 then
            newn = 10
            nm = 0
            newm = newm + 74
        end
    end

    -- RIGHT PANEL -- INFORMATION / INTERFACE
    local rpanel = vgui.Create( "DPanel", pSwarmShop )
    rpanel:SetKeyboardInputEnabled( false )
    rpanel:SetFocusTopLevel( true )
    rpanel:SetSize( ww / 2 - 30, wh - 45 )
    rpanel:SetPos( ww / 2 + 15, 35 )
    function rpanel:Paint()
        draw.RoundedBox( 8, 0, 0, rpanel:GetWide(), rpanel:GetTall(), Color( 55, 85, 85, 55 ) )
    end

    -- Info Icon
    rpanel_testicon = vgui.Create( "DImage", rpanel )
    rpanel_testicon:SetKeyboardInputEnabled( false )
    rpanel_testicon:SetFocusTopLevel( true )
    rpanel_testicon:SetSize( 64, 64 )
    rpanel_testicon:SetImage( defaulticon )
    rpanel_testicon:SetPos( 10, 10 )

    -- Info Title
    rpanel_testtitle = vgui.Create( "DLabel", rpanel )
    rpanel_testtitle:SetKeyboardInputEnabled( false )
    rpanel_testtitle:SetFocusTopLevel( true )
    rpanel_testtitle:SetPos( 35, 85 )
    rpanel_testtitle:SetFont( "DSMedium" )
    rpanel_testtitle:SetColor( Color( 215, 255, 155, 215 ) )
    rpanel_testtitle:SetText( "" )

    -- Info Price
    rpanel_testprice = vgui.Create( "DLabel", rpanel )
    rpanel_testprice:SetKeyboardInputEnabled( false )
    rpanel_testprice:SetFocusTopLevel( true )
    rpanel_testprice:SetPos( 35, 110 )
    rpanel_testprice:SetFont( "DSSmall" )
    rpanel_testprice:SetColor( Color( 255, 215, 55, 215 ) )
    rpanel_testprice:SetText( "" )

    -- Info Description
    rpanel_testdesc = vgui.Create( "DLabel", rpanel )
    rpanel_testdesc:SetKeyboardInputEnabled( false )
    rpanel_testdesc:SetFocusTopLevel( true )
    rpanel_testdesc:SetPos( 15, 160 )
    rpanel_testdesc:SetFont( "DSSmall" )
    rpanel_testdesc:SetColor( Color( 255, 255, 100, 215 ) )
    rpanel_testdesc:SetText( "" )




    -- BUY BUTTON
    rpanel_buybutton = vgui.Create( "DButton", rpanel )
    rpanel_buybutton:SetKeyboardInputEnabled( false )
    rpanel_buybutton:SetFocusTopLevel( true )
    rpanel_buybutton:SetPos( 35, rpanel:GetTall() - 85 )
    rpanel_buybutton:SetSize( 200, 25 )
    rpanel_buybutton:SetTextColor( Color( 185, 215, 85, 255 ) )
    rpanel_buybutton:SetFont( "DSSmall" )
    rpanel_buybutton:SetText( "Buy" )
    function rpanel_buybutton:Paint()
        draw.RoundedBox( 8, 0, 0, rpanel_buybutton:GetWide(), rpanel_buybutton:GetTall(), Color( 155, 185, 85, 65 ) )
    end

    function rpanel_buybutton:DoClick()
        if selected == -1 then
            return
        end

        surface.PlaySound( Sound( "buttons/blip1.wav" ) )
        RunConsoleCommand( "SwarmBuyMod", selected )
    end
end
