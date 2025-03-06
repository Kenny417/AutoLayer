---@diagnostic disable: inject-field

local addonName, addonTable = ...;

AutoLayer = LibStub("AceAddon-3.0"):NewAddon("AutoLayer", "AceConsole-3.0", "AceEvent-3.0")
AceGUI = LibStub("AceGUI-3.0")
local minimap_icon = LibStub("LibDBIcon-1.0")


--- A helper function to ensure the length of a whisper won't exceed
--- the 255 character limit but after currentLayer value substitution.
--- Assumes layer can be a 2 digit value & assumes "[Autolayer] " preceeds the 
--- template value in an outgoing whisper message leaving 243 characters to customize.
local function checkTemplateLength(template)
    if template:find("{layer}") then
        template = template:gsub("{layer}", "99")
    end
    if template:find("%%s") then
        template = string.format(template, "99")
    end
    if #template > 243 then 
        return "Value is too long. Maximum length is 243 characters."
    end
    return true
end

local options = {
    name = "AutoLayer",
    handler = AutoLayer,
    type = "group",
    args = {
        generalSettings = {
            type = "group",
            name = "General Settings",
            inline = true,
            order = 0,
            args = {
                enabled = {
                    type = 'toggle',
                    name = 'Enabled',
                    desc = 'Enable or disable AutoLayer.',
                    set = 'SetEnabled',
                    get = 'GetEnabled',
                    order = 1,
                },
                debug = {
                    type = 'toggle',
                    name = 'Debug Mode',
                    desc = 'Enable or disable debug messages.',
                    set = 'SetDebug',
                    get = 'GetDebug',
                    order = 2,
                },
                minimap = {
                    type = 'toggle',
                    name = 'Hide Minimap Icon',
                    desc = 'Show or hide the minimap icon.',
                    set = function(info, val)
                        AutoLayer.db.profile.minimap.hide = val
                        if val then
                            minimap_icon:Hide("AutoLayer")
                        else
                            minimap_icon:Show("AutoLayer")
                        end
                    end,
                    get = function(info)
                        return AutoLayer.db.profile.minimap.hide
                    end,
                    order = 3,
                },
                guildOnly = {
                    type = 'toggle',
                    name = 'Guild Only',
                    desc = 'Only invite players from your guild.',
                    set = function(info, val)
                        AutoLayer.db.profile.guildOnly = val
                    end,
                    get = function(info)
                        return AutoLayer.db.profile.guildOnly
                    end,
                    order = 4,
                },
            },
        },

        messagingSettings = {
            type = "group",
            name = "Messaging Settings",
            inline = true,
            order = 1,
            args = {
                triggers = {
                    type = 'input',
                    name = 'Invite Triggers',
                    desc = 'Comma-separated phrases to trigger inviting a player. Case insensitive',
                    set = 'SetTriggers',
                    get = 'GetTriggers',
                    order = 1,
                },
                blacklist = {
                    type = 'input',
                    name = 'Blacklist',
                    desc = 'Comma-separated words to ignore messages containing them.',
                    set = 'SetBlacklist',
                    get = 'GetBlacklist',
                    order = 2,
                },
                invertKeywords = {
                    type = 'input',
                    name = 'Invert Keywords',
                    desc = 'Comma-separated words to exclude specific layers.',
                    set = 'SetInvertKeywords',
                    get = 'GetInvertKeywords',
                    order = 3,
                },
                channelFiltering = {
                    type = 'select',
                    width = 1.2,
                    name = 'Filter Chat Channels',
                    desc = 'Select an option to perform inclusive or exclusive chat channel filtering.',
                    values = {["none"] = "None", ["inclusive"] = "Trigger only these channels", ["exclusive"] = "Trigger all channels except"},
                    set = function(info, val) 
                        AutoLayer.db.profile.channelFiltering = val 
                    end,
                    get = function(info) 
                        return AutoLayer.db.profile.channelFiltering 
                    end,
                    order = 4,
                },
                filteredChannels = {
                    type = 'input',
                    width = 1.8,
                    name = 'Channels names for filtering',
                    desc = 'Comma-separated channel names for filtering. * can be used as a wildcard',
                    set = function(info, val)
                        if val == "" then
                            AutoLayer.db.profile.channelFiltering = "none"
                        end
                        AutoLayer.db.profile.filteredChannels = val
                    end,
                    get = function(info)
                        return AutoLayer.db.profile.filteredChannels
                    end,
                    disabled = function()
                        return AutoLayer.db.profile.channelFiltering == "none"
                    end,
                    order = 5,
                },
                inviteWhisper = {
                    type = 'toggle',
                    name = 'Whisper Invites',
                    desc = 'Send a whisper to players when inviting them.',
                    set = function(info, val)
                        AutoLayer.db.profile.inviteWhisper = val
                    end,
                    get = function(info)
                        return AutoLayer.db.profile.inviteWhisper
                    end,
                    order = 6,
                },
                inviteWhisperTemplate = {
                    type = 'input',
                    width = 'double',
                    name = 'Whisper Template',
                    desc = 'Template for invite whispers. Use {layer} for layer number.',
                    set = function(info, val)
                        AutoLayer.db.profile.inviteWhisperTemplate = val
                    end,
                    get = function(info)
                        return AutoLayer.db.profile.inviteWhisperTemplate
                    end,
                    validate = function(info, val)
                        return checkTemplateLength(val)
                    end,
                    order = 7,
                },
                inviteWhisperReminder = {
                    type = 'toggle',
                    name = 'Whisper Reminder Text',
                    desc = 'Send a reminder text to Leave Party after layer switch.',
                    set = function(info, val)
                        AutoLayer.db.profile.inviteWhisperReminder = val
                    end,
                    get = function(info)
                        return AutoLayer.db.profile.inviteWhisperReminder
                    end,
                    order = 8,
                },				
				inviteWhisperTemplateReminder = {
                    type = 'input',
					width = 'double',
                    name = 'Whisper Template Second Line',
                    desc = 'Reminder to Leave Party after layer switch.',
                    set = function(info, val)
                        AutoLayer.db.profile.inviteWhisperTemplateReminder = val
                    end,
                    get = function(info)
                        return AutoLayer.db.profile.inviteWhisperTemplateReminder
                    end,
					validate = function(info, val)
						return checkTemplateLength(val)
					end,
                    order = 9,
                },
            },
        },

        soundAndBehavior = {
            type = "group",
            name = "Sound and Behavior",
            inline = true,
            order = 2,
            args = {
                mutesounds = {
                    type = 'toggle',
                    name = 'Mute Sounds',
                    desc = 'Mute party-related sounds while AutoLayer is active.',
                    set = function(info, val)
                        AutoLayer.db.profile.mutesounds = val
                        if val then
                            AutoLayer:MuteAnnoyingSounds()
                        else
                            AutoLayer:UnmuteAnnoyingSounds()
                        end
                    end,
                    get = function(info)
                        return AutoLayer.db.profile.mutesounds
                    end,
                    order = 1,
                },
                turnOffWhileRaidAssist = {
                    type = 'toggle',
                    name = 'Disable in Raid Assist',
                    desc = 'Turn off AutoLayer functionality when you are raid assist.',
                    set = function(info, val)
                        AutoLayer.db.profile.turnOffWhileRaidAssist = val
                    end,
                    get = function(info)
                        return AutoLayer.db.profile.turnOffWhileRaidAssist
                    end,
                    order = 2,
                },
                autokick = {
                    type = 'toggle',
                    name = 'Auto-Kick on Full',
                    desc = '|cffFF0000Requires manual interaction.|r Kicks the last member if the group is full.',
                    set = function(info, val)
                        AutoLayer.db.profile.autokick = val
                    end,
                    get = function(info)
                        return AutoLayer.db.profile.autokick
                    end,
                    order = 3,
                },
                hideAutoWhispers = {
                    type = 'toggle',
                    name = 'Hide AddOn Whispers',
                    desc = 'Silence auto whispers sent out by AutoLayer',
                    set = function(info, val)
                        AutoLayer.db.profile.hideAutoWhispers = val
                        if val then
                            AutoLayer:filterChatEventAutoLayerWhisperMessages()
                        else
                            AutoLayer:unfilterChatEventAutoLayerWhisperMessages()
                        end
                    end,
                    get = function(info)
                        return AutoLayer.db.profile.hideAutoWhispers
                    end,
                    order = 4,
                },
                hideSystemGroupMessages = {
                    type = 'toggle',
                    name = 'Hide Group Notices',
                    desc = 'Silence system group notices eg. "X has left the party"',
                    set = function(info, val)
                        AutoLayer.db.profile.hideSystemGroupMessages = val
                        if val then
                            AutoLayer:filterChatEventSystemGroupMessages()
                        else
                            AutoLayer:unfilterChatEventSystemGroupMessages()
                        end
                    end,
                    get = function(info)
                        return AutoLayer.db.profile.hideSystemGroupMessages
                    end,
                    order = 5,
                },
            },
        },
    },
}

