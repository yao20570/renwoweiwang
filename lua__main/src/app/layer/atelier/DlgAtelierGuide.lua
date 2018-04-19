-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-05-08 19:28:23 星期一
-- Description: 工坊预约生产界面
-----------------------------------------------------

local MDialog = require("app.common.dialog.MDialog")

local DlgAtelierGuide = class("DlgAtelierGuide", function()
	-- body
	return MDialog.new(e_dlg_index.atelierguide)
end)

function DlgAtelierGuide:ctor(  )
	-- body
	self:myInit()
	parseView("dlg_guide", handler(self, self.onParseViewCallback))
end

function DlgAtelierGuide:myInit(  )
	-- body

end

--解析布局回调事件
function DlgAtelierGuide:onParseViewCallback( pView )
	-- body
	self:setContentView(pView) --加入内容层
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgAtelierGuide",handler(self, self.onDlgAtelierGuideDestroy))
end

--初始化控件
function DlgAtelierGuide:setupViews(  )
	--body	
	self.pLayInfo = self:findViewByName("lay_info")
	self.pImgGuide = self:findViewByName("img_yindao")
	--self.pLayBot = self:findViewByName("lay_bot")

	-- self.pLbTip1 = self:findViewByName("lb_tip_1")
	-- self.pLbTip1:setString(getConvertedStr(6, 10210))
	-- setTextCCColor(self.pLbTip1, _cc.pwhite)

	self.pLbTip2 = self:findViewByName("lb_tip_2")
	self.pLbTip2:setString(getConvertedStr(6, 10211))
	setTextCCColor(self.pLbTip2, _cc.pwhite)

	self.pLbTip3 = self:findViewByName("lb_tip_3")
	self.pLbTip3:setString(getConvertedStr(6, 10212))
	setTextCCColor(self.pLbTip3, _cc.pwhite)
	self.pLbTip4 = self:findViewByName("lb_tip_4")
	self.pLbTip4:setString(getConvertedStr(6, 10180))
	setTextCCColor(self.pLbTip4, _cc.pwhite)
	self.pLbTip5 = self:findViewByName("lb_tip_5")
	self.pLbTip5:setString(getConvertedStr(6, 10214))
	setTextCCColor(self.pLbTip5, _cc.pwhite)

	self.pLbCityPeople = self:findViewByName("lb_city_p")
	self.pLbCityPeople:setString("0")
	setTextCCColor(self.pLbCityPeople, _cc.green)

	self.pLbCountryPelple = self:findViewByName("lb_country_p")
	self.pLbCountryPelple:setString("0")
	setTextCCColor(self.pLbCountryPelple, _cc.green)

	self.pLbTime = self:findViewByName("lb_time")
	self.pLbTime:setString(getConvertedStr(6, 10215))
	setTextCCColor(self.pLbTime, _cc.red)	

	self.pImgColse = self:findViewByName("img_close")
	self.pImgColse:setViewTouched(true)
	self.pImgColse:setIsPressedNeedScale(false)
	self.pImgColse:onMViewClicked(function ( pView )
		-- body
		self:closeDlg(false)
	end)
	local atelierData = Player:getBuildData():getBuildById(e_build_ids.atelier)
	if atelierData then
		atelierData:openGuide()
	end
end

--控件刷新
function DlgAtelierGuide:updateViews(  )
	-- body
	--本城人口变化
	local ncitychange = Player:getBuildData():getBuildById(e_build_ids.palace):getOwnCityPeopleChangeCnt()
	if ncitychange > 0 then
		self.pLbCityPeople:setString("+"..ncitychange, false)
		setTextCCColor(self.pLbCityPeople, _cc.green)
	elseif ncitychange < 0 then
		self.pLbCityPeople:setString(ncitychange, false)
		setTextCCColor(self.pLbCityPeople, _cc.red)
	else
		self.pLbCityPeople:setString(getConvertedStr(6, 10445), false)
		setTextCCColor(self.pLbCityPeople, _cc.pwhite)
	end
	local nCountryChange = Player:getBuildData():getBuildById(e_build_ids.palace):getCountryPeopleChangeCnt()
	if nCountryChange > 0 then
		self.pLbCountryPelple:setString("+"..nCountryChange, false)
		setTextCCColor(self.pLbCountryPelple, _cc.green)
	elseif nCountryChange < 0 then
		self.pLbCountryPelple:setString(nCountryChange, false)
		setTextCCColor(self.pLbCountryPelple, _cc.red)
	else
		self.pLbCountryPelple:setString(getConvertedStr(6, 10445), false)
		setTextCCColor(self.pLbCountryPelple, _cc.pwhite)
	end
	--变化前对列数
	local nOutQueue = Player:getBuildData():getBuildById(e_build_ids.atelier).nOutQueue
	local nLa = ncitychange + nCountryChange*nOutQueue
	if nLa > 0 then
		self.pLbTime:setString(getConvertedStr(6, 10450))
		setTextCCColor(self.pLbTime, _cc.green)
	elseif nLa < 0 then
		self.pLbTime:setString(getConvertedStr(6, 10215))
		setTextCCColor(self.pLbTime, _cc.red)
	else
		self.pLbTime:setString(getConvertedStr(6, 10445))
		setTextCCColor(self.pLbTime, _cc.pwhite)
	end
end

--析构方法
function DlgAtelierGuide:onDlgAtelierGuideDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgAtelierGuide:regMsgs(  )
	-- body

end
--注销消息
function DlgAtelierGuide:unregMsgs(  )
	-- body

end

--暂停方法
function DlgAtelierGuide:onPause( )
	-- body
	self:unregMsgs()	
end

--继续方法
function DlgAtelierGuide:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

return DlgAtelierGuide