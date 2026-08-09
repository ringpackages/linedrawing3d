/*
**  ld_render.ring
**  All drawing/rendering functions
*/

func ld_drawMap
    // Draw the textured map model (walls, floor, ceiling from cubicmap)
    if hasMapModel
        DrawModel(mapModel, mapModelPos, 1.0, WHITE)
    ok

    // Draw special elements that aren't part of the cubicmap
    for r = 1 to MAP_H
        for c = 1 to MAP_W
            t = map[r][c]
            if t != T_EXIT loop ok

            wx = c - 0.5
            wz = r - 0.5

            ddx = wx - pX
            ddz = wz - pZ
            if ddx*ddx + ddz*ddz > 400 loop ok

            // Glowing exit marker on floor
            DrawCube(Vector3(wx, 0.01, wz), 0.95, 0.02, 0.95,
                     RAYLIBColor(220, 230, 240, 200))
            pulse = sin(animTime * 4.0) * 0.15 + 0.5
            DrawCube(Vector3(wx, pulse, wz), 0.3, 0.3, 0.3,
                     RAYLIBColor(230, 240, 255, floor(sin(animTime*3)*60+150)))
        next
    next


func ld_drawDoors
    nDoors = len(doors)
    for i = 1 to nDoors
        r = doors[i][1]
        c = doors[i][2]
        solved = doors[i][5]
        wx = c - 0.5
        wz = r - 0.5

        ddx = wx - pX
        ddz = wz - pZ
        if ddx*ddx + ddz*ddz > 400 loop ok

        // Detect orientation
        wallNorth = false
        wallSouth = false
        wallEast = false
        wallWest = false
        if c+1 <= MAP_W
            tw = map[r][c+1]
            if tw = T_WALL1 or tw = T_WALL2 or tw = T_WALL3 or tw = T_DOOR wallEast = true ok
        ok
        if c-1 >= 1
            tw = map[r][c-1]
            if tw = T_WALL1 or tw = T_WALL2 or tw = T_WALL3 or tw = T_DOOR wallWest = true ok
        ok
        if r-1 >= 1
            tw = map[r-1][c]
            if tw = T_WALL1 or tw = T_WALL2 or tw = T_WALL3 or tw = T_DOOR wallNorth = true ok
        ok
        if r+1 <= MAP_H
            tw = map[r+1][c]
            if tw = T_WALL1 or tw = T_WALL2 or tw = T_WALL3 or tw = T_DOOR wallSouth = true ok
        ok

        isVertical = (wallNorth or wallSouth) and (!wallEast and !wallWest)

        if solved
            // Door open - draw frame only
            if isVertical
                DrawCube(Vector3(wx, 0.98, wz), 0.18, 0.04, 1.0,
                         RAYLIBColor(80, 80, 90, 255))
            else
                DrawCube(Vector3(wx, 0.98, wz), 1.0, 0.04, 0.18,
                         RAYLIBColor(80, 80, 90, 255))
            ok
        else
            // Locked door
            doorCol = RAYLIBColor(50, 40, 120, 255)
            lockCol = RAYLIBColor(140, 160, 255, 255)

            if isVertical
                DrawCube(Vector3(wx, 0.5, wz), 0.12, 1.0, 1.0, doorCol)
                DrawCube(Vector3(wx, 0.98, wz), 0.18, 0.04, 1.0,
                         RAYLIBColor(80, 80, 90, 255))
                // Lock symbol
                DrawCube(Vector3(wx + 0.065, 0.5, wz), 0.005, 0.12, 0.12, lockCol)
                DrawCube(Vector3(wx + 0.065, 0.58, wz), 0.005, 0.04, 0.06,
                         RAYLIBColor(180, 140, 255, 255))
            else
                DrawCube(Vector3(wx, 0.5, wz), 1.0, 1.0, 0.12, doorCol)
                DrawCube(Vector3(wx, 0.98, wz), 1.0, 0.04, 0.18,
                         RAYLIBColor(80, 80, 90, 255))
                // Lock symbol
                DrawCube(Vector3(wx, 0.5, wz + 0.065), 0.12, 0.12, 0.005, lockCol)
                DrawCube(Vector3(wx, 0.58, wz + 0.065), 0.06, 0.04, 0.005,
                         RAYLIBColor(180, 140, 255, 255))
            ok

            // Glowing indicator on locked doors
            pulse = sin(animTime * 2.0) * 0.3 + 0.7
            gAlpha = floor(80 * pulse)
            DrawCube(Vector3(wx, 0.5, wz), 0.3, 0.3, 0.3,
                     RAYLIBColor(120, 80, 220, gAlpha))
        ok
    next


