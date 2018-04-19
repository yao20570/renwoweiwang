-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-06-15 15:10:23 星期四
-- Description: 国家界面
-----------------------------------------------------

local MDialog = require("app.common.dialog.MDialog")
local ItemCountryLog = require("app.layer.country.ItemCountryLog")

local DlgChoiceCountry = class("DlgChoiceCountry", function()
	-- body
	return MDialog.new(e_dlg_index.dlgchoicecountry)
end)

function DlgChoiceCountry:ctor( nCallBackFunc )
	self.nCallBackFunc = nCallBackFunc
	-- body
	self:myInit()
	parseView("dlg_choice_country", handler(self, self.onParseViewCallback))
end

function DlgChoiceCountry:myInit(  )
	-- body
	self.nDefInfluence = Player:getPlayerInfo().nWeakInfluence
	self.nChoice = Player:getPlayerInfo().nWeakInfluence
	self.nType = 0
	self.pLayEffect = nil
	self.pImgTx = nil
	NEW_ROLE = true -- 记录为新创角色
end

--解析布局回调事件
function DlgChoiceCountry:onParseViewCallback( pView )
	self:setContentView(pView) --加入内容层
	self:setupViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("DlgChoiceCountry",handler(self, self.onDlgChoiceCountryDestroy))
end

--初始化控件
function DlgChoiceCountry:setupViews(  )	
	-- body	
	self.pLayRoot = self:findViewByName("root")
	self.pLayRoot:setScale(display.width/self.pLayRoot:getWidth(), display.height/self.pLayRoot:getHeight())
	--设置标题
	local pTxtTitle = self:findViewByName("txt_title")
	pTxtTitle:setString(getConvertedStr(6, 10412))

	local pImgBack = self:findViewByName("img_back")
	pImgBack:setViewTouched(true)
	pImgBack:onMViewClicked(handler(self, self.onUpLayerClicked))

	self.pLayBot = self:findViewByName("lay_bot")

	self.pImgBg = self:findViewByName("img_bg")

	self.pImgChu = self:findViewByName("img_chu")
    self.pLayChu = self:findViewByName("lay_chu")
	self.pLayChu:setViewTouched(true)
	self.pLayChu:onMViewClicked(function ( pview )
		self.nChoice = e_type_country.wuguo					
		self:updateViews()	
		self:updateEffect(self.pImgChu)
    end)
    
	self.pImgHan = self:findViewByName("img_han")
    self.pLayHan = self:findViewByName("lay_han")
	self.pLayHan:setViewTouched(true)
	self.pLayHan:onMViewClicked(function ( pview )
		self.nChoice = e_type_country.shuguo
		self:updateViews()	
		self:updateEffect(self.pImgHan)
    end)	
    
	self.pImgQin = self:findViewByName("img_qin")
    self.pLayQin = self:findViewByName("lay_qin")
	self.pLayQin:setViewTouched(true)
	self.pLayQin:onMViewClicked(function ( pview )
		self.nChoice = e_type_country.weiguo		
		self:updateViews()
		self:updateEffect(self.pImgQin)		
    end)			

    self.pLayEffect = self:findViewByName("lay_effect")   
    self.pLayEffect:setVisible(false) 

	-- self.pLbTip1 = self:findViewByName("lb_tip_1")
	-- local tStr = {
 --    	{color=_cc.white,text=getConvertedStr(6, 10414)},
 --    	{color=_cc.yellow,text="200"},
	--     {color=_cc.white,text=getConvertedStr(6, 10415)},
	--     {color=_cc.white,text=getConvertedStr(6, 10416)},
	-- }
	-- self.pLbTip1:setString(tStr, false)

	local strprize = {
		{color=_cc.white, text=getConvertedStr(6, 10416)},
		{color=_cc.yellow,text="200"},
		{color=_cc.white, text=getConvertedStr(6, 10415)},
	}
	self.pLbPrize = self:findViewByName("lb_prize")
	self.pLbPrize:setString(strprize, false)
	if self.nDefInfluence == e_type_country.weiguo then
		self.pLbPrize:setPositionX(self.pLayQin:getPositionX() + self.pLayQin:getWidth() / 2)	
	elseif self.nDefInfluence == e_type_country.shuguo then
		self.pLbPrize:setPositionX(self.pLayHan:getPositionX() + self.pLayQin:getWidth() / 2)		
	elseif self.nDefInfluence == e_type_country.wuguo then
		self.pLbPrize:setPositionX(self.pLayChu:getPositionX() + self.pLayQin:getWidth() / 2)			
	end
	
	self.pLayBtn = self:findViewByName("lay_btn")
	self.pBtnUpLayer = getCommonButtonOfContainer(self.pLayBtn, TypeCommonBtn.L_BLUE, getConvertedStr(6, 10413), false)
	self.pBtnUpLayer:onCommonBtnClicked(handler(self, self.requestChoiceCountry))

	self.pImgNpc = self:findViewByName("img_npc")

	self.pLbTip1 = self:findViewByName("lb_tip_1")
	self.pLbTip1:setString(getConvertedStr(6, 10493))
	setTextCCColor(self.pLbTip1, _cc.yellow)

	self.pImgArrow = self:findViewByName("img_arrow")
	self.pImgArrow:setVisible(false)
	-- self.pImgArrow:setViewTouched(false)
	-- self.pImgArrow:onMViewClicked(handler(self, self.gotoHomeView))

	self.pLbTip3 = MUI.MLabel.new({
        text="",
        size=20,
        anchorpoint=cc.p(0.5, 0.5),
        dimensions = cc.size(600, 0),
        })
	self.pLbTip3:setPosition(320, 180)
	
	self.pLayBot:addView(self.pLbTip3, 10)
	self.pLayBtn = self:findViewByName("lay_btn")
	self.pBtnUpLayer = getCommonButtonOfContainer(self.pLayBtn, TypeCommonBtn.L_BLUE, getConvertedStr(6, 10413), false)
	self.pBtnUpLayer:onCommonBtnClicked(handler(self, self.requestChoiceCountry))	

	-- self:createEffect()
