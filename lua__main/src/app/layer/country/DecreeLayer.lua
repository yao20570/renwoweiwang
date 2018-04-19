----------------------------------------------------- 
-- author: maheng
-- updatetime: 2017-06-07 10:31:14
-- Description: 圣旨
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")

local DecreeLayer = class("DecreeLayer", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)


function DecreeLayer:ctor(  )
	-- body
	self:myInit()
	parseView("decree_layer", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DecreeLayer:myInit(  )
	-- body

end

--解析布局回调事件
function DecreeLayer:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DecreeLayer",handler(self, self.onDecreeLayerDestroy))
end

--初始化控件
function DecreeLayer:setupViews( )
	-- body
	self.pLayRoot = self:findViewByName("root")
	self.pLbTip = self:findViewByName("lb_tip")	
	setTextCCColor(self.pLbTip, _cc.yellow)	
	self.pLbTip:setString(getConvertedStr(6, 10324))
	--书写

	self.pLayBottom = self:findViewByName("lay_bottom")
	self.pLayBtn = self:findViewByName("lay_btn")
	self.pBtn = getCommonButtonOfContainer(self.pLayBtn, TypeCommonBtn.M_BLUE, getConvertedStr(6, 10328), true)
	self.pBtn:onCommonBtnClicked(handler(self, self.onShuxieClicked))
	-- self.pImgShuxie = self:findViewByName("img_shuxie")
	-- self.pImgShuxie:setViewTouched(true)
	-- self.pImgShuxie:setIsPressedNeedScale(false)
	-- self.pImgShuxie:onMViewClicked(handler(self, self.onShuxieClicked))
	--文字内容层
	self.pLayContent = self:findViewByName("lay_content")	
	self.pLbContent = MUI.MLabel.new({
		    text = "",
		    size = 20,
		    anchorpoint = cc.p(0, 1),
		    align = cc.ui.TEXT_ALIGN_LEFT,
    		valign = cc.ui.TEXT_VALIGN_TOP,
		    color = cc.c3b(255, 255, 255),
		    dimensions = cc.size(350, 0),
		    })	
	self.pLayContent:addView(self.pLbContent, 10)
	self.pLbContent:setPosition(45, self.pLayContent:getHeight() - 50)

	local sStrDef = getTextColorByConfigure(getTipsByIndex(10014))
	self.pLbDef = MUI.MLabel.new({
		    text = "",
		    size = 20,
		    anchorpoint = cc.p(0.5, 0.5),
		    align = cc.ui.TEXT_ALIGN_LEFT,
    		valign = cc.ui.TEXT_VALIGN_TOP,
		    color = cc.c3b(255, 255, 255),
		    dimensions = cc.size(350, 0),
		    })	
	self.pLbDef:setString(sStrDef, false)
	self.pLbDef:setPosition(self.pLayContent:getWidth()/2, self.pLayContent:getHeight()/4*3)
	self.pLayContent:addView(self.pLbDef, 10)
	--centerInView(self.pLayContent, self.pLbDef)
	--印章
	self.pImgYinzhang = self:findViewByName("img_yinzhang")
	--国王标签
	--self.pLbTip1 = self:findViewByName("lb_tip_1") 
	-- self.pLbTip1:setString(getConvertedStr(6, 10326))
	-- setTextCCColor(self.pLbTip1, _cc.pwhite)
	--国王名称
	self.pLbKingName = self:findViewByName("lb_kingname")
	setTextCCColor(self.pLbKingName, _cc.pwhite)	
	--时间
	self.pLbDate = self:findViewByName("lb_time")
	setTextCCColor(self.pLbDate, _cc.pwhite)
	self.pLbDate:setString(formatTimeYMD(0))
end

-- 修改控件内容或者是刷新控件数据
function DecreeLayer:updateViews( )
	-- body
	local tCountryDatavo = Player:getCountryData():getCountryDataVo()
	--dump(tCountryDatavo, "tCountryDatavo", 100)
	if tCountryDatavo:isHaveKing() == true then
		local sStr = {
			{color=_cc.pwhite,text=getConvertedStr(6, 10326)},
			{color=_cc.pwhite,text=tCountryDatavo.tKingVo.sKName}
		}
		self.pLbKingName:setString(sStr, false)
		self.pLbDate:setString(formatTimeYMD(tCountryDatavo.nAfficheTime), false)
		self.pLbDate:setVisible(true)	
		
		self.pLbDef:setVisible(false)	
		--圣旨更新
		self.pLbContent:setVisible(true)
		self.pLbContent:setString("    "..tCountryDatavo.sAffiche, false)
		
	else		
		self.pLbKingName:setString(getConvertedStr(3, 10139), false)
		self.pLbDate:setVisible(false)		
		self.pLbDef:setVisible(true)
		self.pLbContent:setVisible(false)
	end
	if tCountryDatavo:isKing() == true then--当前玩家是国王
		--self.pImgShuxie:setVisible(true)
		self.pLayBottom:setVisible(true)
	else
		self.pLayBottom:setVisible(false)
		--self.pImgShuxie:setVisible(false)
	end
end

-- 析构方法
function DecreeLayer:onDecreeLayerDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DecreeLayer:regMsgs(  )
	-- body
	--注册国家界面刷新消息
	regMsg(self, gud_refresh_country_msg, handler(self, self.updateViews))	
end
--注销消息
function DecreeLayer:unregMsgs(  )
	-- body
	--注销国家界面刷新消息
	unregMsg(self, gud_refresh_country_msg)
end

--暂停方法
function DecreeLayer:onPause( )
	-- body
	self:unregMsgs()	
end

--继续方法
function DecreeLayer:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

--书写图标点击回调
function DecreeLayer:onShuxieClicked( pview )
	-- body
	local tCountryDatavo = Player:getCountryData():getCountryDataVo()
	local ntimes = tonumber(getCountryParam("maxModifyNoticeTimes"))
	local nleft = ntimes - tCountryDatavo.nAfficheCnt
	if nleft > 0 then
		local tObject = {}
		tObject.nType = e_dlg_index.dlgsenddecree --dlg类型
		sendMsg(ghd_show_dlg_by_type,tObject)	
	else
		TOAST(getConvertedStr(6, 10467))
	end		
end
return DecreeLayer