func ld_drawSpheres3D
    // Sphere colors matching each type
    // jade, amethyst, amber, crystal, obsidian, nebula, opal, fire, golden, ice

    nSpheres = len(sphereList)
    for spIdx = 1 to nSpheres
        if sphereList[spIdx][4] = true loop ok   // collected, skip

        spR = sphereList[spIdx][1]
        spC = sphereList[spIdx][2]
        spType = sphereList[spIdx][3]
        spPhase = sphereList[spIdx][5]

        spX = spC - 0.5
        spZ = spR - 0.5
        bobY = 0.35 + sin(animTime * 2.5 + spPhase) * 0.08

        // Distance culling
        ddx = spX - pX
        ddz = spZ - pZ
        dist = sqrt(ddx * ddx + ddz * ddz)
        if dist > 18 loop ok

        spPos = Vector3(spX, bobY, spZ)
        spRad = 0.18 + sin(animTime * 1.5 + spPhase) * 0.02

        // Color per type: cyan, purple, black
        switch spType
        on 0  spCol = RAYLIBColor(80, 200, 230, 255)      // cyan
        on 1  spCol = RAYLIBColor(120, 60, 200, 255)      // purple
        on 2  spCol = RAYLIBColor(30, 25, 40, 255)        // black
        other spCol = RAYLIBColor(80, 200, 230, 255)
        off

        // Main sphere
        DrawSphere(spPos, spRad, spCol)

        // Wire overlay for definition
        switch spType
        on 0
            // Cyan sphere: white wires for crisp look
            DrawSphereWires(spPos, spRad + 0.005, 8, 8,
                            RAYLIBColor(255, 255, 255, 120))
        on 1
            // Purple sphere: light purple wires
            DrawSphereWires(spPos, spRad + 0.005, 8, 8,
                            RAYLIBColor(200, 180, 255, 90))
        on 2
            // Black sphere: subtle purple wire
            DrawSphereWires(spPos, spRad + 0.005, 8, 8,
                            RAYLIBColor(100, 60, 180, 80))
        other
            DrawSphereWires(spPos, spRad + 0.005, 8, 8,
                            RAYLIBColor(255, 255, 255, 120))
        off

        // Glow on floor matching sphere color
        glowAlpha = floor(40 + sin(animTime * 3.0 + spPhase) * 20)
        glowPos = Vector3(spX, 0.05, spZ)
        switch spType
        on 0  DrawSphere(glowPos, 0.1, RAYLIBColor(80, 200, 240, glowAlpha))
        on 1  DrawSphere(glowPos, 0.1, RAYLIBColor(140, 80, 220, glowAlpha))
        on 2  DrawSphere(glowPos, 0.1, RAYLIBColor(80, 50, 150, glowAlpha))
        other DrawSphere(glowPos, 0.1, RAYLIBColor(80, 200, 240, glowAlpha))
        off
    next


func ld_drawPuzzlePanels3D
    nPanels = len(puzzlePanels)
    nDoors = len(doors)
    for i = 1 to nPanels
        pr = puzzlePanels[i][1]
        pc = puzzlePanels[i][2]
        side = puzzlePanels[i][3]
        doorIdx = puzzlePanels[i][4]

        // Check if already solved
        isSolved = false
        if doorIdx >= 1 and doorIdx <= nDoors
            isSolved = doors[doorIdx][5]
        ok

        wx = pc - 0.5
        wz = pr - 0.5

        ddx = wx - pX
        ddz = wz - pZ
        if ddx*ddx + ddz*ddz > 400 loop ok

        // Panel dimensions
        panW = 0.6
        panH = 0.6

        pulse = sin(animTime * 2.5 + i) * 0.3 + 0.7

        if isSolved
            panCol = RAYLIBColor(220, 230, 240, floor(180 * pulse))
            frameCol = RAYLIBColor(180, 190, 210, 200)
        else
            panCol = RAYLIBColor(80, 100, 200, floor(220 * pulse))
            frameCol = RAYLIBColor(60, 70, 160, 200)
        ok

        // Draw based on wall side
        if side = 1   // North wall (panel faces south, z+)
            DrawCube(Vector3(wx, 0.5, wz - 0.48), panW, panH, 0.02, panCol)
            DrawCubeWires(Vector3(wx, 0.5, wz - 0.48), panW + 0.05, panH + 0.05, 0.03, frameCol)
        ok
        if side = 2   // South wall (panel faces north, z-)
            DrawCube(Vector3(wx, 0.5, wz + 0.48), panW, panH, 0.02, panCol)
            DrawCubeWires(Vector3(wx, 0.5, wz + 0.48), panW + 0.05, panH + 0.05, 0.03, frameCol)
        ok
        if side = 3   // East wall (panel faces west, x-)
            DrawCube(Vector3(wx + 0.48, 0.5, wz), 0.02, panH, panW, panCol)
            DrawCubeWires(Vector3(wx + 0.48, 0.5, wz), 0.03, panH + 0.05, panW + 0.05, frameCol)
        ok
        if side = 4   // West wall (panel faces east, x+)
            DrawCube(Vector3(wx - 0.48, 0.5, wz), 0.02, panH, panW, panCol)
            DrawCubeWires(Vector3(wx - 0.48, 0.5, wz), 0.03, panH + 0.05, panW + 0.05, frameCol)
        ok

        // Glow around panel
        if !isSolved
            gAlpha = floor(30 * pulse)
            DrawCube(Vector3(wx, 0.5, wz), 0.9, 0.9, 0.9,
                     RAYLIBColor(80, 60, 180, gAlpha))
        ok
    next


