-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-04-13 14:58:43 星期四
-- Description: 玩家基础信息
-----------------------------------------------------


local PlayerInfo = class("PlayerInfo")
local ActorVo = require("app.layer.playerinfo.ActorVo")
function PlayerInfo:ctor(  )
	self:myInit()
end

function PlayerInfo:myInit(  )
	-- body
	--基础信息
	self.pid 							= 			"" 				--玩家id
	self.sName 							= 			"" 				--玩家名字
	self.nGender 						= 			1 				--玩家性别
	self.nExp 							= 			0 				--玩家经验
	self.nLv 							= 			0 				--玩家等级
	self.sCreateDate 					= 			"" 				--玩家注册时间
	self.nVip 							= 			nil 			--玩家VIP等级
	self.nVipExp 						= 			0 				--玩家Vip积分
	self.nScore 						= 			0 				--玩家战斗力
	self.nMoney							= 			0 				--玩家金币
	self.nPrestige 						= 			0 				--玩家威望
	self.sBanneret 						= 			"" 				--玩家爵位
	self.nInfluence 					= 			0 				--玩家势力
	self.nEnergy 						= 			0 				--玩家能量
	self.nEnergyUT 						= 			0 				--玩家恢复能量所需要的时间
	self.nEnergyLastLoadTime 			= 			nil 			--最后加载能量恢复时间
	self.nBuyEnergyNum 					= 			0 				--每天购买体力次数
	--资源信息
	self.nWood 							= 			0 				--资源：木
	self.nFood 							= 			0 				--资源：粮
	self.nCoin 							= 			0 				--资源：银币
	self.nIron 							= 			0 				--资源：铁
	self.nMedal 						= 			0 				--竞技场代币
	self.nCountryCoin 					= 			0 				--国家商店货币
	--兵种
	self.nInfantry 						= 			0 				--步兵
	self.nArcher 						= 			0 				--弓兵
	self.nSowar 						= 			0 				--骑兵

	self.tBoughtVipGift                 =           {}              --已购买vip礼包
	self.nCountrySelected               =           1               --是否选择了国家0:就是没选  1是选了 --兼容测试服务器才写1~，znftodo
	self.nFirstLogin                    =           nil               --玩家当天第一次登录标志 0否 1是

	self.nWeakInfluence 				= 			0 				--首次登陆未选择国家的默认弱势方
	self.nPrevScore                     =           nil
	self.nKillHeroExp 					= 			0 				--斩将积分
	self.nRoyalscore                    =           0

	--主公头像（目前没有头像系统，临时在这里处理）
	self.sTx 							= 			"#i130000_tx.png" 	--主公头像

	self.nOpenXLBTips					=			0 			--是否开启巡逻兵提示 1开启,0没开启，当完成配表的任务时，会去修改值

	self.tIconDatas                     = 			getAllIconsData() --配置数据 用于显示头像更换
	self.tBoxDatas                     = 			getAllBoxsData() 	--配置数据 用于显示头像框更换
	self.tTitleDatas 					= 			getAllTitlesData()  --配置数据 有用于显示玩家称号
	self.nBoxRed 						= 			0 				--头像框红点	
	self.pActorVo 					  	= 			ActorVo.new()
	self.nHeroRecommondCd               =           0           --名将推荐cd
end