local defaults = {
    profile = {
        enabled = true,
        debug = false,
        triggers = "layer",
        blacklist = "wts,wtb,lfm,lfg,ashen,auto inv,autoinv,pst for,guild,raid,enchant,player,what layer,which layer,WorldBuffs",
        invertKeywords = "not,off,except,but,out,other than,besides,apart from",
        channelFiltering = "none",
        inviteWhisper = true,
        inviteWhisperTemplate = "Inviting you to layer {layer}...",
		inviteWhisperReminder = true,
		inviteWhisperTemplateReminder = "Please Leave Party after layer switch",
        mutesounds = true,
        guildOnly = false,
        hideAutoWhispers = true,
        hideSystemGroupMessages = true,
        layered = 0,
        minimap = {
            hide = false,
        },
        autokick = false,
        turnOffWhileRaidAssist = true,
    }
}

local annoyingSounds = {
	567490, -- invite sent
	567451, -- invite accepted
	539839, 540356, 540778, 540941, 540984, 542585, 542862, 540287, 540579, 541222, 542952, 542659, 539901, 541298, 543146, 543174 -- "they can't join our group"
}

local systemMessages = {
    ERR_INVITE_PLAYER_S,
    ERR_JOINED_GROUP_S,
    ERR_DECLINE_GROUP_S,
    ERR_GROUP_DISBANDED,
    ERR_LEFT_GROUP_S,
    ERR_LEFT_GROUP_YOU,
    ERR_DUNGEON_DIFFICULTY_CHANGED_S,
    ERR_ALREADY_IN_GROUP_S,
}

