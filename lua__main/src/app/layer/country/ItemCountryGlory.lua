----------------------------------------------------- 
-- author: maheng
-- updatetime: 2017-06-06 19:48:14
-- Description: 国家界面快速入口
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")

local ItemCountryGlory = class("ItemCountryGlory", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)


function ItemCountryGlory:ctor(  )
	-- body
	self:myInit()
	parseView("item_country_glory", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function ItemCountryGlory:myInit(  )
	-- body
	self.pCurData = nil
end

--解析布局回调事件
function ItemCountryGlory:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("ItemCountryGlory",handler(self, self.onItemCountryGloryDestroy))
end

--初始化控件
function ItemCountryGlory:setupViews( )
	-- body
	self.pLayRooc = self:findViewByName("root")
	self.pLayIcon = self:findViewByName("lay_icon")
	self.pIcon = getIconGoodsByType(self.pLayIcon, TypeIconGoods.NORMAL, type_icongoods_show.itemnum, nil)

	self.pLbTarget = self:findViewByName("lb_target")
	setTextCCColor(self.pLbTarget, _cc.yellow)
	self.pLbTarget:setString(getConvertedStr(6, 10353))

	self.pLbTip1 = self:findViewByName("lb_param_1")
	setTextCCColor(self.pLbTip1, _cc.pwhite)
	self.pLbTip1:setString(getConvertedStr(6, 10354))

	self.pLbTip2 = self:findViewByName("lb_param_2")
	setTextCCColor(self.pLbTip2, _cc.pwhite)
	self.pLbTip2:setString(getConvertedStr(6, 10355))

	self.pLbTip3 = self:findViewByName("lb_param_3")
	setTextCCColor(self.pLbTip3, _cc.pwhite)
	self.pLbTip3:setString(getConvertedStr(6, 10356))

	self.pImgGet = self:findViewByName("img_get")

	-- self.pLbNum1 = self:findViewByName("lb_num_1")
	-- setTextCCColor(self.pLbNum1, _cc.green)
	-- self.pLbTargetNum1 = self:findViewByName("lb_targetnum_1")
	-- setTextCCColor(self.pLbTargetNum1, _cc.pwhite)

	-- self.pLbNum2 = self:findViewByName("lb_num_2")
	-- setTextCCColor(self.pLbNum2, _cc.green)
	-- self.pLbTargetNum2 = self:findViewByName("lb_targetnum_2")
	-- setTextCCColor(self.pLbTargetNum2, _cc.pwhite)

	-- self.pLbNum3 = self:findViewByName("lb_num_3")
	-- setTextCCColor(self.pLbNum3, _cc.green)
	-- self.pLbTargetNum3 = self:findViewByName("lb_targetnum_3")
	-- setTextCCColor(self.pLbTargetNum3, _cc.pwhite)

	self.pLayBtn = self:findViewByName("lay_btn")
	self.pBtn =	getCommonButtonOfContainer(self.pLayBtn, TypeCommonBtn.M_YELLOW, getConvertedStr(6, 10217))
	self.pBtn:onCommonBtnClicked(handler(self, self.onBtnClicked))

end

-- 修改控件内容或者是刷新控件数据
function ItemCountryGlory:updateViews( )
	-- body

	if self.pCurData then
		local snum = "一"
		if self.pCurData.sTid == 1 then
			snum = "一"
		elseif self.pCurData.sTid == 2 then
			snum = "二"
		elseif self.pCurData.sTid == 3 then
			snum = "三"
		end
		--dump(self.pCurData, "self.pCurData", 100)
		local paward = getDropById(self.pCurData.nAward)
		
		self.pIcon:setCurData(paward[1])
		self.pLbTarget:setString(getConvertedStr(6, 10353)..snum)

		local sColor1 = _cc.green
		if Player:getCountryData().nCityFightTime < self.pCurData.nCastleFight then
			sColor1 = _cc.red
		end
		local sStr1 = {
			{color=_cc.pwhite,text=getConvertedStr(6, 10354)},
			{color=sColor1,text=Player:getCountryData().nCityFightTime},
			{color=_cc.pwhite,text="/"..self.pCurData.nCastleFight}, 
		}
		self.pLbTip1:setString(sStr1, false)

		local sColor2 = _cc.green
		if Player:getCountryData().nCountryFightTime < self.pCurData.nCountryFight then
			sColor2 = _cc.red			
		end
		local sStr2 = {
			{color=_cc.pwhite,text=getConvertedStr(6, 10355)},
			{color=sColor2,text=Player:getCountryData().nCountryFightTime},
			{color=_cc.pwhite,text="/"..self.pCurData.nCountryFight}, 
		}
		self.pLbTip2:setString(sStr2, false)

		local sColor3 = _cc.green
		if Player:getCountryData().nSd < self.pCurData.nScience then
			sColor3 = _cc.red
		end
		local sStr3 = {
			{color=_cc.pwhite,text=getConvertedStr(6, 10356)},
			{color=sColor3,text=Player:getCountryData().nSd},
			{color=_cc.pwhite,text="/"..self.pCurData.nScience}, 
		}
		self.pLbTip3:setString(sStr3, false)		
		--未达成

		if self.pCurData:isHaveGetAward() == true then
			self.pBtn:setBtnEnable(false)
			self.pBtn:setVisible(false)
			self.pImgGet:setCurrentImage("#v2_fonts_yilingqu.png")
			self.pImgGet:setVisible(true)
		else				
			if self.pCurData.bIsFinished == false then
				-- self.pBtn:setBtnEnable(false)
				-- self.pBtn:updateBtnText(getConvertedStr(6, 10396))
				self.pBtn:setVisible(false)
				self.pImgGet:setCurrentImage("#v2_fonts_weidadao.png")
				self.pImgGet:setVisible(true)
			else		
				self.pBtn:setBtnEnable(true)
				self.pBtn:setVisible(true)
				self.pImgGet:setVisible(false)
				self.pBtn:updateBtnText(getConvertedStr(6, 10217))
			end
		end
	end
end

-- 析构方法
function ItemCountryGlory:onItemCountryGloryDestroy(  )
	-- body
end

function ItemCountryGlory:onBtnClicked( pview )
	-- body
	if self.pCurData then
		local id = tonumber(self.pCurData.sTid)
		SocketManager:sendMsg("getHonorTaskPrize", {id})			
	end
end

function ItemCountryGlory:setCurData( _data )
	-- body
	self.pCurData = _data or self.pCurData
	self:updateViews()
end
return ItemCountryGlory


