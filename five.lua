--[[
================================================================================
    PHAZE MENU - ACCURATE UI REPLICA
    
    Réplique fidèle de l'interface Phaze Menu
    - Logo triangulaire + "Phaze"
    - Catégories verticales avec flèches
    - Onglets horizontaux
    - Toggles circulaires
    - Séparateurs stylisés
    - Footer avec infos
    
    Touche par défaut: F5
================================================================================
]]--

local Menu = {}

-- ============================================================================
-- MENU STATE
-- ============================================================================

Menu.Visible = false
Menu.CurrentCategory = 1
Menu.OpenedCategory = nil
Menu.CurrentTab = 1
Menu.CurrentItem = 1
Menu.ItemScrollOffset = 0
Menu.ItemsPerPage = 10
Menu.SelectorY = 0
Menu.SmoothFactor = 0.15

Menu.IsLoading = true
Menu.LoadingComplete = false
Menu.LoadingStartTime = nil
Menu.LoadingDuration = 2000
Menu.LoadingProgress = 0

Menu.SelectingKey = false
Menu.SelectedKey = 0x74 -- F5
Menu.SelectedKeyName = "F5"

Menu.KeyStates = {}

-- ============================================================================
-- COLORS (Phaze Theme - Blue/Cyan accent)
-- ============================================================================

local Colors = {
    -- Backgrounds
    bgMain = { r = 0.08, g = 0.08, b = 0.10, a = 0.95 },
    bgHeader = { r = 0.06, g = 0.06, b = 0.08, a = 1.0 },
    bgItem = { r = 0.10, g = 0.10, b = 0.12, a = 0.9 },
    bgSelected = { r = 0.15, g = 0.40, b = 0.55, a = 1.0 },
    bgTab = { r = 0.12, g = 0.12, b = 0.14, a = 1.0 },
    bgTabActive = { r = 0.15, g = 0.40, b = 0.55, a = 1.0 },
    
    -- Accent (Phaze Blue/Cyan)
    accent = { r = 0.20, g = 0.60, b = 0.85, a = 1.0 },
    accentLight = { r = 0.30, g = 0.70, b = 0.95, a = 1.0 },
    
    -- Text
    textWhite = { r = 1.0, g = 1.0, b = 1.0, a = 1.0 },
    textGray = { r = 0.6, g = 0.6, b = 0.65, a = 1.0 },
    textMuted = { r = 0.4, g = 0.4, b = 0.45, a = 1.0 },
    
    -- Toggle
    toggleOn = { r = 0.20, g = 0.60, b = 0.85, a = 1.0 },
    toggleOff = { r = 0.3, g = 0.3, b = 0.35, a = 1.0 },
    
    -- Separator
    separator = { r = 0.5, g = 0.5, b = 0.55, a = 0.6 }
}

-- ============================================================================
-- DIMENSIONS
-- ============================================================================

local Dim = {
    x = 80,
    y = 150,
    width = 320,
    headerHeight = 70,
    categoryHeight = 32,
    tabHeight = 32,
    itemHeight = 32,
    footerHeight = 28,
    padding = 12,
    toggleRadius = 8,
    logoSize = 28
}

-- ============================================================================
-- DRAWING HELPERS
-- ============================================================================

local function DrawRect(x, y, w, h, color, rounding)
    rounding = rounding or 0
    if Susano and Susano.DrawRectFilled then
        Susano.DrawRectFilled(x, y, w, h, color.r, color.g, color.b, color.a, rounding)
    end
end

local function DrawText(x, y, text, size, color)
    if Susano and Susano.DrawText then
        Susano.DrawText(x, y, tostring(text), size, color.r, color.g, color.b, color.a)
    end
end

local function DrawLine(x1, y1, x2, y2, color, thickness)
    thickness = thickness or 1
    if Susano and Susano.DrawLine then
        Susano.DrawLine(x1, y1, x2, y2, color.r, color.g, color.b, color.a, thickness)
    end
end

local function DrawCircle(x, y, radius, filled, color)
    if Susano and Susano.DrawCircle then
        Susano.DrawCircle(x, y, radius, filled, color.r, color.g, color.b, color.a, 1, 32)
    end
end

local function GetTextWidth(text, size)
    if Susano and Susano.GetTextWidth then
        return Susano.GetTextWidth(tostring(text), size)
    end
    return string.len(tostring(text)) * (size * 0.5)
end

-- ============================================================================
-- DRAW PHAZE LOGO (Triangle)
-- ============================================================================

local function DrawPhaseLogo(x, y, size)
    -- Triangle bleu stylisé (comme le logo Phaze)
    local halfSize = size / 2
    
    -- Triangle principal
    if Susano and Susano.DrawLine then
        -- Côté gauche
        Susano.DrawLine(x, y + size, x + halfSize, y, Colors.accent.r, Colors.accent.g, Colors.accent.b, 1.0, 2)
        -- Côté droit
        Susano.DrawLine(x + halfSize, y, x + size, y + size, Colors.accent.r, Colors.accent.g, Colors.accent.b, 1.0, 2)
        -- Base
        Susano.DrawLine(x, y + size, x + size, y + size, Colors.accent.r, Colors.accent.g, Colors.accent.b, 1.0, 2)
        
        -- Ligne intérieure (style Phaze)
        Susano.DrawLine(x + halfSize, y + 8, x + halfSize, y + size - 5, Colors.accentLight.r, Colors.accentLight.g, Colors.accentLight.b, 0.8, 2)
    end
end

-- ============================================================================
-- DRAW HEADER
-- ============================================================================

