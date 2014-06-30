if CLIENT then return end
local voteNextMap = false
local nextMap = ""

hook.Add("OnRoundStart", "BVVote_CheckVote", function(round)
	if string.lower(gmod.GetGamemode().Name) != "deathrun" then return end
	if GAMEMODE.RoundLimit:GetInt() - round == 4 or voteNextMap then
		local Maps = {}
		for _,v in ipairs({"dr_", "deathrun_"}) do
			local files, directories = file.Find( "maps/" .. v .. "*.bsp", "GAME" )
			for k,_ in ipairs(files) do
				files[k] = string.Left(files[k], #files[k]-4)
			end
			table.Add(Maps, files)
		end

		local Options = {}
		for k,v in RandomPairs(Maps) do
			if #Options >= 5 then break end
			if v == game.GetMap() then continue end
			local map = table.concat(string.Explode("_", v), " ", 2)
			Options[#Options+1] = {["id"] = v, ["value"] = map}
		end

		voteNextMap = !BVVote.StartVote(player.GetAll(), "Next map", Options , 10, function(plTbl, option)
			if Themis then
				Themis:ChatBroadcast(
					{"LineIcon", "Global"},
					Color(0,150,0),
					option.value,
					Color(255,255,255),
					" won with ",
					Color(0,150,0),
					tostring(option.votes),
					Color(255,255,255),
					" vote" .. (option.votes > 1 and "s" or "") .."."
				)
			else
				for k, ply in pairs( player.GetAll() ) do
					ply:ChatPrint( option.value .. " won with " .. tostring(option.votes) .. " vote" .. (option.votes == 1 and "" or "s") .."." )
				end
			end

			nextMap = option.id
		end)
	end
end)

hook.Add("MapVoteNext", "BVVote_ChangeMap", function()
	return nextMap
end)