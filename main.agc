
// Project: PlatformerEngine 
// Created: 2024-03-18

#include "src/System/CollisionSystem.agc"
#include "src/System/TileMapSystem.agc"

// show all errors
SetErrorMode(2)

// set window properties
SetWindowTitle( "PlatformerEngine" )
SetWindowSize( 640, 480, 0 )
SetWindowAllowResize( 1 ) // allow the user to resize the window

// set display properties
SetVirtualResolution( 640, 480 ) // doesn't have to match the window
SetOrientationAllowed( 1, 1, 1, 1 ) // allow both portrait and landscape on mobile devices
SetSyncRate( 30, 0 ) // 30fps instead of 60 to save battery
SetScissor( 0,0,0,0 ) // use the maximum available screen space, no black borders
UseNewDefaultFonts( 1 ) // since version 2.0.22 we can use nicer default fonts


// Create a basic example map
map AS TMS_Map
map = TMS_LoadMap("world1.txt", "tileset.png", 48, 16, 16)
TMS_SetCameraDimensions(map, 640, 480)
TMS_SetMapCameraPos(map, 0, 0)


do
	IF GetRawKeyState(37) // left
		TMS_AddCameraMovement(map, -5, 0)
	ENDIF
	
	IF GetRawKeyState(39) // right
		TMS_AddCameraMovement(map, 5, 0)
	ENDIF
	
    IF GetRawKeyState(38) // up
		TMS_AddCameraMovement(map, 0, -5)
	ENDIF
	
	IF GetRawKeyState(40) // down
		TMS_AddCameraMovement(map, 0, 5)
	ENDIF
	
    TMS_DrawMap(map)
    Sync()
loop
