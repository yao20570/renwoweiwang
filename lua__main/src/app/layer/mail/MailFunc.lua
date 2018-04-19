local MailFunc = {}

--获取国家文本
function parseCountryName( nCountry)
	local sStr = ""
	if nCountry then
		sStr = string.format("%s:%s;",getCountryShortName(nCountry, true),getColorByCountry(nCountry))
	end
	return sStr
end

--获取道具名字文本
--ig神将补充
local function parseGoodsName( nGoodsId, ig)
	local sStr = ""
	if nGoodsId then
		local tGoods = getGoodsByTidFromDB(nGoodsId)
		if tGoods then
			if tGoods.sName and tGoods.nQuality then
				if ig and ig == 1 then
					sStr = string.format(";"..getConvertedStr(1,10321).."%s:%s;",tGoods.sName, getColorByQuality(tGoods.nQuality))
				else
					sStr = string.format(";%s:%s;",tGoods.sName, getColorByQuality(tGoods.nQuality))
				end
			end
		else
			if(nGoodsId >= 70001 and nGoodsId <= 89999) then -- 怪物组
				local npc = getNpcGropListDataById(nGoodsId)
				if npc then
					sStr = npc.name
				end
			end
		end
	end
	return sStr
end

--获取区域名字
local function parseBlockName( nBlockId )
	local sStr = ""
	if nBlockId then
		local tMapData = getWorldMapDataById(nBlockId)
		if tMapData then
			sStr = tMapData.name
		end
	end
	return sStr
end

--获取矿点等级
local function parseMineLv( nMine )
	if nMine then
		local tMineData = getWorldMineData(nMine)
		if tMineData then
			return tMineData.level
		end
	end
	return 0
end

--获取矿点名字
local function parseMineName( nMine )
	local sStr = ""
	if nMine then
		local tMineData = getWorldMineData(nMine)
		if tMineData then
			sStr = tMineData.name
		end
	end
	return sStr
end

--获取乱军等级
local function parseWildArmyLv( nDid )
	if nDid then
		local tEnemyData = getArmyDataInTables(nDid)
		if tEnemyData then
			return tEnemyData.level
		end
	end
	return 0
end

--获取乱军名字
local function parseWildArmyName( nDid )
	local sStr = ""
	if nDid then
		--邮件特殊处理
		local tEnemyData = getArmyDataInTables(nDid)
		if tEnemyData then
			sStr = tEnemyData.name
		end
	end
	return sStr
end
--获取幽魂等级
local function parseGhostLv( nDid )
	if nDid then
		local tEnemyData = getWorldGhostdomData(nDid)
		if tEnemyData then
			return tEnemyData.level2
		end
	end
	return 0
end

--获取幽魂名字
local function parseGhostName( nDid )
	local sStr = ""
	if nDid then
		--邮件特殊处理
		local tEnemyData = getWorldGhostdomData(nDid)
		if tEnemyData then
			sStr = tEnemyData.name
		end
	end
	return sStr
end


function MailFunc.getContentTextColor( tMailMsg)
	if not tMailMsg then
		return nil
	end

	local tMailData = getMailDataById(tMailMsg.nId)
	if not tMailData then
		return
	end

	--找出数据
	local nFill = tMailData.fill
	local sContent = tMailData.content
	if nFill == nil or sContent == nil then
		return
	end
	--颜色文本，值
	local tTextColor , _ = MailFunc.analysisMailMsg(tMailMsg, sContent)
	return tTextColor
end

