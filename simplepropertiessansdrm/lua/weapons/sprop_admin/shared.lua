

-- Variables that are used on both client and server

AddCSLuaFile()

SWEP.Author			= "William";
SWEP.Instructions	= "Left click on NPC: Configure NPC\nLeft click: do current task\nRight click: open menu";

SWEP.Spawnable			= true;
SWEP.AdminOnly			= true;
SWEP.UseHands			= true;
SWEP.Category 			= "Simple Properties";

SWEP.ViewModel			= "models/weapons/c_pistol.mdl";
SWEP.WorldModel			= "models/weapons/w_Pistol.mdl";

SWEP.Primary.ClipSize		= -1;
SWEP.Primary.DefaultClip	= -1;
SWEP.Primary.Automatic		= false;
SWEP.Primary.Ammo			= "none";

SWEP.Secondary.ClipSize		= -1;
SWEP.Secondary.DefaultClip	= -1;
SWEP.Secondary.Automatic	= false;
SWEP.Secondary.Ammo			= "none";

SWEP.AutoSwitchTo		= false;
SWEP.AutoSwitchFrom		= false;

SWEP.PrintName			= "SPROP Admin";
SWEP.Slot				= 0
SWEP.SlotPos			= 0
SWEP.DrawAmmo			= false


/*---------------------------------------------------------
	Initialize
---------------------------------------------------------*/
function SWEP:Initialize()

	self:SetHoldType( "pistol" );
	if( CLIENT ) then
		SPROP.ActiveDoorIDs = {};
	end
end

function SWEP:Holster()
	if( CLIENT ) then
		SPROP.ActiveDoorIDs = {};
		SPROP.ActiveDoors = {};
		SPROP.ActiveDoorData = {};
	end
	hook.Remove( "PreDrawHalos", "SPROP::Halos" );
	return true
end

/*---------------------------------------------------------
	Reload does nothing
---------------------------------------------------------*/
function SWEP:Reload()
end


function SWEP:Think()


	
end

function SWEP:SetupDoors()

	for i, v in pairs( SPROP.ActiveDoors ) do
		SPROP.ActiveDoorIDs[ v ] = true;
	end
	hook.Remove( "PreDrawHalos", "SPROP::Halos" );
	hook.Add( "PreDrawHalos", "SPROP::Halos", function()
		halo.Add( SPROP.ActiveDoors or {}, Color( 0, 255, 0 ), 5, 5, 2, true, true );
	end )
	
end

/*---------------------------------------------------------
	PrimaryAttack
---------------------------------------------------------*/
function SWEP:DrawHUD()

end

/*---------------------------------------------------------
	SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()

	if( CLIENT && IsFirstTimePredicted() ) then
		SPROP:DoorMenu();
	end
	
end

function SWEP:PrimaryAttack()

	local tr = self.Owner:GetEyeTrace();
	if( tr.Entity && tr.Entity:GetClass() == "sprop_npc" && IsFirstTimePredicted() ) then
		if( SERVER ) then
			tr.Entity:Send( self.Owner );
		end
		return;
	end
	
	if( CLIENT && self.Owner == LocalPlayer() && IsFirstTimePredicted() ) then
		if( tr.Entity ) then
			if( ( tr.Entity.isDoor && tr.Entity:isDoor() ) || ( tr.Entity.IsDoor && tr.Entity:IsDoor() ) ) then
				if( table.HasValue( SPROP.ActiveDoors, tr.Entity ) ) then
					table.RemoveByValue( SPROP.ActiveDoors, tr.Entity );
					SPROP.ActiveDoorIDs[ tr.Entity ] = nil;
				else
					table.insert( SPROP.ActiveDoors, tr.Entity );
				end
				self.Weapon:SetupDoors();
			else
				SPROP.ActiveDoorData[ 1 ] = LocalPlayer():EyePos();
				SPROP.ActiveDoorData[ 2 ] = LocalPlayer():EyeAngles();
				LocalPlayer():ChatPrint( "Saved Preview Position!" );
			end
		end
	end
	
end