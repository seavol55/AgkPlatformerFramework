
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
player.SpriteId = CreateSprite(LoadImage("boy.png"))
SetSpriteAnimation(player.SpriteId, 32, 32, 4)
SetSpriteFrame(player.SpriteId, 1)
SetSpriteVisible(player.SpriteId, 1)
SetSpriteDepth(player.SpriteId, 0)

player.SpaceObject.XPos = 0
player.SpaceObject.YPos = 0
player.SpaceObject.BoxCollider.XOffset = 0
player.SpaceObject.BoxCollider.YOffset = 0
player.SpaceObject.BoxCollider.Height = 32
player.SpaceObject.BoxCollider.Width = 32



// Create a basic example map
map AS TMS_Map
map = TMS_LoadMap("world1.txt", "tileset.png", 48, 16, 16)
TMS_SetCameraDimensions(map, SCREEN_WIDTH, SCREEN_HEIGHT)
TMS_SetMapCameraPos(map, 0, 0)

// Move the player to center of screen
MVS_SetObjectToCenterScreen(player.SpaceObject, map)

do
    IF GetRawKeyState(37) // left
        TMS_AddCameraMovement(map, -5, 0)
        MVS_AddObjectMovement(player.SpaceObject, map, -5, 0)
    ENDIF
    
    IF GetRawKeyState(39) // right
        TMS_AddCameraMovement(map, 5, 0)
        MVS_AddObjectMovement(player.SpaceObject, map, 5, 0)
    ENDIF
    
    IF GetRawKeyState(38) // up
        TMS_AddCameraMovement(map, 0, -5)
        MVS_AddObjectMovement(player.SpaceObject, map, 0, -5)
    ENDIF
    
    IF GetRawKeyState(40) // down
        TMS_AddCameraMovement(map, 0, 5)
        MVS_AddObjectMovement(player.SpaceObject, map, 0, 5)
    ENDIF
    
    
    // Draw tilemap
    TMS_DrawMap(map)
    
    // Draw player object
    SRS_DrawObjectToScreen(player.SpaceObject, map, player.SpriteId)
    Sync()
loop
