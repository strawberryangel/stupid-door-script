// ==========================================================================
// Basic Door Script
// Original Script By Unknown
// Modifications made by Zanlew Wu 01-Apr-2003
// Modifications made by Sophie-Jeanne (mommypickles) Dec 19, 2015.
// Modifications made by Sophie-Jeanne (mommypickles) Nov 11, 2016.
//
// Sophie change log (using semantic versioning http://semver.org/ 
//
// 1.2.0 - Double Doors
//
//	The direction is controlled by the object description.
//	Clicking will turn counter clockwise to open, and clockwise to close.
//  If the object description is a negative number, the directions are reversed.
//
//	The absolute value of the number in the description is also the channel that
//	the script will listen on. You can pair doors by giving one a channel number
//	(e.g. 30000) and the other the negative (e.g. -30000).
//	Touching one will activate both.
//
// 	Yes, this is full of pitfalls. I'm not interested in fixing them right now.
//
// 	To build doors, create a tall thin prim to use as a hinge.
//	This can be invisible if you wish.
//	Put this script inside.
//	Add the rest of the door and link them all with the hinge as the root prim.
//	Set the description as needed.
//	Voilà. Door.
//
//============================================
// Declare global constants.
//
integer SW_OPEN = FALSE;   // used to signify door swinging open
integer SW_CLOSE = TRUE;   // used to signify door swinging closed
integer SW_NORMAL = FALSE; // used to signify a normal swing
integer SW_REVERSE = TRUE; // used to signify a reverse swing

float hinge = 1.0; // Set to -1 for reverse direction
integer hinge_channel;
integer hinge_listener;
string hinge_command = "0b71c53e4771";

//
// Note that it is hard to call a given swing outward or inward as that has
// a lot to do witht he rotation and/or orientation of the door, which
// swing direction is correct/desired, and whether you are referring to the
// swing from the "out" side of the door or the "in" side of the door. It
// was easier by convention to call the swings normal and reverse.

//============================================
// Declare global fields.
//
key     gfOwnerKey;    // Owner of the elevator object
integer gfDoorClosed;  // Current state of the door (Open, Closed)
integer gfDoorSwing;   // Deteremines which way the door swings (In, Out)

// Changes made by Sophie
// Sound names
string SOUND_CLOSE = "Door close";
string SOUND_OPEN = "Door open";
string SOUND_KNOCK = "Door knock";

//============================================
// gmInitFields
//
gmInitFields()
{
	//
	// Get the owner of the door.
	//
	gfOwnerKey = llGetOwner();

	//
	// Close doors by default.
	//
	gfDoorClosed = TRUE;

	//
	// Set the door swing.
	//
	gfDoorSwing = SW_NORMAL;

	return;
}
//
// End of gmInitVars
//============================================

//============================================
// gmSwingDoor
//
gmSwingDoor(integer direction)
{
	//-----------------------
	// Local variable defines
	//
	rotation rot;
	rotation delta;
	float piVal;

	//
	// First thing we need to do is decide whether we are applying a
	// negative or positive PI value to the door swing algorythm. The
	// positive or negative makes the difference on which direction the door
	// swings. Additionally, since we allow the doors to modify their swing
	// direction (so the same door can be placed for inward or outward
	// swing, we have to take that into account as well. Best to determine
	// that value first. The rest of the formula does not change regardless
	// of door swing direction.
	//
	// So we have two variables to pay attention to: open/close and swing
	// in/out. First we start with open/close. We will presume the
	// following:
	//      SW_OPEN:  +PI
	//      SW_CLOSE: -PI
	// This also presumes that the door has a standard swing value of
	// SW_NORMAL.
	//
	// A door that has had it's swing changed would have those values
	// reversed:
	//      SW_OPEN:  -PI
	//      SW_CLOSE: +PI
	//
	// The variable passed into this method determines if the intent were
	// to open the door or close it.
	//
	// The global field gfDoorSwing will be used to modify the PI based on
	// whether the door normally swings in or out.
	//
	if (direction == SW_OPEN)
	{
		//
		// Ok, we know the door is opening. Assign a +PI value to piVal.
		//
		piVal = hinge * PI/4;
		//
		// Now check to see if the door has it's swing reversed.
		//
		if (gfDoorSwing == SW_REVERSE)
		{
			//
			// Yep, it's reversed and we are opening the door, so replace
			// piVal with a -PI value.
			//
			piVal = hinge * -PI/4;
		}
	} else
{
	//
	// So we know we are closing the door this time. Assign a -PI value
	// to piVal.
	//
	piVal = hinge * -PI/4;
	//
	// Now check to see if the door has it's swing reversed.
	//
	if (gfDoorSwing == SW_REVERSE)
	{
		//
		// Yep, it's reversed and we are closing the door, so we need to
		// assing a +PI value to piVal.
		//
		piVal = hinge * PI/4;
	}
}

	//
	// This formula was part of the original script and is what makes
	// the door swing open and closed. This formula use a Pi/-Pi to
	// move the door one quarter-circle in total distance.
	//
	// The only change I've made to this function is to replace the hard-
	// coded PI/-PI values with a variable that is adjusted
	// programmatically to suit the operation at hand.
	//
	rot = llGetRot();
	delta = llEuler2Rot(<0,0,piVal> );
	rot = delta * rot;
	llSetRot(rot);
	llSleep(0.25);
	rot = delta * rot;
	llSetRot(rot);

	return;
}
//
// End of gmSwingDoor
//============================================

