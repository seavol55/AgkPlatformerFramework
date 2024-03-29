/*
 * File name: TileMapSystem.agc
 *
 * Description: File that holds all the types and functions related to
 * Tile map display inside screen
 *
 */

#include "src/System/SystemConventions.agc"


/*
 * Type Name: TMS_Tile
 *
 * Properties:
 *     Id       = Internal Id inside the textfile that contained the tile
 *
 * Description: Type that represents a single tile of a map
 */
TYPE TMS_Tile
    Id       AS INTEGER
    Walkable AS INTEGER
ENDTYPE


/*
 * Type Name: TMS_Map
 *
 * Properties:
 *     Width      = Number of tiles of width
 *     Height     = Number of tiles of height for the map
 *     TileSize   = Dimension of the square that represents the tile
 *     TileSetId  = Sprite Id of the original TileSet image loaded in memory
 *     Data       = All the tile objects that conforms the map
 *     SpriteData = Matrix with all sprites that are visible given camera dimenions
 *     Camera     = camera object that will be in charge of displaying a portion of the map
 *
 * Description: Type that represents a collection of tiles that conforms
 *              the map to render
 */
TYPE TMS_Map
    Width      AS INTEGER
    Height     AS INTEGER
    TileSize   AS INTEGER
    TileSetId  AS INTEGER
    Data       AS TMS_Tile[0,0]
    SpriteData AS INTEGER[0, 0]
    Camera     AS TMS_Camera
ENDTYPE

/*
 * Type Name: TMS_Camera
 *
 * Properties:
 *     XCameraPos = x coordinate regarding the world map being displayed where the camera starts
 *     YCameraPos = y coordinate regarding the world map being displayed where the camera starts
 *     Width      = Width of the camera
 *     Height     = Height of the camera
 *
 * Description: Type that represents a camera that is going to display a part of the map
 *
 */
TYPE TMS_Camera
    XCameraPos AS FLOAT
    YCameraPos AS FLOAT
    Width AS INTEGER
    Height AS INTEGER
ENDTYPE


/*
 * Function Name: TMS_LoadMap
 *
 * Parameters:
 *     mapDescriptor = file path that holds the map data to display
 *     tileSet       = file path that contains the image with all the different tiles
 *                     that will be used to render the map
 *     tileSize      = dimensions of the square that represents a tile
 *     width         = number of tiles that conforms the width of the map
 *     height        = number of tiles that conforms the height of the map
 *
 * Returns Values:
 *     TMS_Map object with all loaded tiles
 *
 * Description: Function used to load a map in memory for future display
 */
FUNCTION TMS_LoadMap(mapDescriptor AS STRING, tileSet AS STRING, tileSize AS INTEGER, width AS INTEGER, height AS INTEGER)
    map            AS TMS_Map
    fileDescriptor AS INTEGER
    sprTileSet     AS INTEGER
    tileCount      AS INTEGER
    
    // Configure how many rows and columns the tile will have
    map.Width = width
    map.Height = height
    map.TileSize = tileSize
    
    // Load in memory the tileset that contains all data to load
    sprTileSet = CreateSprite(LoadImage(tileSet))
    tileCount = (GetSpriteWidth(sprTileSet) / map.TileSize) * (GetSpriteHeight(sprTileSet) / map.TileSize)
    SetSpriteAnimation(sprTileSet, map.TileSize, map.TileSize, tileCount)
    SetSpriteDepth(sprTileSet, BACKGROUND_LEVEL_DRAW) // Map tiles should be at the bottom of the screen concerning draw order
    
    map.TileSetId = sprTileSet
    
    // Load in memory the file that describes how the map looks like
    fileDescriptor = OpenToRead(mapDescriptor)
    
    map.Data.Length = map.Height
    FOR x = 0 TO map.Height - 1
        map.Data[x].Length = map.Width
    NEXT x
    
    
    // Populate TMS_Map with the data from the text file
    FOR x = 0 TO map.Height - 1
        strLine AS STRING
        strLine = ReadLine(fileDescriptor)
        
        FOR y = 0 TO map.Width -1
            // Set the original Id for the tile from file
            map.Data[x, y].Id = Val(GetStringToken2(strLine, ",", y + 1))
            map.Data[x, y].Walkable = 1
            
            IF (map.Data[x, y].Id = 5)
				map.Data[x, y].Walkable = 0
			ENDIF
        NEXT y
    NEXT x
    
    CloseFile(fileDescriptor)
    SetSpriteVisible(sprTileSet, 0)
