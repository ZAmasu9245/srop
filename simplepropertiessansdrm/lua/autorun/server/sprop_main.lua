util.AddNetworkString( "SPROP::Open" );
util.AddNetworkString( "SPROP::Purchase" );
util.AddNetworkString( "SPROP::AddProperty" );
util.AddNetworkString( "SPROP::DelProperty" );
util.AddNetworkString( "SPROP::EditProperty" );
util.AddNetworkString( "SPROP::NPC" );
util.AddNetworkString( "SPROP::DelNPC" );
util.AddNetworkString( "SPROP::SaveNPC" );



function SPROP:Initiate()
	timer.Simple( 10, function()
		MsgC( Color( 0, 255, 0 ), "\n--------------------------\n" );
		MsgC( Color( 0, 255, 0 ), "Loading Simple Properties\n" );

		if( file.Exists( "sprop_" .. game.GetMap() .. "_npcs.txt", "DATA" ) ) then
			SPROP.NPCs = util.JSONToTable( file.Read( "sprop_" .. game.GetMap() .. "_npcs.txt" ) );
			MsgC( Color( 0, 255, 0 ), "\nLoaded " .. table.Count( SPROP.NPCs ) .. " NPCs.\n" );
		else
			MsgC( Color( 0, 255, 0 ), "\nNo NPCs found saved for this map.\n" );
		end
		
		if( file.Exists( "sprop_" .. game.GetMap() .. "_properties.txt", "DATA" ) ) then
			SPROP.Props = util.JSONToTable( file.Read( "sprop_" .. game.GetMap() .. "_properties.txt" ) );
			MsgC( Color( 0, 255, 0 ), "\nLoaded " .. table.Count( SPROP.Props ) .. " properties.\n" );
			c = 0;
			for i, v in pairs( SPROP.Props ) do
				if( type( i ) != "number" ) then
					MsgC( Color( 0, 255, 255 ), "\n\nConverting property " .. i .. " to new version compatibility.\n" );
					v.name = i;
					local data = table.Copy( v );
					table.insert( SPROP.Props, data );
					SPROP.Props[ i ] = nil;
					c = c + 1;
				end
			end
			if( c > 0 ) then
				MsgC( Color( 0, 255, 0 ), "\nConverted " .. c .. " properties.\n\n" );
			end
		else
			MsgC( Color( 0, 255, 0 ), "\nNo properties found saved for this map.\n" );
		end
		
		if( SPROP.Settings.TimedProperties ) then
			if( file.Exists( "sprop_" .. game.GetMap() .. "_permanent.txt", "DATA" ) ) then
				SPROP.Tracker	= util.JSONToTable( file.Read( "sprop_" .. game.GetMap() .. "_permanent.txt" ) );
				MsgC( Color( 0, 255, 0 ), "\nLoaded " .. table.Count( SPROP.Tracker ) .. " owned properties.\n" );
			else
				MsgC( Color( 0, 255, 0 ), "\nNo owned properties found.\n" );
			end
		else
			MsgC( Color( 0, 255, 0 ), "\nTimed properties DISABLED, if you wish to use it please set to true in config.\n" );
		end
		
		MsgC( Color( 0, 255, 0 ), "\n--------------------------\n" );
		MsgC( Color( 0, 255, 0 ), "Last updated: 2018-01-08\n" );
		MsgC( Color( 0, 255, 0 ), "Fixed a saving problem" );
		MsgC( Color( 0, 255, 0 ), "\n--------------------------\n" );
		
		SPROP.Version = SPROP.Version or "1.0.0";
		if( SPROP.Version != "2.0.4" ) then
			hook.Add( "PlayerInitialSpawn", "SPROP::Info", function( _p )
				if( _p:IsSuperAdmin() ) then
					timer.Simple( 20, function()
						_p:ChatPrint( "A new version is available for Simple Properties!" );
						_p:ChatPrint( "Installed: " .. ( SPROP.Version or "1.0.0" ) );
						_p:ChatPrint( "Latest: 2.0.4" );
						_p:ChatPrint( "Fixed Co-Owning error." );
						_p:ChatPrint( "Fixed not drawing models if out of range." );
					end );
				end
			end );
		end
		timer.Simple( 10, function()
			SPROP:Setup();
		end );
		DarkRP.removeChatCommand( "unownalldoors" );
		if( !SPROP.Settings.AllowBuyKeys ) then
			--DarkRP.removeChatCommand( "toggleown" );
		end
		
		for i, v in pairs( player.GetAll() ) do
			SPROP:UpdatePlayer( v );
		end
	end );