local function DrawHeader()
    local x, y = Dim.x, Dim.y
    local w = Dim.width
    local h = Dim.headerHeight
    
    -- Background header
    DrawRect(x, y, w, h, Colors.bgHeader, 6)
    
    -- Logo triangle
    DrawPhaseLogo(x + 20, y + 18, 32)
    
    -- Texte "Phaze"
    DrawText(x + 65, y + 22, "Phaze", 26, Colors.textWhite)
    
    -- Ligne de séparation en bas du header
    DrawLine(x + 10, y + h - 1, x + w - 10, y + h - 1, { r = 0.2, g = 0.2, b = 0.25, a = 0.8 }, 1)
end

-- ============================================================================
-- DRAW MAIN MENU (Categories list)
-- ============================================================================

local function DrawMainMenu()
    local x = Dim.x
    local y = Dim.y + Dim.headerHeight
    local w = Dim.width
    
    -- Title "Main menu"
    DrawRect(x, y, w, 28, { r = 0.05, g = 0.05, b = 0.07, a = 1.0 }, 0)
    DrawText(x + Dim.padding, y + 6, "Main menu", 14, Colors.textGray)
    y = y + 28
    
    -- Categories
    for i, cat in ipairs(Menu.Categories) do
        local itemY = y + (i - 1) * Dim.categoryHeight
        local isSelected = (i == Menu.CurrentCategory)
        
        -- Background
        if isSelected then
            DrawRect(x, itemY, w, Dim.categoryHeight, Colors.bgSelected, 0)
        else
            DrawRect(x, itemY, w, Dim.categoryHeight, Colors.bgItem, 0)
        end
        
        -- Separator line
        DrawLine(x, itemY + Dim.categoryHeight - 1, x + w, itemY + Dim.categoryHeight - 1, { r = 0.15, g = 0.15, b = 0.18, a = 0.5 }, 1)
        
        -- Category name
        DrawText(x + Dim.padding, itemY + 8, cat.name, 15, Colors.textWhite)
        
        -- Arrow ">" for submenu
        if cat.hasTabs then
            DrawText(x + w - 25, itemY + 8, ">", 15, Colors.textGray)
        end
    end
    
    -- Background pour remplir le reste
    local totalCatHeight = #Menu.Categories * Dim.categoryHeight
    local remainingHeight = Dim.itemHeight * Dim.ItemsPerPage - totalCatHeight
    if remainingHeight > 0 then
        DrawRect(x, y + totalCatHeight, w, remainingHeight, Colors.bgMain, 0)
    end
end

-- ============================================================================
-- DRAW TABS
-- ============================================================================

local function DrawTabs(category)
    if not category or not category.tabs then return end
    
    local x = Dim.x
    local y = Dim.y + Dim.headerHeight
    local w = Dim.width
    local h = Dim.tabHeight
    
    local numTabs = #category.tabs
    local tabWidth = w / numTabs
    
    -- Background tabs
    DrawRect(x, y, w, h, Colors.bgTab, 0)
    
    for i, tab in ipairs(category.tabs) do
        local tabX = x + (i - 1) * tabWidth
        local isActive = (i == Menu.CurrentTab)
        
        if isActive then
            -- Active tab background
            DrawRect(tabX, y, tabWidth, h, Colors.bgTabActive, 0)
        end
        
        -- Tab name centered
        local textWidth = GetTextWidth(tab.name, 14)
        local textX = tabX + (tabWidth / 2) - (textWidth / 2)
        DrawText(textX, y + 9, tab.name, 14, Colors.textWhite)
        
        -- Separator between tabs
        if i < numTabs then
            DrawLine(tabX + tabWidth, y + 5, tabX + tabWidth, y + h - 5, Colors.textMuted, 1)
        end
    end
    
    -- Bottom line
    DrawLine(x, y + h - 1, x + w, y + h - 1, { r = 0.15, g = 0.15, b = 0.18, a = 0.5 }, 1)
end

-- ============================================================================
-- DRAW ITEMS
-- ============================================================================