--获取文本颜色
-- {mx} 矿点X位置
-- {my} 矿点Y位置
-- {mn} 矿点名字
-- {ml} 矿点等级
-- {dn} 防守方名称
-- {dc} 防守方国家
-- {dl} 防守方等级
-- {dx} 目标x坐标
-- {dy} 目标y坐标
-- {an} 进攻方名字
-- {ac} 进攻方国家
-- {al} 进攻方等级
-- {ax} 进攻方x坐标
-- {ay} 进攻方y坐标
-- {bn} 区域
-- {ln} 乱军名字
-- {ll} 乱军等级
function MailFunc.analysisMailMsg( tMailMsg, _content )
	if not tMailMsg then
		return nil
	end

	local tMailData = getMailDataById(tMailMsg.nId)
	if not tMailData then
		return
	end

	--找出数据
	local nFill = tMailData.fill
	local sContent = _content or tMailData.content
	if nFill == nil or sContent == nil then
		return
	end

	--字键表
	local tKeysData = {}
	--填充方式1
	if nFill == 0 then
	    local sStr = string.gsub(sContent, "%b{}", function ( sSubStr )
	        local sKey = string.sub(sSubStr,2,-2)
	        local value = tMailMsg[sKey]
	        if sKey == "dc" or sKey == "ac" then --国家
        	elseif sKey == "bn" then --区域名
        	elseif sKey == "ml" then --矿点等级
        		value = tMailMsg.nMine
        		if not value then --矿点占领成功 矿点id
        			value = tMailMsg.nDid
        		end
        	elseif sKey == "mn" then --矿点名称
        		value = tMailMsg.nMine
        		if not value then --矿点占领成功 矿点id
        			value = tMailMsg.nDid
        		end
        	elseif sKey == "ln" then --乱军名字
        		value = tMailMsg.nDid
        	elseif sKey == "ll" then --乱军等级
        		value = tMailMsg.nDid
        	end
	        if value then

	        	tKeysData[sKey] = value
	        	return value
	        end
	        return sSubStr
	    end)
	    return MailFunc.getTranslateStr(sContent, tKeysData, nFill,nil,tMailMsg), tKeysData
	--填充方式2
	elseif nFill == 1 then
	    return MailFunc.getTranslateStr(sContent, tMailMsg.tFillContent, nFill), tMailMsg.tFillContent
	end
	return nil
end



--邮件文本转化（用于分享文本返回）
--sContent文本
--转换的数据
--tHs武将属性补充
function MailFunc.getTranslateStr( sContent, tData, nFill ,tHs ,tMailMsg)
	--字键表
	--填充方式1
	if nFill == 0 then
	    local sStr = string.gsub(sContent, "%b{}", function ( sSubStr )
	        local sKey = string.sub(sSubStr,2,-2)
	        local value = tData[sKey]
	        if sKey == "dc" or sKey == "ac" then --国家
        		value = parseCountryName(value)
        	elseif sKey == "bn" then --区域名
        		value = parseBlockName(value)
        	elseif sKey == "ml" then --矿点等级
        		value = parseMineLv(value)
        	elseif sKey == "mn" then --矿点名称
        		value = parseMineName(value)
        	elseif sKey == "ln" then --乱军名字
        		if tMailMsg then
	        		if tMailMsg.nDty == e_type_atk_def.wildArmy then
	        			value = parseWildArmyName(value)
	        		elseif tMailMsg.nDty == e_type_atk_def.ghostdom then
	        			value = parseGhostName(value)
	        		end
	        	else
	        		value = parseWildArmyName(value)
	        	end	
        	elseif sKey == "ll" then --乱军等级
        		if tMailMsg then
	        		if tMailMsg.nDty == e_type_atk_def.wildArmy then
		        		value = parseWildArmyLv(value)
		        	elseif tMailMsg.nDty == e_type_atk_def.ghostdom then
		        		value = parseGhostLv(value)
		        	end
		        else
		        	value = parseWildArmyLv(value)
		        end
        	end
	        if value then
	        	return value
	        end
	        return sSubStr
	    end)
	    return getTextColorByConfigure(sStr)
	--填充方式2
	elseif nFill == 1 then
	    local sStr = string.gsub(sContent, "%$(%d+)", function ( sSubStr )
	        local nIndex = tonumber(sSubStr)
	        if nIndex then
	        	--lua的数据下标从1开始
	        	if tData and tData[nIndex] then
	        			local sValue = tData[nIndex]
						--"c^i_" 后面是加 国家id的
	        			local nIndex1, nIndex2 = string.find(sValue, "c^i_")
	        			if nIndex2 then
	        				local sSubValue = string.sub(sValue,nIndex2 + 1, -1)
	        				local nCountry = tonumber(sSubValue) 
	        				if nCountry then
	        					local sStr2 = parseCountryName(nCountry)
	        					return sStr2
	   						end
	        			end
	        			--"c^g_" 后面是加 道具id的
						local nIndex1, nIndex2 = string.find(sValue, "c^g_")
	        			if nIndex2 then
	        				local sSubValue = string.sub(sValue, nIndex2 + 1,-1)
	        				if tHs and tHs.t then
	        					sSubValue = tHs.t
	        				end
	        				local nGoodsId = tonumber(sSubValue)
	        				if nGoodsId then
	        					local ig = 0
	        					if tHs and tHs.ig then
	        						ig = tHs.ig or 0
	        					end
	        					local sStr2 = parseGoodsName(nGoodsId, ig)
	        					return sStr2
	   						end
	        			end
	        			--"c^t_" 后面是加 城池类型
	        			local nIndex1, nIndex2 = string.find(sValue, "c^t_")
	        			if nIndex2 then
	        				local sSubValue = string.sub(sValue, nIndex2 + 1,-1)
	        				return getCityKindStr(tonumber(sSubValue))
	        			end
	        			--"c^s_" 后面是加 服务器id
	        			local nIndex1, nIndex2 = string.find(sValue, "c^s_")
	        			if nIndex2 then
	        				local sSubValue = string.sub(sValue, nIndex2 + 1,-1)
	        				local nId = tonumber(sSubValue)
	        				if AccountCenter.allServerNameDict[nId] then
	        					return AccountCenter.allServerNameDict[nId]
	        				end
	        				return sSubValue
	        			end
	        			--"c^str_" 后面是加 字符串, 然后直接把字符串返回
	        			local nIndex1, nIndex2 = string.find(sValue, "c^str_")
	        			if nIndex2 then
	        				local sSubValue = string.sub(sValue, nIndex2 + 1,-1)
	        				return sSubValue
	        			end
	        			--"c^q_" 后面是加 品质, 解析品质颜色返回
	        			local nIndex1, nIndex2 = string.find(sValue, "c^q_")
	        			if nIndex2 then
	        				local sSubValue = string.sub(sValue, nIndex2 + 1,-1)
	        				local sColor = getColorByQuality(tonumber(sSubValue))
	        				return sColor
	        			end

	        		return tData[nIndex]
	        	end
	        end
	        return sSubStr
	    end)
	    return getTextColorByConfigure(sStr)
	end
	return nil