end
SPROP:Initiate();

hook.Add( "InitPostEntity", "SPROP::Setup", function()

	SPROP:Initiate();
	
end );

hook.Add( "playerSellDoor", "SPROP::playerBuyDoor", function( _p, _e )

	for i, v in pairs( SPROP.Props ) do
		for i2, v2 in pairs( v.doors ) do
			if( ents.GetMapCreatedEntity( v2 )  == _e ) then
				return false, "You can only sell this through a property dealer.";
			end
		end
	end

end );

function SPROP:IsDoorAlready( id )

	for i, v in pairs( SPROP.Props ) do
		for i2, v2 in pairs( v.doors ) do
			if( v2 == id ) then
				return true;
			end
		end
	end
	return false;

end

net.Receive( "SPROP::DelProperty", function( _, _p )

	local del = net.ReadFloat();
	if( !table.HasValue( SPROP.Settings.AdminRanks, _p:SPROPUsergroup() ) ) then
		_p:ChatPrint( "<" );
		return;
	end
	
	if( SPROP.Props[ del ] ) then
		for i, v in pairs( SPROP.Props[ del ].doors ) do
			local door = ents.GetMapCreatedEntity( v );
			door:setKeysNonOwnable( false );
			door:removeAllKeysExtraOwners();
			door:removeAllKeysAllowedToOwn();
			door:setKeysTitle( "" );
		end
		SPROP.Props[ del ] = nil;
	end
	
	net.Start( "SPROP::DelProperty" );
	net.WriteFloat( del );
	net.Broadcast();
	
	_p:ChatPrint( "Property deleted." );
	MsgC( Color( 0, 255, 0 ), _p:Nick() .. " deleted property " .. del .. ".\n\n" );
	file.Write( "sprop_" .. game.GetMap() .. "_properties.txt", util.TableToJSON( SPROP.Props ) );

end );

net.Receive( "SPROP::EditProperty", function( _, _p )

	local id = net.ReadFloat();
	local price = net.ReadFloat();
	if( !table.HasValue( SPROP.Settings.AdminRanks, _p:SPROPUsergroup() ) ) then
		_p:ChatPrint( "<" );
		return;
	end
	
	if( SPROP.Props[ id ] ) then
		SPROP.Props[ id ].price = price;
	end

	net.Start( "SPROP::AddProperty" );
	net.WriteFloat( id );
	net.WriteTable( SPROP.Props[ id ] );
	net.Broadcast();

	_p:ChatPrint( "Property modified." );
	MsgC( Color( 0, 255, 0 ), _p:Nick() .. " modified property " .. id .. ".\n\n" );
	file.Write( "sprop_" .. game.GetMap() .. "_properties.txt", util.TableToJSON( SPROP.Props ) );
	
end );

