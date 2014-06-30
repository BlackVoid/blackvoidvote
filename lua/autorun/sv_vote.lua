if CLIENT then return end
BVVote 					= {}
BVVote.Vote 			= {}
BVVote.Vote 			= {}
BVVote.Vote.active 		= false

AddCSLuaFile( 'autorun/cl_vote.lua' )
util.AddNetworkString( "BVVote_StartVote" )
util.AddNetworkString( "BVVote_VoteCount" )
util.AddNetworkString( "BVVote_EndVote" )

function BVVote.VotingPower(ply)
	if Themis then
		return (Themis and ply:HasFlag('IS_DONATOR')) and 2 or 1
	else
		return ply:IsAdmin() and 2 or 1
	end 
end

function BVVote.StartVote(Players, Title, Options, VoteDuration, Callback)
	if BVVote.Vote.active == true then return false end
	BVVote.Vote 			= {}
	BVVote.Vote.active 		= true
	BVVote.Vote.time 		= VoteDuration
	BVVote.Vote.Players		= Players
	BVVote.Vote.VoteC		= 0

	BVVote.Vote.data	= {
							["title"] = Title, ["players"] = #BVVote.Vote.Players,
							["voted"] = 0,
							["end"] = VoteDuration,
							["values"] = {}
						}

	for k,v in pairs(Options) do
		BVVote.Vote.data.values[k] = Options[k]["value"]
		Options[k]["votes"] = 0
	end
	BVVote.Vote.options		= Options
	BVVote.Vote.CallBack	= Callback
	BVVote.Vote.Votes		= {}
	
	for k,v in pairs(Players) do
		BVVote.Vote.Votes[v:SteamID()] = false
	end
	
	timer.Create("BVVote_StopTimer", VoteDuration, 1, function()
		BVVote.EndVote()
	end)
	
	net.Start( "BVVote_StartVote" )
	net.WriteTable( BVVote.Vote.data )
	net.Send(Players)
	
	return true
end

function BVVote.ChoiceListener(ply, cmd, args)
	if !BVVote.Vote.active then return end
	if BVVote.Vote.Votes[ply:SteamID()] == nil then return end
	if (BVVote.Vote.Votes[ply:SteamID()] != nil and BVVote.Vote.Votes[ply:SteamID()] == true) then return end
	
	if BVVote.Vote.options[tonumber(args[1])] then
		BVVote.Vote.options[tonumber(args[1])]["votes"] = BVVote.Vote.options[tonumber(args[1])]["votes"] + BVVote.VotingPower(ply)
		BVVote.Vote.VoteC = BVVote.Vote.VoteC + 1
		BVVote.Vote.Votes[ply:SteamID()] = true
	end
	local EndVote = true
	for k,v in pairs(BVVote.Vote.Votes) do
		if v == false then
			EndVote = false
			break
		end
	end
	net.Start( "BVVote_VoteCount" )
		net.WriteInt( BVVote.Vote.VoteC, 8)
	net.Send(BVVote.Vote.Players)
	if EndVote == true then
		BVVote.EndVote()
	end
end
concommand.Add("BVVote_SendChoice", BVVote.ChoiceListener)

function BVVote.EndVote()
	BVVote.Vote.active = false
	timer.Destroy("BVVote_StopTimer")
	local MostVotes = 0
	for k,v in pairs(BVVote.Vote.options) do
		if MostVotes == 0 or v["votes"] > BVVote.Vote.options[MostVotes]["votes"] then
			MostVotes = k
		end
		if MostVotes != 0 and v["votes"] == BVVote.Vote.options[MostVotes]["votes"] then
			if math.random(1,2) == 1 then
				MostVotes = k
			end
		end
	end
	net.Start( "BVVote_EndVote" )
	net.Send( BVVote.Vote.Players )
	BVVote.Vote.CallBack(BVVote.Vote.Players, BVVote.Vote.options[MostVotes])
end