local function DrawItem(x, y, w, h, item, isSelected, index)
    -- Separator
    if item.isSeparator then
        DrawRect(x, y, w, h, Colors.bgMain, 0)
        
        if item.separatorText then
            local text = "- " .. item.separatorText .. " -"
            local textWidth = GetTextWidth(text, 13)
            local textX = x + (w / 2) - (textWidth / 2)
            DrawText(textX, y + 8, text, 13, Colors.textMuted)
        end
        return
    end
    
    -- Background
    if isSelected then
        -- Smooth selector animation
        if Menu.SelectorY == 0 then Menu.SelectorY = y end
        Menu.SelectorY = Menu.SelectorY + (y - Menu.SelectorY) * Menu.SmoothFactor
        if math.abs(Menu.SelectorY - y) < 0.5 then Menu.SelectorY = y end
        
        DrawRect(x, Menu.SelectorY, w, h, Colors.bgSelected, 0)
    else
        DrawRect(x, y, w, h, Colors.bgItem, 0)
    end
    
    -- Separator line
    DrawLine(x, y + h - 1, x + w, y + h - 1, { r = 0.15, g = 0.15, b = 0.18, a = 0.3 }, 1)
    
    -- Item name
    DrawText(x + Dim.padding, y + 8, item.name or "Unknown", 14, Colors.textWhite)
    
    -- Type-specific rendering
    if item.type == "toggle" then
        -- Circle toggle (Phaze style)
        local toggleX = x + w - 25
        local toggleY = y + h / 2
        
        if item.value then
            -- Filled circle when ON
            DrawCircle(toggleX, toggleY, Dim.toggleRadius, true, Colors.toggleOn)
        else
            -- Empty circle when OFF
            DrawCircle(toggleX, toggleY, Dim.toggleRadius, false, Colors.toggleOff)
        end
        
        -- Slider if hasSlider
        if item.hasSlider and item.value then
            local sliderX = x + 150
            local sliderY = y + h / 2 - 2
            local sliderW = w - 200
            local sliderH = 4
            
            DrawRect(sliderX, sliderY, sliderW, sliderH, Colors.toggleOff, 2)
            
            local val = item.sliderValue or item.sliderMin or 0
            local minV = item.sliderMin or 0
            local maxV = item.sliderMax or 100
            local pct = (val - minV) / (maxV - minV)
            
            DrawRect(sliderX, sliderY, sliderW * pct, sliderH, Colors.accent, 2)
            
            local valText = string.format("%.1f", val)
            DrawText(sliderX + sliderW + 5, y + 8, valText, 12, Colors.textGray)
        end
        
    elseif item.type == "selector" then
        if item.options and #item.options > 0 then
            local sel = item.selected or 1
            local optText = "< " .. tostring(item.options[sel] or "N/A") .. " >"
            local optWidth = GetTextWidth(optText, 13)
            DrawText(x + w - optWidth - 15, y + 9, optText, 13, Colors.textGray)
        end
        
    elseif item.type == "slider" then
        local sliderX = x + 150
        local sliderY = y + h / 2 - 2
        local sliderW = w - 220
        local sliderH = 4
        
        DrawRect(sliderX, sliderY, sliderW, sliderH, Colors.toggleOff, 2)
        
        local val = item.value or item.min or 0
        local minV = item.min or 0
        local maxV = item.max or 100
        local pct = (val - minV) / (maxV - minV)
        
        DrawRect(sliderX, sliderY, sliderW * pct, sliderH, Colors.accent, 2)
        
        local valText = tostring(math.floor(val))
        DrawText(x + w - 40, y + 8, valText, 13, Colors.textGray)
        
    elseif item.type == "action" then
        DrawText(x + w - 25, y + 8, ">", 14, Colors.textGray)
    end
end