end

--控件刷新
function DlgChoiceCountry:updateViews(  )
	-- body		
	local tTmp = nil	
	if self.nChoice == e_type_country.weiguo then
		self.pBtnUpLayer:updateBtnText(getConvertedStr(6, 10489))
		self.pImgNpc:setCurrentImage("ui/bg_guide/v1_img_qinqinshihuang.png")
		self.pLbTip1:setString(getConvertedStr(6, 10493), false)
		tTmp = luaSplit(getTipsByIndex(10056),";")
		self.pImgQin:setScale(1)
		self.pImgHan:setScale(0.8)
		self.pImgChu:setScale(0.8)
	elseif self.nChoice == e_type_country.shuguo then
		self.pBtnUpLayer:updateBtnText(getConvertedStr(6, 10490))
		self.pImgNpc:setCurrentImage("ui/bg_guide/v1_img_hanliubang.png")		
		self.pLbTip1:setString(getConvertedStr(6, 10508), false)		
		tTmp = luaSplit(getTipsByIndex(10057),";")	
		self.pImgQin:setScale(0.8)
		self.pImgHan:setScale(1)
		self.pImgChu:setScale(0.8)			
	elseif self.nChoice  == e_type_country.wuguo then
		self.pBtnUpLayer:updateBtnText(getConvertedStr(6, 10491))
		self.pImgNpc:setCurrentImage("ui/bg_guide/v1_img_chuxiangyu.png")	
		self.pLbTip1:setString(getConvertedStr(6, 10509), false)			
		tTmp = luaSplit(getTipsByIndex(10058),";")	
		self.pImgQin:setScale(0.8)
		self.pImgHan:setScale(0.8)
		self.pImgChu:setScale(1)			
	end	
	self.pLbPrize:setVisible(self.nChoice == self.nDefInfluence)
	local tStr = {}	
	for i = 1, #tTmp do
		local t = luaSplit(tTmp[i], ":")
		local clr = t[2] or _cc.pwhite
		local txt = t[1] or ""
		table.insert(tStr, {color=clr,text=txt})
	end	
	self.pLbTip3:setString(tStr, false)