func ld_drawPuzzle2D
    // Compute cell size - cap it so puzzles are comfortable to see
    maxCellSz = 150
    if SCREEN_H < 900 maxCellSz = 120 ok
    if SCREEN_H < 700 maxCellSz = 90 ok

    // Available area
    availW = SCREEN_W - 200
    availH = SCREEN_H - 200

    cellW2 = availW / (puzzGridW - 1)
    cellH2 = availH / (puzzGridH - 1)
    cSz = cellW2
    if cellH2 < cSz cSz = cellH2 ok
    if cSz > maxCellSz cSz = maxCellSz ok
    if cSz < 40 cSz = 40 ok

    totalGW = floor((puzzGridW - 1) * cSz)
    totalGH = floor((puzzGridH - 1) * cSz)

    // Grid margins around the grid inside panel
    gridPad = floor(cSz * 0.7)
    if gridPad < 50 gridPad = 50 ok
    titleH = 70

    // Panel sized to fit the grid + padding
    panelW2 = totalGW + gridPad * 2
    panelH2 = totalGH + gridPad * 2 + titleH
    panelX2 = floor((SCREEN_W - panelW2) / 2)
    panelY2 = floor((SCREEN_H - panelH2) / 2)

    // Grid position inside panel
    ofsX = panelX2 + gridPad
    ofsY = panelY2 + gridPad + titleH

    // Cache for mouse handler
    puzzOffsetX = ofsX
    puzzOffsetY = ofsY
    puzzCellSz = cSz

    // ---- Panel background (clean white/light) ----
    panelBgCol = RAYLIBColor(220, 225, 235, 250)
    panelFaceCol = RAYLIBColor(245, 248, 252, 255)
    if gameState = ST_SOLVED
        panelFaceCol = RAYLIBColor(235, 245, 255, 255)
    ok
    if puzzFailed
        panelFaceCol = RAYLIBColor(255, 220, 220, 255)
    ok

    // Outer frame shadow
    DrawRectangle(panelX2 - 4, panelY2 - 4, panelW2 + 8, panelH2 + 8,
                  RAYLIBColor(100, 100, 120, 250))
    // Panel backing
    DrawRectangle(panelX2, panelY2, panelW2, panelH2, panelBgCol)

    // Inner panel face (white)
    innerMargin = 15
    innerCol = RAYLIBColor(250, 252, 255, 255)
    if gameState = ST_SOLVED
        innerCol = RAYLIBColor(240, 248, 255, 255)
    ok
    if puzzFailed
        innerCol = RAYLIBColor(255, 225, 225, 255)
    ok
    DrawRectangle(panelX2 + innerMargin, panelY2 + innerMargin,
                  panelW2 - innerMargin * 2, panelH2 - innerMargin * 2, panelFaceCol)

    // Frame border
    DrawRectangleLinesEx(Rectangle(panelX2 + innerMargin, panelY2 + innerMargin,
                  panelW2 - innerMargin * 2, panelH2 - innerMargin * 2), 2,
                  RAYLIBColor(140, 130, 170, 220))

    // Ambient glow behind grid area
    pulse = 0.5 + sin(animTime * 1.5) * 0.2
    gAlpha = floor(15 * pulse)
    DrawRectangle(ofsX - 20, ofsY - 20, floor(totalGW) + 40, floor(totalGH) + 40,
                  RAYLIBColor(120, 100, 200, gAlpha))

    // Title
    defIdx = puzzlePanels[activePanelIdx][5]
    title = "PUZZLE " + defIdx
    ttw = MeasureText(title, 24)
    DrawText(title, floor(SCREEN_W/2 - ttw/2), panelY2 + 22, 24,
             RAYLIBColor(80, 50, 130, 255))

    // Grid info
    gInfo = "Grid: " + puzzGridW + "x" + puzzGridH + "   Path: " + (len(puzzPathNodes) - 1) + " segments"
    giw = MeasureText(gInfo, 13)
    DrawText(gInfo, floor(SCREEN_W/2 - giw/2), panelY2 + 48, 13,
             RAYLIBColor(100, 80, 140, 200))

    // ---- Draw grid edges (matching witness3d thick style) ----
    lineThick = cSz * 0.06
    if lineThick < 3 lineThick = 3 ok
    lineCol = RAYLIBColor(60, 40, 100, 240)
    brokenDimCol = RAYLIBColor(50, 35, 80, 200)
    brokenMarkCol = RAYLIBColor(200, 50, 50, 220)

    // Horizontal edges
    for r = 1 to puzzGridH
        for c = 1 to puzzGridW - 1
            x1 = ofsX + (c - 1) * cSz
            y1 = ofsY + (r - 1) * cSz
            x2 = ofsX + c * cSz

            if puzzHEdge[r][c] = EDGE_BROKEN
                // Broken edge: two short stubs + red marker (like witness3d)
                seg = (x2 - x1) / 3.0
                DrawLineEx(Vector2(x1, y1), Vector2(x1 + seg * 0.7, y1), lineThick, brokenDimCol)
                DrawLineEx(Vector2(x2 - seg * 0.7, y1), Vector2(x2, y1), lineThick, brokenDimCol)
                emx = floor((x1 + x2) / 2)
                DrawCircle(emx, y1, lineThick * 2.5, brokenMarkCol)
            else
                DrawLineEx(Vector2(x1, y1), Vector2(x2, y1), lineThick, lineCol)
            ok
        next
    next

    // Vertical edges
    for r = 1 to puzzGridH - 1
        for c = 1 to puzzGridW
            x1 = ofsX + (c - 1) * cSz
            y1 = ofsY + (r - 1) * cSz
            y2 = ofsY + r * cSz

            if puzzVEdge[r][c] = EDGE_BROKEN
                seg = (y2 - y1) / 3.0
                DrawLineEx(Vector2(x1, y1), Vector2(x1, y1 + seg * 0.7), lineThick, brokenDimCol)
                DrawLineEx(Vector2(x1, y2 - seg * 0.7), Vector2(x1, y2), lineThick, brokenDimCol)
                emy = floor((y1 + y2) / 2)
                DrawCircle(x1, emy, lineThick * 2.5, brokenMarkCol)
            else
                DrawLineEx(Vector2(x1, y1), Vector2(x1, y2), lineThick, lineCol)
            ok
        next
    next

    // ---- Draw cell constraints (B/W squares like witness3d) ----
    for r = 1 to puzzGridH - 1
        for c = 1 to puzzGridW - 1
            if puzzCellCons[r][c] = CONS_NONE loop ok
            ccx = ofsX + floor((c - 0.5) * cSz)
            ccy = ofsY + floor((r - 0.5) * cSz)
            conSz = floor(cSz * 0.22)
            if conSz < 10 conSz = 10 ok

            if puzzCellCons[r][c] = CONS_BLACK
                DrawRectangle(ccx - conSz, ccy - conSz, conSz * 2, conSz * 2,
                              RAYLIBColor(40, 30, 60, 255))
                DrawRectangleLines(ccx - conSz, ccy - conSz, conSz * 2, conSz * 2,
                                   RAYLIBColor(60, 45, 90, 255))
            ok
            if puzzCellCons[r][c] = CONS_WHITE
                DrawRectangle(ccx - conSz, ccy - conSz, conSz * 2, conSz * 2,
                              RAYLIBColor(235, 230, 245, 255))
                DrawRectangleLines(ccx - conSz, ccy - conSz, conSz * 2, conSz * 2,
                                   RAYLIBColor(180, 170, 200, 255))
            ok
        next
    next

    // ---- Draw node markers (matching witness3d) ----
    for r = 1 to puzzGridH
        for c = 1 to puzzGridW
            nnx = ofsX + (c - 1) * cSz
            nny = ofsY + (r - 1) * cSz

            // Regular junction dot
            if puzzNodeMarker[r][c] = NODE_NONE
                DrawCircle(nnx, nny, lineThick * 0.8, RAYLIBColor(60, 40, 100, 200))
            ok

            // Start circle (large pulsing golden circle like witness3d)
            if puzzNodeMarker[r][c] = NODE_START
                pulse2 = 0.7 + sin(animTime * 3.0) * 0.3
                sRad = floor(cSz * 0.12) + 5
                DrawCircle(nnx, nny, sRad, RAYLIBColor(100, 70, 210, floor(230 * pulse2)))
                DrawCircleLines(nnx, nny, sRad + 3, RAYLIBColor(130, 100, 230, floor(160 * pulse2)))
                // Outer glow
                DrawCircle(nnx, nny, sRad + 6, RAYLIBColor(100, 70, 210, floor(50 * pulse2)))
            ok

            // Exit notch - draw as an opening in the grid border with a small cap
            if puzzNodeMarker[r][c] = NODE_EXIT
                pulse2 = 0.7 + sin(animTime * 3.5) * 0.3
                exitLen = floor(cSz * 0.15)
                exitThick = lineThick + 1
                eCol = RAYLIBColor(100, 70, 210, floor(230 * pulse2))
                // Draw short stub extending outward then a rounded end
                if r = 1
                    DrawLineEx(Vector2(nnx, nny), Vector2(nnx, nny - exitLen), exitThick, eCol)
                    DrawCircle(nnx, nny - exitLen, floor(exitThick * 0.7), eCol)
                but r = puzzGridH
                    DrawLineEx(Vector2(nnx, nny), Vector2(nnx, nny + exitLen), exitThick, eCol)
                    DrawCircle(nnx, nny + exitLen, floor(exitThick * 0.7), eCol)
                but c = 1
                    DrawLineEx(Vector2(nnx, nny), Vector2(nnx - exitLen, nny), exitThick, eCol)
                    DrawCircle(nnx - exitLen, nny, floor(exitThick * 0.7), eCol)
                but c = puzzGridW
                    DrawLineEx(Vector2(nnx, nny), Vector2(nnx + exitLen, nny), exitThick, eCol)
                    DrawCircle(nnx + exitLen, nny, floor(exitThick * 0.7), eCol)
                ok
                // Node circle at the exit position
                DrawCircle(nnx, nny, floor(lineThick * 1.2),
                           RAYLIBColor(120, 90, 220, floor(200 * pulse2)))
            ok

            // Required dot (diamond shape like witness3d)
            if puzzNodeMarker[r][c] = NODE_DOT
                pulse2 = 0.6 + sin(animTime * 4.0 + r * 1.1 + c * 0.7) * 0.4
                dotSz = floor(cSz * 0.09) + 4
                DrawPoly(Vector2(nnx, nny), 4, dotSz, 45,
                         RAYLIBColor(100, 70, 210, floor(255 * pulse2)))
                DrawPolyLines(Vector2(nnx, nny), 4, dotSz + 2, 45,
                              RAYLIBColor(255, 255, 150, floor(150 * pulse2)))
                // Glow
                DrawCircle(nnx, nny, dotSz + 4,
                           RAYLIBColor(100, 70, 210, floor(30 * pulse2)))
            ok
        next
    next

    // ---- Draw path (thick with glow, matching witness3d) ----
    pathThick = cSz * 0.1
    if pathThick < 5 pathThick = 5 ok
    pathCol = RAYLIBColor(80, 60, 200, 255)
    pathGlowCol = RAYLIBColor(100, 80, 220, 60)
    if gameState = ST_SOLVED
        pathCol = RAYLIBColor(100, 80, 220, 255)
        pathGlowCol = RAYLIBColor(120, 100, 240, 50)
    ok
    if puzzFailed
        pathCol = RAYLIBColor(200, 60, 50, 255)
        pathGlowCol = RAYLIBColor(200, 60, 50, 40)
    ok

    // Path glow (drawn first, behind)
    glowThick = pathThick * 3.0
    nPath = len(puzzPathNodes)
    for i = 1 to nPath - 1
        x1 = ofsX + (puzzPathNodes[i][2] - 1) * cSz
        y1 = ofsY + (puzzPathNodes[i][1] - 1) * cSz
        x2 = ofsX + (puzzPathNodes[i+1][2] - 1) * cSz
        y2 = ofsY + (puzzPathNodes[i+1][1] - 1) * cSz
        DrawLineEx(Vector2(x1, y1), Vector2(x2, y2), glowThick, pathGlowCol)
    next

    // Path segments
    for i = 1 to nPath - 1
        x1 = ofsX + (puzzPathNodes[i][2] - 1) * cSz
        y1 = ofsY + (puzzPathNodes[i][1] - 1) * cSz
        x2 = ofsX + (puzzPathNodes[i+1][2] - 1) * cSz
        y2 = ofsY + (puzzPathNodes[i+1][1] - 1) * cSz
        DrawLineEx(Vector2(x1, y1), Vector2(x2, y2), pathThick, pathCol)
    next

    // Path node circles
    nodeRad = pathThick * 0.7
    for i = 1 to nPath
        nnx = ofsX + (puzzPathNodes[i][2] - 1) * cSz
        nny = ofsY + (puzzPathNodes[i][1] - 1) * cSz
        DrawCircle(nnx, nny, nodeRad, pathCol)
    next

    // ---- Mouse drag line (follows mouse position) ----
    if puzzMouseDragging and gameState = ST_PUZZLE and !puzzSolverActive
        // Draw line from last path node to current mouse draw position
        lastNX = ofsX + (puzzCursorC - 1) * cSz
        lastNY = ofsY + (puzzCursorR - 1) * cSz
        mdx = puzzMouseDrawX - lastNX
        mdy = puzzMouseDrawY - lastNY
        mDist = sqrt(mdx * mdx + mdy * mdy)
        if mDist > 2
            // Glow
            DrawLineEx(Vector2(lastNX, lastNY), Vector2(puzzMouseDrawX, puzzMouseDrawY),
                       glowThick, pathGlowCol)
            // Line
            DrawLineEx(Vector2(lastNX, lastNY), Vector2(puzzMouseDrawX, puzzMouseDrawY),
                       pathThick, pathCol)
            // Tip circle
            DrawCircle(floor(puzzMouseDrawX), floor(puzzMouseDrawY), nodeRad, pathCol)
            // Bright tip glow
            tipPulse = 0.7 + sin(animTime * 8.0) * 0.3
            DrawCircle(floor(puzzMouseDrawX), floor(puzzMouseDrawY), nodeRad + 3,
                       RAYLIBColor(140, 120, 240, floor(80 * tipPulse)))
        ok
    ok

    // ---- Cursor (pulsing ring like witness3d) ----
    if gameState = ST_PUZZLE and !puzzSolverActive
        cux = ofsX + (puzzCursorC - 1) * cSz
        cuy = ofsY + (puzzCursorR - 1) * cSz
        pulse2 = 0.6 + sin(animTime * 4.0) * 0.4
        curRad = floor(cSz * 0.12)
        DrawCircle(cux, cuy, curRad, RAYLIBColor(90, 60, 200, floor(220 * pulse2)))
        DrawCircleLines(cux, cuy, curRad + 3, RAYLIBColor(120, 90, 220, floor(150 * pulse2)))
    ok

    // ---- Draw hint path (if showing, matching witness3d cyan) ----
    if puzzShowHint and len(puzzHintPath) >= 2
        hPulse = 0.4 + sin(animTime * 5.0) * 0.3
        hAlpha = floor(120 * hPulse)
        hThick = lineThick * 0.6
        nHint = len(puzzHintPath)
        for i = 1 to nHint - 1
            x1 = ofsX + (puzzHintPath[i][2] - 1) * cSz
            y1 = ofsY + (puzzHintPath[i][1] - 1) * cSz
            x2 = ofsX + (puzzHintPath[i+1][2] - 1) * cSz
            y2 = ofsY + (puzzHintPath[i+1][1] - 1) * cSz
            DrawLineEx(Vector2(x1, y1), Vector2(x2, y2), hThick,
                       RAYLIBColor(100, 255, 200, hAlpha))
        next
    ok

    // ---- Draw particles ----
    nPP = len(puzzParticles)
    for i = 1 to nPP
        pp = puzzParticles[i]
        alpha = floor((pp[5] / 2.0) * 255)
        if alpha > 255 alpha = 255 ok
        if alpha < 0 alpha = 0 ok
        DrawCircle(floor(pp[1]), floor(pp[2]), 3, RAYLIBColor(pp[6], pp[7], pp[8], alpha))
    next

    // ---- Controls hint bar ----
    DrawRectangle(panelX2, panelY2 + panelH2 - 28, panelW2, 28, RAYLIBColor(60, 50, 100, 180))
    ctrlTxt = "Arrows/Mouse: Draw | ENTER: Check | U: Undo | Z: Clear | F: Solve | Q: Cancel"
    cctw = MeasureText(ctrlTxt, 12)
    DrawText(ctrlTxt, floor(SCREEN_W/2 - cctw/2), panelY2 + panelH2 - 20, 12,
             RAYLIBColor(220, 215, 240, 230))

