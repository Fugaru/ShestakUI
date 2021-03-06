﻿local T, C, L, _ = unpack(select(2, ...))
if C.tooltip.enable ~= true or C.tooltip.achievements ~= true then return end

----------------------------------------------------------------------------------------
--	Your achievement status in tooltip(Enhanced Achievements by Syzgyn)
----------------------------------------------------------------------------------------
local colors = {
	["GREEN"] = {
		["r"] = 0.25,
		["g"] = 0.75,
		["b"] = 0.25,
	},
	["GRAY"] = {
		["r"] = 0.5,
		["g"] = 0.5,
		["b"] = 0.5,
	},
}

local function SetHyperlink(tooltip, refString)
	local achievementID, numCriteria, GUID, name, completed, quantity, reqQuantity, month, day, year
	local output = {[0] = {}, [1] = {}}
	if select(3, string.find(refString, "(%a-):")) ~= "achievement" then return end

	achievementID = select(3, string.find(refString, ":(%d+):"))
	numCriteria = GetAchievementNumCriteria(achievementID)
	GUID = select(3, string.find(refString, ":%d+:(.-):"))

	if GUID == string.sub(UnitGUID("player"), 3) then
		tooltip:Show()
		return
	end

	tooltip:AddLine(" ")
	_, _, _, completed, month, day, year, _, _, _, _, _, wasEarnedByMe, earnedBy = GetAchievementInfo(achievementID)

	if completed then
		if year < 10 then year = "0"..year end

		if T.client == "ruRU" then
			tooltip:AddLine(L_TOOLTIP_ACH_COMPLETE..day.."/"..month.."/"..year, 0, 1, 0)
		else
			tooltip:AddLine(L_TOOLTIP_ACH_COMPLETE..month.."/"..day.."/"..year, 0, 1, 0)
		end

		if earnedBy then
			tooltip:AddLine(format(ACHIEVEMENT_EARNED_BY, earnedBy))
			if not wasEarnedByMe then
				tooltip:AddLine(format(ACHIEVEMENT_NOT_COMPLETED_BY, T.name))
			elseif T.name ~= earnedBy then
				tooltip:AddLine(format(ACHIEVEMENT_COMPLETED_BY, T.name))
			end
		end
	elseif numCriteria == 0 then
		tooltip:AddLine(L_TOOLTIP_ACH_INCOMPLETE)
	else
		tooltip:AddLine(L_TOOLTIP_ACH_STATUS)
		for i = 1, numCriteria, 2 do
			for a = 0, 1 do
				output[a].text = nil
				output[a].color = nil
				if i + a <= numCriteria then
					name, _, completed, quantity, reqQuantity = GetAchievementCriteriaInfo(achievementID, i + a)
					if completed then
						output[a].text = name
						output[a].color = "GREEN"
					else
						if quantity < reqQuantity and reqQuantity > 1 then
							output[a].text = name.." ("..quantity.."/"..reqQuantity..")"
							output[a].color = "GRAY"
						else
							output[a].text = name
							output[a].color = "GRAY"
						end
					end
				else
					output[a].text = nil
				end
			end
			if output[1].text == nil then
				tooltip:AddLine(output[0].text, colors[output[0].color].r, colors[output[0].color].g, colors[output[0].color].b)
			else
				tooltip:AddDoubleLine(output[0].text, output[1].text, colors[output[0].color].r, colors[output[0].color].g, colors[output[0].color].b, colors[output[1].color].r, colors[output[1].color].g, colors[output[1].color].b)
			end
			output = {[0] = {}, [1] = {}}
		end
	end
	tooltip:Show()
end

hooksecurefunc(GameTooltip, "SetHyperlink", SetHyperlink)
hooksecurefunc(ItemRefTooltip, "SetHyperlink", SetHyperlink)

----------------------------------------------------------------------------------------
--	Criteria status for some Achievements(Achievement Helper by Timmy2250)
----------------------------------------------------------------------------------------
if C.tooltip.ptr ~= true then return end -- PTR
local AchData = {}
local AchString = {}
AchString[347] = {}
AchString[347][0] = L_TOOLTIP_ACH_EAT
AchString[347][1] = L_TOOLTIP_ACH_NOT_EAT
AchString[346] = {}
AchString[346][0] = L_TOOLTIP_ACH_DRINK
AchString[346][1] = L_TOOLTIP_ACH_NOT_DRINK
AchString[621] = {}
AchString[621][0] = L_TOOLTIP_ACH_EQUIP
AchString[621][1] = L_TOOLTIP_ACH_NOT_EQUIP

local function GetServerData(achievementID, maxCriterias)
	for i = 0, maxCriterias do
		local criteriaID = select(10, GetAchievementCriteriaInfo(achievementID, i))
		local itemID = select(8, GetAchievementCriteriaInfoByID(achievementID, criteriaID))
		AchData[itemID] = {}
		AchData[itemID][0] = criteriaID
		AchData[itemID][1] = achievementID
	end
end

GetServerData(347, 513)
GetServerData(621, 89)
GetServerData(346, 221)

local function FindItem(tooltip)
	local _, itemLink = tooltip:GetItem()
	if itemLink ~= nil then
		local id = select(5, string.find(itemLink, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+)"))
		id = tonumber(id)
		if AchData[id] ~= nil then
			local _, _, completed = GetAchievementCriteriaInfoByID(AchData[id][1], AchData[id][0])
			local text = AchString[AchData[id][1]]
			if completed then
				tooltip:AddLine(L_TOOLTIP_ACH_STATUS.." "..text[0], 0, 1, 0)
			else
				tooltip:AddLine(L_TOOLTIP_ACH_STATUS.." "..text[1], 1, 0, 0)
			end
		end
	end
end

GameTooltip:HookScript("OnTooltipSetItem", FindItem)
ItemRefTooltip:HookScript("OnTooltipSetItem", FindItem)