-- 根据服务端信息调整数据
function PlayerInfo:refreshDatasByService( tData )
	--基础信息
	self.pid 							= 			tData.id or self.pid 				    --玩家id
	self.sName 							= 			tData.n or self.sName 			 		--玩家名字
	self.nGender 						= 			tData.gr or self.nGender 				--玩家性别
	self.sCreateDate 					= 			tData.ct or self.sCreateDate	        --玩家注册时间
	self.nScore 						= 			tData.s or self.nScore				    --玩家战斗力
	self.nMoney							= 			tData.g or self.nMoney			        --玩家金币
	self.nPrestige 						= 			tData.p or self.nPrestige	            --玩家威望
	-- self.sBanneret 						= 			tData.bt or self.nBanneret		        --玩家爵位
	--玩家爵位
	self:refreshBanneret( tData.bt )

	self.nInfluence 					= 			tData.ie or self.nInfluence 			--玩家势力(国家)
	self.nCountrySelected               =           tData.cc or self.nCountrySelected       --是否选择了国家
	self.nWeakInfluence 				= 			tData.wc or self.nWeakInfluence 		--首次登陆未选择国家的默认弱势方

	--等级相关
	self:refreshPlayerLv(tData)
	--Vip等级
	self:refreshPlayerVipLv(tData)

	--能量相关
	self:refreshEnergy(tData)
	self.nBuyEnergyNum 					= 			tData.ben or self.nBuyEnergyNum         --每天购买体力次数
	
	--资源信息
	self.nWood 							= 			tData.w or self.nWood				    --资源：木
	self.nFood 							= 			tData.f or self.nFood					--资源：粮
	self.nCoin 							= 			tData.c or self.nCoin					--资源：银币
	self.nIron 							= 			tData.i or self.nIron					--资源：铁
	self.nMedal 						= 			tData.me or self.nMedal				--竞技场代币
	self.nKillHeroExp 					=			tData.ep or self.nKillHeroExp 			--斩将积分
	self.nRoyalscore                    =           tData.epp or self.nRoyalscore                  --皇城战积分
	self.nCountryCoin                   =           tData.ccn or self.nCountryCoin                  --国家商店货币
	--兵种
	self.nInfantry 						= 			tData.it or self.nInfantry				--步兵
	self.nArcher 						= 			tData.ac or self.nArcher				--弓兵
	self.nSowar 						= 			tData.sw or self.nSowar					--骑兵

	--已购买vip礼包
	self.tBoughtVipGift                 =       	tData.vb or self.tBoughtVipGift             --vip礼包
	--头像数据刷新
	--dump(tData.ao, "tData.ao", 100)
	self:refreshIconDatasByService(tData.ao)
	--首次进入游戏保存一个Vip礼包红点
	if self.nCountrySelected == 0 then		
		saveLocalInfo("VipGiftRed"..self.pid, "1")		
	end

	--战斗不播放
	if getToastNCState() == 1 or self.nCountrySelected == 0 then
		--不播放战力变化特效
	else
		--播放战力变化特效
		self:playFCChangeTx()
	end
end

--玩家爵位
function PlayerInfo:refreshBanneret( nLv )
	-- body
	local tData = getCountryBanneretByLv( nLv )
	if tData then
		self.sBanneret = tData.name
	end
end

--刷新玩家等级
function PlayerInfo:refreshPlayerLv( tData )
	-- body
	local bSend = false
	local bgetCountryData = false
	local nopencountry = tonumber(getCountryParam("openLv"))
	if tData.l and tData.l ~= self.nLv then
		bSend = true
		if tData.l and self.nLv < nopencountry and tData.l >= nopencountry then
			bgetCountryData = true
		end
	end
	self.nExp 							= 			tData.e or self.nExp				    --玩家经验
	self.nLv 							= 			tData.l or self.nLv 				    --玩家等级
	if bSend then
		--发送消息刷新对联
		local tObj = {}
		tObj.nType = 1
		sendMsg(ghd_refresh_homeitem_msg, tObj)

		local tConfData = getLevelPreviewData()
		if self.nPreLv then
			if self.nLv >= tConfData[1].level and self.nLv <= tConfData[table.nums(tConfData)].level then
				Player:getNoticeData():setNoticeRedNums(1)
				local tObject = {} 
				tObject.nType = e_index_itemrl.r_gg--对联类型
				tObject.nRedType = 0--红点类型
				tObject.nRedNums = Player:getNoticeData():getNoticeRedNums() --红点个数
				sendMsg(gud_refresh_homelr_red,tObject) --刷新公告上面的红点
			end
		end
		self.nPreLv = self.nLv

		--发送玩家等级变化消息
		sendMsg(ghd_refresh_playerlv_msg)
	end
	if bgetCountryData == true then
		--国家开放事件
		sendMsg(ghd_open_countrysystem_msg)
	end
end

--刷新玩家的Vip等级
function PlayerInfo:refreshPlayerVipLv( tData )
	-- body
	local bSend = false
	local bSaveRed = self.nVip ~= nil
	if tData.v and tData.v ~= self.nVip then
		bSend = true
	end
	self.nVip 							= 			tData.v or self.nVip				    --玩家VIP等级
	self.nVipExp 						= 			tData.vp or self.nVipExp			    --玩家Vip积分
	if bSend then
		--发送玩家Vip等级变化消息		
		if bSaveRed then
			saveLocalInfo("VipGiftRed"..self.pid, "1")
			local tObject = {} 
			tObject.nType = e_index_itemrl.r_sd --对联类型
			tObject.nRedType = 0 --红点类型
			tObject.nRedNums = 1--红点个数
			sendMsg(gud_refresh_homelr_red,tObject)
			--判断成长基金是否满足红点
			local pActData = Player:getActById(e_id_activity.newgrowthfound)
			if pActData then
				-- 刷新活动红点
				sendMsg(gud_refresh_act_red)
			end	
		end
		sendMsg(ghd_refresh_playerviplv_msg)
	end
