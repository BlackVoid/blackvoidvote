if CLIENT then return end
local voteNextMap = false
local nextMap = ""

local num_maps = CreateConVar("mapvote_maps", 5, FCVAR_REPLICATED, "Number of maps that are shown in the vote.")
local force_change = false
local next_map = ""

local rtv_keywords = {}
rtv_keywords["rtv"] = true
rtv_keywords["!rtv"] = true
rtv_keywords["/rtv"] = true
rtv_keywords[":rtv"] = true

hook.Add("OnRoundStart", "BVVote_CheckVote", function(round)
	if string.lower(gmod.GetGamemode().Name) != "deathrun" then return end
	if force_change and #next_map > 0 then
		RunConsoleCommand("changelevel", next_map)
	end
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
			if #Options >= num_maps:GetInt() then break end
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

hook.Add("PlayerSay", "BVVote_RTV", function(ply, text, teamChat)
	if not ply or not IsValid(ply) then return end
	local args = string.Explode(" ", text)
	if #args == 0 or not rtv_keywords[string.lower(args[1])] then return end
	if #args == 2 and ply:IsAdmin() and args[2] == "force" then
		if #next_map == 0 then
			BVVoteCallRTV()
		else
			for k,v in pairs(player.GetAll()) do
				ply:ChatPrint("Map will change next round to '" .. next_map .. "'")
			end
			force_change = true
		end
		return
	end
	ply.MapVote_RTV = ply.MapVote_RTV or false
	if ply.MapVote_RTV then
		ply:ChatPrint("You have already rocked the vote.")
		return true
	end

	ply.MapVote_RTV = true
	local count = 0;
	local percent = math.ceil(0.5*#player.GetAll())
	for k,v in ipairs(player.GetAll()) do
		if v.MapVote_RTV == true then
			count = count + 1
		end
	end
	if math.max(-1, percent - count) == -1 then return end

	for k,v in pairs(player.GetAll()) do
		ply:ChatPrint(ply:Nick() .. " wants to RTV. " .. math.max(0, percent - count) .. " more needed to RTV. Type /rtv to RTV")
	end
	if count >= percent then
		if #next_map == 0 then
			BVVoteCallRTV()
		else
			for k,v in pairs(player.GetAll()) do
				ply:ChatPrint("Map will change next round to '" .. next_map .. "'")
			end
			force_change = true
		end
	end
	return true
end)

function BVVoteCallRTV()
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
		if #Options >= num_maps:GetInt() then break end
		if v == game.GetMap() then continue end
		local map = table.concat(string.Explode("_", v), " ", 2)
		Options[#Options+1] = {["id"] = v, ["value"] = map}
	end

	voteNextMap = !BVVote.StartVote(player.GetAll(), "Next map", Options , 10, function(plTbl, option)

		for k, ply in pairs( player.GetAll() ) do
			ply:ChatPrint( option.value .. " won with " .. tostring(option.votes) .. " vote" .. (option.votes == 1 and "" or "s") ..". Map will change next round." )
		end
		next_map = option.id
		force_change = true
	end)
end