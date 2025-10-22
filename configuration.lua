local addonName, addonTable = ...;

function LayerMe:SetDebug(info, val)
    LayerMe:DebugPrint("SetDebug", info, val)
    self.db.profile.debug = val
end

function LayerMe:GetDebug(info)
    return self.db.profile.debug
end

function LayerMe:SetEnabled(info, val)
    LayerMe:DebugPrint("SetEnabled", info, val)
    self.db.profile.enabled = val
end

function LayerMe:GetEnabled(info)
    return self.db.profile.enabled
end

function LayerMe:SetTriggers(info, val)
    LayerMe:DebugPrint("SetTriggers", info, val)
    self.db.profile.triggers = val
end

function LayerMe:GetTriggers(info)
    return self.db.profile.triggers
end

function LayerMe:ParseTriggers()
    local triggers = {}
    for trigger in string.gmatch(self.db.profile.triggers, "[^,]+") do
        table.insert(triggers, string.lower("*" .. trigger .. "*"))
    end
    return triggers
end

function LayerMe:SetBlacklist(info, val)
    LayerMe:DebugPrint("SetBlacklist", info, val)
    self.db.profile.blacklist = val
end

function LayerMe:GetBlacklist(info)
    return self.db.profile.blacklist
end

function LayerMe:ParseBlacklist()
    local blacklist = {}
    for trigger in string.gmatch(self.db.profile.blacklist, "[^,]+") do
        table.insert(blacklist, trigger)
    end
    return blacklist
end

function LayerMe:SetInvertKeywords(info, val)
    LayerMe:DebugPrint("SetInvertKeywords", info, val)
    self.db.profile.invertKeywords = val
end

function LayerMe:GetInvertKeywords(info)
    return self.db.profile.invertKeywords
end

function LayerMe:ParseInvertKeywords()
    local invertKeywords = {}
    for keyword in string.gmatch(self.db.profile.invertKeywords, "[^,]+") do
        table.insert(invertKeywords, keyword)
    end
    return invertKeywords
end

function LayerMe:GetFilteredChannels(info)
    return self.db.profile.filteredChannels
end

function LayerMe:ParseFilteredChannels()
    local filteredChannels = {}
    for channel in string.gmatch(self.db.profile.filteredChannels, "[^,]+") do
        table.insert(filteredChannels, string.lower(channel))
    end
    return filteredChannels
end

local bunnyLDB = ...

function LayerMe:Toggle()
    self.db.profile.enabled = not self.db.profile.enabled
    self:Print(self.db.profile.enabled and "enabled" or "disabled")

    if self.db.profile.enabled then
        if self.db.profile.hideAutoWhispers then
            self.filterChatEventLayerMeWhisperMessages()
        end
        if self.db.profile.hideSystemGroupMessages then
            self:filterChatEventSystemGroupMessages()
        end
    
        addonTable.bunnyLDB.icon = [[Interface\AddOns\LayerMe\Textures\LayerMe_enabled_icon]]
    else
        if self.db.profile.hideAutoWhispers then
            self.unfilterChatEventLayerMeWhisperMessages()
        end
        if self.db.profile.hideSystemGroupMessages then
            self:unfilterChatEventSystemGroupMessages()
        end

        addonTable.bunnyLDB.icon = [[Interface\AddOns\LayerMe\Textures\LayerMe_disabled_icon]]
    end
end
