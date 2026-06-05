-- 15 second impulse

local IMPULSE = {}

function IMPULSE.SECOND70()
	if GetRoundState() == ROUND_ACTIVE then
		IMPULSE.SWARM_LIVES()
	end
end
hook.Add("Impulse_70Second","70Sec_Impulse",IMPULSE.SECOND70)

function IMPULSE.SWARM_LIVES()
	Swarm_Respawns = Swarm_Respawns + 4
end