end
function DlgChoiceCountry:createEffect(  )
	-- body
	if not self.pImgTx  then
		self.pImgTx = MUI.MImage.new("#sg_xzgj_tx_001.png", {scale9=false})	
		self.pLayRoot:addView(self.pImgTx, 5)	
	end	
	local pView = self.pLayQin
	if self.nDefInfluence == e_type_country.weiguo then		
		self.pImgTx:setPosition(self.pLayQin:getPosition())
		pView = self.pLayQin
	elseif self.nDefInfluence == e_type_country.shuguo then		
		self.pImgTx:setPosition(self.pLayHan:getPosition())	
		pView = self.pLayHan	
	elseif self.nDefInfluence == e_type_country.wuguo then
		self.pImgTx:setPosition(self.pLayChu:getPosition())	
		pView = self.pLayChu
	end		
	-- self.pLayEffect:setBackgroundImage(getBigCountryFlagImg2(self.nDefInfluence))
	-- self.pLayEffect:setPosition(pView:getPositionX() - pView:getWidth()/2, pView:getPositionY() - pView:getHeight()/2)
end

--更新特效
function DlgChoiceCountry:updateEffect( pView )
	-- body
	--print(getBigCountryFlagImg2(self.nDefInfluence))
	-- self.pLayEffect:setBackgroundImage(getBigCountryFlagImg2(self.nDefInfluence))
	-- self.pImgTx:setPosition(pView:getPosition())
	-- self.pLayEffect:setPosition(pView:getPositionX() - pView:getWidth()/2, pView:getPositionY() - pView:getHeight()/2)
end

--析构方法
function DlgChoiceCountry:onDlgChoiceCountryDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgChoiceCountry:regMsgs(  )
	-- body
end
--注销消息
function DlgChoiceCountry:unregMsgs(  )
	-- body
end

--暂停方法
function DlgChoiceCountry:onPause( )
	-- body
	self:unregMsgs()	
end

--继续方法
function DlgChoiceCountry:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

--请求选择国家
function DlgChoiceCountry:requestChoiceCountry( )
	-- body
	if self.nChoice == self.nDefInfluence then
		self.nType = 1
	else
		self.nType = 0
	end
	SocketManager:sendMsg("choiceCountry", {self.nChoice, self.nType} ,handler(self, self.choiceCountryFunc))	
end

function DlgChoiceCountry:choiceCountryFunc( __msg )	
	if  __msg.head.state == SocketErrorType.success then 
		-- --显示箭头
		-- self.pImgArrow:setVisible(true)
		-- --self.pImgArrow:setViewTouched(true)
		-- --按钮隐藏
		-- self.pBtnUpLayer:setVisible(false)
		-- --选择国家点击屏蔽
		-- self.pImgChu:setViewTouched(false)
		-- self.pImgHan:setViewTouched(false)
		-- self.pImgQin:setViewTouched(false)		
		-- if __msg.body.c then
		-- 	self.nDefInfluence = __msg.body.c
		-- 	self:updateViews()
		-- 	-- self.pLbTip3:setString(getTipsByIndex(20005), false)
		-- 	-- setTextCCColor(self.pLbTip3, _cc.pwhite)
		-- end
		-- --设置全界面点击响应
		-- self.pLayRoot:setViewTouched(true)
		-- self.pLayRoot:onMViewClicked(handler(self,self.gotoHomeView))
		self:gotoHomeView()
		-- 玩家创角统计
		doSummitData3k(2)
		--请求相关世界数据
		local tMulitProto = 
		{	
			{sProto = "reqWorldCityData", tParam = {}},
			{sProto = "reqWorldMyCountryWar", tParam = {}},
			{sProto = "reqWorldCityWarInfo", tParam = {Player:getPlayerInfo().pid}},
			{sProto = "reqFriendArmys", tParam = {}},
			{sProto = "reqEpwLine", tParam = {}}
		}
		sendMsg(ghd_mulit_proto_list_req, tMulitProto)
		
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))
	end
end

function DlgChoiceCountry:onUpLayerClicked(  )
	AccountCenter.backToLoginScene(2)
end
--
function DlgChoiceCountry:gotoHomeView(  )
	-- body
	if self.nCallBackFunc then
		self.nCallBackFunc()
	end
	self:closeDlg(false)
	sendMsg(ghd_do_logined_logic)	
end
return DlgChoiceCountry