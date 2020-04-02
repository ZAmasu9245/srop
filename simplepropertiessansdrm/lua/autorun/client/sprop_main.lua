local function SetupFonts()
	surface.CreateFont( "SPROP::GeneralFont", {
		font = "Teko Light",
		size = 32,
		weight = 300,
		antialias = true,
		shadow = true
	} );

	surface.CreateFont( "SPROP::BtnFont", {
		font = "Teko Light",
		size = 36,
		weight = 300,
		antialias = true,
		shadow = false
	} );
	
	surface.CreateFont( "SPROP::SmallFont", {
		font = "Teko Light",
		size = 25,
		weight = 200,
		antialias = true,
		shadow = false
	} );

	surface.CreateFont( "SPROP::NPCFont", {
		font = "Coolvetica",
		size = 32,
		weight = 200,
		antialias = true,
		shadow = false
	} );	
end
SetupFonts();
hook.Add( "InitPostEntity", "SPROP::SetupFonts", SetupFonts );

net.Receive( "SPROP::Open", function( _ )
	
	local data = net.ReadTable();
	local id = net.ReadFloat();
	local owned = net.ReadTable();
	
	
	if( !data.props[ 1 ] ) then
		LocalPlayer():ChatPrint( "I don't sell any properties yet." );
		return;
	end
	
	local rebuildProps;
	local active  = data.props[ 1 ];
	local allOwned = true;
	for i, v in pairs( data.props ) do
		if( !owned[ v ] || owned[ v ][ 1 ] == LocalPlayer():SteamID64() ) then
			allOwned = false;
			active = v;
			break;
		end
	end
	
	if( allOwned ) then
		LocalPlayer():ChatPrint( SPROP.Settings.NoneAvailable );
		return;
	end
	
	if( !owned[ data.props[ 1 ] ] ) then
		active = data.props[ 1 ];
	end
	
	local ref = SPROP.Props[ active ];
	if( !ref ) then
		LocalPlayer():ChatPrint( "I don't sell any properties yet." );
		return;
	end
	

	
	
	local main = vgui.Create( "DFrame" );
	main:MakePopup();
	main:ShowCloseButton( false );
	main:SetTitle( "" );
	main:SetDraggable( false );
	main:SetSize( ScrW(), ScrH() );
	main:Center();
	
	

	local noDraw = {};
	local function setNoDraw( skip )

		for i, v in pairs( noDraw ) do
			if( IsValid( v ) ) then
				v:SetNoDraw( false );
			end
		end
		
		/*
		for i, v in pairs( ents.FindInSphere( ref.view[ 1 ], 1000 ) ) do
			if( table.HasValue( SPROP.Settings.DontDrawThese, v:GetClass() ) ) then
				table.insert( noDraw, v );
				v:SetNoDraw( true );
			end
		end*/
		
		for i, v in pairs( SPROP.Settings.DontDrawThese ) do
			for i2, v2 in pairs( ents.FindByClass( v ) ) do
				table.insert( noDraw, v2 );
				v2:SetNoDraw( true );
			end
		end

	end
	
	local a = LocalPlayer():EyePos();
	local b = LocalPlayer():GetAngles();

	local sel = false;
	main.Paint = function( self, w, h )
		surface.SetDrawColor( color_white );
		surface.DrawRect( 0, 0, w, h );
		
		local rv = {};
		rv.x = 0;
		rv.y = 0;
		rv.w = w;
		rv.h = h;
		
		if( !sel ) then
			rv.origin = a;
			rv.angles = b;
		else
			rv.origin = ref.view[ 1 ];
			rv.angles = ref.view[ 2 ];
		end
		
		render.RenderView( rv );
	end
		
	main.OnClose = function()
		for i, v in pairs( noDraw ) do
			v:SetNoDraw( false );
		end
	end
	
	local close = vgui.Create( "SPROP::DButton", main );
	close:SetText( SPROP.Settings.Close );
	close:SetSize( 60, 25 );
	close:SetPos( main:GetWide() - close:GetWide() - 5, 5 );
	close.DoClick = function()
		net.Start( "SPROP::UnSpectate" );
		net.SendToServer();
		setNoDraw( true );
		main:Close();
	end
	
	local seller = vgui.Create( "DLabel", main );
	seller:SetText( data.name );
	seller:SetColor( color_white );
	seller:SetFont( "DermaLarge" );
	seller:SetPos( 5, 5 );
	seller:SizeToContents();
	

	
	local container = vgui.Create( "SPROP::DScrollPanel", main );
	container:SetSize( SPROP.Settings.BoxWidth, main:GetTall() / 2 );
	container:SetPos( main:GetWide() - container:GetWide(), main:GetTall() - container:GetTall() );
	container.Paint = function( self, w, h )
		
	end

	local sCon = vgui.Create( "DPanel", main );
	sCon:SetSize( SPROP.Settings.BoxWidth, 75 );
	sCon:SetPos( main:GetWide() - sCon:GetWide(), main:GetTall() - container:GetTall() - sCon:GetTall() * 1.25 );
	sCon.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, SPROP.Settings.GeneralClr );
		draw.RoundedBox( 0, 0, 0, w, 1, SPROP.Settings.LineClr );
		draw.RoundedBox( 0, 0, h - 1, w, 1, SPROP.Settings.LineClr );
		draw.RoundedBox( 0, 0, 0, 1, h, SPROP.Settings.LineClr );
	end
	
	activeList = data.props;
	local changeList = {};
	
	local searchBox = vgui.Create( "DTextEntry", sCon );
	searchBox:SetPos( 5, 5 );
	searchBox:SetSize( sCon:GetWide() - 10, 30 );
	searchBox.oldPaint = searchBox.Paint;
	searchBox:SetFont( "SPROP::GeneralFont" );
	searchBox:SetTextColor( Color( 255, 255, 255 ) );
	searchBox:SetHighlightColor( Color( 255, 255, 255 ) );
	searchBox:SetDrawBackground( false );
	searchBox:SetText( SPROP.Settings.SearchDefaultText );
	searchBox.Paint = function( self, w, h )
		searchBox.oldPaint( self, w, h );

		draw.RoundedBox( 0, 0, 0, w, 1, SPROP.Settings.LineClr );
		draw.RoundedBox( 0, 0, h - 1, w, 1, SPROP.Settings.LineClr );
		draw.RoundedBox( 0, 0, 0, 1, h, SPROP.Settings.LineClr );
		draw.RoundedBox( 0, w - 1, 0, 1, h, SPROP.Settings.LineClr );
	end
	
	searchBox.OnGetFocus = function()
		if( searchBox:GetText() == SPROP.Settings.SearchDefaultText ) then
			searchBox:SetText( "" );
		end
	end
	
	searchBox.OnLoseFocus = function()
		if( searchBox:GetText() == "" ) then
			searchBox:SetText( SPROP.Settings.SearchDefaultText );
		end
	end
	
	searchBox.OnTextChanged = function()
		local tbl = {};
		local search = searchBox:GetText();
		for i, v in pairs( SPROP.Props ) do
			if( !table.HasValue( data.props, i ) ) then
				continue;
			end
			
			if( string.find( v.name, search ) ) then
				table.insert( tbl, i );
			end
		end
		activeList = tbl;
		rebuildProps();
	end
	
	local sortBox = vgui.Create( "DComboBox", sCon );
	sortBox:SetPos( 5, 40 );
	sortBox:SetSize( searchBox:GetSize() );
	sortBox.oldPaint = sortBox.Paint;
	sortBox:SetFont( "SPROP::GeneralFont" );
	sortBox:SetColor( color_white );
	sortBox:SetDrawBackground( false );
	sortBox.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, 1, SPROP.Settings.LineClr );
		draw.RoundedBox( 0, 0, h - 1, w, 1, SPROP.Settings.LineClr );
		draw.RoundedBox( 0, 0, 0, 1, h, SPROP.Settings.LineClr );
		draw.RoundedBox( 0, w - 1, 0, 1, h, SPROP.Settings.LineClr );
	end
	
	for i, v in pairs( SPROP.Settings.SortOptions ) do
		sortBox:AddChoice( v );
	end
	
	sortBox.OnSelect = function()
		
		local tbl = {};
		local val = sortBox:GetValue();
		if( val == SPROP.Settings.SortOptions[ 1 ] ) then
			local prices = {};
			for i, v in pairs( SPROP.Props ) do
				if( table.HasValue( data.props, i ) ) then
					prices[ i ] = { price = v.price, id = i };
				end
			end
			table.SortByMember( prices, "price", true );
			for i, v in pairs( prices ) do
				table.insert( tbl, v.id );
			end
		elseif( val == SPROP.Settings.SortOptions[ 2 ] ) then
			local prices = {};
			for i, v in pairs( SPROP.Props ) do
				if( table.HasValue( data.props, i ) ) then
					prices[ i ] = { price = v.price, id = i };
				end
			end
			table.SortByMember( prices, "price", false );
			for i, v in pairs( prices ) do
				table.insert( tbl, v.id );
			end
		elseif( val == SPROP.Settings.SortOptions[ 3 ] ) then
			for i, v in pairs( SPROP.Props ) do
				if( !table.HasValue( data.props, i ) ) then
					continue;
				end
				if( !owned[ i ] ) then
					table.insert( tbl, i );
				end
			end
			
			for i, v in pairs( SPROP.Props ) do
				if( !table.HasValue( data.props, i ) ) then
					continue;
				end			
				if( owned[ i ] ) then
					table.insert( tbl, i );
				end
			end	
		else
			for i, v in pairs( SPROP.Props ) do
				if( !table.HasValue( data.props, i ) ) then
					continue;
				end			
				if( owned[ i ] ) then
					table.insert( tbl, i );
				end
			end
			
			for i, v in pairs( SPROP.Props ) do
				if( !table.HasValue( data.props, i ) ) then
					continue;
				end			
				if( !owned[ i ] ) then
					table.insert( tbl,i );
				end
			end			
		end
		activeList = table.Copy( tbl );
		rebuildProps();
	end
	
	local tbl = {};
	local prices = {};
	for i, v in pairs( SPROP.Props ) do
		if( table.HasValue( data.props, i ) ) then
			prices[ i ] = { price = v.price, id = i };
		end
	end
	table.SortByMember( prices, "price", true );
	for i, v in pairs( prices ) do
		table.insert( tbl, v.id );
	end
	activeList = tbl;
	sortBox:SetText( SPROP.Settings.SortOptions[ 1 ] );
	
	local propTitle = vgui.Create( "DLabel", main );
	propTitle:SetColor( color_white );
	propTitle:SetFont( "Trebuchet24" );
	propTitle:SizeToContents();
	propTitle:SetVisible( false );
	propTitle.Rebuild = function()
		propTitle:SetVisible( true );
		propTitle:SetText( ref.name );
		propTitle:SizeToContents();
		propTitle:SetPos( main:GetWide() / 2 - propTitle:GetWide() / 2, main:GetTall() - propTitle:GetTall() - 45 );	
	end
	propTitle:Rebuild();
	
	local propBuy = vgui.Create( "SPROP::DButton", main );
	propBuy:SetSize( 150, 30 );
	propBuy.Clicks = 0;
	propBuy:SetPos( main:GetWide() / 2 - propBuy:GetWide() / 2, main:GetTall() - propBuy:GetTall() - 10 );
	propBuy.DoClick = function()
		if( propBuy.Clicks != 1 ) then
			propBuy:SetText( SPROP.Settings.Confirm );
			propBuy.Clicks = propBuy.Clicks + 1;
		else
			net.Start( "SPROP::Purchase" );
			net.WriteFloat( active );
			net.SendToServer();
			main:Close();
		end
	end
	propBuy.Rebuild = function()
		propBuy:SetVisible( true );
		if( owned[ active ] ) then
			if( SPROP.Settings.TimedProperties ) then
				if( owned[ active ][ 1 ] == LocalPlayer():SteamID64() ) then
					propBuy:SetText( SPROP.Settings.Extend );
				else
					propBuy:SetVisible( false );
				end
			else
				if( owned[ active ][ 1 ] == LocalPlayer():SteamID64() ) then
					propBuy:SetText( SPROP.Settings.Sell );
				else
					propBuy:SetVisible( false );
				end
			end
		else
			propBuy:SetText( SPROP.Settings.Purchase );
		end
	end
	
	local propSell = vgui.Create( "SPROP::DButton", main );
	propSell:SetSize( 150, 30 );
	propSell:SetText( SPROP.Settings.Sell );
	propSell.Clicks = 0;
	propSell:SetPos( ScrW() / 2 + 5 );
	propSell.DoClick = function()
		if( propSell.Clicks != 1 ) then
			propSell:SetText( SPROP.Settings.Confirm );
			propSell.Clicks = propSell.Clicks + 1;
		else
			net.Start( "SPROP::Unown" );
			net.WriteFloat( active );
			net.SendToServer();
			main:Close();
		end
	end
	propSell.Rebuild = function()
		propSell:SetVisible( true );
		if( owned[ active ] ) then
			if( SPROP.Settings.TimedProperties ) then
				if( owned[ active ][ 1 ] == LocalPlayer():SteamID64() ) then
					propSell:SetText( SPROP.Settings.Sell );
					propBuy:SetPos( ScrW() / 2 - propBuy:GetWide() - 5, main:GetTall() - propBuy:GetTall() - 10 );
					propSell:SetPos( ScrW() / 2 + 5, main:GetTall() - propBuy:GetTall() - 10 );
				else
					propSell:SetVisible( false );
					propBuy:SetPos( main:GetWide() / 2 - propBuy:GetWide() / 2, main:GetTall() - propBuy:GetTall() - 10, main:GetTall() - propBuy:GetTall() - 10 );
				end
			end
		else
			propSell:SetVisible( false );
			propBuy:SetPos( main:GetWide() / 2 - propBuy:GetWide() / 2, main:GetTall() - propBuy:GetTall() - 10, main:GetTall() - propBuy:GetTall() - 10 );
		end
	end
	
	if( !sel ) then
		propSell:SetVisible( false );
		propBuy:SetVisible( false );
		propTitle:SetVisible( false );
	end
	
	
	local buttons = {};
	
	function rebuildProps()
		local y = 0;
		for i, v in pairs( buttons ) do
			v:Remove();
		end

		for i, v in pairs( activeList ) do
			if( !SPROP.Props[ v ] ) then
				continue;
			end
			local r = SPROP.Props[ v ];
			buttons[ i ] = vgui.Create( "SPROP::DButton", container );
			buttons[ i ]:SetSize( container:GetWide(), 60 );
			buttons[ i ]:SetText( "" );
			buttons[ i ]:SetPos( 0, y );
			if( ( table.Count( data.props ) * buttons[ i ]:GetTall() ) > container:GetTall() ) then
				buttons[ i ]:SetWide( container:GetWide() - 15 );
			end
			
			local oldPaint = buttons[ i ].Paint;
			
			if( owned[ v ] && owned[ v ][ 1 ] == LocalPlayer():SteamID64() ) then
			
				local currentOwners = {};
				for i2, v2 in pairs( owned[ v ][ 3 ] ) do
					table.insert( currentOwners, { v2[ 1 ], v2[ 2 ] } );
				end
				
				local ownersAvailable = {};
				for i2, v2 in pairs( player.GetAll() ) do
					if( v2 == LocalPlayer() ) then
						continue;
					end
					
					local av = true;
					for i3, v3 in pairs( currentOwners ) do
						if( v2:SteamID64() == v3[ 1 ] ) then
							av = false;
							break;
						end
					end
					if( !av ) then
						continue;
					end
					
					ownersAvailable[ v2:Nick() ] = v2:EntIndex();
				end
				
				buttons[ i ].addCoOwner = vgui.Create( "DButton", buttons[ i ] );
				buttons[ i ].addCoOwner:SetSize( 16, 16 );
				buttons[ i ].addCoOwner:SetPos( buttons[ i ]:GetWide() - 56, buttons[ i ]:GetTall() / 2 - 8 );
				buttons[ i ].addCoOwner.mat = Material( "icon16/group_add.png" );
				buttons[ i ].addCoOwner:SetText( "" );
				buttons[ i ].addCoOwner.Paint = function( self, w, h )
					surface.SetDrawColor( color_white );
					surface.SetMaterial( buttons[ i ].addCoOwner.mat );
					surface.DrawTexturedRect( 0, 0, 16, 16 );
				end
				
				buttons[ i ].addCoOwner.DoClick = function()
					
					local menu = DermaMenu();
					local btns = {};
					for i2, v2 in pairs( ownersAvailable ) do
						btns[ i2 ] = menu:AddOption( i2 );
						btns[ i2 ].choice = v2;
						btns[ i2 ].DoClick = function()
							net.Start( "SPROP::AddCoOwner" );
							net.WriteFloat( v );
							net.WriteFloat( btns[ i2 ].choice );
							net.SendToServer();
						end
					end
					
					menu:Open();
					
				end
				
				buttons[ i ].addCoOwner:SetToolTip( SPROP.Settings.AddCoOwner );
				

				
				
				buttons[ i ].delCoOwner = vgui.Create( "DButton", buttons[ i ] );
				buttons[ i ].delCoOwner:SetSize( 16, 16 );
				buttons[ i ].delCoOwner:SetPos( buttons[ i ]:GetWide() - 36, buttons[ i ]:GetTall() / 2 - 8 );
				buttons[ i ].delCoOwner.mat = Material( "icon16/group_delete.png" );
				buttons[ i ].delCoOwner:SetText( "" );
				buttons[ i ].delCoOwner.Paint = function( self, w, h )
					surface.SetDrawColor( color_white );
					surface.SetMaterial( buttons[ i ].delCoOwner.mat );
					surface.DrawTexturedRect( 0, 0, 16, 16 );
				end
				
				buttons[ i ].delCoOwner.DoClick = function()
					
					local menu = DermaMenu();
					local btns = {};
					for i2, v2 in pairs( currentOwners ) do
						btns[ i ] = menu:AddOption( v2[ 2 ] );
						btns[ i ].choice = v2[ 1 ];
						btns[ i ].DoClick = function()
							net.Start( "SPROP::DelCoOwner" );
							net.WriteFloat( v );
							net.WriteTable( { btns[ i ].choice });
							net.SendToServer();
						end
					end
					
					menu:Open();
					
				end			
			else
				if( SPROP.Settings.CantSeeOwned && owned[ v ] ) then
					buttons[ i ]:SetEnabled( false );
				end
			end
			


			buttons[ i ].Paint = function( self, w, h )
				oldPaint( self, w, h );
				local clr = Color( 122, 0, 150 );
				if( buttons[ i ]:IsHovered() ) then
					clr = Color( 173, 216, 230 );
				end
				
				surface.SetTextColor( color_white );
				surface.SetFont( "TargetID" );
				surface.SetTextPos( 5, 5 );
				surface.DrawText( r.name );
		
				local text = "";
				if( owned[ v ]  ) then
					if( SPROP.Settings.TimedProperties ) then
						local w, h = surface.GetTextSize( SPROP:GetRemainingTime( owned[ v ][ 4 ] ) );
						surface.SetTextPos( buttons[ i ]:GetWide() - w - 5, 5 );
						surface.DrawText( SPROP:GetRemainingTime( owned[ v ][ 4 ] ) );
					end
					surface.SetTextPos( 5, 24 );
					if( owned[ v ][ 1 ] != LocalPlayer():SteamID64() ) then
						clr = Color( 255, 0, 0 );
						text = string.Replace( SPROP.Settings.Owned, "[x]", owned[ v ][ 2 ] );
						surface.DrawText( text );
					else
						clr = Color( 0, 255, 0 );
						text = string.Replace( SPROP.Settings.Owned, "[x]", SPROP.Settings.OwnedByYou );
						surface.DrawText( text );
					end
				else
					surface.SetTextPos( 5, 24 );
					surface.DrawText( SPROP.Settings.ForSale );
				end			
				surface.SetTextPos( 5, 43 );
				surface.DrawText( DarkRP.formatMoney( r.price ) );
				
				draw.RoundedBox( 0, 0, h - 1, w, 1, clr );
			end
			y = y + buttons[ i ]:GetTall();
			
			buttons[ i ].DoClick = function()
				net.Start( "SPROP::Select" );
				net.WriteFloat( v );
				net.SendToServer();
				setNoDraw();
				
				timer.Simple( 0.15, function()
					sel = true;
					setNoDraw();
					active = v;
					ref = SPROP.Props[ active ];
					propTitle:Rebuild();
					propBuy:Rebuild();
					propSell:Rebuild();
				end );

			end
		end
	end
	rebuildProps();
	