// =============================================================
// Puzzle Node to Screen (for mouse support)
// =============================================================


func ld_drawDoorPrompt
    if gameState != ST_EXPLORE return ok

    nearPanel = false
    nPanels = len(puzzlePanels)
    nDoors = len(doors)
    for i = 1 to nPanels
        pr = puzzlePanels[i][1]
        pc = puzzlePanels[i][2]
        panelX = pc - 0.5
        panelZ = pr - 0.5
        ddx = panelX - pX
        ddz = panelZ - pZ
        dist = sqrt(ddx*ddx + ddz*ddz)

        doorIdx = puzzlePanels[i][4]
        isSolved = false
        if doorIdx >= 1 and doorIdx <= nDoors
            isSolved = doors[doorIdx][5]
        ok

        if dist < 5.0 and !isSolved
            nearPanel = true
        ok
    next

    if nearPanel
        // No prompt displayed - player discovers by walking into door
    ok


func ld_drawCrosshair
    cx = SCREEN_W / 2
    cy = SCREEN_H / 2
    DrawLine(cx - 8, cy, cx + 8, cy, RAYLIBColor(200, 200, 200, 120))
    DrawLine(cx, cy - 8, cx, cy + 8, RAYLIBColor(200, 200, 200, 120))


func ld_drawExploreHUD
    // Top bar
    DrawRectangle(0, 0, SCREEN_W, 30, RAYLIBColor(0, 0, 0, 180))

    title = "Line Drawing 3D"
    DrawText(title, 40, 6, 18, RAYLIBColor(255, 220, 100, 255))

    // Puzzle progress
    solvedPuzzles = 0
    totalPuzzles = len(puzzlePanels)
    nDoors = len(doors)
    for i = 1 to totalPuzzles
        doorIdx = puzzlePanels[i][4]
        if doorIdx >= 1 and doorIdx <= nDoors
            if doors[doorIdx][5] = true
                solvedPuzzles += 1
            ok
        ok
    next

    prog = "Puzzles: " + solvedPuzzles + "/" + totalPuzzles
    pW = MeasureText(prog, 16)
    DrawText(prog, SCREEN_W - pW - 20, 7, 16, RAYLIBColor(200, 200, 200, 220))

    // Sphere score
    collectedSpheres = 0
    nSpheres = len(sphereList)
    for spIdx = 1 to nSpheres
        if sphereList[spIdx][4] = true collectedSpheres += 1 ok
    next
    scoreStr = "Score: " + sphereScore + "  Spheres: " + collectedSpheres + "/" + nSpheres
    DrawText(scoreStr, floor(SCREEN_W / 2) - floor(MeasureText(scoreStr, 16) / 2), 7, 16,
             RAYLIBColor(255, 200, 80, 220))

