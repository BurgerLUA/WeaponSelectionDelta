local folder = "SimpleWeaponLoadout"

util.AddNetworkString("CLSV_Weapons")
util.AddNetworkString("SVCL_Weapons")

function SWL_PlayerInitalSpawn( ply )

	local storename = string.gsub(ply:SteamID(), ":", "_")

	if not file.Exists( folder, "DATA") then
		file.CreateDir( folder ) 
	end
	
	if not file.Exists( folder.."/"..storename .. ".txt", "DATA" ) then 
		file.Write( folder.."/"..storename..".txt", "weapon_csgo_m4a1_s weapon_csgo_usp" )
	end
	
	local weapon = file.Read(folder.."/"..storename ..".txt")
	
	local args = string.Explode( " " , weapon )
	
	ply.NextWeapons = args
	
	net.Start("SVCL_Weapons")
		net.WriteTable(args)
	net.Send(ply)

end

hook.Add( "PlayerInitialSpawn", "SWL: PlayerInitalSpawn", SWL_PlayerInitalSpawn )


function SWL_PlayerSpawn(ply)

	ply:StripAmmo()
	ply:StripWeapons()
	
	if ply:IsBot() == false then
	
		ply:Give("gmod_tool")
		ply:Give("weapon_physgun")
		
		
		if ply.NextWeapons then
			
			
			for k,v in pairs(ply.NextWeapons) do
			
				ply:ConCommand("gm_giveswep " .. v)
			
			
			end
			
		end

	end
	
	net.Start("SVCL_Weapons")
		net.WriteTable(ply.NextWeapons)
	net.Send(ply)
	
end

hook.Add("PlayerSpawn", "SWL: PlayerSpawn", SWL_PlayerSpawn)

net.Receive("CLSV_Weapons", function(len,ply)

	ply.NextWeapons = net.ReadTable()
	
	local FinalStore = string.Implode(" ",ply.NextWeapons)
	local storename = string.gsub(ply:SteamID(), ":", "_")
	
	file.Write( folder.."/"..storename..".txt", FinalStore )
	
	net.Start("SVCL_Weapons")
		net.WriteTable(ply.NextWeapons)
	net.Send(ply)

end)


