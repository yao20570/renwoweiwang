-----------------------------------------------------
-- author: maheng
-- updatetime:  2018-1-16 11:05:40 星期二
-- Description: 竞技场 玩家列表
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local IconHero = require("app.common.iconview.IconHero")
local ArenaFunc = require("app.layer.arena.ArenaFunc")
local ItemArenaLayer = class("ItemArenaLayer", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemArenaLayer:ctor(  )
	-- body
	self:myInit()
	parseView("item_arena_layer", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function ItemArenaLayer:myInit(  )
	-- body
	self.tCurData 			= 	nil 				--当前数据	
	self.bIsIconCanTouched 	= 	false	
	self.tHeros = {}
end

--解析布局回调事件
function ItemArenaLayer:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("ItemArenaLayer",handler(self, self.onDestroy))
end

--初始化控件
function ItemArenaLayer:setupViews( )
	-- body
	self.pLayRoot 	= self:findViewByName("item_arena_layer")
	self.pLbPName 	= self:findViewByName("lb_name")--玩家名字	
	self.pLbZl 		= self:findViewByName("lb_ZL")--玩家战力
	self.pLbZl:setString(getConvertedStr(3, 10233))	
	self.pLbRank 	= self:findViewByName("lb_rank")--排名
	self.pLbRank:setString(getConvertedStr(6, 10685))
	self.pLayIcon 	= self:findViewByName("lay_icon")--玩家头像	
	self.pImgCountry = self:findViewByName("img_country")		
	self.pLayBtn 	= self:findViewByName("lay_btn")--挑战或扫荡按钮层
	self.pBtn = getCommonButtonOfContainer(self.pLayBtn,TypeCommonBtn.M_BLUE,getConvertedStr(6,10684))	
	setMCommonBtnScale(self.pLayBtn, self.pBtn, 0.8)
	self.pBtn:onCommonBtnClicked(handler(self, self.onBtnClicked))	
	self.pBtn:onCommonBtnDisabledClicked(handler(self, self.onDisBtnClick))

	self.pImgSelected = self:findViewByName("img_selected")

	self.pLayContent = self:findViewByName("lay_cont")

	self:onMViewClicked(handler(self, self.onItemClicked))
	self:setIsPressedNeedScale(false)
end

-- 修改控件内容或者是刷新控件数据
function ItemArenaLayer:updateViews( )
	-- body
	if not self.tCurData then
		return
	end
	-- dump(self.tCurData, "self.tCurData", 100)
	local data = self.tCurData:getActorVo()
	if not self.pIcon then
		self.pIcon = getIconGoodsByType(self.pLayIcon, TypeIconHero.NORMAL,type_icongoods_show.header, data, TypeIconHeroSize.M)
		self.pIcon:setIconIsCanTouched(self.bIsIconCanTouched)
		--self.pIcon:setIconClickedCallBack(handler(self, self.onIconClicked))
	else
		self.pIcon:setCurData(data)
	end

	--设置挑战和扫荡的表现
	self.pImgCountry:setCurrentImage(getCountryImg(self.tCurData.nInfluence))	
	self.pLbPName:setString(self.tCurData.sName..getSpaceStr(1)..getLvString(self.tCurData.nLevel, false), false)
	
	local sStr1 = {
		{color=_cc.pwhite, text=getConvertedStr(6, 10685)},
		{color=_cc.white, text=self.tCurData.nRank},
	}
	if self.tCurData.bLucky then
		table.insert(sStr1, {color=_cc.purple, text=getConvertedStr(6, 10725)})
	end
	self.pLbRank:setString(sStr1, false)
	self.pLbRank:setVisible(self.tCurData.nRank ~= 0)

	local sStr2 = {
		{color=_cc.pwhite, text=getConvertedStr(3, 10233)},
		{color=_cc.blue, text=self.tCurData.nScore},
	}
	self.pLbZl:setString(sStr2, false)
	--武将信息刷新
	self:updateHeros()	

	if self.tCurData.nRank <= 10 and self.tCurData.nRank > 0 then
		self.pLayRoot:setBackgroundImage("#v1_img_kelashen6liang.png",{scale9 = true,capInsets=cc.rect(50,50, 1, 1)})	
	else
		self.pLayRoot:setBackgroundImage("#v1_img_kelashen6.png",{scale9 = true,capInsets=cc.rect(50,50, 1, 1)})	
	end
	local pData = Player:getArenaData()
	if pData then
		self.pBtn:setBtnEnable(pData:getChallengeCd() <= 0)
	end

	--新手教程
	if self.nIndex == 1 then
		Player:getNewGuideMgr():setNewGuideFinger(self.pBtn, e_guide_finer.first_arena_btn)
	end
end

--武将信息刷新
function ItemArenaLayer:updateHeros()
	-- body
	local tHerosData = self.tCurData.tHeroVos
	for i = 1, 4 do
		local pData = tHerosData[i]
		local pHeroItem = self.tHeros[i]
		if pData then
			if not pHeroItem then
				pHeroItem = IconHero.new(TypeIconHero.NORMAL)
				pHeroItem:setIconIsCanTouched(false)
				pHeroItem:setPosition(84*(i - 1) + 11,12)
				pHeroItem:setScale(0.7)
				self.pLayContent:addView(pHeroItem,10)
				self.tHeros[i] = pHeroItem
			end
			pHeroItem:setCurData(pData)
			pHeroItem:setHeroType()
			pHeroItem:setVisible(true)
		else
			if pHeroItem then
				pHeroItem:setVisible(false)
			end
		end
	end
end
--弃用 暂时保留
-- function ItemArenaLayer:setSelectedStatus( _bSelected )
-- 	-- body
-- 	self.pImgSelected:setVisible(_bSelected)
-- 	if _bSelected then
-- 		setTextCCColor(self.pLbPName, _cc.blue)
-- 	else
-- 		setTextCCColor(self.pLbPName, _cc.white)
-- 	end
-- end

-- 析构方法
function ItemArenaLayer:onDestroy(  )
	-- body
end

function ItemArenaLayer:setCurData( _tData, _index)
	-- body
	self.tCurData = _tData
	self.nIndex = _index
	self:updateViews()
end

--点击事件回调
function ItemArenaLayer:onItemClicked(  )
	-- body
	if not self.tCurData then
		return
	end
	-- dump(self.tCurData, "self.tCurData", 100)
	if self.tCurData.nIsNpc == 0 then
		local sPlayerId = self.tCurData.nId 
		SocketManager:sendMsg("checkArenaPlayer", {sPlayerId}) --刷新竞技场幸运列表	
	end
end

--按钮点击回调 挑战
function ItemArenaLayer:onBtnClicked( pView )
	-- body
	local pData = Player:getArenaData()
	if not pData then
		return
	end

	--新手教程
	Player:getNewGuideMgr():setNewGuideFingerClicked(e_guide_finer.first_arena_btn)
	
	local nLeftChallenge = pData.nChallenge
	if nLeftChallenge > 0 then
		SocketManager:sendMsg("reqArenaChallenge", {self.tCurData.nRank, self.tCurData.nId}) 		
	else
		local pItem = Player:getBagInfo():getItemDataById(e_id_item.arenaToken)
		if pItem and pItem.nCt > 0 then
			--使用城占令牌
			ShowDlgUseArenatToken()
		else			
			local nBuyLeft = pData:getLeftVipChallengeTime()
			if nBuyLeft > 0 then
				showBuyArenaChallenge()		
			else
				if Player:getPlayerInfo():isVipLevelFull() then				
					TOAST(getConvertedStr(6, 10830))--今日挑战次数已耗尽
				else
					TOAST(getConvertedStr(6, 10710))
				end
			end				
		end	
	end
end

function ItemArenaLayer:onDisBtnClick(  )
	-- body	
	local pData = Player:getArenaData()	
	if not pData then
		return
	end	
	local nLeft = pData:getChallengeCd()	
	local nCost = tonumber(getArenaParam("CDCosts") or 0)
	if nLeft > 0 then	
		ArenaFunc.doClearChallengeCd(nCost)--执行清理CD流程
	end	
end


return ItemArenaLayer