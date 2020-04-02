function SPROP:TimeMenu( data )
	
	if( !table.HasValue( SPROP.Settings.AdminRanks, LocalPlayer():GetUserGroup() ) ) then
		return;
	end
	
	local main = vgui.Create( "DFrame" );
	main:SetSize( 600, 230 );
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
	
	local sideW = main:GetWide() / 2 - 20;
	
	local title = vgui.Create( "DLabel", main );
	title:SetText( "NPC Administration" );
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
		draw.RoundedBox( 0, 5, 87, w - 10, SPROP.Settings.LineH / 2, SPROP.Settings.LineClr );
	end
	
	local rebuild;
	local y = 5;
	local addTitle = vgui.Create( "DLabel", container );
	addTitle:SetFont( "SPROP::GeneralFont" );
	addTitle:SetText( "Select player(only shown if they have a property)" );
	addTitle:SetColor( color_white );
	addTitle:SizeToContents();
	addTitle:SetPos( container:GetWide() / 2 - addTitle:GetWide() / 2, y );
	y = y + addTitle:GetTall() + 5;
	
	local propList = vgui.Create( "DComboBox", container );
	propList:SetSize( container:GetWide() - 10, 30 );
	propList:SetPos( 5, y );
	propList:SetFont( "SPROP::GeneralFont" );
	propList:SetColor( color_white );
	propList:SetDrawBackground( false );
	propList.oldPaint = propList.Paint;
	propList.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, 1, SPROP.Settings.LineClr );
		draw.RoundedBox( 0, 0, h - 1, w, 1, SPROP.Settings.LineClr );
		draw.RoundedBox( 0, 0, 0, 1, h, SPROP.Settings.LineClr );
		draw.RoundedBox( 0, w - 1, 0, 1, h, SPROP.Settings.LineClr );
	end
	y = y + propList:GetTall() + 30;
	
	for i, v in pairs( data ) do
		propList:AddChoice( v[ 2 ] );
	end
	
	local selected;
	propList.OnSelect = function()
		selected = propList:GetValue();
		rebuild();
	end
	
	local e = {};
	function rebuild()
	
		for i, v in pairs( e ) do
			v:Remove();
		end
		
		e.list = vgui.Create( "DComboBox", container );
		e.list:SetSize( container:GetWide() - 10, 30 );
		e.list:SetPos( 5, y );
		e.list:SetFont( "SPROP::GeneralFont" );
		e.list:SetColor( color_white );
		e.list:SetDrawBackground( false );
		e.list.oldPaint = e.list.Paint;
		e.list.Paint = function( self, w, h )
			draw.RoundedBox( 0, 0, 0, w, 1, SPROP.Settings.LineClr );
			draw.RoundedBox( 0, 0, h - 1, w, 1, SPROP.Settings.LineClr );
			draw.RoundedBox( 0, 0, 0, 1, h, SPROP.Settings.LineClr );
			draw.RoundedBox( 0, w - 1, 0, 1, h, SPROP.Settings.LineClr );
		end
		
		for i, v in pairs( data ) do
			if( v[ 2 ] == selected ) then
				local prop = i;
				e.list:AddChoice( i .. "." .. SPROP.Props[ i ].name .. "(time remaining: " .. SPROP:GetRemainingTime( data[ i ][ 4 ] ) .. ")" );
			end
		end
		y = y + e.list:GetTall() + 5;
		
		local unown;
		e.remove = vgui.Create( "DButton", container );
		e.remove:SetSize( e.list:GetSize() );
		e.remove:SetPos( 5, y );
		e.remove:SetText( "Unown property" );
		e.remove:SetVisible( false );
		e.remove:SetColor( color_white );
		e.remove:SetFont( "SPROP::BtnFont" );
		e.remove.Paint = function( self, w, h )
			draw.RoundedBox( 0, 0, 0, w, 1, SPROP.Settings.LineClr );
			draw.RoundedBox( 0, 0, h - 1, w, 1, SPROP.Settings.LineClr );
			draw.RoundedBox( 0, 0, 0, 1, h, SPROP.Settings.LineClr );
			draw.RoundedBox( 0, w - 1, 0, 1, h, SPROP.Settings.LineClr );		
		end
		
		e.list.OnSelect = function()
			unown = tonumber( string.Explode( ".", e.list:GetValue() )[ 1 ] );
			e.remove:SetVisible( true );
		end
		
		e.remove.DoClick = function()
			if( e.remove:GetText() == "Unown property" ) then
				e.remove:SetText( "Are you sure?" );
			else
				net.Start( "SPROP::Unown" );
				net.WriteFloat( unown );
				net.SendToServer();
				for i, v in pairs( e ) do
					v:Remove();
				end
			end
		end
	end
	
	
end

net.Receive( "SPROP::TimeMenu", function( _ )
	SPROP:TimeMenu( net.ReadTable() );
end );

