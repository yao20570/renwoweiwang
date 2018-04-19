--
-- Author: maheng
-- Date: 2017-06-29 11:30:29
-- 活动排行前三名卡片

local MCommonView = require("app.common.MCommonView")
local ActorVo = require("app.layer.playerinfo.ActorVo")
local ItemActCard = class("ItemActCard", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--创建函数
function ItemActCard:ctor(Idx)
	-- body
	self:myInit(Idx)

	parseView("item_rank_topthree", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("ItemActCard",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemActCard:myInit(Idx)
	self.nIndex = Idx or 1 
	self.pData = nil --数据
	self.pArenaData = nil
	self.sInfoIdx = nil
	self.sTip = nil
end

--解析布局回调事件
function ItemActCard:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)
	self:setupViews()
	self:updateViews()
end

--初始化控件
function ItemActCard:setupViews( )
	--ly 
	self.pLayRoot = self:findViewByName("root")
	self.pLayIcon = self:findViewByName("lay_icon")	 
	self.pLbNoneTip = self:findViewByName("lb_none_tip")	 	
    self.pLbNoneTip:setString(getConvertedStr(10, 90003))
    self.pLbNoneTip:setVisible(false)
	--lb
	self.pLbName = self:findViewByName("lb_name")
	setTextCCColor(self.pLbName, _cc.yellow)
	self.pLbNum = self:findViewByName("lb_num")
	--img
	self.pImgFlag = self:findViewByName("img_flag")--国家
	self.pImgRank =  self:findViewByName("img_rank")--排名1,2,3
	self.pImgRank:setScale(0.8)
	self:setViewTouched(true)
	self:setIsPressedNeedScale(false)
	self:onMViewClicked(handler(self, self.jumpToPlayerInfo))
	self:resizeImg()

	self.nClickHandler = nil
end

-- 修改控件内容或者是刷新控件数据
function ItemActCard:updateViews(  )
	-- body
	if self.pData then
		-- dump(self.pData, "self.pData", 10)
		local data = ActorVo.new()
		-- data.nGtype = e_type_goods.type_head --头像
		-- data.sIcon = self.pData.p
		-- data.nQuality = 100
		data:initData(self.pData.p, self.pData.box, self.pData.tit)
		local pIconHero = getIconGoodsByType(self.pLayIcon, TypeIconHero.NORMAL,type_icongoods_show.header, data, TypeIconHeroSize.M)
		pIconHero:setIconIsCanTouched(false)

		self.pLbName:setString(self.pData["n"])
		self.pImgFlag:setCurrentImage(WorldFunc.getCountryFlagImg(self.pData["c"])) 
		self.pLbNum:setVisible(true)
		self.pImgFlag:setVisible(true)
        self.pLbNoneTip:setVisible(false)

		if self.sTip and self.sInfoIdx then			
			if self.sInfoIdx == "jw" then--爵位
				local nLv = self.pData[self.sInfoIdx] or 1
				local pBanneret = getBanneretByLv(nLv)
				local sNo = ""
				if pBanneret then
					sNo = pBanneret.name
				else
					sNo = getConvertedStr(3, 10139)
				end
				local tStr = {
					{color=_cc.pwhite, text=self.sTip},
					{color=_cc.blue, text=sNo},
				}
				self.pLbNum:setString(tStr, false)	
			else
				local nNum = self.pData[self.sInfoIdx] or 0
				local sNum = ""
				if nNum then
					if nNum >= 10000 then
						sNum = formatCountToStr(nNum)
					else
						sNum = tostring(nNum)
					end
				end	
				local tStr = {
					{color=_cc.pwhite, text=self.sTip},
					{color=_cc.blue, text=sNum},
				}
				self.pLbNum:setString(tStr, false)				
			end			
		else
			self.pLbNum:setString("", false)
		end
	elseif self.pArenaData then
		local data = ActorVo.new()
		data:initData(self.pArenaData.icon, self.pArenaData.box, nil)
		local pIconHero = getIconGoodsByType(self.pLayIcon, TypeIconHero.NORMAL,type_icongoods_show.header, data, TypeIconHeroSize.M)
		pIconHero:setIconIsCanTouched(false)		
		self.pLbName:setString(self.pArenaData.name)		
		self.pImgFlag:setCurrentImage(WorldFunc.getCountryFlagImg(self.pArenaData.country))
		local nNum = self.pArenaData.score or 0
		local sNum = ""
		if nNum then
			if nNum >= 10000 then
				sNum = formatCountToStr(nNum)
			else
				sNum = tostring(nNum)
			end
		end		
		local tStr = {
			{color=_cc.pwhite, text=getConvertedStr(6, 10240)},
			{color=_cc.blue, text=sNum},
		}
		self.pLbNum:setString(tStr, false)			 
		self.pLbNum:setVisible(true)
		self.pImgFlag:setVisible(true)
        self.pLbNoneTip:setVisible(false)        	
	else
		self.pLbNum:setVisible(false)
		self.pImgFlag:setVisible(false)
        self.pLbNoneTip:setVisible(true)

		-- local data = {}
		-- data.nGtype = e_type_goods.type_head --头像
		-- data.sIcon = "ui/daitu.png"
		-- data.nQuality = 100	
		local data = ActorVo.new()	
		local pIconHero = getIconGoodsByType(self.pLayIcon, TypeIconHero.NORMAL,type_icongoods_show.header, data, TypeIconHeroSize.M)
		pIconHero:setIconIsCanTouched(false)
		self.pLbName:setString("")
	end
end

-- 
function ItemActCard:setShowInfoIndex( sTip, sindex )
	-- body
	self.sTip = sTip or nil	
	self.sInfoIdx = sindex or nil
end
--竞技场专属
function ItemActCard:setArenaClickHandler( _nHandler )
	-- body
	if not _nHandler then
		return
	end
	self.nClickHandler = _nHandler
end

--析构方法
function ItemActCard:onDestroy(  )
	-- body
end

--设置数据 _data
function ItemActCard:setCurData(_tData)
	self.pData = _tData or nil
	self:updateViews()
end
--竞技场排行专用
function ItemActCard:setArenaData(_tData)
	self.pArenaData = _tData or nil
	self:updateViews()
end

function ItemActCard:resizeImg(  )
	-- body
	local nbgH = 0	
	if self.nIndex == 1 then
		self.pImgRank:setCurrentImage("#v1_img_paixingbang1.png")
		self.pLayRoot:setBackgroundImage("#v2_img_jinq.png")
	elseif self.nIndex == 2 then
		self.pImgRank:setCurrentImage("#v1_img_paixingbang2.png")
		self.pLayRoot:setBackgroundImage("#v2_img_yinq.png")
	elseif self.nIndex == 3 then
		self.pImgRank:setCurrentImage("#v1_img_paixingbang3.png")
		self.pLayRoot:setBackgroundImage("#v2_img_tongq.png")
	end	
end

--icon点击响应
function ItemActCard:jumpToPlayerInfo( pView )
	-- body
	if self.pData and self.pData.i then
		local pMsgObj = {}
		pMsgObj.nplayerId = self.pData.i
		pMsgObj.bToChat = false
		--发送获取其他玩家信息的消息
		sendMsg(ghd_get_playerinfo_msg, pMsgObj)
	else
		if self.nClickHandler then
			self.nClickHandler(self.pArenaData)
		end
	end
end

--
function ItemActCard:setPlayerCardTouched( _btouched )
	-- body
	local bTouched = _btouched or false
	self:setViewTouched(bTouched)
end
return ItemActCard