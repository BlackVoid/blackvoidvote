if SERVER then return end

surface.CreateFont( "Trebuchet22", {
	font 		= "Trebuchet18",
	size 		= 22,
	weight 		= 0,
	blursize 	= 0,
	scanlines 	= 0,
	antialias 	= true,
	underline 	= false,
	italic 		= false,
	strikeout 	= false,
	symbol 		= false,
	rotary 		= false,
	shadow 		= false,
	additive 	= false,
	outline 	= false
})

BVVote					= {}

BVVote.BindKeys 		= {}
BVVote.BindKeys[KEY_1] 	= 1
BVVote.BindKeys[KEY_2] 	= 2
BVVote.BindKeys[KEY_3] 	= 3
BVVote.BindKeys[KEY_4] 	= 4
BVVote.BindKeys[KEY_5] 	= 5
BVVote.BindKeys[KEY_6] 	= 6
BVVote.BindKeys[KEY_7] 	= 7
BVVote.BindKeys[KEY_8] 	= 8
BVVote.BindKeys[KEY_9] 	= 9

BVVote.BlockBinds		= {
	"slot1",
	"slot2",
	"slot3",
	"slot4",
	"slot5",
	"slot6",
	"slot7",
	"slot8",
	"slot9"
}

BVVote.Choice 			= 0
BVVote.Details			= {}
BVVote.Details.values	= {}

hook.Remove("Think", "BVVote.KeyListener")
hook.Remove("HUDPaint", "BVVote.DrawVoteBox")
hook.Remove("PlayerBindPress","PlayerBindPress")
print( [[
-------------------------------------------
---       This server is running        ---
---            BlackVoid Vote           ---
-------------------------------------------
]] )

function BVVote.BlockKeyPress(ply, bind, pressed)
	if table.HasValue(BVVote.BlockBinds, bind) then
		return true
	end
end


function BVVote.KeyListener()
	for k, v in pairs(BVVote.BindKeys) do
		if input.IsKeyDown(k) and #BVVote.Details.values >= v then
			RunConsoleCommand("BVVote_SendChoice", v)
			BVVote.Choice = v
			hook.Remove("Think", "BVVote.KeyListener")
		end
	end
end

function BVVote.EndVote(len)
	hook.Remove("Think", "BVVote.KeyListener")
	hook.Remove("HUDPaint", "BVVote.DrawVoteBox")
	hook.Remove("PlayerBindPress","BVVote.BlockKeyPress")
	timer.Destroy("BVVote_StopTimer")
end
net.Receive( "BVVote_EndVote", BVVote.EndVote )

function BVVote.DrawVoteBox()
	local H = ScrH()/2-(#BVVote.Details.values*20/2)
	local mdl = 155
	draw.RoundedBox( 6, 50, H, 210, 60 + #BVVote.Details.values * 13 , Color( 0, 0, 0, 150 ) )
	draw.SimpleText("Vote: " .. BVVote.Details.title, "Trebuchet22", mdl, H + 10, Color(200,200,200,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	H = H + 30
	for k,v in pairs(BVVote.Details.values) do
		local C = Color(255,255,255,255)
		if k == BVVote.Choice then
			C = Color(150,40,40,255)
		end
		draw.SimpleText( k .. ". " .. v, "Trebuchet18", 60, H, C, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		H = H + 13
	end
	draw.SimpleText(BVVote.Details["voted"] .. " of " .. BVVote.Details["players"] .. " has voted!", "Trebuchet18", mdl, H + 7, Color(200,200,200,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(math.max(math.Round(BVVote.Details["end"] - os.time()), 0) .. " seconds left", "Trebuchet18", mdl, H + 20, Color(200,200,200,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function BVVote.UpdateVoteCount(len)
	BVVote.Details["voted"] = net.ReadInt(8)
end
net.Receive( "BVVote_VoteCount", BVVote.UpdateVoteCount )

function BVVote.DataListener( len )
	BVVote.Details = net.ReadTable()
	BVVote.Choice = 0
	hook.Add("Think", "BVVote.KeyListener", BVVote.KeyListener)
	hook.Add("HUDPaint", "BVVote.DrawVoteBox", BVVote.DrawVoteBox)
	hook.Add("PlayerBindPress","BVVote.BlockKeyPress", BVVote.BlockKeyPress)
	timer.Create("BVVote_StopTimer", math.Round(BVVote.Details["end"]), 1, function()
		BVVote.EndVote()
	end)
	BVVote.Details["end"] = BVVote.Details["end"] + os.time()
end
net.Receive( "BVVote_StartVote", BVVote.DataListener )