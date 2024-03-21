
// Project: PlatformerEngine 
// Created: 2024-03-18

#include "src/System/CollisionSystem.agc"
#include "src/System/TileMapSystem.agc"
#include "src/System/MovementSystem.agc"
#include "src/System/SpriteRendererSystem.agc"

#constant SCREEN_WIDTH 640
#constant SCREEN_HEIGHT 480

// ----------------------------------------------------------------------------------------------
// show all errors
SetErrorMode(2)

// set window properties
SetWindowTitle( "PlatformerEngine" )
SetWindowSize( SCREEN_WIDTH, SCREEN_HEIGHT, 0 )
SetWindowAllowResize( 0 ) // allow the user to resize the window

// set display properties
SetVirtualResolution( SCREEN_WIDTH, SCREEN_HEIGHT ) // doesn't have to match the window
SetOrientationAllowed( 1, 1, 1, 1 ) // allow both portrait and landscape on mobile devices
SetSyncRate( 30, 0 ) // 30fps instead of 60 to save battery
SetScissor( 0,0,0,0 ) // use the maximum available screen space, no black borders
UseNewDefaultFonts( 1 ) // since version 2.0.22 we can use nicer default fonts
// -----------------------------------------------------------------------------------------------




// Create a simple player type to demonstrate the use of movement system
TYPE Player
    SpriteId    AS INTEGER
    SpaceObject AS CS_SpaceObject
ENDTYPE


player AS Player
player.SpaceObject.SpriteId = CreateSprite(LoadImage("boy.png"))
SetSpriteAnimation(player.SpaceObject.SpriteId, 32, 32, 4)
SetSpriteFrame(player.SpaceObject.SpriteId, 1)
SetSpriteVisible(player.SpaceObject.SpriteId, 1)
SetSpriteDepth(player.SpaceObject.SpriteId, 0)
SetSpriteShape(player.SpaceObject.SpriteId, BOX_SPRITE_SHAPE)

player.SpaceObject.XPos = 0
player.SpaceObject.YPos = 0



// Create a basic example map
map AS TMS_Map
map = TMS_LoadMap("world1.txt", "tileset.png", 48, 16, 16)
TMS_SetCameraDimensions(map, SCREEN_WIDTH, SCREEN_HEIGHT)
TMS_SetMapCameraPos(map, 0, 0)

// Move the player to center of screen
MVS_SetObjectToCenterScreen(player.SpaceObject, map)

do
	movementResult AS MVS_MovementResult
	movementResult.xAmount = 0
	movementResult.yAmount = 0
	
    IF GetRawKeyState(37) // left
		movementResult.xAmount = -5
    ELSEIF GetRawKeyState(39) // right
		movementResult.xAmount = 5
	ELSEIF GetRawKeyState(38) // up
		movementResult.yAmount = -5
    ELSEIF GetRawKeyState(40) // down
		movementResult.yAmount = 5
    ENDIF
    
    // Check if movement is valid
    MVS_GetValidMovementInWorld(player.SpaceObject, map, movementResult)
    TMS_AddCameraMovement(map, movementResult.xAmount, movementResult.yAmount)
    MVS_AddObjectMovement(player.SpaceObject, map, movementResult.xAmount, movementResult.yAmount)
    
    
    // Draw tilemap
    TMS_DrawMap(map)
    
    // Draw player object
    SRS_DrawObjectToScreen(player.SpaceObject, map)
    Sync()
loop
