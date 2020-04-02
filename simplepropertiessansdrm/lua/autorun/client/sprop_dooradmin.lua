SPROP.ActiveDoorIDs = SPROP.ActiveDoorIDs or {};
SPROP.ActiveDoorData = SPROP.ActiveDoorData or {};
SPROP.ActiveDoors	= SPROP.ActiveDoors or {};

function SPROP:DoorMenu()

	if( !table.HasValue( SPROP.Settings.AdminRanks, LocalPlayer():GetUserGroup() ) ) then
		return;
	end
	
	local main = vgui.Create( "DFrame" );
	main:SetSize( 600, 270 );
	main:Center();
	main:MakePopup();
	main:SetTitle( "" );
	main.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, SPROP.Settings.GeneralClr );
		draw.RoundedBox( 0, 0, 30, w, SPROP.Settings.LineH, SPROP.Settings.LineClr );
	end
	main:ShowCloseButton( false );
	
	main.CloseBtn = vgui.Create( "DButton", main );
	main.CloseBtn:SetText( "x" );
	main.CloseBtn:SetFont( "SPROP::GeneralFont" );
	main.CloseBtn:SetSize( 25, 25 );
	main.CloseBtn:SetColor( color_white );
	main.CloseBtn:SetPos( main:GetWide() - main.CloseBtn:GetWide(), 0 );
	main.CloseBtn.DoClick = function()
		main:Close();
	end
	main.CloseBtn.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 0, 0, 180 ) );
	end
	
	local buildLeft, buildRight;
	
	local title = vgui.Create( "DLabel", main );
	title:SetText( "Properties Administration" );
	title:SetFont( "SPROP::GeneralFont" );
	title:SetColor( color_white );
	title:SizeToContents();
	title:SetPos( main:GetWide() / 2 - title:GetWide() / 2, 3 );
	
	local container = vgui.Create( "DPanel", main );
	container:SetSize( main:GetWide() - 20, main:GetTall() - title:GetTall() - 20 );
	container:SetPos( 10, title:GetTall() + 10 );
	container.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, SPROP.Settings.GeneralClr2 );
		draw.RoundedBox( 0, 5, 27, w - 10, SPROP.Settings.LineH / 2, SPROP.Settings.LineClr );
		draw.RoundedBox( 0, w / 2 - SPROP.Settings.LineH / 4, 5, SPROP.Settings.LineH / 2, h - 10, SPROP.Settings.LineClr );
	end
	
	local sideW = container:GetWide() / 2 - 20;
	
	local y = 5;
	local addTitle = vgui.Create( "DLabel", container );
	addTitle:SetFont( "SPROP::GeneralFont" );
	addTitle:SetText( SPROP.Settings.AddProperties );
	addTitle:SetPos( 5, y );
	addTitle:SetColor( color_white );
	addTitle:SizeToContents();
	
	y = y + addTitle:GetTall() + 5;
	
	local addBtn = vgui.Create( "DButton", container );
	addBtn:SetText( SPROP.Settings.AddBtn );
	addBtn:SetSize( sideW, 30 );
	addBtn:SetPos( 10, y );
	addBtn:SetColor( color_white );
	addBtn:SetFont( "SPROP::BtnFont" );
	addBtn.Paint = function( self, w, h )
		if( self:IsHovered() ) then
			draw.RoundedBox( 0, 0, 0, w, h, SPROP.Settings.BtnClrH );
			draw.RoundedBox( 0, 0, h-SPROP.Settings.LineH, w, SPROP.Settings.LineH, SPROP.Settings.BtnClrLineH );
		else
			draw.RoundedBox( 0, 0, 0, w, h, SPROP.Settings.BtnClr );
			draw.RoundedBox( 0, 0, h-SPROP.Settings.LineH, w, SPROP.Settings.LineH, SPROP.Settings.BtnClrLine );		
		end
	end
	addBtn.DoClick = function()
		if( SPROP.ActiveDoorIDs && table.Count( SPROP.ActiveDoorIDs ) > 0 ) then
			buildLeft();
		else
			LocalPlayer():ChatPrint( SPROP.Settings.NoActiveDoors );
		end
	end
	y = y + addBtn:GetTall();
	local oldY = y;
	function buildLeft()
	
		local info = vgui.Create( "DLabel", container );
		info:SetFont( "SPROP::GeneralFont" );
		local txt = string.Replace( SPROP.Settings.DoorsSelected, "[x]", table.Count( SPROP.ActiveDoorIDs ) );
		info:SetText( txt );
		info:SetColor( color_white );
		info:SetPos( 10, y );
		info:SizeToContents();
		y = y + info:GetTall();
		
		local price = vgui.Create( "DTextEntry", container );
		price:SetPos( 10, y );
		price:SetSize( sideW, 30 );
		price:SetFont( "SPROP::BtnFont" );
		price:SetValue( SPROP.Settings.InsertPrice );
		price.OnGetFocus = function()
			if( price:GetText() == SPROP.Settings.InsertPrice ) then
				price:SetText( "" );
			end
		end
		
		price.OnLoseFocus = function()
			if( price:GetText() == "" ) then
				price:SetText( SPROP.Settings.InsertPrice );
			end
		end		
		y = y + price:GetTall() + 5;
		
		local name = vgui.Create( "DTextEntry", container );
		name:SetPos( 10, y );
		name:SetSize( sideW, 30 );
		name:SetFont( "SPROP::BtnFont" );
		name:SetText( SPROP.Settings.InsertName );
		name.OnGetFocus = function()
			if( name:GetText() == SPROP.Settings.InsertName ) then
				name:SetText( "" );
			end
		end
		
		name.OnLoseFocus = function()
			if( name:GetText() == "" ) then
				name:SetText( SPROP.Settings.InsertName );
			end
		end
		y = y + name:GetTall() + 5;
		
		local saveBtn = vgui.Create( "DButton", container );
		saveBtn:SetText( SPROP.Settings.SaveProperty );
		saveBtn:SetSize( sideW, 30 );
		saveBtn:SetPos( 10, y );
		saveBtn:SetColor( color_white );
		saveBtn:SetFont( "SPROP::BtnFont" );
		saveBtn.Paint = function( self, w, h )
			if( self:IsHovered() ) then
				draw.RoundedBox( 0, 0, 0, w, h, SPROP.Settings.BtnClrH );
				draw.RoundedBox( 0, 0, h-SPROP.Settings.LineH, w, SPROP.Settings.LineH, SPROP.Settings.BtnClrLineH );
			else
				draw.RoundedBox( 0, 0, 0, w, h, SPROP.Settings.BtnClr );
				draw.RoundedBox( 0, 0, h-SPROP.Settings.LineH, w, SPROP.Settings.LineH, SPROP.Settings.BtnClrLine );		
			end
		end
		saveBtn.DoClick = function()
			local price = tonumber( price:GetValue() );
			local name = name:GetValue();
			
			if( type( price ) != "number" || price < 1 ) then
				LocalPlayer():ChatPrint( "Invalid price!" );
				return;
			end
			
			if( string.len( name ) < 1 ) then
				LocalPlayer():ChatPrint( "Invalid name!" );
				return;
			end
			
			if( !SPROP.ActiveDoorData[ 1 ] || !SPROP.ActiveDoorData[ 2 ] ) then
				LocalPlayer():ChatPrint( "No preview position set, left click with the admin gun (not at door) to set." );
				return;
			end
			
			local tbl = {};
			for i, v in pairs( SPROP.ActiveDoorIDs ) do
				table.insert( tbl, i:EntIndex() );
			end
			
			net.Start( "SPROP::AddProperty" );
			net.WriteTable( tbl );
			net.WriteFloat( price );
			net.WriteString( name );
			net.WriteString( util.TableToJSON( SPROP.ActiveDoorData ) );
			net.SendToServer();
			main:Close();
			SPROP.ActiveDoorIDs = {};
			SPROP.ActiveDoorData = {};
			hook.Remove( "PreDrawHalos", "SPROP::Halos" );
			SPROP.ActiveDoors = {};
		end		
	end

	y = 5;
	local x = main:GetWide() / 2 + SPROP.Settings.LineH / 2;
	local editTitle = vgui.Create( "DLabel", container );
	editTitle:SetFont( "SPROP::GeneralFont" );
	editTitle:SetText( SPROP.Settings.EditProperties );
	editTitle:SetPos( x, y );
	editTitle:SetColor( color_white );
	editTitle:SizeToContents();
	
	y = y + editTitle:GetTall() + 5;
	
	local editBox = vgui.Create( "DComboBox", container );
	editBox:SetText( SPROP.Settings.SelectProperty );
	editBox:SetSize( sideW, 30 );
	editBox:SetPos( x, y );
	editBox:SetColor( color_white );
	editBox:SetFont( "SPROP::BtnFont" );
	for i, v in pairs( SPROP.Props ) do
		editBox:AddChoice( i .. ". " .. v.name );
	end
	
	editBox.Paint = function( self, w, h )
		if( self:IsHovered() ) then
			draw.RoundedBox( 0, 0, 0, w, h, SPROP.Settings.BtnClrH );
			draw.RoundedBox( 0, 0, h-SPROP.Settings.LineH, w, SPROP.Settings.LineH, SPROP.Settings.BtnClrLineH );
		else
			draw.RoundedBox( 0, 0, 0, w, h, SPROP.Settings.BtnClr );
			draw.RoundedBox( 0, 0, h-SPROP.Settings.LineH, w, SPROP.Settings.LineH, SPROP.Settings.BtnClrLine );		
		end
	end
	
	editBox.OnSelect = function()
		buildRight( editBox:GetValue() );
	end
	y = y + editBox:GetTall();
	
	local oldElements = {};
	local function clear()
		for i, v in pairs( oldElements ) do
			if( IsValid( v ) ) then
				v:Remove();
			end
		end	
	end
	
	
	function buildRight( val )
		local id = false;
		local val = string.Explode( " ", val );
		val = string.Replace( val[ 1 ], ".", "" );
		val = tonumber( val );
		

		if( !SPROP.Props[ val ] ) then
			LocalPlayer():ChatPrint( "Unknown error" );
			return;
		end
		
		local data = SPROP.Props[ val ];
		clear();
		y = oldY;
		local info = vgui.Create( "DLabel", container );
		info:SetFont( "SPROP::GeneralFont" );
		local txt = string.Replace( SPROP.Settings.DoorsSelected, "[x]", table.Count( data.doors ) );
		info:SetText( txt );
		info:SetColor( color_white );
		info:SetPos( x, y );
		info:SizeToContents();
		y = y + info:GetTall();
		table.insert( oldElements, info );
		
		local price = vgui.Create( "DTextEntry", container );
		price:SetPos( x, y );
		price:SetSize( sideW, 30 );
		price:SetFont( "SPROP::BtnFont" );
		price:SetValue( data.price );
		table.insert( oldElements, price );
		y = y + price:GetTall() + 5;
		
		local del = vgui.Create( "DButton", container );
		del:SetText( SPROP.Settings.DelProperty );
		del:SetSize( sideW, 30 );
		del:SetPos( x, y );
		del:SetColor( color_white );
		del:SetFont( "SPROP::BtnFont" );
		del.Paint = function( self, w, h )
			if( self:IsHovered() ) then
				draw.RoundedBox( 0, 0, 0, w, h, SPROP.Settings.BtnClrH );
				draw.RoundedBox( 0, 0, h-SPROP.Settings.LineH, w, SPROP.Settings.LineH, SPROP.Settings.BtnClrLineH );
			else
				draw.RoundedBox( 0, 0, 0, w, h, SPROP.Settings.BtnClr );
				draw.RoundedBox( 0, 0, h-SPROP.Settings.LineH, w, SPROP.Settings.LineH, SPROP.Settings.BtnClrLine );		
			end
		end
		
		del.DoClick = function()
			if( del:GetText() == SPROP.Settings.DelProperty ) then
				del:SetText( SPROP.Settings.DelProperty2 );
				return;
			end
			net.Start( "SPROP::DelProperty" );
			net.WriteFloat( val );
			net.SendToServer();
			clear();
		end
		table.insert( oldElements, del );
	
		y = y + del:GetTall() + 5;
		
		
		local saveBtn = vgui.Create( "DButton", container );
		saveBtn:SetText( SPROP.Settings.SaveProperty );
		saveBtn:SetSize( sideW, 30 );
		saveBtn:SetPos( x, y );
		saveBtn:SetColor( color_white );
		saveBtn:SetFont( "SPROP::BtnFont" );
		saveBtn.Paint = function( self, w, h )
			if( self:IsHovered() ) then
				draw.RoundedBox( 0, 0, 0, w, h, SPROP.Settings.BtnClrH );
				draw.RoundedBox( 0, 0, h-SPROP.Settings.LineH, w, SPROP.Settings.LineH, SPROP.Settings.BtnClrLineH );
			else
				draw.RoundedBox( 0, 0, 0, w, h, SPROP.Settings.BtnClr );
				draw.RoundedBox( 0, 0, h-SPROP.Settings.LineH, w, SPROP.Settings.LineH, SPROP.Settings.BtnClrLine );		
			end
		end
		table.insert( oldElements, saveBtn );
		saveBtn.DoClick = function()
			local price = tonumber( price:GetValue() );
			
			if( type( price ) != "number" || price < 1 ) then
				LocalPlayer():ChatPrint( "Invalid price!" );
				return;
			end
			
			net.Start( "SPROP::EditProperty" );
			net.WriteFloat( val );
			net.WriteFloat( price );
			net.SendToServer();
			clear();
		end
	end	
	
end