end

--刷新玩家所属势力
function PlayerInfo:refreshPlayerInfluence( tData )
	-- body
	if tData and tData.c then
		--选择的国家不是默认的国家是时 要重新请求聊天数据
		if self.nInfluence ~= tData.c then
			sendMsg(gud_load_chat_data)
		end
		self.nInfluence = tData.c
		sendMsg(ghd_refresh_playerinfo_country)
	end
end

--刷新体力
function PlayerInfo:refreshEnergy( tData)
	-- body
	if tData then
		self.nEnergy 						= 		tData.eg or self.nEnergy			    --玩家能量
		self.nEnergyUT 						= 		tData.fcd or self.nEnergyUT	            --玩家恢复能量所需要的时间
		-- if tData.fcd and tData.fcd > 0 then
		if tData.fcd then
			self.nEnergyLastLoadTime 		= 		getSystemTime() 				        --最后加载时间
		end
		--发送消息刷新玩家能量值界面
		sendMsg(ghd_refresh_energy_msg)
	end
end

--获得恢复体力剩余时间
function PlayerInfo:getEnergyLeftTime( )
	-- body
	if self.nEnergyUT and self.nEnergyUT > 0 then
		-- 单位是秒
		local fCurTime = getSystemTime()
		-- 总共剩余多少秒
		local fLeft = self.nEnergyUT - (fCurTime - self.nEnergyLastLoadTime or 0)
		if(fLeft < 0) then
			fLeft = 0
		end
		return fLeft
	else
		return 0
	end
end

--获得购买体力剩余次数
--return 剩余几次，总购买次数，已经购买几次
function PlayerInfo:getBuyEnergyLeftTimes(  )
	-- body
	--已经购买几次了
	local nHadBuy = Player:getPlayerInfo().nBuyEnergyNum or 0
	--总可以购买几次
	--获取Vip数据
	local tCurVip = getAvatarVIPByLevel(Player:getPlayerInfo().nVip)
	local nCanBuy = tCurVip.buyenemy or 2
	--剩下购买次数
	local nLeftBuy = nCanBuy - nHadBuy

	return nLeftBuy, nCanBuy, nHadBuy
end

--购买体力消耗的金币
--_nBuyTime：购买次数
function PlayerInfo:buyEnergyCost( _nBuyTime )
	-- body
	local nHadBuy = Player:getPlayerInfo().nBuyEnergyNum or 0
	--查表
	local tCosts = luaSplit(getGlobleParam("energyPrice"), ",")
	--总花费
	local nAllCost = 0
	local nCurIndex = nHadBuy + 1
	local nEndIndex = nHadBuy + _nBuyTime
	for i = nCurIndex, #tCosts do
		if i > nEndIndex then
			break
		end
		nAllCost = nAllCost + tCosts[i]
	end
	return nAllCost
end

--获取可扫荡vip等级
function PlayerInfo:getCanRaidVip()
	local nVip = 1
	for i=1,10 do
		if getAvatarVIPByLevel(i).canraid == 1 then
			nVip = i
			break
		end
	end
	return nVip
end

--Vip等级已满
function PlayerInfo:isVipLevelFull(  )
	-- body
	local tVipDatas = getAvatarVIPData()
	local nMaxVip = table.nums(tVipDatas) - 1
	-- print("nMaxVip--------=", nMaxVip)
	return self.nVip >= nMaxVip
end

--获取基础资源数量
--_resid 资源id
function PlayerInfo:getBaseResNum( _resid )
	-- body
	if _resid then
		if _resid == e_resdata_ids.lc then --粮草
			return self.nFood
		elseif _resid == e_resdata_ids.yb then--钱币
			return self.nCoin
		elseif _resid == e_resdata_ids.mc then--木材
			return self.nWood
		elseif _resid == e_resdata_ids.bt then--镔铁
			return self.nIron
		end
	else
		return self.nWood + self.nFood + self.nCoin
	end
	return 0
end

--获取是否已购买vip礼包
function PlayerInfo:getIsBoughtVipGift( nId )
	for i=1,#self.tBoughtVipGift do
		if self.tBoughtVipGift[i] == nId then
			return true
		end
	end
	return false
end