//============================================
// gmCloseDoor
//
// The close command is used to close doors. If the doors are
// locked, the doors cannot be closed. (Note: presumably, this
// script does not allow doors to be opened AND locked at the same
// time). If the doors are already closed, they cannot be
// re-closed. These checks will be made before performing a door
// close operation. Once the door is successfully closed, the
// door's state will be updated.
//
gmCloseDoor()
{
	//
	// First let's check to see if the door is already closed. If it
	// is, let the user know.
	//
	if (gfDoorClosed == TRUE)
	{
		//
		// Yep, it was already closed.
		//
		llSay (0, "This door is already closed.");
		return;
	}

	//
	// Now we generate the proper sound for the door closing.
	//
	playSound(SOUND_CLOSE);

	//
	// Now we call the method gmSwingDoor with the SW_CLOSE argument (since
	// we are closing the door.
	//
	gmSwingDoor(SW_CLOSE);

	//
	// Now that the door is closed, set the door's state.
	//
	gfDoorClosed = TRUE;

	return;
}
//
// End of gmCloseDoor
//============================================

//============================================
// gmOpenDoor
//
// The open command is used to open the doors. If the doors are
// locked, the doors cannot be opened. If the doors are already
// opened, they cannot be re-opened. These checks will be made
// before performing a door open operation. Once the door is
// successfully opened, the door's state will be updated.
//
gmOpenDoor()
{
	//
	// First let's check to see if the door is open already. If it is,
	// let the user know.
	//
	if (gfDoorClosed == FALSE)
	{
		//
		// Yep, it was already open.
		//
		llSay (0, "This door is already open.");
		return;
	}

	//
	// Now we generate the proper sound for the door closing.
	//
	playSound(SOUND_OPEN);

	//
	// Now we call the method gmSwingDoor with the SW_OPEN argument (since
	// we are opening the door.
	//
	gmSwingDoor(SW_OPEN);

	//
	// Now that the door is opened, set the door's state.
	//
	gfDoorClosed = FALSE;
	return;
}
//
// End of gmOpenDoor
//============================================


// Sophie's addition. Don't try to play a sound that doesn't exist in inventory.
playSound(string soundName)
{
	if(llGetInventoryType(soundName) == INVENTORY_SOUND)
		llTriggerSound(soundName, 0.2);
}

get_parameters_from_description()
{
	integer description = (integer)llGetObjectDesc();
	if(description < 0)
	{
		hinge = -1.0;
		hinge_channel = -description;
	}
	if(description > 0)
	{
		hinge = 1.0;
		hinge_channel = description;
	}

	llListenRemove(hinge_listener);
	hinge_listener = llListen(hinge_channel, "", NULL_KEY, hinge_command);
}

// This was originally in the touch_start() event handler.
process_touch()
{
	//
	// This is the same code as the UNLOCK, OPEN and CLOSE DOOR
	// code. For reasons of brevity, I have removed the comments
	// from this copy of the code.
	//
	if (gfDoorClosed == FALSE)
	{
		playSound(SOUND_CLOSE);
		gmSwingDoor(SW_CLOSE);
		gfDoorClosed = TRUE;
		return;
	}
	else
	{
		playSound(SOUND_OPEN);
		gmSwingDoor(SW_OPEN);
		gfDoorClosed = FALSE;
		return;
	}
}


// This code was in the listen() event handler.
original_voice_command(integer channel, string name, key id, string msg)
{
	//-----------------------
	// Local variable defines
	//
	string operName;
	string ownerName;

	//
	// Ideally, we want the door only to work on spoken commands
	// from the owner. To accomplish this task, we need to check the
	// id of the owner and the person issuing the command to see if
	// they match.
	//
	// Alternately, commands can be issued from the control panel,
	// which can be used by anyone. Later on, it will be presumed that
	// access to the control panel will be controlled.
	//

	//
	// First get the string names of the owner and the operator so they
	// can be compared.
	//
	operName = llKey2Name(id);
	ownerName = llKey2Name(gfOwnerKey);

	//
	// First we check the owner.
	//
	if (ownerName != operName)
	{
		//
		// Nope, not a match.
		//
		playSound(SOUND_KNOCK);
		llSay(0, "Voice command access is for owner only.");
		return;
	}

	//----------------------------------------
	// OPEN DOOR
	//
	if(msg == "open")
	{
		gmOpenDoor();
	}

	//----------------------------------------
	// CLOSE DOOR
	//
	if (msg == "close")
	{
		gmCloseDoor();
	}
}


//============================================
// Default State
//
// This is the state that is automatically bootstrapped when the object
// is first created/rez'd, or the world or environment resets.
//
default
{
	//
	// state_entry() is the first method executed when the state it resides
	// in is run. So State A, B, and C all can have state_entry methods,
	// and if they do, they are run when their respective states are called
	// and or executed.
	//
	state_entry()
	{
		get_parameters_from_description(); // Sophie's hack
		//
		// Perform global field initialization
		//
		gmInitFields();

		//
		// We are listening for two different commands. This script is set
		// up to accept spoken commands only from the object owner.
		//
		llListen(0, "", "", "open");
		llListen(0, "", "", "close");
	}

	listen(integer channel, string name, key id, string msg)
	{
		if(msg == hinge_command) process_touch();
	}

	touch_start(integer i)
	{
		llSay(hinge_channel, hinge_command);
		process_touch();
	}
}
