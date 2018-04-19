----------------------------------------------------- 
-- author: maheng
-- updatetime: 2017-06-07 10:33:14
-- Description: 国王
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local ItemResPrize = require("app.layer.task.ItemResPrize")
local KingLayer = class("KingLayer", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)


function KingLayer:ctor(  )
	-- body
	self:myInit()
	parseView("king_layer", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function KingLayer:myInit(  )
	-- body

end

--解析布局回调事件
function KingLayer:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("KingLayer",handler(self, self.onKingLayerDestroy))
end

--初始化控件
function KingLayer:setupViews( )
	-- body
	self.pLayRoot = self:findViewByName("root")
	self.pLayCont = self:findViewByName("lay_content")
	self.pLbKing = self:findViewByName("lb_king")
	setTextCCColor(self.pLbKing, _cc.yellow)
	self.pLbKing:setString(getConvertedStr(6, 10326)..getLvString(0, true), false)

	self.pLbTip1 = self:findViewByName("Lb_tip_1")
	setTextCCColor(self.pLbTip1, _cc.pwhite)
	self.pLbTip1:setString(getTipsByIndex(10046), false)

	self.pLayIcon = self:findViewByName("lay_icon")	

	-- self.pLbTip2 = self:findViewByName("lb_tip_2")
	-- setTextCCColor(self.pLbTip2, _cc.pwhite)
	-- self.pLbTip2:setString(getConvertedStr(6, 10327), false)

	self.pLbNumber = self:findViewByName("lb_number")
	-- setTextCCColor(self.pLbNumber, _cc.blue)
	-- self.pLbNumber:setString("9999", false)	

	self.pLayTip = self:findViewByName("lay_tip")
	self.pLbTip3 = self:findViewByName("lb_tip_3")
	setTextCCColor(self.pLbTip3, _cc.pwhite)
	self.pLbTip3:setString(getConvertedStr(6, 10329), false)

	local tItems = luaSplitMuilt(getCountryParam("worshipOb"), ";", ":")	
	local x = self.pLbTip3:getPositionX() --+ self.pLbTip1:getWidth()
	local y = self.pLbTip3:getPositionY()
	for i = 1, #tItems do
		local tRes = tItems[i]
		local pResData = getGoodsByTidFromDB(tRes[1])
		if pResData then
			pResData.nCt = tonumber(tRes[2] or 0)
			local pItemResPrize = ItemResPrize.new(true)				
			pItemResPrize:setCurData(pResData)
			pItemResPrize:setPosition(x + (i-1)*(pItemResPrize:getWidth() + 20), y - pItemResPrize:getHeight()/2)
			self.pLayTip:addView(pItemResPrize, 10)	
		end
	end		

	self.pLayBtn = self:findViewByName("lay_btn")
	self.pBtn = getCommonButtonOfContainer(self.pLayBtn, TypeCommonBtn.M_BLUE, getConvertedStr(6, 10331), true)
	self.pBtn:onCommonBtnClicked(handler(self, self.onWorshipBtnClicked))

	self.pLbDef = self:findViewByName("lb_def")
	self.pLbDef:setString(getTipsByIndex(529), false)
	setTextCCColor(self.pLbDef, _cc.pwhite)

	self.pLayRed = self:findViewByName("lay_red")

end

-- 修改控件内容或者是刷新控件数据
function KingLayer:updateViews( )
	-- body	
	local tCountryDatavo = Player:getCountryData():getCountryDataVo()
	if tCountryDatavo:isHaveKing() == true then
		self.pLayCont:setVisible(true)
		self.pLbDef:setVisible(false)
		self.pLbKing:setString(getConvertedStr(6, 10326)..tCountryDatavo.tKingVo.sKName..getLvString(tCountryDatavo.tKingVo.nKLv), false)
		
		local data = Player:getCountryData():getPosterByOfficial(e_official_ids.king)
		if data then
			data.nGtype = e_type_goods.type_head --头像
		end
		-- data.sIcon = tCountryDatavo.tKingVo.sKIcon
		-- data.nQuality = 100
		local pIconHero = getIconGoodsByType(self.pLayIcon, TypeIconHero.NORMAL,type_icongoods_show.header, data, TypeIconHeroSize.M)
		pIconHero:setIconIsCanTouched(false)
		
	-- self.pLbTip2 = self:findViewByName("lb_tip_2")
	-- setTextCCColor(self.pLbTip2, _cc.pwhite)
	-- self.pLbTip2:setString(getConvertedStr(6, 10327), false)

	-- self.pLbNumber = self:findViewByName("lb_number")
	-- setTextCCColor(self.pLbNumber, _cc.blue)
	-- self.pLbNumber:setString("9999", false)	
		local sStr = {
			{color=_cc.pwhite, text=getConvertedStr(6, 10327)},
			{color=_cc.blue, text=tCountryDatavo.nWorship},
		}		
		self.pLbNumber:setString(sStr, false)
		local ishadworship = tCountryDatavo:isHadWorship()
		if ishadworship == true then--已经膜拜
			self.pBtn:setBtnEnable(false)
			self.pBtn:updateBtnText(getConvertedStr(6, 10377))
		else--未膜拜
			self.pBtn:setBtnEnable(true)
			self.pBtn:updateBtnText(getConvertedStr(6, 10331))
			self.pLbTip3:setPositionY(self.pLayTip:getHeight()/2)
		end
	else
		local data = {}
		data.nGtype = e_type_goods.type_head --头像
		data.sIcon = "ui/daitu.png"
		data.nQuality = 100		
		local pIconHero = getIconGoodsByType(self.pLayIcon, TypeIconHero.NORMAL,type_icongoods_show.item, data, TypeIconHeroSize.M)
		pIconHero:setIconIsCanTouched(false)
				
		self.pLayCont:setVisible(false)
		self.pLbDef:setVisible(true)
	end		
	showRedTips(self.pLayRed, 0, Player:getCountryData():getMobaiRedNum())
end

-- 析构方法
function KingLayer:onKingLayerDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function KingLayer:regMsgs(  )
	-- body
	--注册国家界面刷新消息
	regMsg(self, gud_refresh_country_msg, handler(self, self.updateViews))	
	--注册国家膜拜红点消息
	regMsg(self, ghd_mobai_red_msg, handler(self, self.updateViews))
	--注册国家官员刷新消息
	regMsg(self, gud_refresh_country_official_msg, handler(self, self.updateViews))	
end
--注销消息
function KingLayer:unregMsgs(  )
	-- body
	--注销国家界面刷新消息
	unregMsg(self, gud_refresh_country_msg)
	--注销国家膜拜红点消息
	unregMsg(self, ghd_mobai_red_msg)
	--注销国家官员刷新消息
	unregMsg(self, gud_refresh_country_official_msg)	
end

--暂停方法
function KingLayer:onPause( )
	-- body
	self:unregMsgs()	
end

--继续方法
function KingLayer:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

--膜拜按钮回调
function KingLayer:onWorshipBtnClicked( pView )
	-- body	
	SocketManager:sendMsg("worshipKing", {})	
end
return KingLayer