ENDFUNCTION map



/*
 * Function Name: TMS_DrawMap
 *
 * Parameters:
 *     map = TMS_Map that represents the object we want to load in memory
 *
 * Returns Values:
 *     None
 *
 * Description: Function used to render a map already loaded in memory
 */
FUNCTION TMS_DrawMap(map REF AS TMS_Map)
    ClearScreen()
    
    // Step 1: Based on camera resolution and position, calculate just the exact
    //         columns and rows that appear on screen to not waste time moving everything
    //         else
    xTile AS INTEGER
    xTileEnd AS INTEGER
    yTile AS INTEGER
    yTileEnd AS INTEGER
    
    xResidual AS INTEGER
    yResidual AS INTEGER
    
    xTile = Floor(map.Camera.XCameraPos / (map.TileSize * 1.0))
    xTileEnd = Floor((map.Camera.XCameraPos + map.Camera.Width) / (map.TileSize * 1.0))
    xResidual = Mod(map.Camera.XCameraPos, map.TileSize)
    
    yTile = Floor(map.Camera.YCameraPos / (map.TileSize * 1.0))
    yTileEnd = Floor((map.Camera.YCameraPos + map.Camera.Height) / (map.TileSize * 1.0))
    yResidual = Mod(map.Camera.YCameraPos, map.TileSize)
    
    IF (xTileEnd >= map.Width)
        xTileEnd = map.Width - 1
    ENDIF
    
    IF (yTileEnd >= map.Height)
        yTileEnd = map.Height - 1
    ENDIF
    
    // Please dop not confuse, we're using x,y using the matrix conventions
    // but for the plane, x = y, y = x
    FOR x = yTile TO yTileEnd
        FOR y = xTile TO xTileEnd
            xScreenCoordinate AS FLOAT
            yScreenCoordinate AS FLOAT
            
            xScreenCoordinate = (y - xTile)*map.TileSize - xResidual
            yScreenCoordinate = (x - yTile)*map.TileSize - yResidual
            
            // From the buffer, set the corresponding Frame of the tile we are supposed to display
            SetSpriteFrame(map.SpriteData[(x - yTile), (y - xTile)], map.Data[x, y].Id)
            SetSpritePosition(map.SpriteData[(x - yTile), (y - xTile)], xScreenCoordinate, yScreenCoordinate)
        NEXT y
    NEXT x
    
    // Borders put them outside of the screen
    IF ((xTileEnd - xTile) + 1 < map.SpriteData[0].Length)
        FOR x = 0 TO map.SpriteData.Length - 1
            FOR y = (xTileEnd - xTile) + 1 TO map.SpriteData[0].Length - 1
                SetSpritePosition(map.SpriteData[x, y], -500, -500)
            NEXT y
        NEXT x
    ENDIF
    
    IF ((yTileEnd - yTile) + 1 < map.SpriteData.Length)
        FOR x = (yTileEnd - yTile) + 1 TO map.SpriteData.Length - 1
            FOR y = 0 TO map.SpriteData[0].Length - 1
                SetSpritePosition(map.SpriteData[x, y], -500, -500)
            NEXT y
        NEXT x
    ENDIF
    
ENDFUNCTION

/*
 * Function Name: TMS_SetCameraDimensions
 *
 * Parameters:
 *     map    = TMS_Map that represents the object we want to load in memory
 *     width  = Width of the camera that will be used to render the map
 *     height = Height of the camera that will be used to render the map
 *
 * Returns Values:
 *     None
 *
 * Description: Function used to set the camera dimensions that will be used for
 *              the map loaded in memory
 */