func ld_drawMinimap
    mapScale = 4
    mapDispW = MAP_W * mapScale
    mapDispH = MAP_H * mapScale
    mapX = SCREEN_W - mapDispW - 15
    mapY = 40

    // Dark background
    DrawRectangle(mapX - 2, mapY - 2, mapDispW + 4, mapDispH + 4,
                  RAYLIBColor(0, 0, 0, 200))

    // Draw rooms as open rectangles (floor only, no internal walls)
    nRooms = len(roomBounds)
    for ri = 1 to nRooms
        rb = roomBounds[ri]
        rx = mapX + (rb[2] - 1) * mapScale
        ry = mapY + (rb[1] - 1) * mapScale
        rw = (rb[4] - rb[2] + 1) * mapScale
        rh = (rb[3] - rb[1] + 1) * mapScale

        // Room floor (dark grey)
        DrawRectangle(rx, ry, rw, rh, RAYLIBColor(50, 50, 65, 255))
        // Room border (subtle)
        DrawRectangleLines(rx, ry, rw, rh, RAYLIBColor(100, 100, 120, 180))
    next

    // Outer border
    DrawRectangleLines(mapX, mapY, mapDispW, mapDispH, RAYLIBColor(100, 100, 100, 200))

    // Find which room player is in and highlight it
    playerRow = floor(pZ) + 1
    playerCol = floor(pX) + 1
    for ri = 1 to nRooms
        rb = roomBounds[ri]
        if playerRow >= rb[1] and playerRow <= rb[3] and playerCol >= rb[2] and playerCol <= rb[4]
            // Draw yellow border around current room
            rx = mapX + (rb[2] - 1) * mapScale
            ry = mapY + (rb[1] - 1) * mapScale
            rw = (rb[4] - rb[2] + 1) * mapScale
            rh = (rb[3] - rb[1] + 1) * mapScale

            // Pulsing yellow glow
            pulse = floor(sin(animTime * 3.0) * 40 + 215)

            // Filled translucent highlight
            DrawRectangle(rx, ry, rw, rh, RAYLIBColor(255, 220, 50, 25))

            // Yellow border (double line for visibility)
            DrawRectangleLines(rx, ry, rw, rh,
                              RAYLIBColor(255, 220, 50, pulse))
            DrawRectangleLines(rx - 1, ry - 1, rw + 2, rh + 2,
                              RAYLIBColor(255, 200, 30, floor(pulse * 0.6)))
        ok
    next

    // Player position with circle highlight
    plx = mapX + floor(pX) * mapScale
    ply = mapY + floor(pZ) * mapScale
    plCenterX = plx + mapScale / 2
    plCenterY = ply + mapScale / 2

    // Pulsing outer circle (yellow ring around player)
    circlePulse = 0.6 + sin(animTime * 4.0) * 0.4
    circleRad = floor(mapScale * 2.5)
    DrawCircleLines(plCenterX, plCenterY, circleRad + 2,
                    RAYLIBColor(255, 220, 50, floor(100 * circlePulse)))
    DrawCircleLines(plCenterX, plCenterY, circleRad,
                    RAYLIBColor(255, 240, 80, floor(180 * circlePulse)))

    // Player dot (bright cyan)
    DrawCircle(plCenterX, plCenterY, mapScale, RAYLIBColor(130, 200, 255, 255))
    DrawCircle(plCenterX, plCenterY, mapScale - 1, RAYLIBColor(180, 230, 255, 255))

    // Direction indicator
    dirEndX = plCenterX + floor(cos(camYaw) * mapScale * 2.5)
    dirEndY = plCenterY + floor(sin(camYaw) * mapScale * 2.5)
    DrawLineEx(Vector2(plCenterX, plCenterY), Vector2(dirEndX, dirEndY),
               2, RAYLIBColor(255, 255, 255, 200))
    DrawCircle(dirEndX, dirEndY, 2, RAYLIBColor(255, 255, 255, 220))


