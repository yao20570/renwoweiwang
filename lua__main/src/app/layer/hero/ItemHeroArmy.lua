-- Author: liangzhaowei
-- Date: 2017-04-26 10:58:23
-- 武将队列item

local MCommonView = require("app.common.MCommonView")
local ItemHeroInfoLb = require("app.layer.hero.ItemHeroInfoLb")

local ItemHeroArmy = class("ItemHeroArmy", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--_index 下标  _tData 数据
--_type:为2时是过关斩将上阵
function ItemHeroArmy:ctor(_index,_tData,_type)
	-- body
	self:myInit()

	if not _type then
		self.nType = 1
	else
		self.nType = _type
	end

	self.tData = _tData
	self.nIndex = _index or self.nIndex

	parseView("item_hero_army_info", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("ItemHeroArmy",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemHeroArmy:myInit()
	-- body
	self.nIndex = 1 --下标
	self.tData = {} --数据
	self.pRichViewTips1 = nil --富文本1

end

--解析布局回调事件
function ItemHeroArmy:onParseViewCallback( pView )

	self.pItemView = pView
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	--ly         	



	--lb
	-- self.pLbN = self:findViewByName("lb_n")
	-- setTextCCColor(self.pLbN,_cc.pwhite)
	-- self.pLbV = self:findViewByName("lb_v")
	-- setTextCCColor(self.pLbV,_cc.blue)
	-- if nType ==1 then
	-- 	self.pLbE = self:findViewByName("lb_e")
	-- 	setTextCCColor(self.pLbE,_cc.green)
	-- end


	self:setupViews()
	self:updateViews()

end

--初始化控件
function ItemHeroArmy:setupViews( )
	--ly
	--资质数据显示
	self.tLyTalentInfo = {}
	for i=1,3 do
		local pView = self:findViewByName("ly_talent_"..i)
		self.tLyTalentInfo[i] = ItemHeroInfoLb.new(i,2)
		pView:addView(self.tLyTalentInfo[i],10)
	end

	

	--icon
	local pLyIcon = self:findViewByName("ly_icon")
	self.pIcon  =  getIconHeroByType(pLyIcon,TypeIconHero.NORMAL,self.tData,TypeIconHeroSize.M)

	self.pLyHeroMain = self:findViewByName("ly_hero_info_main")
	--武将名称,vip等级
    --等级富文本
    local strTips1 = {
    	{color=getColorByQuality(self.tData.nQuality),text=self.tData.sName},
    	{color=_cc.blue,text=getLvString(self.tData.nLv)},
    }

    self.pRichViewTips1 = MUI.MLabel.new({text= "",size = 22})
    self.pRichViewTips1:setPosition(116,87)
    self.pRichViewTips1:setString(strTips1)
    self.pRichViewTips1:setAnchorPoint(cc.p(0,0.5))
    self.pLyHeroMain:addView(self.pRichViewTips1,10)


	local tLbText = {}
	if self.nType == 2 then --过关斩将上阵显示剩余兵力百分比
		local fPer = Player:getPassKillHeroData():getHeroProById(self.tData.nId)
		local sColor = _cc.green
		if fPer <= 0 then
			sColor = _cc.red
		elseif fPer < 1 then
			sColor = _cc.yellow
		end
		tLbText.tLabel = {
			{getConvertedStr(7, 10381), getC3B(_cc.pwhite)},
			{tostring(fPer*100).."%", getC3B(sColor)}
		}
		tLbText.fontSize = 18
	else
		local sExText = ""
		-- if self.tData:getExTotalTalent() > 0 then
			sExText = "+"..self.tData:getExTotalTalent()
		-- end

		tLbText.tLabel = {
			{getConvertedStr(5, 10036),getC3B(_cc.pwhite)},
			{tostring(self.tData:getBaseTotalTalent()),getC3B(_cc.blue)},
			{sExText,getC3B(_cc.green)},
		}
	end

	local pLyBtn =  self:findViewByName("lb_btn")
	self.pBtnUp = getCommonButtonOfContainer(pLyBtn,TypeCommonBtn.M_BLUE,getConvertedStr(5,10035),true,tLbText)	
	self.pBtnUp:onCommonBtnClicked(handler(self, self.onClicked))

	sendMsg(ghd_guide_finger_show_or_hide, false)

end


-- 修改控件内容或者是刷新控件数据
function ItemHeroArmy:updateViews(  )

	if not self.tData then
		return
	end
	--属性值
	for k,v in pairs(self.tLyTalentInfo) do
		local tData = self.tData.tAttList[k]
		if tData then
			v:setCurData(tData)
		end
	end

	--等级文本刷新
	if self.pRichViewTips1 then

	    --等级富文本
	    local strTips1 = {
	    	{color=getColorByQuality(self.tData.nQuality),text=self.tData.sName},
	    	{color=getColorByQuality(self.tData.nQuality),text=getLvString(self.tData.nLv)},
	    }
	    self.pRichViewTips1:setString(strTips1)
	end


	if self.nType == 2 then --显示剩余兵力
		local fPer = Player:getPassKillHeroData():getHeroProById(self.tData.nId)
		local sColor = _cc.green
		if fPer <= 0 then
			sColor = _cc.red
		elseif fPer < 1 then
			sColor = _cc.yellow
		end
		self.pBtnUp:setExTextLbCnCr(2, tostring((math.ceil(fPer*1000))/10).."%", getC3B(sColor))
		if fPer <= 0 then
			self.pBtnUp:updateBtnText(getConvertedStr(7, 10382))
			self.pBtnUp:setBtnEnable(false)
			--武将头像置灰
			self.pIcon:setIconBgToGray(true)
		else
			self.pIcon:setIconBgToGray(false)
			--如果该武将已上阵, 按钮上文字为下阵, 如果未上阵则显示上阵
			local bHasOnline = Player:getPassKillHeroData():getIsOnlineById(self.tData.nId)
			if bHasOnline then
				self.pBtnUp:updateBtnText(getConvertedStr(7, 10383)) --下阵
				self.pBtnUp:updateBtnType(TypeCommonBtn.M_YELLOW)
			else
				self.pBtnUp:updateBtnText(getConvertedStr(5, 10035)) --上阵
				self.pBtnUp:updateBtnType(TypeCommonBtn.M_BLUE)
			end
			self.pBtnUp:setBtnEnable(true)
		end
	else
		self.pBtnUp:setExTextLbCnCr(2,self.tData:getBaseTotalTalent())
		if self.tData:getExTotalTalent() > 0 then
			self.pBtnUp:setExTextLbCnCr(3,"+"..self.tData:getExTotalTalent())
		else
			self.pBtnUp:setExTextLbCnCr(3,"")
		end
	end

	--icon
	self.pIcon:setCurData(self.tData)
	self.pIcon:setHeroType()

	

	--新手引导上阵按钮
	doDelayForSomething(self, function()
		-- body
		sendMsg(ghd_guide_finger_show_or_hide, true)

		

		if self.nTarHeroId and self.tData.sTid == self.nTarHeroId then
			-- if self.tData.nKind == en_soldier_type.sowar then -- 骑将
				Player:getNewGuideMgr():setNewGuideFinger(self.pBtnUp, e_guide_finer.sowar_hero_online_btn)
			-- else
				Player:getNewGuideMgr():setNewGuideFinger(self.pBtnUp, e_guide_finer.online_btn)
			-- end

		end
		if self.nHeroIndex == 1 then
			Player:getNewGuideMgr():setNewGuideFinger(self.pBtnUp, e_guide_finer.first_select_hero)
		end
	end, 0.1)
end

-- 上阵点击响应
function ItemHeroArmy:onClicked(pView)
	-- if self.tData.nId then
		-- SocketManager:sendMsg("trainHero", {self.tData.nId,0})
	-- end

	--新手引导点击上阵完成
	if self.tData.nKind == en_soldier_type.sowar then -- 骑将
		Player:getNewGuideMgr():setNewGuideFingerClicked(e_guide_finer.sowar_hero_online_btn)
	else
		Player:getNewGuideMgr():setNewGuideFingerClicked(e_guide_finer.online_btn)
	end
	Player:getNewGuideMgr():setNewGuideFingerClicked(e_guide_finer.first_select_hero)

	if self.pHandler  then
		self.pHandler(self.tData)
	end
end

-- 上阵按钮回调
function ItemHeroArmy:setHandler(_handler)
	-- body
	if _handler then
		self.pHandler = _handler
	end
end

--析构方法
function ItemHeroArmy:onDestroy(  )
	-- body
end

--设置数据 _data
function ItemHeroArmy:setCurData(_tData, _nTarHeroId, nHeroIndex)
	if not _tData then
		return
	end

	self.tData = _tData or {}

	--指引英雄的id
	self.nTarHeroId = _nTarHeroId

	self.nHeroIndex = nHeroIndex

	self:updateViews()


end




return ItemHeroArmy