end


--获取邮件图标(只限于非系统邮件)
function MailFunc.getMailIcon( tMailMsg )
	local nId = tMailMsg.nId
	local tMailReport = getMailReport(nId)
	if tMailReport then
		if tMailReport.sIcon ~= nil then
			return tMailReport.sIcon
		else
			return MailFunc.getMailDetailIcon(tMailMsg)
		end
	end
	return nil
end

--从其他邮件数据中获取防守方的图片或名字
function MailFunc.getImgByMailMsg( tMailMsg )
	local sImgPath = nil
	local sName = nil
	local nLv = nil
	local nDty = tMailMsg.nDty
	if nDty == e_type_atk_def.player then --玩家
		sImgPath = getPlayerIconStr(tMailMsg.sDefSid)		--i	String	当前头像
		sName = tMailMsg.sDefName
	elseif nDty == e_type_atk_def.npc then --npc
		if tMailMsg.nDid then
			local tNpcList = getNpcGropById(tMailMsg.nDid)
			if tNpcList and tNpcList[1] then
				tNpc = tNpcList[1]
				sName = tNpc.sName
				sImgPath = tNpc.sIcon
			end
		end
	elseif nDty == e_type_atk_def.sysCity then --国战
		local tCityData = getWorldCityDataById(tMailMsg.nDid)
		if tCityData then
			sName = tCityData.name
			sImgPath = tCityData.tCityicon[tMailMsg.nDefCountry]
		end
	elseif nDty == e_type_atk_def.wildArmy then --乱军
		if tMailMsg.bIsMoBing then
			local tWorldEnemyData = getAwakeArmyData(tMailMsg.nDid)
			if tWorldEnemyData then
				sName = tWorldEnemyData.name
				sImgPath = tWorldEnemyData.sIcon
			end
		else
			local tWorldEnemyData = getWorldEnemyData(tMailMsg.nDid)
			if tWorldEnemyData then
				sName = tWorldEnemyData.name
				sImgPath = tWorldEnemyData.sIcon
			end
		end
	elseif nDty == e_type_atk_def.mine then --矿点
		local tMineData = getWorldMineData(tMailMsg.nDid)
		if tMineData then
			sImgPath = tMineData.sIcon
		end
		if tMailMsg.tDefHeros and #tMailMsg.tDefHeros then
			local tTemp=tMailMsg.tDefHeros[1]
			if tTemp then
				sName = tTemp.sPlayerName
				nLv = tTemp.nHeroLv
			end
		end
	end
	return sImgPath