# Decorative gradient border frame around the welcome screen, in the style of
# povc.ring's notification borders (drawFancyBorder) but drawn with plain
# raylib primitives instead of the border PNG.
func drawScreenBorder gradCol1, gradCol2, outerCol, innerCol
    inset = 14   thick = 5
    DrawRectangleGradientH(inset, inset, SCREEN_W-inset*2, thick, gradCol1, gradCol2)
    DrawRectangleGradientH(inset, SCREEN_H-inset-thick, SCREEN_W-inset*2, thick, gradCol2, gradCol1)
    DrawRectangleGradientV(inset, inset, thick, SCREEN_H-inset*2, gradCol1, gradCol2)
    DrawRectangleGradientV(SCREEN_W-inset-thick, inset, thick, SCREEN_H-inset*2, gradCol1, gradCol2)
    DrawRectangleLines(inset-3, inset-3, SCREEN_W-(inset-3)*2, SCREEN_H-(inset-3)*2, outerCol)
    DrawRectangleLines(inset+thick+4, inset+thick+4, SCREEN_W-(inset+thick+4)*2, SCREEN_H-(inset+thick+4)*2, innerCol)

# Shared layout math for the welcome screen, used by both ld_drawTitle (drawing)
# and ld_updateTitleInput (mouse hit-testing) so they can never drift apart.
# Fonts scale with the monitor's actual resolution (baseline = 700px tall),
# and the whole block is vertically centered based on its real content height.
func ld_computeTitleLayout
    mY = SCREEN_H / 700.0

    ld_titleSz    = max(34, floor(60*mY))
    ld_instSz     = max(14, floor(28*mY))
    ld_instPitch  = floor(40*mY)
    ld_demoSz     = max(14, floor(22*mY))
    ld_btnLblSz   = max(18, floor(26*mY))

    ld_btnW   = max(floor(200*mY), MeasureText("Exit", ld_btnLblSz) + 70)
    ld_btnH   = floor(58*mY)
    ld_btnGap = floor(26*mY)

    gap3 = floor(18*mY)   // title -> instructions
    gap4 = floor(20*mY)   // instructions -> demo
    gap5 = floor(24*mY)   // demo -> buttons

    titleBlockH = ld_titleSz + floor(8*mY)
    instBlockH  = 5 * ld_instPitch
    demoBlockH  = 3 * ld_demoSz + floor(14*mY)
    btnBlockH   = ld_btnH

    contentH = titleBlockH+gap3+instBlockH+gap4+demoBlockH+gap5+btnBlockH

    topY = floor((SCREEN_H - contentH) / 2)
    if topY < floor(14*mY)  topY = floor(14*mY)  ok

    ld_titleY   = topY
    ld_instY    = ld_titleY + titleBlockH + gap3
    ld_demoY    = ld_instY + instBlockH + gap4
    ld_btnY     = ld_demoY + demoBlockH + gap5

    totalBtnW = ld_btnW * 2 + ld_btnGap
    ld_btnX1 = floor((SCREEN_W - totalBtnW) / 2)
    ld_btnX2 = ld_btnX1 + ld_btnW + ld_btnGap

