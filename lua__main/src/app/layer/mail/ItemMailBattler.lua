----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-05-22 18:05:46
-- Description: 邮件战役子项 玩家或者武将
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ActorVo = require("app.layer.playerinfo.ActorVo")
local MailFunc = require("app.layer.mail.MailFunc")
local MImgLabel = require("app.common.button.MImgLabel")
-- local nOriPlayerNamePosY = 97 --写死算了 
local ItemMailBattler = class("ItemMailBattler", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--_nType  1-左边 2-右边
function ItemMailBattler:ctor( _nType )
	--解析文件
	self.nType=_nType or 1
	if self.nType==1 then
		parseView("item_mail_battle_battler_left", handler(self, self.onParseViewCallback))
	elseif self.nType==2 then
		parseView("item_mail_battle_battler_right", handler(self, self.onParseViewCallback))
	end

end

--解析界面回调
function ItemMailBattler:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemMailBattler",handler(self, self.onItemMailBattlerDestroy))
end

-- 析构方法
function ItemMailBattler:onItemMailBattlerDestroy(  )
    self:onPause()
end

function ItemMailBattler:regMsgs(  )
end

function ItemMailBattler:unregMsgs(  )
end

function ItemMailBattler:onResume(  )
	self:regMsgs()
end

function ItemMailBattler:onPause(  )
	self:unregMsgs()
end

function ItemMailBattler:setupViews(  )
	self.pLayView = self:findViewByName("view")
	self.pLayPlayerBg = self:findViewByName("lay_player_bg")
	self.pLayHeroBg = self:findViewByName("lay_hero_bg")
	self.pTxtHeroName = self:findViewByName("txt_hero_name")
	self.pImgResult = self:findViewByName("img_result")
	self.pTxtName = self:findViewByName("txt_name")
	setTextCCColor(self.pTxtName,_cc.blue)

	self.pLayIcon = self:findViewByName("lay_icon")
	self.pLayHeroIcon = self:findViewByName("lay_hero_icon")
	self.pTxtTroops = self:findViewByName("txt_troops")
	
	self.pTxtLose = self:findViewByName("txt_lose")
	self.pLayCityIcon = self:findViewByName("lay_city_icon")

	--坐标
	self.pTxtPos= self:findViewByName("txt_pos")
	-- if self.nType==1 then
	-- 	self.pTxtPos:setAnchorPoint(cc.p(0, 0))
	-- elseif self.nType==2 then
	-- 	self.pTxtPos:setAnchorPoint(cc.p(1, 0))
	-- end
	self.pTxtPos:setVisible(false)
	self.pImgPos = self:findViewByName("img_pos")
	self.pImgPos:setVisible(false)

	self.sTroopsTitle=""
	self.sLoseTitle=""

	self.pLayPos=self:findViewByName("lay_pos_btn")
	self.pLayPos:setViewTouched(false)
	self.pLayPos:setIsPressedNeedScale(false)
	self.pLayPos:onMViewClicked(handler(self, self.onClickPos))

	self.pLayView=self:findViewByName("view")
	self.pLayView:setVisible(true)
	self.pTxtTip=self:findViewByName("txt_tip")
	self.pTxtTip:setVisible(false)
	

	self.pTxtPlayerName=self:findViewByName("txt_player_name")
	self.pTxtPlayerName:setVisible(false)

	self.nOriPlayerNamePosY = self.pTxtPlayerName:getPositionY()
end

function ItemMailBattler:updateViews(  )
end

--获取玩家头像路径
function ItemMailBattler:getPlayerHeadImgPath( sId )
	if not sId then
		print("no sId")
		return
	end
	local tAvatarIcon = getAvatarIcon(sId)
	if tAvatarIcon then
		return tAvatarIcon.sIcon
	end
	return nil
end

--设置进攻方玩家详细（矿点）
function ItemMailBattler:setAtkFightDetail( tFightDetail )
	self:setPlayerData()
	local tStr={
		{color=_cc.pwhite,text=tFightDetail.sAtkName},
		{color=_cc.pwhite,text=getLvString(tFightDetail.nAtkLv)},
	}
	self.pTxtName:setString(tStr)--(getCountryShortName(tFightDetail.nAtkCountry, true))
	
	local tStrTroops={
		{color=_cc.pwhite,text=self.sTroopsTitle},
		{color=_cc.white,text=tFightDetail.nAtkTroops},
	}
	self.pTxtTroops:setString(tStrTroops)
	local tStrLost={
		{color=_cc.pwhite,text=self.sLoseTitle},
		{color=_cc.white,text="-"..tFightDetail.nAtkLoseTroops},
	}
	self.pTxtLose:setString(tStrLost)

	--设置图片
	local pActorVo = ActorVo.new()
	pActorVo:initData(tFightDetail.sAtkSid, nil, nil)
	local pIcon = getIconGoodsByType(self.pLayIcon, TypeIconHero.NORMAL,type_icongoods_show.header, pActorVo, TypeIconHeroSize.M)	
end

--设置防守方玩家详细（矿点）
function ItemMailBattler:setDefFightDetail( tFightDetail)
	self:setPlayerData()

	local tStr={
		{color=_cc.pwhite,text=tFightDetail.sDefName},
		{color=_cc.pwhite,text=getLvString(tFightDetail.nDefLv)},
	}
	self.pTxtName:setString(tStr)--(getCountryShortName(tFightDetail.nAtkCountry, true))
	local tStrTroops={
		{color=_cc.pwhite,text=self.sTroopsTitle},
		{color=_cc.white,text=tFightDetail.nDefTroops},
	}
	self.pTxtTroops:setString(tStrTroops)
	local tStrLost={
		{color=_cc.pwhite,text=self.sLoseTitle},
		{color=_cc.white,text="-"..tFightDetail.nDefLoseTroops},
	}
	self.pTxtLose:setString(tStrLost)
	--设置图片
	-- local sImgPath = self:getPlayerHeadImgPath(tFightDetail.sDefSid)
	-- self:setPlayerImg(sImgPath)
	-- local tCityInfo = nil
	-- print("collect---")
	-- local tCityData = getWorldCityDataById(tMailMsg.nDid)
	-- if tCityData then
	-- 	sName = tCityData.name
	-- 	sImgPath = tCityData.tCityicon[tMailMsg.nDefCountry]
	-- end
	-- tCityInfo = {nCityId = tMailMsg.nDid, nCountry = tMailMsg.nDefCountry}
	-- self:setPlayerImg(sImgPath, nil , tCityInfo)
	local pActorVo = ActorVo.new()
	pActorVo:initData(tFightDetail.sDefSid, nil, nil)
	local pIcon = getIconGoodsByType(self.pLayIcon, TypeIconHero.NORMAL,type_icongoods_show.header, pActorVo, TypeIconHeroSize.M)		
end

--设置玩家数据
function ItemMailBattler:setPlayerData(  )
	self.pTxtLose:setVisible(true)

	self.sTroopsTitle=getConvertedStr(3, 10124)
	self.sLoseTitle=getConvertedStr(3, 10225)
	-- setTextCCColor(self.pTxtLose, _cc.red)
end

--设置武将数据
function ItemMailBattler:setHeroData( tFightHero, nCountry)
	-- self.pTxtPlayerName:setVisible(true)
	self.pTxtPlayerName:setPositionY(self.nOriPlayerNamePosY) 

	self:hideTip()
	self.pLayPlayerBg:setVisible(false)
	local tStr = {
		{color=_cc.pwhite,text=tostring(tFightHero.sPlayerName)},
		-- {color=_cc.pwhite,text=getLvString(tFightHero.nHeroLv)},
	}
	self.pTxtName:setString(tStr)--(getCountryShortName(nCountry, true))
	self.sTroopsTitle=getConvertedStr(3, 10226)
	local tStrTroops={
		{color=_cc.pwhite,text=self.sTroopsTitle},
		{color=_cc.white,text=tFightHero.nKill},
	}
	self.pTxtTroops:setString(tStrTroops)

	
	--战功
	local nPrestige = nil
	local nHeroGetExp = nil
	if tFightHero.bIsNpc then
		nPrestige = 0
	--有战功才会显示战功
	elseif tFightHero.nPrestige then 
		nPrestige = tFightHero.nPrestige
	--有经验才会显示经验
	elseif tFightHero.nHeroGetExp then
		nHeroGetExp = tFightHero.nHeroGetExp
	end
	if nPrestige  then
		if nPrestige > 0 then
			self.pTxtLose:setVisible(true)
			self.sLoseTitle=getConvertedStr(3, 10224)
			local tStr={
				{color=_cc.pwhite,text=self.sLoseTitle},
				{color=_cc.green,text="+"..nPrestige},
			}
			self.pTxtLose:setString(tStr)
		else
			self.pTxtLose:setVisible(false)

		end
	elseif nHeroGetExp then
		self.pTxtLose:setVisible(true)
		self.sLoseTitle=getConvertedStr(3, 10343)

		local tStr={
			{color=_cc.pwhite,text=self.sLoseTitle},
			{color=_cc.green,text="+"..nHeroGetExp},
		}
		self.pTxtLose:setString(tStr)
	else
		-- self.pTxtLoseTitle:setVisible(false)
		self.pTxtLose:setVisible(false)
	end

	--设置武将名字
	local tHeroData = getGoodsByTidFromDB(tFightHero.nHeroId)
	if tHeroData then
		local tStr = {
			{color=_cc.pwhite,text=tostring(tHeroData.sName)},
			{color=_cc.blue,text=getLvString(tFightHero.nHeroLv)},
		}
		self.pTxtPlayerName:setVisible(true)
		self.pTxtPlayerName:setString(tStr)
		self.pTxtTroops:setPositionY(self.pTxtPlayerName:getPositionY()-self.pTxtTroops:getHeight()-5)
		self.pTxtLose:setPositionY(self.pTxtTroops:getPositionY()-self.pTxtLose:getHeight()-5)
	else
		self.pTxtPlayerName:setVisible(false)
		self.pTxtTroops:setPositionY(self.pTxtPlayerName:getPositionY())
		self.pTxtLose:setPositionY(self.pTxtTroops:getPositionY()-self.pTxtLose:getHeight()-5)
	end
	--设置武将图标
	local nHeroId = tFightHero.nTemplate or tFightHero.nHeroId
	self:setHeroIcon(nHeroId, tFightHero.nQuality, tFightHero.nIg)

	if not self.pTxtLose:isVisible() then
		self.pTxtPlayerName:setPositionY(self.nOriPlayerNamePosY - 8)
		self.pTxtTroops:setPositionY(self.nOriPlayerNamePosY - 28)
		self.pTxtName:setPositionY(self.nOriPlayerNamePosY + 15 )
		-- self.pTxtPlayerName:setPositionY(self:pTxtPlayerName:getPositionY() - 5)
		-- self.pTxtPlayerName:setPositionY(self:pTxtPlayerName:getPositionY() - 5)
	end
end

--设置进攻方玩家数据（国战，城战）
function ItemMailBattler:setAtkPlayer( tMailMsg )
	self:setPlayerData()
	local tStr = {
			{color=_cc.blue,text=""},
			{color=_cc.blue,text=tostring(tMailMsg.sAtkName)},
			{color=_cc.blue,text=getLvString(tMailMsg.nAtkLv)},
		}
	
	local tStrTroops={
			{color=_cc.pwhite,text=self.sTroopsTitle},
			{color=_cc.white,text=tMailMsg.nAtkTroops},
		}
	self.pTxtTroops:setString(tStrTroops)
	local tStrLost={
			{color=_cc.pwhite,text=self.sLoseTitle},
			{color=_cc.white,text="-"..tostring(tMailMsg.nAtkLoseTroops)},
		}
	self.pTxtLose:setString(tStrLost)

	local sName = tMailMsg.sAtkName
	--设置名字
	-- self.pTxtName:setString(sName)	
	--类型
	local sImgPath = nil
	local nAty = tMailMsg.nAty
	local tCityInfo = nil
	if nAty == e_type_atk_def.player then --玩家
		local pActorVo = ActorVo.new()
		pActorVo:initData(tMailMsg.sAtkSid, nil, nil)
		pIcon = getIconGoodsByType(self.pLayIcon, TypeIconHero.NORMAL,type_icongoods_show.header, pActorVo, TypeIconHeroSize.M)

		if not self.pImgCountry then
			self.pImgCountry = MUI.MImage.new(WorldFunc.getCountryFlagImg(tMailMsg.nAtkCountry))
			self.pImgCountry:setAnchorPoint(0,1)
			self.pImgCountry:setScale(0.9)
			self.pImgCountry:setPosition(0,pIcon:getHeight()+5)
			self.pImgCountry:setZOrder(10)
			pIcon:addView(self.pImgCountry)
		else
			self.pImgCountry:setCurrentImage(WorldFunc.getCountryFlagImg(tMailMsg.nAtkCountry))
		end
		pIcon:setPositionY(pIcon:getPositionY()-3)
		--sImgPath = self:getPlayerHeadImgPath(tMailMsg.sAtkSid)
	elseif nAty == e_type_atk_def.npc then --npc
		if tMailMsg.nAid then
			local tNpcList = getNpcGropById(tMailMsg.nAid)
			if tNpcList and tNpcList[1] then
				tNpc = tNpcList[1]
				sName = tNpc.sName
				sImgPath = tNpc.sIcon
			end
		end
	elseif nAty == e_type_atk_def.sysCity then --国战

		local tCityData = getWorldCityDataById(tMailMsg.nAid)
		local sCountry=getCountryShortName(tMailMsg.nAtkCountry,true)
		local sColor=getColorByCountry(tMailMsg.nAtkCountry)
		if tCityData then
			tStr[1].text=sCountry
			tStr[1].color = sColor
			tStr[2].text =tCityData.name
			sImgPath = tCityData.tCityicon[tMailMsg.nAtkCountry]
		end
		tCityInfo = {nCityId = tMailMsg.nAid, nCountry = tMailMsg.nAtkCountry}
	elseif nAty == e_type_atk_def.wildArmy then --乱军
		if tMailMsg.bIsMoBing then
			local tEnemyData = getAwakeArmyData(tMailMsg.nDid)
			if tEnemyData then
				return tEnemyData.sIcon
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
		sImgPath=tMineData.sIcon
		self:setPlayerImg(sImgPath, nil, nil,false,0.68)

		return
	elseif nAty == e_type_atk_def.ghostBoss then --ghostBoss
		if tMailMsg.nAid then
			local tNpc,tNpcData = getGhostBossById(tMailMsg.nAid)
			if tNpcData then
				tNpc = tNpcData
				sName = tNpc.sName
				sImgPath = tNpc.sIcon
			end
		end
	elseif nAty == e_type_atk_def.kingzhou then --纣王试炼
		local pKingZhou = WorldFunc.getKingZhouConfData()
		if pKingZhou  then
			sName = pKingZhou.sName
			sImgPath = pKingZhou.sRoleImg
			nScale = 0.8
		end	
	end

	self.pTxtName:setString(tStr)
	--设置图片
	self:setPlayerImg(sImgPath, nil , tCityInfo)
end

--设置防守方玩家数据（国战，城战）
function ItemMailBattler:setDefPlayer( tMailMsg )
	self:setPlayerData()

	local sName = tMailMsg.sDefName
	local tStr = {
		{text=""},
		{text=tostring(tMailMsg.sDefName)},
		{text=getLvString(tMailMsg.nDefLv)},
	}

	local tStrTroops={
			{color=_cc.pwhite,text=self.sTroopsTitle},
			{color=_cc.white,text=tMailMsg.nDefTroops},
		}
	self.pTxtTroops:setString(tStrTroops)
	local tStrLost={
			{color=_cc.pwhite,text=self.sLoseTitle},
			{color=_cc.white,text="-"..tostring(tMailMsg.nDefLoseTroops)},
		}
	self.pTxtLose:setString(tStrLost)

	local sImgPath = nil
	local nScale=1
	--类型
	local tCityInfo = nil
	local sImgPath = nil
	local nDty = tMailMsg.nDty
	if nDty == e_type_atk_def.player then --玩家
		--sImgPath = self:getPlayerHeadImgPath(tMailMsg.sDefSid)
		local tMailReport = getMailReport(tMailMsg.nId)
		local pActorVo = ActorVo.new()
		pActorVo:initData(tMailMsg.sDefSid, nil, nil)
		pIcon = getIconGoodsByType(self.pLayIcon, TypeIconHero.NORMAL,type_icongoods_show.header, pActorVo, TypeIconHeroSize.M)
		if not self.pImgCountry then
			self.pImgCountry = MUI.MImage.new(WorldFunc.getCountryFlagImg(tMailMsg.nDefCountry))
			self.pImgCountry:setAnchorPoint(0,1)
			self.pImgCountry:setScale(0.9)

			self.pImgCountry:setPosition(0,pIcon:getHeight()+5)
			self.pImgCountry:setZOrder(10)

			pIcon:addView(self.pImgCountry)
		else
			self.pImgCountry:setCurrentImage(WorldFunc.getCountryFlagImg(tMailMsg.nDefCountry))
		end
		pIcon:setPositionY(pIcon:getPositionY()-3)
		self.pTxtName:setString(tStr)
		return		
				
	elseif nDty == e_type_atk_def.npc then --npc
		if tMailMsg.nDid then
			-- if tMailMsg.nBossLv and tMailMsg.nBossDif then
			if tMailMsg.nFightType == e_type_mail_fight.awakeBoss then
				local tWorldBossData = getAwakeBossData(tMailMsg.nBossLv,tMailMsg.nBossDif)
				if tWorldBossData then
					sName = tWorldBossData.name
					sImgPath = tWorldBossData.sIcon
					--纣王不显示等级
					tStr = {
						{text=tostring(tMailMsg.sDefName)},
					}
					self.pTxtName:setString(tStr)
					nScale=0.7
				end
			elseif tMailMsg.nFightType == e_type_mail_fight.wileArmy then

				local tNpcList = getNpcGropById(tMailMsg.nDid)
				if tNpcList and tNpcList[1] then
					tNpc = tNpcList[1]
					sName = tNpc.sName
					sImgPath = tNpc.sIcon
				end
			end
		end
	elseif nDty == e_type_atk_def.sysCity then --国战
		
		local tCityData = getWorldCityDataById(tMailMsg.nDid)
		local sCountry=getCountryShortName(tMailMsg.nDefCountry,true)
		local sColor = getColorByCountry(tMailMsg.nDefCountry)
		if tCityData then
			tStr[1].text=sCountry
			tStr[1].color = sColor
			tStr[2].text =tCityData.name

			sImgPath = tCityData.tCityicon[tMailMsg.nDefCountry]
		end
		tCityInfo = {nCityId = tMailMsg.nDid, nCountry = tMailMsg.nDefCountry}
	elseif nDty == e_type_atk_def.wildArmy then --乱军
		if tMailMsg.bIsMoBing then
			local tWorldEnemyData = getAwakeArmyData(tMailMsg.nDid)
			if tWorldEnemyData then
				sName = tWorldEnemyData.name
				sImgPath = tWorldEnemyData.sIcon
				nScale = 0.8
			end
		else
			local tWorldEnemyData = getWorldEnemyData(tMailMsg.nDid)
			if tWorldEnemyData then
				sName = tWorldEnemyData.name
				sImgPath = tWorldEnemyData.sIcon
				nScale = 0.8
			end
		end
	elseif nDty == e_type_atk_def.mine then --矿点
		if tMailMsg.tDefHeros and #tMailMsg.tDefHeros then
			local tTemp=tMailMsg.tDefHeros[1]

			local tStr = {
				{text=tostring(tTemp.sPlayerName)},
				{text=getLvString(tTemp.nHeroLv)},
			}
			self.pTxtName:setString(tStr)--(getCountryShortName(tMailMsg.nDefCountry, true))
		end
		
		local tMineData = getWorldMineData(tMailMsg.nDid)
		sImgPath=tMineData.sIcon
		self:setPlayerImg(sImgPath, nil, nil,false,0.6)
		return
	elseif nDty == e_type_atk_def.ghostdom then --幽魂
		local tNpcDetailData= getWorldGhostdomData(tMailMsg.nDid)
		if tNpcDetailData then
			tNpc = tNpcDetailData
			sName = tNpc.name
			sImgPath = tNpc.sIcon
		end
		tStr = {
			{text=tostring(tMailMsg.sDefName)}
		}
	elseif nDty == e_type_atk_def.kingzhou then --纣王试炼
		local pKingZhou = WorldFunc.getKingZhouConfData()
		if pKingZhou  then			
			sName = pKingZhou.sName
			sImgPath = pKingZhou.sRoleImg
			nScale = 0.8
		end		
	end
	self.pTxtName:setString(tStr)--(getCountryShortName(tMailMsg.nDefCountry, true))
	--设置图片
	self:setPlayerImg(sImgPath, nil, tCityInfo,true,nScale)
	
end

--设置玩家头像 sImgPath icon图片 _nQuality 品质,isNeedBg 是否需要背景框，nScale 头像缩放比例
function ItemMailBattler:setPlayerImg( sImgPath, _nQuality, tCityInfo ,_isNeedBg,_nScale)
	--隐藏武将图标
	self.pLayHeroIcon:setVisible(false)

	local nQuality = _nQuality or 100

	local isNeedBg=_isNeedBg or true
	local nScale=_nScale or 1

	if tCityInfo then
		self.pLayCityIcon:setVisible(true)
		self.pLayIcon:setVisible(false)
		WorldFunc.getSysCityIconOfContainer(self.pLayCityIcon, tCityInfo.nCityId, tCityInfo.nCountry, true)
	else
		self.pLayCityIcon:setVisible(false)
		self.pLayIcon:setVisible(true)

		--设置玩家头像
		if sImgPath then
			if not self.pImgHead then
				
				self.pImgHeadBg = MUI.MImage.new(getIconBgByQuality(nQuality))
				self.pImgHeadBg:setScale(0.8)
				self.pLayIcon:addView(self.pImgHeadBg)
				centerInView(self.pLayIcon, self.pImgHeadBg)

				self.pImgHead = MUI.MImage.new(sImgPath)
				
				self.pLayIcon:addView(self.pImgHead)
				centerInView(self.pLayIcon, self.pImgHead)

				local pRect = self.pImgHeadBg:getBoundingBox()
				local nLen = math.max(pRect.width, pRect.height)
				if nLen == pRect.width then
					self.pImgHead:setScale((nLen - 10)/ self.pImgHeadBg:getWidth())
				else
					self.pImgHead:setScale((nLen - 10)/ self.pImgHeadBg:getHeight())
				end
			else
				self.pImgHeadBg:setCurrentImage(getIconBgByQuality(nQuality))
				self.pImgHead:setCurrentImage(sImgPath)
			end

			--背景框
			if isNeedBg  then 
				if self.pImgHeadBg then
					self.pImgHeadBg:setVisible(false)
				end
			end
			self.pImgHead:setScale(nScale)

		end
	end
end

--设置武将图标
function ItemMailBattler:setHeroIcon( nHeroId, nQuality, nIg)
	self.pLayCityIcon:setVisible(false)
	self.pLayIcon:setVisible(false)
	self.pLayHeroIcon:setVisible(true)
	--设置武将图标
	local tHeroData = getGoodsByTidFromDB(nHeroId)
	if nQuality then
		tHeroData.nQuality = nQuality
		
	end
	if nIg then
		tHeroData.nIg = nIg
	end
	if tHeroData then
		self.pHeroIcon = getIconHeroByType(self.pLayHeroIcon, TypeIconHero.NORMAL, tHeroData, 0.8)
		self.pHeroIcon:setHeroType()
	end
end

--_nType 1-进攻方 2-防守方
function ItemMailBattler:setPlayPos(_tMailMsg ,_nType)
	-- body
	if _tMailMsg then
		self.pTxtPos:setVisible(true)
		self.pImgPos:setVisible(true)
		if _nType==1 then 
			
			self.nPosX=_tMailMsg.nAtkX
			self.nPosY=_tMailMsg.nAtkY
		elseif _nType==2 then
			self.nPosX=_tMailMsg.nDefX
			self.nPosY=_tMailMsg.nDefY
		end
		
		local sPosStr=underLineTheStr(self.nPosX .. "," .. self.nPosY)
		-- self.pTxtPos:setString(sPosStr)

		local sStr = {
			{text = getConvertedStr(7, 10301), color = _cc.pwhite},
			{text = sPosStr, color = _cc.green}
		}
		self.pTxtPos:setString(sStr)
		if _nType==2 then 
			self.pImgPos:setPositionX(self.pTxtPos:getPositionX()-self.pTxtPos:getWidth()-self.pImgPos:getWidth()/2+5)
		else
			self.pImgPos:setPositionX(112)
		end

		self.pLayPos:setViewTouched(true)
	end
end

function ItemMailBattler:onClickPos( )
	-- body

	if self.nPosX and self.nPosY then
		local fX, fY = WorldFunc.getMapPosByDotPosEx(self.nPosX, self.nPosY)
		closeAllDlg()
		sendMsg(ghd_world_location_mappos_msg, {fX = fX, fY = fY, isClick = true})
		
		
		-- closeDlgByType(e_dlg_index.mail,false)
	end
end
--1-进攻方  2-防守方
function ItemMailBattler:showTip(_nType)
	-- body
	self.pLayView:setVisible(false)
	self.pTxtTip:setVisible(false)
	-- if _nType==1 then
	-- 	self.pTxtTip:setString(getConvertedStr(9,10025))

	-- elseif _nType==2 then
	-- 	self.pTxtTip:setString(getConvertedStr(9,10024))  
	-- end
end

--1-进攻方  2-防守方
function ItemMailBattler:hideTip()
	-- body
	self.pLayView:setVisible(true)
	self.pTxtTip:setVisible(false)
	
end

--1-进攻方 2-防守方
function ItemMailBattler:setMyPlayerName(tMailMsg,_nType)

	-- local sName=""
	-- local sLv=""

	-- if _nType==1 then
	-- 	sName = tMailMsg.sAtkName
	-- 	sLv=getLvString(tMailMsg.nAtkLv)
	-- elseif _nType==2 then
	-- 	sName=tMailMsg.sDefName
	-- 	sLv=getLvString(tMailMsg.nDefLv)
	-- end

	-- -- local sName = tMailMsg.sDefName
	-- local tStr = {
	-- 	{text=sName},
	-- 	{text=sLv},
	-- }
	-- self.pTxtPlayerName:setString(tStr)
	-- body
	self.pTxtPlayerName:setVisible(true)
	local tStr = {
		{text=tostring(_sName)},
		{text=getLvString(_nLv)},
	}
	self.pTxtPlayerName:setString(tStr)

	self.pTxtTroops:setPositionY(self.pTxtPlayerName:getPositionY()-self.pTxtTroops:getHeight()-5)
	self.pTxtLose:setPositionY(self.pTxtTroops:getPositionY()-self.pTxtLose:getHeight()-5)
end


return ItemMailBattler


