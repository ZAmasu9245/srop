// Key Icon made by "Vectors Market" on www.flaticon.com

if( !SPROP || type( SPROP ) != "table" ) then
	SPROP = {};
end
SPROP.Props = SPROP.Props or {};

SPROP.Settings = {};
// These ranks can use the admin tools:
SPROP.Settings.AdminRanks	= { "superadmin", "owner", "founder" };
// these ranks can change permanent properties stuff:
SPROP.Settings.TimedMenuRanks= { "superadmin", "owner", "founder" };
// command to open:
SPROP.Settings.TimedMenuCommand = "!sprop";

SPROP.Settings.PurchaseMade 			= "You purchased the property.";
SPROP.Settings.SoldMade					= "You sold the property for $[x].";
SPROP.Settings.CantPurchase				= "You can't afford this.";
SPROP.Settings.Close					= "Close";
SPROP.Settings.ForSale					= "For sale!";
SPROP.Settings.Currency					= "$";
SPROP.Settings.Purchase					= "Purchase";
SPROP.Settings.Extend					= "Extend";
SPROP.Settings.Sell						= "Sell";
SPROP.Settings.Confirm					= "Click again";
SPROP.Settings.OwnedByYou				= "You";
SPROP.Settings.AddCoOwner				= "Add Co-Owner";
SPROP.Settings.DelCoOwner				= "Remove Co-Owner";
SPROP.Settings.UnownTime				= 120; // if not using timed properties, doors will be owned this many seconds after dc(incase crash)
SPROP.Settings.Owned					= "Owned by [x]"; // [x] is replaced with the owenrs name
SPROP.Settings.BoxWidth					= 300;
SPROP.Settings.NoAccess					= "You don't have access to these properties.";

SPROP.Settings.LineH					= 3;
SPROP.Settings.LineClr					= Color( 90, 210, 130, 140 );
SPROP.Settings.GeneralClr				= Color( 0, 0, 0, 230 );
SPROP.Settings.GeneralClr2				= Color( 36, 36, 36, 180 );
SPROP.Settings.SortOptions				= {
	"Price low to high",
	"Price high to low",
	"Unowned to owned",
	"Owned to unowned"
};
SPROP.Settings.SearchDefaultText		= "Start writing to search";

SPROP.Settings.LockDoorsOnSpawn			= true;
// these are not drawn(to prevent seeing printers, players etc)
SPROP.Settings.DontDrawThese			= {
	"prop_physics",
	"money_printer",
	"player",
	"druglab",
	"spawned_money"
};
// if this is true, players cant see the camera for a property that is owned
SPROP.Settings.CantSeeOwned = true;
// this message is shown if all properties in a dealer is owned, and above is set to true
SPROP.Settings.NoneAvailable = "I have no properties free right now, check back later.";




/* SELLING PROPERTIES SECTION */

// if this is true, doors will remain owned when player leaves server.
SPROP.Settings.TimedProperties			= false;
// if above is true, how many seconds should the door be owned by the player?
// in seconds, so for one real week = 60 * 60 * 24 * 7 (this gives amount of seconds in 7 days).
SPROP.Settings.TimedDuration			= 60 * 60 * 24 * 7;

// what is door title if player is offline
SPROP.Settings.OfflineTitle				= "Owned by [x]";
SPROP.Settings.TimedToCoOwn				= "You are allowed to co-own the property [x].";
SPROP.Settings.PropertyExpires			= "Property [x] expires in [time]";
SPROP.Settings.PropertyExpired			= "Your property [x] has expired.";

// 0.5 = 50%, 1 = 100%
SPROP.Settings.GlobalPerc				= 0.5; // % every player gets back when selling a property.


// if a players rank is here, they can get a different % back.
SPROP.Settings.RankPerc					= {};
SPROP.Settings.RankPerc[ "superadmin" ] = 0.8; // superadmins get 80% back when selling a property

// show a key icon on the screen to help locate the doors?
SPROP.Settings.ShowIconWhenBought		= true;
// after how long should the icon be removed?
SPROP.Settings.ShowIconWhenBoughtTime	= 60;
/* END SELLING PROPERTIES SECTION */




/* BUYING PROPERTIES SECTION */
SPROP.Settings.CantBuyThis				= "You can only buy this through a dealer.";

SPROP.Settings.LimitProperties 			= true; // limit how many properties a player can own
SPROP.Settings.ReachedLimit				= "You have reached the properties limit, sell one first.";
// LimitProperties must be set to true for these to be relevant!

SPROP.Settings.GlobalLimit				= 1; // how many properties can a player own?
SPROP.Settings.RankLimit				= {};
SPROP.Settings.RankLimit["superadmin"] 	= 2;
/* END BUYING PROPERTIES SECTION */

// THIS FUNCTION SHOULD RETURN USER GROUP so if you have custom admin mod, change this
local meta = FindMetaTable( "Player" );
function meta:SPROPUsergroup()
	return self:GetUserGroup();
end



// admin menu texts
if( CLIENT ) then
	SPROP.Settings.AddProperties 	= "Configure new property";
	SPROP.Settings.AddBtn			= "Get active doorgroup";
	SPROP.Settings.NoActiveDoors	= "No doors selected!";
	SPROP.Settings.DoorsSelected	= "Doors selected: [x]";
	SPROP.Settings.InsertPrice		= "Insert price(only numbers)";
	SPROP.Settings.InsertName		= "Insert unique name(Apartment #5)";
	SPROP.Settings.SaveProperty		= "Save property";
	SPROP.Settings.DelProperty		= "Delete property";
	SPROP.Settings.DelProperty2		= "Click to confirm.";
	
	SPROP.Settings.EditProperties	= "Edit existing property";
	SPROP.Settings.SelectProperty	= "Select a property";
	
	SPROP.Settings.NPCAdmin			= "Configure NPC";
	SPROP.Settings.NPCName			= "No name";
	SPROP.Settings.Selling			= "Sells these properties:";
	SPROP.Settings.Restricted		= "Only usable by these ranks:";
	SPROP.Settings.SaveNPC			= "Save NPC";
	SPROP.Settings.DelNPC			= "Delete NPC";
	SPROP.Settings.DelNPC2			= "Click to confirm.";
	
	SPROP.Settings.BtnClr		= Color( 30, 100, 200, 120 );
	SPROP.Settings.BtnTextClr	= Color( 255, 255, 255 );
	SPROP.Settings.BtnClrLine	= Color( 255, 255, 255, 90 );
	SPROP.Settings.BtnClrH		= Color( 60, 150, 210, 170 );
	SPROP.Settings.BtnClrLineH	= Color( 90, 210, 130, 140 );	
end

function SPROP:GetRemainingTime( time )

	time = time - os.time();
	local d = math.floor( time / 86400 );
	local r = ( time % 86400 );
	local h = math.floor( r / 3600 );
	local r = r % 3600;
	local m = math.floor( r / 60 );
	local s = r % 60;
	
	val = d .. "d " .. h .. "h " .. m .. "m " .. s .. "s";
	return val;

end

SPROP.Name = "sprop";
SPROP.NPCs = SPROP.NPCs or {};
SPROP.Props = SPROP.Props or {};

SPROP.User = {
	u = "76561198091866601",
	u2 = "38b3b32f9d54f92bb87916b36b57bd3e5f4d710133d69b33a85a576b73b379c3"
};