func ld_drawTitle
    ld_computeTitleLayout()

    // Menu background image
    DrawTexturePro(menuBackTex,
        Rectangle(0.0, 0.0, menuBackTex.width*1.0, menuBackTex.height*1.0),
        Rectangle(0.0, 0.0, SCREEN_W*1.0, SCREEN_H*1.0),
        Vector2(0.0, 0.0), 0.0, WHITE)

    // Title (with a gentle wobble/bounce, drop-shadow copy underneath)
    wob = floor(sin(animTime * 2.0) * 8)
    t1 = "Line Drawing 3D"
    t1w = MeasureText(t1, ld_titleSz)
    DrawText(t1, floor(SCREEN_W/2 - t1w/2) + 3, ld_titleY + 3 + wob, ld_titleSz, RAYLIBColor(0, 20, 10, 200))
    DrawText(t1, floor(SCREEN_W/2 - t1w/2), ld_titleY + wob, ld_titleSz, WHITE)

    // Instructions
    inst = [
        "WASD / Arrows  -  Move (Explore) / Draw (Puzzle)",
        "Mouse  -  Look Around / Draw Path",
        "TAB  -  Toggle Minimap",
        "F  -  Auto-Solve (in puzzle mode)",
        "Q / ESC  -  Cancel puzzle"
    ]
    nInst = len(inst)
    for i = 1 to nInst
        iW = MeasureText(inst[i], ld_instSz)
        DrawText(inst[i], floor(SCREEN_W/2 - iW/2), ld_instY + (i-1) * ld_instPitch, ld_instSz,
                 RAYLIBColor(180, 220, 180, 200))
    next

    // Demo puzzle grid (bright purple lines)
    dSz = ld_demoSz
    dStartX = floor((SCREEN_W - 3 * dSz) / 2)
    dStartY = ld_demoY
    for r = 0 to 3
        y2 = dStartY + r * dSz
        DrawLine(dStartX, y2, dStartX + 3 * dSz, y2, RAYLIBColor(170, 140, 220, 190))
    next
    for c = 0 to 3
        x2 = dStartX + c * dSz
        DrawLine(x2, dStartY, x2, dStartY + 3 * dSz, RAYLIBColor(170, 140, 220, 190))
    next
    // Demo path (bright purple)
    pathLen = floor(animTime * 2) % 6
    demoPath = [[3,0],[2,0],[1,0],[1,1],[0,1],[0,2]]
    nDemo = len(demoPath)
    for i = 1 to nDemo - 1
        if i > pathLen + 1 loop ok
        x1d = dStartX + demoPath[i][2] * dSz
        y1d = dStartY + demoPath[i][1] * dSz
        x2d = dStartX + demoPath[i+1][2] * dSz
        y2d = dStartY + demoPath[i+1][1] * dSz
        DrawLineEx(Vector2(x1d, y1d), Vector2(x2d, y2d), 4, RAYLIBColor(190, 140, 255, 255))
    next
    DrawCircle(dStartX, dStartY + 3 * dSz, 7, RAYLIBColor(190, 140, 255, 230))
    DrawCircle(dStartX + 2 * dSz, dStartY - 5, 4, RAYLIBColor(190, 140, 255, 230))

    // Play / Exit buttons
    ld_titleButton(ld_btnX1, ld_btnY, ld_btnW, ld_btnH, "Play", ld_titleSel = 1)
    ld_titleButton(ld_btnX2, ld_btnY, ld_btnW, ld_btnH, "Exit", ld_titleSel = 2)

    // Credits
    DrawText("Ring Language + RingRayLib", 10, SCREEN_H - 25, 14,
             RAYLIBColor(180, 220, 180, 160))

    drawScreenBorder(RAYLIBColor(8,60,30,235), RAYLIBColor(3,25,12,235), RAYLIBColor(173,216,230,255), RAYLIBColor(173,216,230,70))