--添加已购买vip礼包
function PlayerInfo:addBoughtVipGift( nId )
	table.insert(self.tBoughtVipGift, nId)
end

--获取是否弹出
function PlayerInfo:getIsCountrySelected()
	return self.nCountrySelected == 1
end

--播放战力变化
function PlayerInfo:playFCChangeTx( )
	showFCChangeTx(self.nPrevScore, self.nScore)
	self.nPrevScore = self.nScore
end

function PlayerInfo:getVipGiftRedNum(  )
	-- body
	--商店开启判断
	local nRedNum = 0
	local bIsOpen = getIsReachOpenCon(9, false)	
	if bIsOpen then
		nRedNum = tonumber(getLocalInfo("VipGiftRed"..self.pid, "0"))		
	end
	return nRedNum
end

function PlayerInfo:clearVipGiftRedNum(  )
	-- body
	saveLocalInfo("VipGiftRed"..self.pid, "0")
	local tObject = {} 
	tObject.nType = e_index_itemrl.r_sd --对联类型
	tObject.nRedType = 0 --红点类型
	tObject.nRedNums = 0 --红点个数
	sendMsg(gud_refresh_homelr_red,tObject)
end
--获取当前玩家的头像信息
function PlayerInfo:getActorVo(  )
	-- body
	return self.pActorVo
end
--获取当前配置的头像数据
function PlayerInfo:getMyIconDatas(  )
	-- body
	return self.tIconDatas
end

--获取当前配置的头像框数据
function PlayerInfo:getMyBoxDatas( )
	-- body
	return self.tBoxDatas
end

--获取当前配置的称号数据
function PlayerInfo:getMyTitleDatas( )
	-- body
	return self.tTitleDatas
end

function PlayerInfo:refreshIconDatasByService( _tData )
	-- body
	if not _tData then
		return 
	end	
	--当前玩家的头像数据刷新
	self.pActorVo:refreshDatasByService(_tData)
	--刷新头像的网路配置
	-- dump(_tData, "头像相关数据", 100)
	if _tData.ik and #_tData.ik > 0 then
		for k, v in pairs(_tData.ik) do
			local pIconData = self:getIconDataById(v.id)
			if pIconData then
				pIconData:refreshByService(v)
			end
		end
	end	
	--刷新头像框的后端配置
	if _tData.bk and #_tData.bk > 0 then
		for k, v in pairs(_tData.bk) do
			local pBoxData = self:getBoxDataById(v.id)
			if pBoxData then
				pBoxData:refreshByService(v)
			end
		end
	end	
	if _tData.tk and #_tData.tk > 0 then
		for k, v in pairs(_tData.tk) do
			local pTitleData = self:getTitleDataById(v.id)
			if pTitleData then
				pTitleData:refreshByService(v)		
			end
		end
	end		
end

--头像数据
function PlayerInfo:getIconDataById( _ID )
	-- body
	if not _ID then
		return nil
	end
	for k, v in pairs(self.tIconDatas) do
		if v.sTid == _ID then
			return v
		end
	end
	return nil
end
--头像框数据
function PlayerInfo:getBoxDataById( _ID )
	-- body
	if not _ID then
		return nil
	end
	for k, v in pairs(self.tBoxDatas) do
		if v.sTid == _ID then
			return v
		end
	end
	return nil	
end

function PlayerInfo:getTitleDataById( _ID )
	-- body
	if not _ID then
		return nil
	end
	for k, v in pairs(self.tTitleDatas) do
		if v.sTid == _ID then
			return v
		end
	end
	return nil		
end

--设置名将推荐cd
function PlayerInfo:setHeroRecommondCd( nCd )
	self.nHeroRecommondCd = nCd
	self.nHeroRecommondSystemTime = getSystemTime()
end

--获取名将推荐cd
function PlayerInfo:getHeroRecommondCd( )
	-- print("playerinfo 418",self.nHeroRecommondCd)
	if self.nHeroRecommondCd and self.nHeroRecommondCd > 0 then
		local fCurTime = getSystemTime()
		local fLeft = self.nHeroRecommondCd - (fCurTime - self.nHeroRecommondSystemTime)
		if(fLeft < 0) then
			fLeft = 0
		end
		return fLeft
	else
		return 0
	end
	return 0
end

--玩家战力总评
function PlayerInfo:refreshPlayerPower(_data)
	-- body
	self.tPlayerPower = _data
end

--获取玩家战力评分
function PlayerInfo:getPlayerPower()
	-- body
	return self.tPlayerPower or {}
end


return PlayerInfo