function SPROP:NPCMenu( data, _e )
	
	_e = Entity( _e );
	
	if( !table.HasValue( SPROP.Settings.AdminRanks, LocalPlayer():GetUserGroup() ) ) then
		return;
	end
	
	local main = vgui.Create( "DFrame" );
	main:SetSize( 600, 370 );
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
	end
	
	local y = 5;
	local addTitle = vgui.Create( "DLabel", container );
	addTitle:SetFont( "SPROP::GeneralFont" );
	addTitle:SetText( SPROP.Settings.NPCAdmin );
	addTitle:SetColor( color_white );
	addTitle:SizeToContents();
	addTitle:SetPos( container:GetWide() / 2 - addTitle:GetWide() / 2, y );
	y = y + addTitle:GetTall() + 5;
	local startY = y;
	
	local name = vgui.Create( "DTextEntry", container );
	name:SetPos( 10, y );
	name:SetSize( sideW, 30 );
	name:SetFont( "SPROP::BtnFont" );
	name:SetText( data.name or SPROP.Settings.NPCName );
	name.OnGetFocus = function()
		if( name:GetText() == SPROP.Settings.NPCName ) then
			name:SetText( "" );
		end
	end
	
	name.OnLoseFocus = function()
		if( name:GetText() == "" ) then
			name:SetText( SPROP.Settings.NPCName );
		end
	end
	y = y + name:GetTall() + 5;

	local mdl = vgui.Create( "DTextEntry", container );
	mdl:SetPos( 10, y );
	mdl:SetSize( sideW, 30 );
	mdl:SetFont( "SPROP::BtnFont" );
	mdl:SetText( _e:GetModel() );
	mdl.OnGetFocus = function()
		if( mdl:GetText() == SPROP.Settings.NPCName ) then
			mdl:SetText( _e:GetModel() );
		end
	end
	
	mdl.OnLoseFocus = function()
		if( mdl:GetText() == "" ) then
			mdl:SetText( SPROP.Settings.NPCName );
		end
	end
	y = y + mdl:GetTall() + 5;

	local ranks = vgui.Create( "SPROP::DScrollPanel", container );
	ranks:SetSize( sideW, container:GetTall() - y - 50 );
	ranks:SetPos( 10, y );
	ranks.Paint = function( self, w, h )
	
	end
	
	local ranksTitle = vgui.Create( "DLabel", ranks );
	ranksTitle:SetFont( "SPROP::GeneralFont" );
	ranksTitle:SetText( SPROP.Settings.Restricted );
	ranksTitle:SetColor( color_white );
	ranksTitle:SizeToContents();
	ranksTitle:SetPos( 0, 0 );
	
	local ranksLayout = vgui.Create( "DIconLayout", ranks );
	ranksLayout:SetSize( ranks:GetWide(), ranks:GetTall() - 25 );
	ranksLayout:SetPos( 0, 25 );
	ranksLayout:SetSpaceY( 3 );

    local grps = {};
    if( serverguard ) then
        for i, v in pairs( serverguard.ranks:GetStored() ) do
            table.insert( grps, i );
        end
    else
        if( !xgui || !xgui.data || !xgui.data.groups ) then
            for i, v in pairs( CAMI:GetUsergroups() ) do
                grps[ #grps + 1 ] = v;
            end
        else
            grps = xgui.data.groups;
        end
    end
			
	local ranksTracker = {};

	for i, v in pairs( grps ) do
		local panel = ranksLayout:Add( "DPanel" );
		panel:SetSize( ranksLayout:GetWide(), 25 );
		panel.Paint = function( self, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 125, 125, 125, 90 ) );
			draw.RoundedBox( 0, 0, h - 1, w, 1, SPROP.Settings.LineClr );
		end
		panel.checkbox = vgui.Create( "DCheckBox", panel );
		panel.checkbox:SetPos( 5, 5 );
		if( data.ranks && data.ranks[ v ] ) then
			panel.checkbox:SetChecked( true );
			ranksTracker[ v ] = true;
		end
		panel.id = v;
		panel.checkbox.OnChange = function()
			if( panel.checkbox:GetChecked() ) then
				ranksTracker[ panel.id ] = true;
			else
				ranksTracker[ panel.id ] = nil;
			end
		end
		
		panel.label = vgui.Create( "DLabel", panel );
		panel.label:SetColor( color_white );
		panel.label:SetText( v );
		panel.label:SetFont( "SPROP::SmallFont" );
		panel.label:SetPos( 7.5 + panel.checkbox:GetWide(), 0 );
		panel.label:SizeToContents();
	end
	
	--
	
	local props = vgui.Create( "SPROP::DScrollPanel", container );
	props:SetSize( sideW - 5, container:GetTall() - startY - 40 );
	props:SetPos( sideW + 15, startY );
	props.Paint = function( self, w, h )
	
	end
	
	local propsTitle = vgui.Create( "DLabel", props );
	propsTitle:SetFont( "SPROP::GeneralFont" );
	propsTitle:SetText( SPROP.Settings.Selling );
	propsTitle:SetColor( color_white );
	propsTitle:SizeToContents();
	propsTitle:SetPos( 0, 0 );
	
	local layout = vgui.Create( "DIconLayout", props );
	layout:SetSize( props:GetWide(), props:GetTall() - 40 );
	layout:SetPos( 0, 35 );
	layout:SetSpaceY( 3 );
	
	local tracker = {};
	for i, v in pairs( SPROP.Props ) do
		local panel = layout:Add( "DPanel" );
		panel:SetSize( layout:GetWide(), 25 );
		panel.Paint = function( self, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 125, 125, 125, 90 ) );
			draw.RoundedBox( 0, 0, h - 1, w, 1, SPROP.Settings.LineClr );
		end
		panel.checkbox = vgui.Create( "DCheckBox", panel );
		panel.checkbox:SetPos( 5, 5 );
		panel.id = i;
		if( data.props && table.HasValue( data.props, i ) ) then
			panel.checkbox:SetChecked( true );
			table.insert( tracker, panel.id );
		end
		
		panel.checkbox.OnChange = function()
			if( panel.checkbox:GetChecked() ) then
				table.insert( tracker, panel.id );
			else
				table.RemoveByValue( tracker, panel.id );
			end
		end
		
		panel.label = vgui.Create( "DLabel", panel );
		panel.label:SetColor( color_white );
		panel.label:SetText( v.name );
		panel.label:SetFont( "SPROP::SmallFont" );
		panel.label:SetPos( 7.5 + panel.checkbox:GetWide(), 0 );
		panel.label:SizeToContents();
	end
	
	
	local saveBtn = vgui.Create( "DButton", container );
	saveBtn:SetText( SPROP.Settings.SaveNPC );
	saveBtn:SetSize( sideW - 5, 30 );
	saveBtn:SetPos( 10, container:GetTall() - 40 );
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
		local ranks = ranksTracker;
		local name = name:GetValue();
		local mdl = mdl:GetValue();
		local props = tracker;
		
		net.Start( "SPROP::SaveNPC" );
		net.WriteString( name );
		net.WriteString( mdl );		
		net.WriteTable( ranks );
		net.WriteTable( props );
		net.WriteFloat( _e:EntIndex() );
		net.SendToServer();
		main:Close();
	end

	local delBtn = vgui.Create( "DButton", container );
	delBtn:SetText( SPROP.Settings.DelNPC );
	delBtn:SetSize( sideW, 30 );
	delBtn:SetPos( sideW + 15, container:GetTall() - 40 );
	delBtn:SetColor( color_white );
	delBtn:SetFont( "SPROP::BtnFont" );
	delBtn.Paint = function( self, w, h )
		if( self:IsHovered() ) then
			draw.RoundedBox( 0, 0, 0, w, h, SPROP.Settings.BtnClrH );
			draw.RoundedBox( 0, 0, h-SPROP.Settings.LineH, w, SPROP.Settings.LineH, SPROP.Settings.BtnClrLineH );
		else
			draw.RoundedBox( 0, 0, 0, w, h, SPROP.Settings.BtnClr );
			draw.RoundedBox( 0, 0, h-SPROP.Settings.LineH, w, SPROP.Settings.LineH, SPROP.Settings.BtnClrLine );		
		end
	end
	delBtn.DoClick = function()
		if( delBtn:GetText() == SPROP.Settings.DelNPC ) then
			delBtn:SetText( SPROP.Settings.DelNPC2 );
			return;
		else
			net.Start( "SPROP::DelNPC" );
			net.WriteFloat( _e:EntIndex() );
			net.SendToServer();
			main:Close();
		end
	end
	
