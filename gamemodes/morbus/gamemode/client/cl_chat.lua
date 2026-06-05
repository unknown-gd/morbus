-- Morbus - morbus.remscar.com
-- Developed by Remscar and the Morbus dev team
--[[
MORBUS CLIENT COMMUNICATION
--]]

local tex = surface.GetTextureID( "morbus/voiceicon" )

function VoiceIndicators( ply )
    for k, v in player.Iterator() do
        if v:IsSpeaking() and v ~= ply then
            local distance = v:GetPos():Distance( ply:GetPos() )
            if distance < 750 or (ply:IsSpec() and distance < 2000) then
                local pos = v:GetPos() + Vector( 0, 0, 70 )
                local toscreen = BindToScreen( pos )
                local size = math.Clamp( 25 + (750 * 15) / (distance + 31), 24, 90 )
                --MsgN(size)
                surface.SetTexture( tex )
                surface.SetDrawColor( 255, 255, 255, 200 )
                surface.DrawTexturedRect( toscreen.x - size / 2, toscreen.y - size / 2, size, size )
            end
        end
    end
end

--[[
VOICE
--]]
local PANEL = {}
local PlayerVoicePanels = {}


function PANEL:Init()
    self.LabelName = vgui.Create( "DLabel", self )
    self.LabelName:SetFont( "GModNotify" )
    self.LabelName:Dock( FILL )
    self.LabelName:DockMargin( 8, 0, 0, 0 )
    self.LabelName:SetTextColor( Color( 255, 255, 255, 255 ) )

    self.Avatar = vgui.Create( "AvatarImage", self )
    self.Avatar:Dock( LEFT )
    self.Avatar:SetSize( 32, 32 )

    if GetRoundState() == ROUND_ACTIVE then
        self.Avatar:SetVisible( false )
    end

    self.Color = color_transparent

    self:SetSize( 250, 32 + 8 )
    self:DockPadding( 4, 4, 4, 4 )
    self:DockMargin( 2, 2, 2, 2 )
    self:Dock( BOTTOM )
end

function PANEL:Setup( ply )
    self.ply = ply
    if GetRoundState() ~= ROUND_ACTIVE then
        self.LabelName:SetText( ply:Nick() )
        self.Avatar:SetPlayer( ply )
    else
        self.LabelName:SetText( ply:GetFName() )
        self.Avatar:SetVisible( false )
    end

    self:InvalidateLayout()
end

function PANEL:Paint( w, h )
    if (not IsValid( self.ply )) then return end

    draw.RoundedBox( 4, 0, 0, w, h, Color( 0, self.ply:VoiceVolume() * 255, 0, 240 ) )
end

function PANEL:Think()
    ply = self.ply
    if (IsValid( self.ply )) then
        if GetRoundState() ~= ROUND_ACTIVE then
            self.LabelName:SetText( ply:Nick() )
            self.Avatar:SetPlayer( ply )
        else
            self.LabelName:SetText( ply:GetFName() )
            self.Avatar:SetVisible( false )
        end
    end

    if (self.fadeAnim) then
        self.fadeAnim:Run()
    end
end

function PANEL:FadeOut( anim, delta, data )
    if (anim.Finished) then
        if (IsValid( PlayerVoicePanels[ self.ply ] )) then
            PlayerVoicePanels[ self.ply ]:Remove()
            PlayerVoicePanels[ self.ply ] = nil
            return
        end

        return
    end

    self:SetAlpha( 255 - (255 * delta) )
end

derma.DefineControl( "VoiceNotify", "", PANEL, "DPanel" )



local function PositionVoicePanelList()
    g_VoicePanelList:SetPos( 25, 25 )
    --g_VoicePanelList:SetBottomUp(false)
end