net.Receive( "SPROP::AddProperty", function( _, _p )

	local doors = net.ReadTable();
	local price = net.ReadFloat();
	local name = net.ReadString();
	local viewdata = util.JSONToTable( net.ReadString() );
	if( !table.HasValue( SPROP.Settings.AdminRanks, _p:SPROPUsergroup() ) ) then
		_p:ChatPrint( "<" );
		return;
	end
	
	local tbl = {};
	for i, v in pairs( doors ) do
		local _e = Entity( v );
		
		if( _e:MapCreationID() ) then
			if( SPROP:IsDoorAlready( _e:MapCreationID() ) ) then
				_p:ChatPrint( "One or more of the doors are already used in another property configuration!" );
				return;
			end
			table.insert( tbl, _e:MapCreationID() );
		end
		_e:setKeysNonOwnable( true );
		_e:setKeysTitle( name );
		_e:keysLock();
	end
	
	local data = {};
	data.price = price;
	data.doors = tbl;
	data.view = viewdata;
	data.name = name;
	table.insert( SPROP.Props, data );

	
	file.Write( "sprop_" .. game.GetMap() .. "_properties.txt", util.TableToJSON( SPROP.Props ) );
	MsgC( Color( 0, 255, 0 ), "\nProperty " .. name .. ", containing of " .. table.Count( data.doors ) .. " doors added for $" .. data.price .. " by " .. _p:Nick() .. ".\n\n" );
	_p:ChatPrint( "Property added!" );
	
	for i, v in pairs( player.GetAll() ) do
		SPROP:SendProperty( #SPROP.Props, v );
	end
	
end );

hook.Add( "PlayerInitialSpawn", "SPROP::UpdatePlayer", function( _p )
	SPROP:UpdatePlayer( _p );
	_p:PrintMessage( HUD_PRINTCONSOLE, "\n\nLoading properties..\n\n" );
end );

function SPROP:SendProperty( id, _p )
	if( !SPROP.Props[ id ] || !_p ) then
		return;
	end
	
	local tbl = table.Copy( SPROP.Props[ id ] );
	for i, v in pairs( tbl.doors ) do
		tbl.doors[ i ] = ents.GetMapCreatedEntity( v );
	end
	net.Start( "SPROP::AddProperty" );
	net.WriteFloat( id );
	net.WriteTable( tbl );
	net.Send( _p );
end

net.Receive( "SPROP::SaveNPC", function( _, _p )

	if( !table.HasValue( SPROP.Settings.AdminRanks, _p:SPROPUsergroup() ) ) then
		_p:ChatPrint( "<" );
		return;
	end
	
	local name = net.ReadString();
	local mdl = net.ReadString();
	local ranks = net.ReadTable();
	local props = net.ReadTable();
	local _e = Entity( net.ReadFloat() );
	
	local badMdls = { "models/zombie/classic.mdl", "models/vortigaunt.mdl" };
	if( table.HasValue( badMdls, string.lower( mdl ) ) ) then
		mdl = "models/mossman.mdl";
		_p:ChatPrint( "this model causes crashes, changing" );
	end
		
	local mdlTest = ents.Create( "sprop_npc" );
	mdlTest:SetModel( mdl );
	mdlTest:Spawn();
	
	if( mdlTest:GetModel() == "models/error.mdl" ) then
		_p:ChatPrint( "Invalid model!(error model)." );
		return;
	end
	
	if( !_e.id || !IsValid( _e ) ) then
		_e.id = os.time();
	end
	local data = {
		pos = _e:GetPos(),
		ang = _e:GetAngles(),
		model = mdl,
		name = name,
		props = props,
		ranks = ranks
	};
	
	SPROP.NPCs[ _e.id ] = data;
	
	file.Write( "sprop_" .. game.GetMap() .. "_npcs.txt", util.TableToJSON( SPROP.NPCs ) );
	SPROP:Setup();
	MsgC( Color( 0, 255, 0 ), "\n" .. _p:Nick() .. " saved NPC " .. name .. ".\n\n" );
	_p:ChatPrint( "NPC saved." );
	
end );

net.Receive( "SPROP::DelNPC", function( _, _p )

	if( !table.HasValue( SPROP.Settings.AdminRanks, _p:SPROPUsergroup() ) ) then
		_p:ChatPrint( "<" );
		return;
	end
	
	local _e = Entity( net.ReadFloat() );
	if( IsValid( _e ) && _e.id && SPROP.NPCs[ _e.id ] ) then
		MsgC( Color( 0, 255, 0 ), _p:Nick() .. " deleted a property NPC.\n\n" );
		SPROP.NPCs[ _e.id ] = nil;
		_e:Remove();
		file.Write( "sprop_" .. game.GetMap() .. "_npcs.txt", util.TableToJSON( SPROP.NPCs ) );
		SPROP:Setup();
		_p:ChatPrint( "NPC deleted." );
	else
		_p:ChatPrint( "Invalid NPC." );
		_p:ChatPrint( "Maybe the NPC hasn't been saved yet." );
	end

end );

function SPROP:UpdatePlayer( _p )
	
	MsgC( Color( 0, 255, 0 ), "\nSending properties data to " .. _p:Nick() .. ".\n\n" );
	local c = 1;
	for i, v in pairs( SPROP.Props ) do
		c = c + 1;
		timer.Simple( c, function()
		SPROP:SendProperty( i, _p );
		end );
	end

end

SPROP.Tracker = SPROP.Tracker or {};
function SPROP:Setup()
	for i, v in pairs( ents.FindByClass( "sprop_npc" ) ) do
		v:Remove();
	end
	
	for i, v in pairs( SPROP.NPCs or {} ) do
		if( v.name == "" ) then continue end
		local _e = ents.Create( "sprop_npc" );
		_e:SetPos( v.pos );
		_e:SetAngles( v.ang );
			local badMdls = { "models/zombie/classic.mdl", "models/vortigaunt.mdl" };
			if( table.HasValue( badMdls, v.model ) ) then
				v.model = "models/mossman.mdl";
			end
		
		_e:SetModel( v.model );
		_e:Spawn();
		
		_e:SetNWString( "spropName", v.name or "No name" );
		timer.Simple( 0.5, function()
			if( IsValid( _e ) ) then
				_e:SetModel( v.model );
			end
		end );
		
		local write = false;
		for i2, v2 in pairs( v.props ) do
			if( !SPROP.Props[ v2 ] ) then
				SPROP.NPCs[ i ].props[ i2 ] = nil;
				write = true;
			end
		end
		
		file.Write( "sprop_" .. game.GetMap() .. "_npcs.txt", util.TableToJSON( SPROP.NPCs ) );
		_e.props = v.props;
		_e.id = i;
	end
	
	for i, v in pairs( SPROP.Props ) do
		for i2, v2 in pairs( v.doors ) do
			ents.GetMapCreatedEntity( v2 ):setKeysNonOwnable( true );
			ents.GetMapCreatedEntity( v2 ):setKeysTitle( v.name );
			if( SPROP.Settings.LockDoorsOnSpawn ) then
				ents.GetMapCreatedEntity( v2 ):keysLock();
			end
		end
	end
end

concommand.Add( "sprop_setup", function( _p )
	if( _p:IsSuperAdmin() ) then
		SPROP:Setup();
		_p:ChatPrint( "Done!" );
	else
		_p:ChatPrint( "No access!" );
	end
end );

util.AddNetworkString( "SPROP::Select" );

net.Receive( "SPROP::Select", function( _, _p )
	local id = net.ReadFloat();
	
	if( !SPROP.Props[ id ] ) then
		return;
	end
	
	local door = ents.GetMapCreatedEntity( SPROP.Props[ id ].doors[ 1 ] );
	if( !IsValid( door ) ) then
		return;
	end
	
	
	_p:SpectateEntity( door );
end );

util.AddNetworkString( "SPROP::UnSpectate" );
net.Receive( "SPROP::UnSpectate", function( _, _p )
	_p:UnSpectate();
end );

function SPROP:Purchase( _p, id )
	if( !SPROP.Props[ id ] || !_p:canAfford( SPROP.Props[ id ].price ) ) then
		DarkRP.notify( _p, 0, 5, SPROP.Settings.CantPurchase );
		return;
	end
	
	_p:UnSpectate();
	if( SPROP.Settings.LimitProperties && !( SPROP.Tracker[ id ] && SPROP.Tracker[ id ][ 1 ] == _p:SteamID64() ) ) then
	
		local max = SPROP.Settings.RankLimit[ _p:SPROPUsergroup() ] or SPROP.Settings.GlobalLimit;
		local count = 0;
		for i, v in pairs( SPROP.Tracker ) do
			if( v[ 1 ] == _p:SteamID64() ) then
				count = count + 1;
			end
		end
		
		if( count >= max ) then
			DarkRP.notify( _p, 0, 5, SPROP.Settings.ReachedLimit );
			return;
		end
	
	end
	
	_p:EmitSound( "ambient/levels/labs/coinslot1.wav" );
	_p:addMoney( -SPROP.Props[ id ].price );
	DarkRP.notify( _p, 0, 5, SPROP.Settings.PurchaseMade );
	_p.SPROP = true;	
	if( SPROP.Settings.TimedProperties ) then
		if( SPROP.Tracker[ id ] && SPROP.Tracker[ id ][ 1 ] == _p:SteamID64() ) then
			MsgC( Color( 0, 255, 0 ), "\n" .. _p:Nick() .. " extended property " .. SPROP.Props[ id ].name .. ".\n" );
			SPROP.Tracker[ id ][ 4 ] = SPROP.Tracker[ id ][ 4 ] + SPROP.Settings.TimedDuration;
		else
			SPROP.Tracker[ id ] = { _p:SteamID64(), _p:Nick(), {}, os.time() + SPROP.Settings.TimedDuration };	
			for i, v in pairs( SPROP.Props[ id ].doors ) do
				local _e = ents.GetMapCreatedEntity( v );
				if( !IsValid( _e ) ) then
					continue;
				end
				_e:keysOwn( _p );
				_e:setKeysNonOwnable( false );
			end
			_p:SendLua( "SPROP:DrawKeyHUD( " .. id .. " )" );
		end
		SPROP:SaveTracker();
	else
		_p:SendLua( "SPROP:DrawKeyHUD( " .. id .. " )" );
		MsgC( Color( 0, 255, 0 ), _p:Nick() .. " purchased property " .. id .. "\n" );
		SPROP.Tracker[ id ] = { _p:SteamID64(), _p:Nick(), {}, os.time() + SPROP.Settings.TimedDuration };	
		for i, v in pairs( SPROP.Props[ id ].doors ) do
			local _e = ents.GetMapCreatedEntity( v );
			if( !IsValid( _e ) ) then
				continue;
			end
			_e:keysOwn( _p );
			_e:setKeysNonOwnable( false );
		end
	end
	
	
end

function SPROP:SaveTracker()
	file.Write( "sprop_" .. game.GetMap() .. "_permanent.txt", util.TableToJSON( SPROP.Tracker ) );
end

function SPROP:SetupDoor( v, prop )

	print( "Setup Door: step #1" );
	local door = ents.GetMapCreatedEntity( v );
	if( SPROP.Tracker[ prop ] && SPROP.Settings.TimedProperties ) then
	print( "Setup Door: step #2 - using timed properties" );
		local ref = SPROP.Tracker[ prop ];
		if( player.GetBySteamID64( ref[ 1 ] ) ) then
			print( "Setup Door: step #3 - player online" );
			door:setKeysNonOwnable( false );
			door:setKeysTitle( SPROP.Props[ prop ].name );
			local target = player.GetBySteamID64( ref[ 1 ] );
			door:keysOwn( target );
			
			local coowners = {};
			for i, v in pairs( SPROP.Tracker[ prop ][ 3 ] ) do
				for i2, v2 in pairs( player.GetAll() ) do
					if( v[ 1 ] == v2:SteamID64() ) then
						door:addKeysAllowedToOwn( v2 );
					end
				end
			end
		else
			print( "Setup Door: step #3 - player not online" );
			local title = string.Replace( SPROP.Settings.OfflineTitle, "[x]", ref[ 2 ] );
			door:setKeysTitle( title );
			door:setKeysNonOwnable( true );
		end
	else
		print( "Setup Door: step #4 - not using timed properties" );
		SPROP.Tracker[ prop ] = nil;
		if( IsValid( door:getDoorOwner() ) ) then
			door:keysUnOwn( door:getDoorOwner() );
		end
		door:setKeysNonOwnable( true );
		door:removeAllKeysExtraOwners();
		door:removeAllKeysAllowedToOwn();
		door:setKeysTitle( SPROP.Props[ prop ].name );
	end
	
	door:Fire( "close", "", 0 );
	door:keysLock();	
end

if( SPROP.Settings.TimedProperties ) then
	local time = 600;
	if( SPROP.Settings.CheckPropertyOwnageDelay ) then
		time = SPROP.Settings.CheckPropertyOwnageDelay;
	end
	
	timer.Create( "SPROP::CheckPropertyOwnage", time, 0, function()
		
		for i, v in pairs( SPROP.Tracker ) do

			if( v[ 4 ] <= os.time() ) then
				SPROP:Expire( i );
				continue;
			end
			
			MsgC( Color( 0, 255, 0 ), "\n\nProperty " .. SPROP.Props[ i ].name .. " owned by " .. v[ 2 ] .. " expires in " .. SPROP:GetRemainingTime( v[ 4 ] ) .. ".\n\n" );
			local msg = string.Replace( SPROP.Settings.PropertyExpires, "[x]", SPROP.Props[ i ].name );
			msg = string.Replace( msg, "[time]", SPROP:GetRemainingTime( v[ 4 ] ) );
			
			if( player.GetBySteamID64( v[ 1 ] ) ) then
				player.GetBySteamID64( v[ 1 ] ):ChatPrint( msg );
			end
			

		
		end
		
	end );
end

function SPROP:Expire( id )
	
	local ref = SPROP.Props[ id ];
	if( !ref ) then
		return;
	end
	
	if( player.GetBySteamID64( SPROP.Tracker[ id ][ 1 ] ) ) then
		local msg = string.Replace( SPROP.Settings.PropertyExpired	, "[x]", SPROP.Props[ id ].name );
		player.GetBySteamID64( SPROP.Tracker[ id ][ 1 ] ):ChatPrint( msg );
	end
	
	MsgC( Color( 0, 255, 0 ), "\nProperty " .. SPROP.Props[ id ].name .. " owned by " .. SPROP.Tracker[ id ][ 2 ] .. " expired.\n" );
	SPROP.Tracker[ id ] = nil;
	SPROP:Reset( id );
	SPROP:SaveTracker();
end

util.AddNetworkString( "SPROP::Unown" );
net.Receive( "SPROP::Unown", function( _, _p )
	if( !table.HasValue( SPROP.Settings.TimedMenuRanks, _p:SPROPUsergroup() ) ) then
		return;
	end
	
	local target = net.ReadFloat();
	if( !SPROP.Tracker[ target ] ) then
		return;
	end
	
	if( SPROP.Settings.TimedProperties ) then
		local perc = SPROP.Settings.RankPerc[ _p:SPROPUsergroup() ] or SPROP.Settings.GlobalPerc;
		_p:addMoney( ( SPROP.Props[ target ].price * perc ) * 0.5 );
	end
	
	MsgC( Color( 0, 255, 0 ), "\n" .. _p:Nick() .. " force unowning property: " .. SPROP.Props[ target ].name .. " owned by " .. SPROP.Tracker[ target ][ 2 ] .. ".\n\n" );
	SPROP:Expire( target );
end );

util.AddNetworkString( "SPROP::TimeMenu" );
hook.Add( "PlayerSay", "SPROP::TimeMenu", function( _p, msg, _ )

	if( msg == SPROP.Settings.TimedMenuCommand
	&& table.HasValue( SPROP.Settings.TimedMenuRanks, _p:SPROPUsergroup() ) ) then
	
		net.Start( "SPROP::TimeMenu" );
		net.WriteTable( SPROP.Tracker );
		net.Send( _p );
	
	end

end );

hook.Add( "PlayerInitialSpawn", "SPROP::CheckIfOwner", function( _p )

	if( !SPROP.Settings.TimedProperties ) then
		return;
	end
	
	timer.Simple( 10, function()
	
		for i, v in pairs( SPROP.Tracker ) do
			if( v[ 1 ] == _p:SteamID64() ) then
				v[ 2 ] = _p:Nick();
				SPROP:SaveTracker();
			end
			
			if( v[ 1 ] == _p:SteamID64() ) then
				if( v[ 4 ] < os.time() ) then
					SPROP:Expire( i );
					break;
				end
				for i2, v2 in pairs( SPROP.Props[ i ].doors ) do
					SPROP:SetupDoor( v2, i );
				end
				MsgC( Color( 0, 255, 0 ), "\n" .. _p:Nick() .. " owns property " .. SPROP.Props[ i ].name .. ", setting up.\n\n" );
				local msg = string.Replace( SPROP.Settings.PropertyExpires, "[x]", SPROP.Props[ i ].name );
				msg = string.Replace( msg, "[time]", SPROP:GetRemainingTime( v[ 4 ] ) );
				
				_p:ChatPrint( msg );
			end
		end
		
		for i, v in pairs( SPROP.Tracker ) do
			if( !player.GetBySteamID64( v[ 1 ] ) ) then
				continue;
			end
			go = false;
			
			for i2, v2 in pairs( v[ 3 ] ) do		
				if( v2[ 1 ] == _p:SteamID64() ) then
					go = true;
				end
			end
			
			if( go ) then
				for i2, v2 in pairs( SPROP.Props[ i ].doors ) do
					ents.GetMapCreatedEntity( v2 ):addKeysAllowedToOwn( _p );
				end
				
				local msg = string.Replace( SPROP.Settings.TimedToCoOwn, "[x]", SPROP.Props[ i ].name );
				_p:ChatPrint( msg );
			end
		end
	
	end );

end );

function SPROP:Reset( id )
	if( !SPROP.Props[ id ] ) then
		return;
	end
	
	for i, v in pairs( SPROP.Props[ id ].doors ) do
		SPROP:SetupDoor( v, id );
	end
	
	if( !SPROP.Settings.TimedProperties ) then
		SPROP.Tracker[ id ] = nil;
	end
end

function SPROP:Sell( _p, id )
	if( !SPROP.Props[ id ] || !SPROP.Tracker[ id ] || SPROP.Tracker[ id ][ 1 ] != _p:SteamID64() ) then
		return;
	end
	
	MsgC( Color( 0, 255, 0 ), _p:Nick() .. " sold " .. id .. "\n" );
	local perc = SPROP.Settings.RankPerc[ _p:SPROPUsergroup() ] or SPROP.Settings.GlobalPerc;
	_p:addMoney( SPROP.Props[ id ].price * perc );
	DarkRP.notify( _p, 0, 5, string.Replace( SPROP.Settings.SoldMade, "[x]", SPROP.Props[ id ].price * perc ) );
	_p:EmitSound( "ambient/levels/labs/coinslot1.wav" );
	
	SPROP:Reset( id );
end
net.Receive( "SPROP::Purchase", function( _, _p )
	local id = net.ReadFloat();
	if( !SPROP.Props[ id ] ) then
		return;
	end
	
	if( SPROP.Tracker[ id ] ) then
		if( SPROP.Settings.TimedProperties ) then
			SPROP:Purchase( _p, id );
		elseif( SPROP.Tracker[ id ][ 1 ] == _p:SteamID64() ) then
			SPROP:Sell( _p, id );
		end
	else
		SPROP:Purchase( _p, id );
	end
end );


// new
util.AddNetworkString( "SPROP::DelCoOwner" );
net.Receive( "SPROP::DelCoOwner", function( _, _p )
	local prop = net.ReadFloat();
	local data = net.ReadTable();
	local steamid = data[ 1 ];
	if( !SPROP.Props[ prop ] || !SPROP.Tracker[ prop ] || SPROP.Tracker[ prop ][ 1 ] != _p:SteamID64() ) then
		return;
	end
	
	SPROP:DelCoOwner( prop, steamid );
end );

function SPROP:DelCoOwner( prop, target )

	if( SPROP.Tracker[ prop ] ) then
			MsgC( Color( 0, 255, 0 ), "\n" .. SPROP.Tracker[ prop ][ 2 ] .. " removed Co-Owner " .. target .. ".\n" );

		for i, v in pairs( SPROP.Tracker[ prop ][ 3 ] ) do
			if( v[ 1 ] == target ) then
				SPROP.Tracker[ prop ][ 3 ][ i ] = nil;
				break;
			end
		end
		
		if( player.GetBySteamID64( target ) ) then
			for i, v in pairs( SPROP.Props[ prop ].doors ) do
				if( IsValid( ents.GetMapCreatedEntity( v ) ) && ents.GetMapCreatedEntity( v ):isDoor() ) then
					ents.GetMapCreatedEntity( v ):keysUnOwn( player.GetBySteamID64( target ) );
					ents.GetMapCreatedEntity( v ):removeKeysAllowedToOwn( player.GetBySteamID64( target ) );
				end
			end
		end
		
		
		SPROP:SaveTracker();
		
	end

end


function SPROP:AddCoOwner( prop, target )
	
	for i, v in pairs( SPROP.Props[ prop ].doors ) do
		ents.GetMapCreatedEntity( v ):addKeysAllowedToOwn( target );
		ents.GetMapCreatedEntity( v ):addKeysDoorOwner( target );
	end
	
	if( SPROP.Settings.TimedProperties ) then
		if( SPROP.Tracker[ prop ] ) then
			table.insert( SPROP.Tracker[ prop ][ 3 ], { target:SteamID64(), target:Nick() } );
			SPROP:SaveTracker();
		end
	end


end

util.AddNetworkString( "SPROP::AddCoOwner" );
net.Receive( "SPROP::AddCoOwner", function( _, _p )

	local prop = net.ReadFloat();
	local target = Entity( net.ReadFloat() );
	
	if( !SPROP.Props[ prop ] || !SPROP.Tracker[ prop ] || SPROP.Tracker[ prop ][ 1 ] != _p:SteamID64()
		|| !IsValid( target ) ) then
		return;
	end
	
	SPROP:AddCoOwner( prop, target );
	MsgC( Color( 0, 255, 0 ), "\n" .. _p:Nick() .. " added Co-Owner " .. target:Nick() .. ".\n" );

end );

hook.Add( "PlayerDisconnected", "SPROP::Disconnect", function( _p )
	
	local ply = _p:SteamID64();
	timer.Simple( SPROP.Settings.UnownTime, function()
		if( IsValid( player.GetBySteamID64( ply ) ) ) then
			return;
		end
		for i, v in pairs( SPROP.Tracker ) do
			if( v[ 1 ] == ply ) then
				SPROP:Reset( i );
			end
		end
	end );
	
end );

hook.Add( "PostCleanupMap", "SPROP::SetupAgain", function()
	SPROP:Setup();
end );

resource.AddFile( "resource/fonts/teko_light.ttf" );
resource.AddFile( "materials/sprop_key.png" );

SPROP.Version = "2.0.4";