local function matchesAnySystemMessage(msg)
    for _, systemMessage in ipairs(systemMessages) do            
        local pattern = systemMessage:gsub("%%s", "(.+)")
        if msg:match(pattern) then
            return true
        end            
    end
    return false
end


---@diagnostic disable-next-line: duplicate-set-field
function AutoLayer:OnInitialize()
    LibStub("AceConfig-3.0"):RegisterOptionsTable("AutoLayer", options)
    self.db = LibStub("AceDB-3.0"):New("AutoLayerDB", defaults)
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("AutoLayer", "AutoLayer")
    local icon = ""

    if self.db.profile.enabled then
        icon = [[Interface\AddOns\AutoLayer_Vanilla\Textures\AutoLayer_enabled_icon]]
    else
        icon = [[Interface\AddOns\AutoLayer_Vanilla\Textures\AutoLayer_disabled_icon]]
    end

    if self.db.profile.mutesounds then
        self:MuteAnnoyingSounds()
    end

    if self.db.profile.hideAutoWhispers then
        self.filterChatEventAutoLayerWhisperMessages()
    end

    if self.db.profile.hideSystemGroupMessages then
        self:filterChatEventSystemGroupMessages()
    end

    ---@diagnostic disable-next-line: missing-fields
    local bunnyLDB = LibStub("LibDataBroker-1.1"):NewDataObject("AutoLayer", {
        type = "data source",
        text = "AutoLayer",
        icon = icon,

        -- listen for right click
        OnClick = function(self, button)
            if button == "LeftButton" then
                AutoLayer:Toggle()
            end

            if button == "RightButton" then
                AutoLayer:HopGUI()
            end
        end,

        onMouseUp = function(self, button)
            print(button)
            AutoLayer:Toggle()
        end,
        OnTooltipShow = function(tooltip)
            tooltip:AddLine("AutoLayer")
            tooltip:AddLine("Left-click to toggle AutoLayer")
            tooltip:AddLine("Right-click to hop layers")
            tooltip:AddLine("Layered " .. self.db.profile.layered .. " times")
            
            if addonTable.NWB ~= nil then
                local currentLayer = AutoLayer:getCurrentLayer()
                if currentLayer == 0 then
                    tooltip:AddLine("Current layer: unknown, target an NPC")
                else
                    tooltip:AddLine("Current layer: " .. currentLayer)
                end
            end
        end,
    })

    addonTable.bunnyLDB = bunnyLDB

    local frame = CreateFrame("Frame", "MuteSoundFrame")
    frame.MuteSoundFile = MuteSoundFile
    minimap_icon:Register("AutoLayer", bunnyLDB, self.db.profile.minimap)
end

function AutoLayer:MuteAnnoyingSounds()
	for _, soundFileId in pairs(annoyingSounds) do
		MuteSoundFile(soundFileId)
	end
end

function AutoLayer:UnmuteAnnoyingSounds()
	for _, soundFileId in pairs(annoyingSounds) do
		UnmuteSoundFile(soundFileId)
	end
end

--For hiding outgoing automatic whispers
local function whisperInformFilter(self, event, msg, author, ...)            
    local filtered =  string.sub(msg, 1, 11) == "[AutoLayer]"  
    return filtered, msg, author,...            
end        
function AutoLayer:filterChatEventAutoLayerWhisperMessages()
    ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", whisperInformFilter)
end
function AutoLayer:unfilterChatEventAutoLayerWhisperMessages()
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_WHISPER_INFORM", whisperInformFilter)
end

--For hiding group system messages
local function systemFilter(self, event, msg, author, ...)
    local filtered = AutoLayer:GetEnabled() and matchesAnySystemMessage(msg)
    return filtered, msg, author,...
end
function AutoLayer:filterChatEventSystemGroupMessages()
    ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", systemFilter) 
end
function AutoLayer:unfilterChatEventSystemGroupMessages()
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SYSTEM", systemFilter)
end

function AutoLayer:DebugPrint(...)
    if self.db.profile.debug then
        self:Print(...)
    end
end