end

net.Receive( "SPROP::NPC", function( _ )
	SPROP:NPCMenu( net.ReadTable(), net.ReadFloat() );
end );

hook.Add( "HUDPaint", "SPROP::NPCName", function()
	
	for i, v in pairs( ents.FindByClass( "sprop_npc" ) ) do
		if( v:GetPos():Distance( LocalPlayer():GetPos() ) < 200 ) then
			local pos = v:GetPos() + Vector( 0, 0, 75 + ( v:GetPos():Distance( LocalPlayer():GetPos() ) / 10 ) );
			pos = pos:ToScreen();
			if( LocalPlayer():IsLineOfSightClear( v:GetPos() + Vector( 0, 0, 80 ) ) ) then
				local name = v:GetNWString( "spropName", "No name" );
				
				surface.SetFont( "SPROP::NPCFont" );
				local w, h = surface.GetTextSize( name );
				draw.DrawText( name, "SPROP::NPCFont", pos.x - ( w / 2 ) - 3, pos.y, Color( 0, 0, 0, 255 ), ALIGN_CENTER );
				draw.DrawText( name, "SPROP::NPCFont", pos.x - ( w / 2 ), pos.y, Color( 255, 255, 255, 255 ), ALIGN_CENTER );
			end
		end
	end
	
end );

--timer.Simple( 5, function() if( !table.HasValue( SPROP.Settings.AdminRanks, LocalPlayer():GetUserGroup() ) ) then usermessage.Hook("KeysMenu", function() return end ) end end );