end

--获取邮件详情图标(只限于非系统邮件)
--bIsBResTip 是否是战斗提示
function MailFunc.getMailDetailIcon( tMailMsg, bIsBResTip)
	local nId = tMailMsg.nId
	local tMailReport = getMailReport(nId)
	if tMailReport then
		--玩家城池战役
		-- print("temp---",tMailReport.template)
		if tMailReport.template == 1 then
			return getPlayerCityIcon(tMailMsg.nDefCityLv, tMailMsg.nDefCountry)
		end

		--国战战役
		if tMailReport.template == 2 then
			local tCityData = getWorldCityDataByPos(tMailMsg.nDefX, tMailMsg.nDefY)
			if tCityData then
				return tCityData.tCityicon[tMailMsg.nDefCountry]
			end
			if tMailMsg.nFightType == e_type_mail_fight.awakeBoss then
				local tAwakeBoss = getAwakeBossData(tMailMsg.nBossLv, tMailMsg.nBossDiff)
				if tAwakeBoss then
					return tAwakeBoss.sIcon
				end
			elseif tMailMsg.nFightType == e_type_mail_fight.zhouwang then				
				local pKingZhou = WorldFunc.getKingZhouConfData()
				if pKingZhou then
					return pKingZhou.sRoleImg					
				end					
			end
		end
		
		--乱军
		if tMailReport.template == 3 then
			if tMailMsg.nFightType == e_type_mail_fight.ghost then
				local tNpcDetailData= getWorldGhostdomData(tMailMsg.nDid)
				-- local tNpcDetailData = getAwakeArmyData(tMailMsg.nDid)
				if tNpcDetailData then
					return tNpcDetailData.sIcon
				end
			elseif tMailMsg.nFightType == e_type_mail_fight.wileArmy then
				local tEnemyData = getWorldEnemyData(tMailMsg.nDid)
				if tEnemyData then
					return tEnemyData.sIcon
				end
			elseif tMailMsg.nFightType == e_type_mail_fight.ghostWar then
				local tNpcData , tNpcDetailData= getGhostBossById(tMailMsg.nAid)
				-- local tNpcDetailData = getAwakeArmyData(tMailMsg.nDid)
				if tNpcDetailData then
					return tNpcDetailData.sIcon
				end
			end
		end

		--采集报告,矿点相关
		if tMailReport.template == 4 or tMailReport.template == 5 then
			local tWorldMineData = getWorldMineData(tMailMsg.nMine)
			if tWorldMineData then
				return tWorldMineData.sIcon
			end
			if bIsBResTip then
				return MailFunc.getImgByMailMsg(tMailMsg)
			end
		end

		--侦查别人相关
		if tMailReport.template == 6 then
			return getPlayerCityIcon(tMailMsg.nDefCityLv, tMailMsg.nDefCountry)
		end

		--别人侦查我
		if tMailReport.template == 9 then
			-- dump(tMailMsg, "MailFunc 408")
			return getPlayerCityIcon(tMailMsg.nDefCityLv, tMailMsg.nAtkCountry)
		end

		--驻守武将
		if tMailReport.template == 7 then
			return getPlayerCityIcon(tMailMsg.nDefCityLv, tMailMsg.nDefCountry)
		end

		--目标丢失
		if tMailReport.template == 8 then
			if tMailMsg.nLoseType == e_type_lose.city then --玩家城市
				return getPlayerCityIcon(tMailMsg.nDefCityLv, tMailMsg.nDefCountry)
			elseif tMailMsg.nLoseType == e_type_lose.sysCity then --系统城市
				local tSysCity = getWorldCityDataById(tMailMsg.nLoseId)
				if tSysCity then
					return tSysCity.tCityicon[tMailMsg.nDefCountry]
				end
			elseif tMailMsg.nLoseType == e_type_lose.mines then --矿点
				local tWorldMineData = getWorldMineData(tMailMsg.nLoseId)
				if tWorldMineData then
					return tWorldMineData.sIcon
				end
			elseif tMailMsg.nLoseType == e_type_lose.wileArmy then --乱军
				local tEnemyData = getAwakeArmyData(tMailMsg.nLoseId)
				if tEnemyData then
					return tEnemyData.sIcon
				else
					local tWorldEnemyData = getWorldEnemyData(tMailMsg.nLoseId)
					if tWorldEnemyData then
						return tWorldEnemyData.sIcon
					end

				end
				-- if tMailMsg.bIsMoBing then
				-- 	local tEnemyData = getAwakeArmyData(tMailMsg.nLoseId)
				-- 	if tEnemyData then
				-- 		return tEnemyData.sIcon
				-- 	end
				-- else
				-- 	local tWorldEnemyData = getWorldEnemyData(tMailMsg.nLoseId)
				-- 	if tWorldEnemyData then
				-- 		return tWorldEnemyData.sIcon
				-- 	end
				-- end
			elseif tMailMsg.nLoseType == e_type_lose.boss then --boss
				-- dump("mail---",tMailMsg)
				local tBossData = getAwakeBossData(tMailMsg.nLoseId, Player:getWuWangDiff())
				if tBossData then
					--乱军图片
					return tBossData.sIcon
				end
			else
				-- dump(tMailMsg)
				if tMailMsg.tBlockId then 
					local tCity = getWorldMapDataById(tMailMsg.tBlockId)
					if tCity then
						dump(tCity)
					end
				end
			end
		end

	end
	return nil
