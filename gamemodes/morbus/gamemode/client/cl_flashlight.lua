-- Morbus - morbus.remscar.com
-- Developed by Remscar and the Morbus dev team



function LIGHT.TurnOn(ply)
    if not ply then return end

    ply.Light = true
end

function LIGHT.TurnOff(ply)
    if not ply then return end

    ply.Light = false
end

function LIGHT.RecieveBattery(data)
    local bat = data:ReadChar()
    if not LocalPlayer() then return end

    LocalPlayer().Battery = bat
    LocalPlayer().NextBattery = LIGHT.ToTime(LIGHT.Regen(LIGHT.Precent(bat)))
end

usermessage.Hook("SendBattery", LIGHT.RecieveBattery)

function LIGHT.RecieveLight(data)
    local on = data:ReadBool()
    if on then
        LIGHT.TurnOn(LocalPlayer())
    else
        LIGHT.TurnOff(LocalPlayer())
    end
end

usermessage.Hook("SendLight", LIGHT.RecieveLight)

function LIGHT.RecieveNV(data)
    local on = data:ReadBool()
    LocalPlayer().NightVision = on
end

usermessage.Hook("SendNV", LIGHT.RecieveNV)


function LIGHT.Think(ply)   --Actually called every 0.25 second
    if not ply or not IsValid(ply) then return end

    if not ply:Alive() or ply:IsSwarm() then return end

    if ply:Team() == TEAM_SPEC then return end

    if ply.Light then
        if ply.Battery > 0 then
            if ply:IsCyborg() then
                ply.Battery = 100
            else
                ply.Battery = ply.Battery - 1
            end

            if ply.Battery < 0 then
                LIGHT.TurnOff(ply)
            end
        else
            LIGHT.TurnOff(ply)
        end
    else
        --[[if ply.Battery < LIGHT_BATTERY then

			ply.Battery = (ply.NextBattery/4) + ply.Battery
			if ply.Battery > LIGHT_BATTERY then

				ply.Battery = LIGHT_BATTERY
			end
		end--]]
    end
end

timer.Create("SecondQImpulse", 1, 0, function() LIGHT.Think(LocalPlayer()) end)
function CalcView(ply, pos, angles, fov, znear, zfar)
    if CLIENT then
        local flashlight = ply:GetNWEntity('Flashlight')
        if flashlight:IsValid() then
            flashlight:SetPos(ply:EyePos() + ply:EyeAngles():Forward() * 15)
            flashlight:SetAngles(ply:EyeAngles())
        end
    end
end

hook.Add("CalcView", "CalcView", CalcView)


function LIGHT.Draw(ply)
    if not GetGlobalBool("mutator_nightmare", false) then
        local tall = 16
        local wide = 70
        local border = 3
        local by = 62
        draw.RoundedBox(2, ScrW() / 2 - wide / 2, ScrH() - by, wide, tall, Color(0, 0, 0, 230))
        draw.RoundedBox(2, ScrW() / 2 - wide / 2 + border, ScrH() - by + border, wide - border * 2, tall - border * 2,
            Color(120, 120, 120, 230))
        local ratio = math.Clamp(ply.Battery / LIGHT_BATTERY, 0, 1)
        draw.RoundedBox(0, ScrW() / 2 - wide / 2 + border, ScrH() - by + border, (wide - border * 2) * ratio,
            tall - border * 2, Color(255, 205, 0, 230))
        draw.RoundedBox(0, ScrW() / 2 - wide / 2 + border, ScrH() - by + border, (wide - border * 2) * ratio,
            tall - border * 4, Color(255, 180, 0, 230))
    end
end

LightMat = Material("sprites/light_ignorez")
BeamMat = Material("effects/lamp_beam")
