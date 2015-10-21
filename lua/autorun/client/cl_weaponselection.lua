surface.CreateFont( "WeaponSelectionFont", {
	font = "Arial", 
	size = 64, 
	weight = 500, 
	blursize = 0, 
	scanlines = 0, 
	antialias = true, 
	underline = false, 
	italic = false, 
	strikeout = false, 
	symbol = false, 
	rotary = false, 
	shadow = false, 
	additive = false, 
	outline = false, 
} )

function SWL_GenerateWeapons(SWEPCategory)

	local WeaponTable = weapons.GetList()
	
	--table.sort(WeaponTable)
	
	local Weapons = {}

	for i,SWEP in pairs(WeaponTable) do
		--if SWEP.Base == "weapon_buu_base" then
			if SWEP.Spawnable then
				if SWEP.Category then
					if SWEP.Category ~= "" then
						if not Weapons[SWEP.Category] then
							Weapons[SWEP.Category] = {}
						end

						table.Add(Weapons[SWEP.Category],{WeaponTable[i].ClassName})
					end
				end
			end
		--end
	end
	
	return Weapons

end


function SWL_Derma()

	local x = ScrW()
	local y = ScrH()

	local size = 1/16
	
	local MenuBase = vgui.Create("DFrame")
	MenuBase:SetPos(x*size*0.5,x*size*0.5)
	MenuBase:SetSize(x - x*size, y - y*size)
	MenuBase:SetTitle("Weapon Selection")
	MenuBase:Center(true)
	MenuBase:SetDeleteOnClose(false)
	MenuBase:SetDraggable( true )
	MenuBase:SetBackgroundBlur(false)
	MenuBase:SetVisible( true )
	MenuBase.Paint = function()
		draw.RoundedBox( 8, 0, 0, MenuBase:GetWide(), MenuBase:GetTall(), Color( 0, 0, 0, 150 ) )
	end
	MenuBase:MakePopup()

	local ALL = SWL_GenerateWeapons()

	local Base = {}
	local Scroll = {}
	local Panel = {}
	local List = {}
	
	local BaseScroll = vgui.Create("DScrollPanel",MenuBase)
	BaseScroll:SetSize(MenuBase:GetWide()/2 - 10 - 10, MenuBase:GetTall() - 30 - 10)
	BaseScroll:SetPos(10, 30)
	
	Base = vgui.Create("DIconLayout",BaseScroll)
	Base:SetSize(BaseScroll:GetWide() - 20, BaseScroll:GetTall()/4)
	Base:SetPos(0,0)
	Base:SetSpaceX(5)
	Base:SetSpaceY(5)
	

	
	
	for k,v in pairs(ALL) do
		
		--k is the Category Name
		--v is the table of weapons of that category
		
		--[[
		Scroll[k] = vgui.Create("DScrollPanel",Base)
		Base:Add(Scroll[k])
		Scroll[k]:SetSize(Base:GetWide(), Base:GetTall())
		--]]
		
		List[k] = vgui.Create("DIconLayout",Base)
		List[k]:SetSize(Base:GetWide(), 0)
		List[k]:SetPos(0,0)
		List[k]:SetSpaceX(5)
		List[k]:SetSpaceY(5)
		List[k]:SizeToContents()
		
		Panel[k] = {}
		
		CLabel = vgui.Create( "DLabel")
		CLabel:SetText( k )
		CLabel:SetFont("WeaponSelectionFont")
		CLabel:SetSize( 1800, 100)
		List[k]:Add(CLabel)
		
		for l,b in pairs(v) do

			-- l is the amount of weapons in that category
			-- b is weapon_m9k_*
		
			Panel[l] = vgui.Create("ContentIcon")
			List[k]:Add(Panel[l])
			Panel[l]:SetMaterial("entities/" .. b)
			Panel[l]:SetName(weapons.Get(b).PrintName)
			Panel[l].DoClick = function() 
				AddWeapon(b) 
			end
		end
		
	end
	
	local EquScroll = vgui.Create("DScrollPanel",MenuBase)
	EquScroll:SetSize(MenuBase:GetWide()/2 - 10 - 10, MenuBase:GetTall() - 30 - 10)
	EquScroll:SetPos(MenuBase:GetWide()/2, 30)
	
	local EquList = vgui.Create("DIconLayout",EquScroll)
	EquList:SetSize(EquScroll:GetWide(), EquScroll:GetTall())
	EquList:SetPos(0,0)
	EquList:SetSpaceX(5)
	EquList:SetSpaceY(5)
	
	local EquPanel = {}
	local LoadoutTable = {}

	if LocalPlayer().CurrentLoadout then
		for k,v in pairs(LocalPlayer().CurrentLoadout) do
			if v~= nil then
				print(v)
				timer.Simple(0.25,function()
					AddWeapon(v)
				end)
			end
		end
	end
	
	function AddWeapon(class)
	
		if not EquPanel[class] then
		
			--print("ADDING " .. class)
	
			EquPanel[class] = vgui.Create("ContentIcon")
			EquList:Add(EquPanel[class])
			EquPanel[class]:SetMaterial("entities/" .. class)
			EquPanel[class]:SetName(weapons.Get(class).PrintName)
			EquPanel[class].DoClick = function() RemoveWeapon(class) end
			
			table.Add(LoadoutTable,{class})
			--UpdateWeapons(LoadoutTable)
			
		end
		
		
	end
	
	function RemoveWeapon(class)
	
		if EquPanel[class] then
			EquPanel[class]:Remove()
			EquPanel[class] = nil
			--LoadoutTable[class] = nil
			--table.RemoveByValue(EquPanel,class)
			table.RemoveByValue(LoadoutTable,class)
			UpdateWeapons(LoadoutTable)
		end
		
	end

	local ApplyButton = vgui.Create( "DButton",MenuBase )
	ApplyButton:SetPos(MenuBase:GetWide() - MenuBase:GetWide()/3, MenuBase:GetTall()/3 + 100 + 30 + 20 + 20 + 20 + 20 + 50) 
	ApplyButton:SetText( "Apply This Loadout" )
	ApplyButton:SetSize( 255, 60 )
	ApplyButton.DoClick = function()
		--RunConsoleCommand("weapon_take",LoadoutTable)
		
		
		UpdateWeapons(LoadoutTable)
		
	end

end

concommand.Add("selectweapon", SWL_Derma)



net.Receive("SVCL_Weapons", function(len)

	local Table = net.ReadTable() 

	LocalPlayer().CurrentLoadout = Table

end)


function UpdateWeapons(LoadoutTable)

	--error("where")

	net.Start("CLSV_Weapons")
		net.WriteTable(LoadoutTable)
	net.SendToServer()
		
	--LocalPlayer().CurrentLoadout = LoadoutTable
end