end );


function SPROP:DrawKeyHUD( id )
	local tbl = SPROP.Props[ id ];
	if( !tbl ) then return end
	local material = Material( "materials/sprop_key.png" );
	hook.Add( "HUDPaint", "SPROP::DrawKeysHUD", function()
		
		for i, v in pairs( tbl.doors ) do
			if( !IsValid( v ) ) then
				continue;
			end
			
			local modelData = v:OBBMaxs();
			local pos = v:GetPos():ToScreen();
			local dist = v:GetPos():Distance( LocalPlayer():GetPos() );
			
			surface.SetDrawColor( color_white );
			surface.SetMaterial( material );
			surface.DrawTexturedRect( pos.x, pos.y, 16, 16 );
			
			dist = math.Round( ( dist / 17.3 ) - 3, 0 );
			draw.SimpleText( dist .. "m", "SPROP::SmallFont", pos.x + 21, pos.y, color_white );
		end
		
	end );
	timer.Simple( SPROP.Settings.ShowIconWhenBoughtTime, function()
		hook.Remove( "HUDPaint", "SPROP::DrawKeysHUD" );
	end );
end


local PANEL = {};
function PANEL:Init()
	self:SetFont( "ChatFont" );
	self:SetColor( color_white );
end
function PANEL:Paint( w, h )
	if( self:IsHovered() ) then
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 120 ) );
	else
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 180 ) );
	end
end


vgui.Register( "SPROP::DButton", PANEL, "DButton" );

PANEL = {};
function PANEL:Init()

	local sbar = self:GetVBar();
	
	function sbar:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 0 ) );
	end
	
	function sbar.btnUp:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 90, 90, 90, 255 ) );
	end
	
	function sbar.btnDown:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 90, 90, 90, 255 ) );
	end
	
	function sbar.btnGrip:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 140, 140, 140, 255 ) );
	end

end


vgui.Register( "SPROP::DScrollPanel", PANEL, "DScrollPanel" );


net.Receive( "SPROP::AddProperty", function( _ )

	local id = net.ReadFloat();
	local data = net.ReadTable();
	SPROP.Props[ id ] = data;
end );


net.Receive( "SPROP::DelProperty", function( _ )

	local id = net.ReadFloat();
	SPROP.Props[ id ] = nil;

end );