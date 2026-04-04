-- ShardCounter.lua (updated full version)
local frame = CreateFrame("Frame", "ShardCounterFrame", UIParent)
frame:SetWidth(40)
frame:SetHeight(40)
frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
frame:SetFrameStrata("HIGH")
frame:SetFrameLevel(10)

-- Make movable
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")

-- Saved position
ShardCounterDB = ShardCounterDB or { locked = false, point = {"CENTER", 0, 0} }

-- Apply saved position
frame:ClearAllPoints()
frame:SetPoint(ShardCounterDB.point[1], UIParent, ShardCounterDB.point[1], ShardCounterDB.point[2], ShardCounterDB.point[3])

-- Drag logic
frame:SetScript("OnDragStart", function()
    if not ShardCounterDB.locked then
        frame:StartMoving()
    end
end)

frame:SetScript("OnDragStop", function()
    frame:StopMovingOrSizing()
    local point, _, _, x, y = frame:GetPoint()
    ShardCounterDB.point = {point, x, y}
end)

-- Create icon (35x35, 20% zoom)
local icon = frame:CreateTexture(nil, "ARTWORK")
icon:SetWidth(35)
icon:SetHeight(35)
icon:SetPoint("CENTER", frame, "CENTER", 0, 0)
icon:SetTexture("Interface\\AddOns\\ShardCounter\\Textures\\INV_Misc_Gem_Amethyst_02")
icon:SetTexCoord(0.15, 0.85, 0.15, 0.85)  -- 20% zoom

-- Top line
local top = frame:CreateTexture(nil, "OVERLAY")
top:SetTexture(0,0,0,1) -- solid black
top:SetHeight(2)
top:SetPoint("TOPLEFT", icon, "TOPLEFT", -1, 1)
top:SetPoint("TOPRIGHT", icon, "TOPRIGHT", 1, 1)

-- Bottom line
local bottom = frame:CreateTexture(nil, "OVERLAY")
bottom:SetTexture(0,0,0,1)
bottom:SetHeight(2)
bottom:SetPoint("BOTTOMLEFT", icon, "BOTTOMLEFT", -1, -1)
bottom:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 1, -1)

-- Left line
local left = frame:CreateTexture(nil, "OVERLAY")
left:SetTexture(0,0,0,1)
left:SetWidth(2)
left:SetPoint("TOPLEFT", icon, "TOPLEFT", -1, 1)
left:SetPoint("BOTTOMLEFT", icon, "BOTTOMLEFT", -1, -1)

-- Right line
local right = frame:CreateTexture(nil, "OVERLAY")
right:SetTexture(0,0,0,1)
right:SetWidth(2)
right:SetPoint("TOPRIGHT", icon, "TOPRIGHT", 1, 1)
right:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 1, -1)

-- Create count text (visible on top)
local countText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
countText:SetFont("Fonts\\FRIZQT__.TTF", 30, "OUTLINE")
countText:SetPoint("CENTER", icon, "CENTER", 0, 0)
countText:SetTextColor(1, 1, 1)
countText:SetDrawLayer("OVERLAY", 2) -- above border and icon


-- Soul Shard item ID
local SOUL_SHARD_ID = 6265

-- Count shards
local function GetShardCount()
    local count = 0
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local link = GetContainerItemLink(bag, slot)
            if link then
                local _, _, itemID = string.find(link, "item:(%d+):")
                itemID = tonumber(itemID)
                if itemID == SOUL_SHARD_ID then
                    local _, itemCount = GetContainerItemInfo(bag, slot)
                    count = count + (itemCount or 1)
                end
            end
        end
    end
    return count
end

-- Update display (1.12 compatible)
local function UpdateShards()
    -- Directly set the icon since GetItemIcon doesn't exist
    icon:SetTexture("Interface\\AddOns\\ShardCounter\\Textures\\INV_Misc_Gem_Amethyst_02")
    
    local count = GetShardCount()
    countText:SetText(count)
end

-- Events
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("BAG_UPDATE")

frame:SetScript("OnEvent", function()
    UpdateShards()
end)

-- Slash commands
SLASH_SHARDCOUNTER1 = "/sc"

SlashCmdList["SHARDCOUNTER"] = function(msg)
    msg = string.lower(msg or "")

    if msg == "lock" then
        ShardCounterDB.locked = true
        print("ShardCounter: locked")

    elseif msg == "unlock" then
        ShardCounterDB.locked = false
        print("ShardCounter: unlocked (drag to move)")

    else
        print("ShardCounter commands:")
        print("/sc lock - lock position")
        print("/sc unlock - unlock and move")
    end
end