local function DrawItems(category)
    if not category or not category.tabs then return end
    
    local currentTab = category.tabs[Menu.CurrentTab]
    if not currentTab or not currentTab.items then return end
    
    local items = currentTab.items
    local x = Dim.x
    local y = Dim.y + Dim.headerHeight + Dim.tabHeight
    local w = Dim.width
    local h = Dim.itemHeight
    
    local startIdx = Menu.ItemScrollOffset + 1
    local endIdx = math.min(startIdx + Dim.ItemsPerPage - 1, #items)
    
    for i = startIdx, endIdx do
        local item = items[i]
        local itemY = y + (i - startIdx) * h
        local isSelected = (i == Menu.CurrentItem)
        
        DrawItem(x, itemY, w, h, item, isSelected, i)
    end
    
    -- Fill remaining space
    local drawnItems = endIdx - startIdx + 1
    if drawnItems < Dim.ItemsPerPage then
        local fillY = y + drawnItems * h
        local fillH = (Dim.ItemsPerPage - drawnItems) * h
        DrawRect(x, fillY, w, fillH, Colors.bgMain, 0)
    end
end

-- ============================================================================
-- DRAW FOOTER
-- ============================================================================

local function DrawFooter()
    local x = Dim.x
    local w = Dim.width
    local h = Dim.footerHeight
    
    local y
    if Menu.OpenedCategory then
        y = Dim.y + Dim.headerHeight + Dim.tabHeight + (Dim.ItemsPerPage * Dim.itemHeight)
    else
        y = Dim.y + Dim.headerHeight + 28 + (#Menu.Categories * Dim.categoryHeight)
    end
    
    DrawRect(x, y, w, h, Colors.bgHeader, 0)
    
    -- Build info (like Phaze)
    DrawText(x + Dim.padding, y + 7, "Build 100001", 12, Colors.textMuted)
    
    -- Page info if in category
    if Menu.OpenedCategory then
        local cat = Menu.Categories[Menu.OpenedCategory]
        if cat and cat.tabs then
            local tab = cat.tabs[Menu.CurrentTab]
            if tab and tab.items then
                local total = #tab.items
                local pageInfo = tostring(Menu.CurrentItem) .. "/" .. tostring(total)
                local pageWidth = GetTextWidth(pageInfo, 12)
                DrawText(x + w - pageWidth - 15, y + 7, pageInfo, 12, Colors.textMuted)
            end
        end
    end
end

-- ============================================================================
-- DRAW LOADING SCREEN
-- ============================================================================

local function DrawLoadingScreen()
    local screenW, screenH = 1920, 1080
    if Susano and Susano.GetScreenWidth then
        screenW = Susano.GetScreenWidth()
        screenH = Susano.GetScreenHeight()
    end
    
    -- Overlay
    DrawRect(0, 0, screenW, screenH, { r = 0, g = 0, b = 0, a = 0.85 }, 0)
    
    -- Box
    local boxW, boxH = 350, 140
    local boxX = (screenW - boxW) / 2
    local boxY = (screenH - boxH) / 2
    
    DrawRect(boxX, boxY, boxW, boxH, Colors.bgHeader, 8)
    
    -- Logo
    DrawPhaseLogo(boxX + boxW/2 - 40, boxY + 20, 35)
    DrawText(boxX + boxW/2 - 5, boxY + 25, "Phaze", 24, Colors.textWhite)
    
    -- Loading bar
    local barX = boxX + 40
    local barY = boxY + 80
    local barW = boxW - 80
    local barH = 8
    
    DrawRect(barX, barY, barW, barH, Colors.toggleOff, 4)
    
    local progress = Menu.LoadingProgress / 100
    DrawRect(barX, barY, barW * progress, barH, Colors.accent, 4)
    
    -- Percentage
    local pctText = string.format("%.0f%%", Menu.LoadingProgress)
    local pctWidth = GetTextWidth(pctText, 14)
    DrawText(boxX + boxW/2 - pctWidth/2, boxY + 100, pctText, 14, Colors.textGray)
end

-- ============================================================================
-- DRAW KEY SELECTOR
-- ============================================================================

local function DrawKeySelector()
    local screenW, screenH = 1920, 1080
    if Susano and Susano.GetScreenWidth then
        screenW = Susano.GetScreenWidth()
        screenH = Susano.GetScreenHeight()
    end
    
    DrawRect(0, 0, screenW, screenH, { r = 0, g = 0, b = 0, a = 0.8 }, 0)
    
    local boxW, boxH = 320, 130
    local boxX = (screenW - boxW) / 2
    local boxY = (screenH - boxH) / 2
    
    DrawRect(boxX, boxY, boxW, boxH, Colors.bgHeader, 8)
    
    -- Accent line top
    DrawRect(boxX, boxY, boxW, 3, Colors.accent, 0)
    
    -- Title
    local title = "Select Menu Key"
    local titleW = GetTextWidth(title, 18)
    DrawText(boxX + boxW/2 - titleW/2, boxY + 20, title, 18, Colors.textWhite)
    
    -- Key box
    local keyBoxW, keyBoxH = 120, 35
    local keyBoxX = boxX + boxW/2 - keyBoxW/2
    local keyBoxY = boxY + 55
    
    DrawRect(keyBoxX, keyBoxY, keyBoxW, keyBoxH, Colors.bgItem, 4)
    
    local keyText = Menu.SelectedKeyName or "Press key..."
    local keyW = GetTextWidth(keyText, 16)
    DrawText(keyBoxX + keyBoxW/2 - keyW/2, keyBoxY + 9, keyText, 16, Colors.accent)
    
    -- Hint
    local hint = "Press [Enter] to confirm"
    local hintW = GetTextWidth(hint, 12)
    DrawText(boxX + boxW/2 - hintW/2, boxY + boxH - 22, hint, 12, Colors.textMuted)
end

-- ============================================================================
-- MAIN RENDER
-- ============================================================================

function Menu.Render()
    if not (Susano and Susano.BeginFrame) then return end
    
    Susano.BeginFrame()
    
    if Menu.IsLoading then
        DrawLoadingScreen()
    elseif Menu.SelectingKey then
        DrawKeySelector()
    elseif Menu.Visible then
        DrawHeader()
        
        if Menu.OpenedCategory then
            local cat = Menu.Categories[Menu.OpenedCategory]
            DrawTabs(cat)
            DrawItems(cat)
        else
            DrawMainMenu()
        end
        
        DrawFooter()
    end
    
    if Susano.SubmitFrame then
        Susano.SubmitFrame()
    end
end

-- ============================================================================
-- INPUT HANDLING
-- ============================================================================

Menu.KeyNames = {
    [0x08] = "Backspace", [0x09] = "Tab", [0x0D] = "Enter", [0x1B] = "ESC",
    [0x20] = "Space", [0x25] = "Left", [0x26] = "Up", [0x27] = "Right", [0x28] = "Down",
    [0x30] = "0", [0x31] = "1", [0x32] = "2", [0x33] = "3", [0x34] = "4",
    [0x35] = "5", [0x36] = "6", [0x37] = "7", [0x38] = "8", [0x39] = "9",
    [0x41] = "A", [0x42] = "B", [0x43] = "C", [0x44] = "D", [0x45] = "E",
    [0x46] = "F", [0x47] = "G", [0x48] = "H", [0x49] = "I", [0x4A] = "J",
    [0x4B] = "K", [0x4C] = "L", [0x4D] = "M", [0x4E] = "N", [0x4F] = "O",
    [0x50] = "P", [0x51] = "Q", [0x52] = "R", [0x53] = "S", [0x54] = "T",
    [0x55] = "U", [0x56] = "V", [0x57] = "W", [0x58] = "X", [0x59] = "Y", [0x5A] = "Z",
    [0x70] = "F1", [0x71] = "F2", [0x72] = "F3", [0x73] = "F4", [0x74] = "F5",
    [0x75] = "F6", [0x76] = "F7", [0x77] = "F8", [0x78] = "F9", [0x79] = "F10",
    [0x7A] = "F11", [0x7B] = "F12"
}

function Menu.IsKeyJustPressed(keyCode)
    if not (Susano and Susano.GetAsyncKeyState) then return false end
    
    local down, pressed = Susano.GetAsyncKeyState(keyCode)
    local wasDown = Menu.KeyStates[keyCode] or false
    
    Menu.KeyStates[keyCode] = down == true
    
    return pressed == true or (down == true and not wasDown)
end

local function findNextNonSeparator(items, startIndex, direction)
    local index = startIndex
    local attempts = 0
    while attempts < #items do
        index = index + direction
        if index < 1 then index = #items
        elseif index > #items then index = 1 end
        
        if items[index] and not items[index].isSeparator then
            return index
        end
        attempts = attempts + 1
    end
    return startIndex
end

function Menu.HandleInput()
    if Menu.IsLoading then return end
    
    -- Key selection
    if Menu.SelectingKey then
        if Menu.IsKeyJustPressed(0x0D) and Menu.SelectedKey then
            Menu.SelectingKey = false
            return
        end
        
        local keysToCheck = {
            0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4A, 0x4B, 0x4C, 0x4D,
            0x4E, 0x4F, 0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x5A,
            0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7A, 0x7B
        }
        
        for _, keyCode in ipairs(keysToCheck) do
            if Menu.IsKeyJustPressed(keyCode) then
                Menu.SelectedKey = keyCode
                Menu.SelectedKeyName = Menu.KeyNames[keyCode] or string.format("0x%02X", keyCode)
                break
            end
        end
        return
    end
    
    -- Toggle menu
    if Menu.SelectedKey and Menu.IsKeyJustPressed(Menu.SelectedKey) then
        Menu.Visible = not Menu.Visible
        if not Menu.Visible then
            Menu.OpenedCategory = nil
            Menu.SelectorY = 0
        end
    end
    
    if not Menu.Visible then return end
    
    -- Navigation
    if not Menu.OpenedCategory then
        -- Main menu navigation
        if Menu.IsKeyJustPressed(0x26) then -- Up
            Menu.CurrentCategory = Menu.CurrentCategory - 1
            if Menu.CurrentCategory < 1 then Menu.CurrentCategory = #Menu.Categories end
        elseif Menu.IsKeyJustPressed(0x28) then -- Down
            Menu.CurrentCategory = Menu.CurrentCategory + 1
            if Menu.CurrentCategory > #Menu.Categories then Menu.CurrentCategory = 1 end
        elseif Menu.IsKeyJustPressed(0x0D) or Menu.IsKeyJustPressed(0x27) then -- Enter or Right
            local cat = Menu.Categories[Menu.CurrentCategory]
            if cat and cat.hasTabs then
                Menu.OpenedCategory = Menu.CurrentCategory
                Menu.CurrentTab = 1
                Menu.CurrentItem = 1
                Menu.ItemScrollOffset = 0
                Menu.SelectorY = 0
                
                if cat.tabs[1] and cat.tabs[1].items then
                    Menu.CurrentItem = findNextNonSeparator(cat.tabs[1].items, 0, 1)
                end
            end
        end
    else
        -- Category navigation
        local cat = Menu.Categories[Menu.OpenedCategory]
        if not cat or not cat.tabs then return end
        
        local currentTab = cat.tabs[Menu.CurrentTab]
        if not currentTab or not currentTab.items then return end
        
        local items = currentTab.items
        
        -- Back
        if Menu.IsKeyJustPressed(0x08) or Menu.IsKeyJustPressed(0x25) then -- Backspace or Left (when no selector)
            local item = items[Menu.CurrentItem]
            if item and item.type ~= "selector" and item.type ~= "slider" then
                Menu.OpenedCategory = nil
                Menu.SelectorY = 0
                return
            end
        end
        
        -- Tab switching with Q/E or Left/Right on tabs row
        if Menu.IsKeyJustPressed(0x51) then -- Q
            Menu.CurrentTab = Menu.CurrentTab - 1
            if Menu.CurrentTab < 1 then Menu.CurrentTab = #cat.tabs end
            Menu.CurrentItem = 1
            Menu.ItemScrollOffset = 0
            Menu.SelectorY = 0
            local newTab = cat.tabs[Menu.CurrentTab]
            if newTab and newTab.items then
                Menu.CurrentItem = findNextNonSeparator(newTab.items, 0, 1)
            end
        elseif Menu.IsKeyJustPressed(0x45) then -- E
            Menu.CurrentTab = Menu.CurrentTab + 1
            if Menu.CurrentTab > #cat.tabs then Menu.CurrentTab = 1 end
            Menu.CurrentItem = 1
            Menu.ItemScrollOffset = 0
            Menu.SelectorY = 0
            local newTab = cat.tabs[Menu.CurrentTab]
            if newTab and newTab.items then
                Menu.CurrentItem = findNextNonSeparator(newTab.items, 0, 1)
            end
        end
        
        -- Item navigation
        if Menu.IsKeyJustPressed(0x26) then -- Up
            Menu.CurrentItem = findNextNonSeparator(items, Menu.CurrentItem, -1)
            if Menu.CurrentItem <= Menu.ItemScrollOffset then
                Menu.ItemScrollOffset = math.max(0, Menu.CurrentItem - 1)
            end
        elseif Menu.IsKeyJustPressed(0x28) then -- Down
            Menu.CurrentItem = findNextNonSeparator(items, Menu.CurrentItem, 1)
            if Menu.CurrentItem > Menu.ItemScrollOffset + Dim.ItemsPerPage then
                Menu.ItemScrollOffset = Menu.CurrentItem - Dim.ItemsPerPage
            end
        end
        
        local item = items[Menu.CurrentItem]
        if not item then return end
        
        -- Value adjustment
        if item.type == "selector" then
            if Menu.IsKeyJustPressed(0x25) then -- Left
                item.selected = (item.selected or 1) - 1
                if item.selected < 1 then item.selected = #item.options end
                if item.onChange then item.onChange(item.options[item.selected], item.selected) end
            elseif Menu.IsKeyJustPressed(0x27) then -- Right
                item.selected = (item.selected or 1) + 1
                if item.selected > #item.options then item.selected = 1 end
                if item.onChange then item.onChange(item.options[item.selected], item.selected) end
            end
        elseif item.type == "slider" then
            local step = item.step or 1
            if Menu.IsKeyJustPressed(0x25) then
                item.value = math.max(item.min or 0, (item.value or 0) - step)
                if item.onChange then item.onChange(item.value) end
            elseif Menu.IsKeyJustPressed(0x27) then
                item.value = math.min(item.max or 100, (item.value or 0) + step)
                if item.onChange then item.onChange(item.value) end
            end
        elseif item.type == "toggle" and item.hasSlider then
            local step = item.sliderStep or 0.5
            if Menu.IsKeyJustPressed(0x25) then
                item.sliderValue = math.max(item.sliderMin or 0, (item.sliderValue or 0) - step)
            elseif Menu.IsKeyJustPressed(0x27) then
                item.sliderValue = math.min(item.sliderMax or 100, (item.sliderValue or 0) + step)
            end
        end
        
        -- Enter action
        if Menu.IsKeyJustPressed(0x0D) then
            if item.type == "toggle" then
                item.value = not item.value
                if item.onClick then item.onClick(item.value) end
            elseif item.type == "action" then
                if item.onClick then item.onClick() end
            end
        end
    end
end

-- ============================================================================
-- CATEGORIES (Phaze Style)
-- ============================================================================

Menu.Categories = {
    { name = "Player", hasTabs = true, tabs = {
        { name = "Player", items = {
            { name = "", isSeparator = true, separatorText = "Basic" },
            { name = "Godmode", type = "toggle", value = false },
            { name = "Semi Godmode", type = "toggle", value = false },
            { name = "Anti Headshot", type = "toggle", value = false },
            { name = "No Ragdoll", type = "toggle", value = false },
            { name = "", isSeparator = true, separatorText = "Health" },
            { name = "Max Health", type = "action" },
            { name = "Max Armor", type = "action" },
            { name = "Revive", type = "action" }
        }},
        { name = "Miscellaneous", items = {
            { name = "", isSeparator = true, separatorText = "Basic" },
            { name = "No collision", type = "toggle", value = false },
            { name = "Solo session", type = "toggle", value = false },
            { name = "Friendly fire", type = "toggle", value = false },
            { name = "Force third-person camera", type = "toggle", value = false },
            { name = "", isSeparator = true, separatorText = "Other" },
            { name = "Door unlocker", type = "toggle", value = false },
            { name = "Anti cuff", type = "toggle", value = false },
            { name = "Anti carry", type = "toggle", value = false },
            { name = "Anti teleport", type = "toggle", value = false }
        }},
        { name = "Wardrobe", items = {
            { name = "Random Outfit", type = "action" },
            { name = "Save Outfit", type = "action" },
            { name = "Load Outfit", type = "action" }
        }}
    }},
    { name = "Vehicle", hasTabs = true, tabs = {
        { name = "Spawn", items = {
            { name = "Teleport Into", type = "toggle", value = false },
            { name = "", isSeparator = true, separatorText = "Cars" },
            { name = "Car", type = "selector", options = {"Adder", "Zentorno", "T20", "Osiris", "Entity XF"}, selected = 1 },
            { name = "Spawn Selected", type = "action" }
        }},
        { name = "Options", items = {
            { name = "", isSeparator = true, separatorText = "Performance" },
            { name = "Max Upgrade", type = "action" },
            { name = "Repair Vehicle", type = "action" },
            { name = "Flip Vehicle", type = "action" },
            { name = "", isSeparator = true, separatorText = "Mods" },
            { name = "Godmode Vehicle", type = "toggle", value = false },
            { name = "Speed Boost", type = "toggle", value = false },
            { name = "No Collision", type = "toggle", value = false },
            { name = "Rainbow Paint", type = "toggle", value = false }
        }}
    }},
    { name = "Weapon", hasTabs = true, tabs = {
        { name = "Mods", items = {
            { name = "", isSeparator = true, separatorText = "Aimbot" },
            { name = "Silent Aim", type = "toggle", value = false },
            { name = "Magic Bullet", type = "toggle", value = false },
            { name = "", isSeparator = true, separatorText = "Weapon Mods" },
            { name = "No Recoil", type = "toggle", value = false },
            { name = "No Spread", type = "toggle", value = false },
            { name = "Rapid Fire", type = "toggle", value = false },
            { name = "Infinite Ammo", type = "toggle", value = false },
            { name = "No Reload", type = "toggle", value = false }
        }},
        { name = "Give", items = {
            { name = "Give All Weapons", type = "action" },
            { name = "Remove All Weapons", type = "action" }
        }}
    }},
    { name = "Combat", hasTabs = true, tabs = {
        { name = "General", items = {
            { name = "Attach Target", type = "toggle", value = false },
            { name = "Super Punch", type = "toggle", value = false }
        }}
    }},
    { name = "Visual", hasTabs = true, tabs = {
        { name = "ESP", items = {
            { name = "", isSeparator = true, separatorText = "Player ESP" },
            { name = "Enable ESP", type = "toggle", value = false },
            { name = "Draw Box", type = "toggle", value = false },
            { name = "Draw Skeleton", type = "toggle", value = false },
            { name = "Draw Name", type = "toggle", value = false },
            { name = "Draw Distance", type = "toggle", value = false }
        }},
        { name = "World", items = {
            { name = "Time", type = "slider", value = 12, min = 0, max = 23, step = 1 },
            { name = "Freeze Time", type = "toggle", value = false },
            { name = "Weather", type = "selector", options = {"Clear", "Clouds", "Rain", "Thunder", "Snow"}, selected = 1 },
            { name = "Apply Weather", type = "action" }
        }}
    }},
    { name = "Miscellaneous", hasTabs = true, tabs = {
        { name = "Movement", items = {
            { name = "", isSeparator = true, separatorText = "Noclip" },
            { name = "Noclip", type = "toggle", value = false, hasSlider = true, sliderValue = 1.0, sliderMin = 0.5, sliderMax = 10.0, sliderStep = 0.5 },
            { name = "", isSeparator = true, separatorText = "Speed" },
            { name = "Fast Run", type = "toggle", value = false },
            { name = "Super Jump", type = "toggle", value = false },
            { name = "Infinite Stamina", type = "toggle", value = false }
        }}
    }},
    { name = "Settings", hasTabs = true, tabs = {
        { name = "Menu", items = {
            { name = "Menu Position X", type = "slider", value = 80, min = 0, max = 800, step = 10, onChange = function(val) Dim.x = val end },
            { name = "Menu Position Y", type = "slider", value = 150, min = 0, max = 600, step = 10, onChange = function(val) Dim.y = val end }
        }},
        { name = "Theme", items = {
            { name = "Theme", type = "selector", options = {"Blue", "Purple", "Red", "Green", "Pink"}, selected = 1, onChange = function(val)
                local themes = {
                    Blue = { r = 0.20, g = 0.60, b = 0.85 },
                    Purple = { r = 0.58, g = 0.20, b = 0.83 },
                    Red = { r = 0.85, g = 0.25, b = 0.25 },
                    Green = { r = 0.25, g = 0.75, b = 0.40 },
                    Pink = { r = 0.85, g = 0.30, b = 0.60 }
                }
                if themes[val] then
                    Colors.accent = { r = themes[val].r, g = themes[val].g, b = themes[val].b, a = 1.0 }
                    Colors.bgSelected = { r = themes[val].r * 0.8, g = themes[val].g * 0.8, b = themes[val].b * 0.8, a = 1.0 }
                    Colors.bgTabActive = { r = themes[val].r * 0.8, g = themes[val].g * 0.8, b = themes[val].b * 0.8, a = 1.0 }
                    Colors.toggleOn = { r = themes[val].r, g = themes[val].g, b = themes[val].b, a = 1.0 }
                end
            end }
        }}
    }}
}

-- ============================================================================
-- HELPER FUNCTION
-- ============================================================================

function FindItem(categoryName, tabName, itemName)
    for _, cat in ipairs(Menu.Categories) do
        if cat.name == categoryName and cat.tabs then
            for _, tab in ipairs(cat.tabs) do
                if tab.name == tabName and tab.items then
                    for _, item in ipairs(tab.items) do
                        if item.name == itemName then return item end
                    end
                end
            end
        end
    end
    return nil
end

-- ============================================================================
-- FUNCTIONALITY
-- ============================================================================

local function SetupFunctionality()
    -- Godmode
    local item = FindItem("Player", "Player", "Godmode")
    if item then item.onClick = function(val) SetEntityInvincible(PlayerPedId(), val) end end
    
    -- Max Health
    item = FindItem("Player", "Player", "Max Health")
    if item then item.onClick = function() SetEntityHealth(PlayerPedId(), GetEntityMaxHealth(PlayerPedId())) end end
    
    -- Max Armor
    item = FindItem("Player", "Player", "Max Armor")
    if item then item.onClick = function() SetPedArmour(PlayerPedId(), 100) end end
    
    -- Revive
    item = FindItem("Player", "Player", "Revive")
    if item then
        item.onClick = function()
            local ped = PlayerPedId()
            ResurrectPed(ped)
            ClearPedBloodDamage(ped)
            SetEntityHealth(ped, GetEntityMaxHealth(ped))
        end
    end
    
    -- Vehicle Spawn
    item = FindItem("Vehicle", "Spawn", "Spawn Selected")
    if item then
        item.onClick = function()
            local carSelector = FindItem("Vehicle", "Spawn", "Car")
            if carSelector then
                local cars = {"adder", "zentorno", "t20", "osiris", "entityxf"}
                local model = cars[carSelector.selected] or "adder"
                local hash = GetHashKey(model)
                RequestModel(hash)
                local t = 0
                while not HasModelLoaded(hash) and t < 100 do Wait(10) t = t + 1 end
                if HasModelLoaded(hash) then
                    local ped = PlayerPedId()
                    local coords = GetEntityCoords(ped)
                    local veh = CreateVehicle(hash, coords.x + 3, coords.y, coords.z, GetEntityHeading(ped), true, false)
                    local tpInto = FindItem("Vehicle", "Spawn", "Teleport Into")
                    if tpInto and tpInto.value then SetPedIntoVehicle(ped, veh, -1) end
                    SetModelAsNoLongerNeeded(hash)
                end
            end
        end
    end
    
    -- Max Upgrade
    item = FindItem("Vehicle", "Options", "Max Upgrade")
    if item then
        item.onClick = function()
            local veh = GetVehiclePedIsIn(PlayerPedId(), false)
            if veh ~= 0 then
                SetVehicleModKit(veh, 0)
                for i = 0, 49 do
                    local max = GetNumVehicleMods(veh, i)
                    if max > 0 then SetVehicleMod(veh, i, max - 1, false) end
                end
            end
        end
    end
    
    -- Repair
    item = FindItem("Vehicle", "Options", "Repair Vehicle")
    if item then
        item.onClick = function()
            local veh = GetVehiclePedIsIn(PlayerPedId(), false)
            if veh ~= 0 then SetVehicleFixed(veh) end
        end
    end
    
    -- Flip
    item = FindItem("Vehicle", "Options", "Flip Vehicle")
    if item then
        item.onClick = function()
            local veh = GetVehiclePedIsIn(PlayerPedId(), false)
            if veh ~= 0 then SetVehicleOnGroundProperly(veh) end
        end
    end
    
    -- Give Weapons
    item = FindItem("Weapon", "Give", "Give All Weapons")
    if item then
        item.onClick = function()
            local weapons = {"WEAPON_PISTOL", "WEAPON_SMG", "WEAPON_ASSAULTRIFLE", "WEAPON_PUMPSHOTGUN", "WEAPON_SNIPERRIFLE", "WEAPON_RPG", "WEAPON_MINIGUN"}
            local ped = PlayerPedId()
            for _, w in ipairs(weapons) do GiveWeaponToPed(ped, GetHashKey(w), 9999, false, false) end
        end
    end
    
    -- Remove Weapons
    item = FindItem("Weapon", "Give", "Remove All Weapons")
    if item then item.onClick = function() RemoveAllPedWeapons(PlayerPedId(), true) end end
    
    -- Apply Weather
    item = FindItem("Visual", "World", "Apply Weather")
    if item then
        item.onClick = function()
            local ws = FindItem("Visual", "World", "Weather")
            if ws then
                local weathers = {"CLEAR", "CLOUDS", "RAIN", "THUNDER", "SNOW"}
                SetWeatherTypeNowPersist(weathers[ws.selected] or "CLEAR")
            end
        end
    end
end

-- ============================================================================
-- FEATURE LOOPS
-- ============================================================================

CreateThread(function()
    while true do
        local sleep = 100
        
        -- Godmode
        local item = FindItem("Player", "Player", "Godmode")
        if item and item.value then SetEntityInvincible(PlayerPedId(), true) end
        
        -- No Ragdoll
        item = FindItem("Player", "Player", "No Ragdoll")
        if item and item.value then SetPedCanRagdoll(PlayerPedId(), false) end
        
        -- Infinite Stamina
        item = FindItem("Miscellaneous", "Movement", "Infinite Stamina")
        if item and item.value then RestorePlayerStamina(PlayerId(), 1.0) end
        
        -- Fast Run
        item = FindItem("Miscellaneous", "Movement", "Fast Run")
        if item and item.value then
            SetRunSprintMultiplierForPlayer(PlayerId(), 1.49)
        else
            SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
        end
        
        -- Super Jump
        item = FindItem("Miscellaneous", "Movement", "Super Jump")
        if item and item.value then sleep = 0 SetSuperJumpThisFrame(PlayerId()) end
        
        -- Noclip
        item = FindItem("Miscellaneous", "Movement", "Noclip")
        if item and item.value then
            sleep = 0
            local ped = PlayerPedId()
            local speed = item.sliderValue or 1.0
            SetEntityCollision(ped, false, false)
            FreezeEntityPosition(ped, true)
            
            local camRot = GetGameplayCamRot(2)
            local fwd = vector3(
                -math.sin(math.rad(camRot.z)) * math.abs(math.cos(math.rad(camRot.x))),
                math.cos(math.rad(camRot.z)) * math.abs(math.cos(math.rad(camRot.x))),
                math.sin(math.rad(camRot.x))
            )
            local pos = GetEntityCoords(ped)
            local newPos = pos
            
            if IsControlPressed(0, 32) then newPos = newPos + fwd * speed end
            if IsControlPressed(0, 33) then newPos = newPos - fwd * speed end
            if IsControlPressed(0, 34) then newPos = newPos - vector3(-fwd.y, fwd.x, 0) * speed end
            if IsControlPressed(0, 35) then newPos = newPos + vector3(-fwd.y, fwd.x, 0) * speed end
            if IsControlPressed(0, 44) then newPos = newPos + vector3(0, 0, speed) end
            if IsControlPressed(0, 38) then newPos = newPos - vector3(0, 0, speed) end
            
            SetEntityCoordsNoOffset(ped, newPos.x, newPos.y, newPos.z, false, false, false)
        else
            SetEntityCollision(PlayerPedId(), true, true)
            FreezeEntityPosition(PlayerPedId(), false)
        end
        
        -- Vehicle Godmode
        item = FindItem("Vehicle", "Options", "Godmode Vehicle")
        if item and item.value then
            local veh = GetVehiclePedIsIn(PlayerPedId(), false)
            if veh ~= 0 then SetEntityInvincible(veh, true) end
        end
        
        -- Infinite Ammo
        item = FindItem("Weapon", "Mods", "Infinite Ammo")
        if item and item.value then
            local ped = PlayerPedId()
            local _, weapon = GetCurrentPedWeapon(ped)
            if weapon then SetPedInfiniteAmmo(ped, true, weapon) end
        end
        
        -- Time
        local timeItem = FindItem("Visual", "World", "Time")
        local freezeItem = FindItem("Visual", "World", "Freeze Time")
        if freezeItem and freezeItem.value and timeItem then
            NetworkOverrideClockTime(math.floor(timeItem.value), 0, 0)
        end
        
        Wait(sleep)
    end
end)

-- ============================================================================
-- MAIN THREADS
-- ============================================================================

CreateThread(function()
    Menu.LoadingStartTime = GetGameTimer()
    
    while Menu.IsLoading do
        local elapsed = GetGameTimer() - Menu.LoadingStartTime
        Menu.LoadingProgress = (elapsed / Menu.LoadingDuration) * 100
        
        if Menu.LoadingProgress >= 100 then
            Menu.LoadingProgress = 100
            Menu.IsLoading = false
            Menu.LoadingComplete = true
            Menu.SelectingKey = true
        end
        
        Wait(0)
    end
end)

CreateThread(function()
    SetupFunctionality()
    
    while true do
        Menu.Render()
        if Menu.LoadingComplete then
            Menu.HandleInput()
        end
        Wait(0)
    end
end)

print("[PHAZE] Menu loaded - Default key: F5")