function GM:PlayerStartVoice( ply )
    local client = LocalPlayer()
    if not HUD_DEBUG[ 11 ] then return end

    if not IsValid( g_VoicePanelList ) or not IsValid( client ) then return end

    -- There'd be an extra one if voice_loopback is on, so remove it.
    GAMEMODE:PlayerEndVoice( ply, true )

    if not IsValid( ply ) then return end

    -- Tell server this is global
    if client == ply then
        if client:IsActiveAlien() then
            if (not client:KeyDown( IN_ZOOM )) and (not client:KeyDownLast( IN_ZOOM )) then
                client.alien_voice = true
                RunConsoleCommand( "morbus_alien_voice", "1" )
            else
                client.alien_voice = false
                RunConsoleCommand( "morbus_alien_voice", "0" )
            end
        end

        if ((client:GetNWBool( "alienform", false ) == true) and client:IsActiveAlien()) or client:IsActiveSwarm() then
            client.alien_voice = false
            RunConsoleCommand( "morbus_alien_voice", "0" )
        end
    end

    local pnl = vgui.Create( "VoiceNotify" )
    pnl:Setup( ply )
    pnl.LabelName:SetText( ply:GetFName() )



    if client:IsActiveAlien() then
        if ply == client then
            if not client.alien_voice then
                pnl.Color = Color( 210, 0, 0, 255 )
            end
        elseif ply:IsActiveAlien() then
            if not ply.alien_voice then
                pnl.Color = Color( 200, 0, 0, 255 )
                pnl.Think = nil
            end
        elseif ply:IsSwarm() then
            pnl.Color = Color( 200, 0, 0, 255 )
            pnl.Think = nil
        end
    end

    g_VoicePanelList:AddItem( pnl )

    PlayerVoicePanels[ ply ] = pnl

    if not (ply:IsAlien() and (not ply.alien_voice)) then
        --ply:AnimPerformGesture(ACT_GMOD_IN_CHAT)
    end
end

local function ReceiveVoiceState( um )
    local idx = um:ReadShort()
    local state = um:ReadBool()


    -- prevent glitching due to chat starting/ending across round boundary
    if GetRoundState() ~= ROUND_ACTIVE then return end

    if (not IsValid( LocalPlayer() )) or (not LocalPlayer():IsAlien()) then return end

    local ply = player.GetByID( idx )
    if IsValid( ply ) then
        ply.alien_voice = state

        if IsValid( PlayerVoicePanels[ ply ] ) then
            PlayerVoicePanels[ ply ].Color = state and Color( 0, 200, 0 ) or Color( 200, 0, 0 )
        end
    end
end
usermessage.Hook( "avstate", ReceiveVoiceState )


local function VoiceClean()
    for ply, pnl in pairs( PlayerVoicePanels ) do
        if (not IsValid( pnl )) or (not IsValid( ply )) then
            GAMEMODE:PlayerEndVoice( ply )
        end
    end
end
timer.Create( "VoiceClean", 10, 0, VoiceClean )


function GM:PlayerEndVoice( ply, no_reset )
    if IsValid( PlayerVoicePanels[ ply ] ) then
        g_VoicePanelList:RemoveItem( PlayerVoicePanels[ ply ] )
        PlayerVoicePanels[ ply ]:Remove()
        PlayerVoicePanels[ ply ] = nil
    end

    if IsValid( ply ) and not no_reset then
        ply.alien_voice = true
    end
end

local function CreateVoiceVGUI()
    g_VoicePanelList = vgui.Create( "DPanelList" )

    g_VoicePanelList:ParentToHUD()

    PositionVoicePanelList()

    g_VoicePanelList:SetSize( 200, ScrH() - 200 )
    g_VoicePanelList:SetDrawBackground( false )
    g_VoicePanelList:SetSpacing( 8 )

    MutedState = vgui.Create( "DLabel" )
    MutedState:SetPos( ScrW() - 200, ScrH() - 50 )
    MutedState:SetSize( 200, 50 )
    MutedState:SetFont( "Trebuchet19" )
    MutedState:SetText( "" )
    MutedState:SetTextColor( Color( 240, 240, 240, 250 ) )
    MutedState:SetVisible( false )
end
hook.Add( "InitPostEntity", "CreateVoiceVGUI", CreateVoiceVGUI )



--[[
TEXT
--]]
local function RoleChatRecv( um )
    local sender = um:ReadEntity()
    if not IsValid( sender ) then return end

    local text = um:ReadString()

    chat.AddText( Color( 255, 30, 40 ),
        "(ALIEN CHAT) ",
        Color( 255, 200, 20 ),
        sender:GetFName(),
        Color( 255, 255, 200 ),
        ": " .. text )
end
usermessage.Hook( "alien_chat", RoleChatRecv )