FUNCTION TMS_SetCameraDimensions(map REF AS TMS_Map, width AS INTEGER, height AS INTEGER)
    map.Camera.Width = width
    map.Camera.Height = height
    
    // Buffer corresponding sprites that represents the screen
    numberRows AS INTEGER
    numberCols AS INTEGER
    
    numberRows = Ceil(map.Camera.Height / (map.TileSize * 1.0))
    numberCols = Ceil(map.Camera.Width / (map.TileSize * 1.0))
    
    // Add extra buffer if camera won't cover whole map
    IF(numberCols + 2 <= map.Width)
        numberCols = numberCols + 2
    ENDIF
    
    IF(numberRows + 2 <= map.Height)
        numberRows = numberRows + 2
    ENDIF
    
    // Create buffer of Sprites that will be used just to cover the camera
    map.SpriteData.Length = numberRows
    FOR x = 0 TO numberRows - 1
        map.SpriteData[x].Length = numberCols
    NEXT x
    
    FOR x = 0 TO numberRows - 1
        FOR y = 0 TO numberCols - 1
            map.SpriteData[x, y] = CloneSprite(map.TileSetId)
            
            // Set tile offscrean so TileMap renderer doesn't have problems
            SetSpritePosition(map.SpriteData[x, y], -500, -500)
            SetSpriteVisible(map.SpriteData[x, y], 1)
            SetSpriteShape(map.SpriteData[x, y], BOX_SPRITE_SHAPE)
        NEXT y
    NEXT x
ENDFUNCTION


/*
 * Function Name: TMS_SetMapCameraPos
 *
 * Parameters:
 *     map    = TMS_Map that represents the object we want to load in memory
 *     x      = x Map Coordinate to set the camera
 *     y      = y Map Coordinate to set the camera
 *
 * Returns Values:
 *     None
 *
 * Description: Function used to set the camera dimensions that will be used for
 *              the map loaded in memory
 */
FUNCTION TMS_SetMapCameraPos(map REF AS TMS_Map, x AS FLOAT, y AS FLOAT)
    map.Camera.XCameraPos = x
    map.Camera.YCameraPos = y
    
    // If the camera position is less than 0, force it to be 0 
    // (so camera doesn't go out of boundaries)
    IF (map.Camera.XCameraPos < 0)
        map.Camera.XCameraPos = 0
    ENDIF
    
    IF (map.Camera.YCameraPos < 0)
        map.Camera.YCameraPos = 0
    ENDIF
    
    // Avoid to show black area
    IF ((map.Camera.XCameraPos + map.Camera.Width) > map.Width * map.TileSize )
        map.Camera.XCameraPos = (map.Width * map.TileSize) - map.Camera.Width
    ENDIF
    
    IF ((map.Camera.YCameraPos + map.Camera.Height) > map.Height * map.TileSize )
        map.Camera.YCameraPos = (map.Height * map.TileSize) - map.Camera.Height
    ENDIF
ENDFUNCTION



/*
 * Function Name: TMS_AddCameraMovement
 *
 * Parameters:
 *     map    = TMS_Map that represents the object we want to load in memory
 *     x      = x amount to add/substract to the current camera position
 *     y      = y amount to add/substract to the current camera position
 *
 * Returns Values:
 *     None
 *
 * Description: Function used to Add a given amount of movement to the map camera
 */
FUNCTION TMS_AddCameraMovement(map REF AS TMS_Map, x AS FLOAT, y AS FLOAT)
    map.Camera.XCameraPos = map.Camera.XCameraPos + x
    map.Camera.YCameraPos = map.Camera.YCameraPos + y
    
    // If the camera position is less than 0, force it to be 0 
    // (so camera doesn't go out of boundaries)
    IF (map.Camera.XCameraPos < 0)
        map.Camera.XCameraPos = 0
    ENDIF
    
    IF (map.Camera.YCameraPos < 0)
        map.Camera.YCameraPos = 0
    ENDIF
    
    // Avoid to show black area
    IF ((map.Camera.XCameraPos + map.Camera.Width) > map.Width * map.TileSize )
        map.Camera.XCameraPos = (map.Width * map.TileSize) - map.Camera.Width
    ENDIF
    
    IF ((map.Camera.YCameraPos + map.Camera.Height) > map.Height * map.TileSize )
        map.Camera.YCameraPos = (map.Height * map.TileSize) - map.Camera.Height
    ENDIF
ENDFUNCTION
