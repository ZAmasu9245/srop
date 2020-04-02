AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()

	self:SetModel( "models/mossman.mdl" );
	self:SetHullType( HULL_HUMAN );
	self:SetHullSizeNormal();
	self:SetNPCState( NPC_STATE_SCRIPT );
	self:SetSolid( SOLID_BBOX );
	self:CapabilitiesAdd( CAP_ANIMATEDFACE || CAP_TURN_HEAD );
	self:SetUseType( SIMPLE_USE );
	self:DropToFloor();
	self.nextClick = CurTime() + 1;
	self:SetMaxYawSpeed( 90 );
	
end

function ENT:Send( _p )

	net.Start( "SPROP::NPC" );
	net.WriteTable( SPROP.NPCs[ self.id ] or {} );
	net.WriteFloat( self:EntIndex() );
	net.Send( _p );

end

function ENT:AcceptInput( _event, _a, _p )

	if( _event == "Use" && _p:IsPlayer() && self.nextClick < CurTime() )  then
		if( !SPROP.NPCs[ self.id ] ) then
			_p:ChatPrint( "Not configured yet." );
			return;
		end
		
		if( SPROP.NPCs[ self.id ]
			&& SPROP.NPCs[ self.id ].ranks
			&& table.Count( SPROP.NPCs[ self.id ].ranks ) > 0
			&& !SPROP.NPCs[ self.id ].ranks[ _p:GetUserGroup() ] ) then
			_p:ChatPrint( SPROP.Settings.NoAccess );
			return;
		end
		net.Start( "SPROP::Open" );
		net.WriteTable( SPROP.NPCs[ self.id ] );
		net.WriteFloat( self.id );
		net.WriteTable( SPROP.Tracker );
		net.Send( _p );
		self.nextClick = CurTime() + 0.5;
	end
	
end