end

--得到获取资源显示
function MailFunc.getGetResTextColor( tItemList )
	if not tItemList then
		return
	end
	local sResStr = ""
	for i=1,#tItemList do
		local nId = tItemList[i].k
		local nNum = tItemList[i].v
		local tGood = getGoodsByTidFromDB(nId)
		if tGood then
			sResStr = sResStr .. string.format("%s:%s ", tGood.sName, getResourcesStr(nNum))
		end
	end
	local tStr = {
		{text = getConvertedStr(3, 10212) .. " ", color = _cc.white},
		{text = sResStr, color = _cc.blue},
	}
	return tStr
end

function MailFunc.getAtkInfo(_tMailMsg )
	-- body
	local tMailData = getMailDataById(_tMailMsg.nId)
	if not tMailData then
		return
	end
	local tInfo={}
	if _tMailMsg.sAtkName==Player:getPlayerInfo().sName then		--我为进攻方
		table.insert(tInfo,{sStr=getConvertedStr(9,10011),nFontSize=18,sColor=_cc.pwhite})
		local sNameAndLv=""
		if tMailData.template==e_type_mail_report.mine or tMailData.template==e_type_mail_report.wildArmy then --矿点
			sNameAndLv=_tMailMsg.sDefName.. getLvString(_tMailMsg.nDefLv)
			table.insert(tInfo,{sStr=sNameAndLv,nFontSize=20,sColor=_cc.white})
		-- elseif _tMailMsg.nFightType==e_type_mail_fight.cityWar then


		-- end
		elseif tMailData.template==e_type_mail_report.countryWar then --国战
			local sCountryName=getBlockShowName(_tMailMsg.tBlockId,2)
			sNameAndLv=sCountryName.. getLvString(_tMailMsg.nDefLv)
			table.insert(tInfo,{sStr=sNameAndLv,nFontSize=20,sColor=_cc.white})
		end
		return tInfo
	else--我方为防守方
		local sAtkInfo=string.format(getConvertedStr(9, 10013), getCountryShortName(_tMailMsg.nAtkCountry, true), 
			_tMailMsg.sAtkName, getLvString(_tMailMsg.nAtkLv))
		if tMailData.template==e_type_mail_report.mine then --矿点
			local sNameAndLv=""
			table.insert(tInfo,{sStr=getConvertedStr(9,10017),nFontSize=18,sColor=_cc.pwhite})
			sNameAndLv=_tMailMsg.sDefName.. getLvString(_tMailMsg.nDefLv)
			table.insert(tInfo,{sStr=sNameAndLv,nFontSize=20,sColor=_cc.pwhite})
			table.insert(tInfo,{sStr=getConvertedStr(9,10018),nFontSize=18,sColor=_cc.pwhite})
			table.insert(tInfo,{sStr=sAtkInfo,nFontSize=20,sColor=_cc.pwhite})
			table.insert(tInfo,{sStr=getConvertedStr(9,10016),nFontSize=18,sColor=_cc.pwhite})

			return tInfo
		end
	end
end

return MailFunc