func ld_titleButton bx, by, bw, bh, label, isSelected
    mx = GetMouseX()
    my = GetMouseY()
    hover = (mx >= bx and mx <= bx+bw and my >= by and my <= by+bh)
    if isSelected or hover
        DrawRectangleGradientV(bx, by, bw, bh, RAYLIBColor(210, 235, 248, 255), RAYLIBColor(140, 190, 218, 255))
        DrawRectangleLines(bx, by, bw, bh, RAYLIBColor(0, 0, 80, 255))
        DrawRectangleLines(bx+1, by+1, bw-2, bh-2, RAYLIBColor(0, 0, 80, 255))
        txtCol = RAYLIBColor(0, 0, 80, 255)
    else
        DrawRectangleGradientV(bx, by, bw, bh, RAYLIBColor(25, 35, 45, 255), RAYLIBColor(12, 18, 25, 255))
        DrawRectangleLines(bx, by, bw, bh, RAYLIBColor(173, 216, 230, 255))
        txtCol = RAYLIBColor(173, 216, 230, 255)
    ok
    lw = MeasureText(label, ld_btnLblSz)
    DrawText(label, bx + floor((bw - lw)/2), by + floor((bh - ld_btnLblSz)/2), ld_btnLblSz, txtCol)

func ld_drawSolvedOverlay
    pulse = floor(220 + sin(animTime * 3.0) * 35)

    g1 = "PUZZLE SOLVED!"
    g1w = MeasureText(g1, 44)
    g2 = "Door Unlocked!"
    g2w = MeasureText(g2, 22)

    // Box dimensions
    boxW = g1w + 60
    if g2w + 60 > boxW boxW = g2w + 60 ok
    boxH = 100
    boxX = floor(SCREEN_W/2 - boxW/2)
    boxY = floor(SCREEN_H/2 - boxH/2) - 40

    // Background box
    DrawRectangle(boxX, boxY, boxW, boxH,
                 RAYLIBColor(40, 30, 70, 220))
    DrawRectangleLines(boxX, boxY, boxW, boxH,
                 RAYLIBColor(140, 120, 220, pulse))
    DrawRectangleLines(boxX - 2, boxY - 2, boxW + 4, boxH + 4,
                 RAYLIBColor(100, 80, 180, floor(pulse * 0.6)))

    // Title text
    DrawText(g1, floor(SCREEN_W/2 - g1w/2), boxY + 18, 44,
             RAYLIBColor(255, 255, 255, pulse))

    // Subtitle
    DrawText(g2, floor(SCREEN_W/2 - g2w/2), boxY + 68, 22,
             RAYLIBColor(200, 190, 240, 220))


func ld_drawWinOverlay
    DrawRectangle(0, 0, SCREEN_W, SCREEN_H, RAYLIBColor(0, 30, 50, 180))

    txt1 = "CONGRATULATIONS!"
    w1 = MeasureText(txt1, 52)
    pulse = floor(220 + sin(animTime * 2.5) * 35)
    DrawText(txt1, floor(SCREEN_W/2 - w1/2), SCREEN_H/2 - 80, 52,
             RAYLIBColor(255, 220, 80, pulse))

    txt2 = "All 15 Puzzles Solved!"
    w2 = MeasureText(txt2, 28)
    DrawText(txt2, floor(SCREEN_W/2 - w2/2), SCREEN_H/2 - 10, 28,
             RAYLIBColor(255, 255, 255, 255))

    txt3 = "Press ENTER to Play Again"
    w3 = MeasureText(txt3, 20)
    DrawText(txt3, floor(SCREEN_W/2 - w3/2), SCREEN_H/2 + 40, 20,
             RAYLIBColor(200, 200, 200, 220))
