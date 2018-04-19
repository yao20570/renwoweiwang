----------------------------------------------------- 
-- author: luwenjing
-- updatetime: 2018-01-19 10:47:26
-- Description: 攻城掠地界面
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local IconGoods = require("app.common.iconview.IconGoods")
local FCommonTabHost = require("app.common.tabhost.FCommonTabHost")
local MImgLabel = require("app.common.button.MImgLabel")

local FirstAttkCity = require("app.layer.attackcity.FirstAttkCity")
local AttkCityFiveTarget = require("app.layer.attackcity.AttkCityFiveTarget")
local DlgAttkCity = class("DlgAttkCity", function()
	return DlgBase.new(e_dlg_index.attkcity)
end)

function DlgAttkCity:ctor( nTabIndex )

	if nTabIndex then
		self.nFirstTabIndex = nTabIndex 
	else
		self.nFirstTabIndex = tonumber(getLocalInfo("attkcityTab", "2"))
	end

	self.nCurTabIndex = self.nFirstTabIndex

	parseView("dlg_attk_city", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgAttkCity:onParseViewCallback( pView )
	self:addContentView(pView) --加入内容
	self:addContentTopSpace(2)
	self:myInit()
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgAttkCity",handler(self, self.onDlgAttkCityDestroy))
end

-- 析构方法
function DlgAttkCity:onDlgAttkCityDestroy(  )

    self:onPause()
end

function DlgAttkCity:regMsgs(  )
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))
end

function DlgAttkCity:unregMsgs(  )
	unregUpdateControl(self)--停止计时刷新
	unregMsg(self, gud_refresh_activity)

end

function DlgAttkCity:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function DlgAttkCity:onPause(  )
	saveLocalInfo("attkcityTab", tostring(self.nCurTabIndex))
	self:unregMsgs()
end

function DlgAttkCity:myInit(  )
	-- body
	self.tActData=Player:getActById(e_id_activity.attackcity)
	
end

function DlgAttkCity:setupViews(  )
	self:setTitle(getConvertedStr(9,10105))
	self.tTitles={getConvertedStr(9,10106),getConvertedStr(9,10107)}
	self.pLbTime = self:findViewByName("lb_time")
	self.pLbPoint = self:findViewByName("lb_point")
	-- self.nFirstTabIndex=1
	local pLayTab=self:findViewByName("lay_tab")
	self.pTabHost = FCommonTabHost.new(pLayTab,1,1,self.tTitles,handler(self, self.getLayerByKey), 1)
	self.pTabHost:setLayoutSize(pLayTab:getLayoutSize())
	self.pTabHost:removeLayTmp1()
	self.pTabHost:removeLayTmp2()
	self.pTabHost:setTabChangedHandler(handler(self, self.onTabChanged))
	pLayTab:addView(self.pTabHost,10)

	--初始化红点
	local nWidOff = pLayTab:getWidth()/2
	local x = pLayTab:getPositionX()
	local y = pLayTab:getPositionY() + pLayTab:getHeight() - 28
	self.pLayRedS={}
	for i = 1, 2 do
		if not self.pLayRedS[i] then
			local pLayRed = MUI.MLayer.new(true)
			pLayRed:setLayoutSize(26, 26)		
			pLayRed:setPosition(x + nWidOff*i - 26, y)
            pLayRed:setIgnoreOtherHeight(true)
			pLayTab:addView(pLayRed, 100)
			self.pLayRedS[i] = pLayRed
		end
	end

	self.pTabHost:setDefaultIndex(self.nFirstTabIndex)

	regUpdateControl(self,handler(self,self.updateCd))
end

function DlgAttkCity:refreshRedNum( )
	-- body

	local nTotalNum , nFirst,nBx,nDaily = self.tActData:getRedNums() 
	if nFirst > 0  or nDaily >0 then
		showRedTips(self.pLayRedS[2], 0,1)
	else
		showRedTips(self.pLayRedS[2], 0,0)
	end
	showRedTips(self.pLayRedS[1], 0, nBx)
	
end

--控件刷新
function DlgAttkCity:updateViews()
	self.tActData=Player:getActById(e_id_activity.attackcity)
	if not self.tActData then
		self:closeDlg()
		return
	end

	local tStr = getTextColorByConfigure(string.format(getConvertedStr(9,10122),self.tActData.nP))
	self.pLbPoint:setString(tStr)

	self:refreshRedNum()
	
end

--通过key值获取内容层的layer
function DlgAttkCity:getLayerByKey( _sKey, _tKeyTabLt )
	local pLayer = nil

    local tSize = self.pTabHost:getCurContentSize()
	if( _sKey == _tKeyTabLt[1] ) then
		pLayer = AttkCityFiveTarget.new(tSize)	
		self.pAttkCityFiveTarget = pLayer
	elseif (_sKey == _tKeyTabLt[2] ) then
		pLayer = FirstAttkCity.new()
		self.pFirstAttkCity = pLayer
	end
	return pLayer
end

--时间更新函数
function DlgAttkCity:updateCd()

	if not self.tActData then
		return
	end
	local sTime = self.tActData:getRemainTime2()
	self.pLbTime:setString(sTime)
end

function DlgAttkCity:onTabChanged( _sKey, _nType )

	-- if _sKey == "tabhost_key_1" then
	-- 	self.nCurTabIndex=1
	-- 	if self.pMoBingTaoFa then
	-- 		self.pMoBingTaoFa:setCanShowGetItem(true)
	-- 	end
	-- else
		if _sKey == "tabhost_key_1" then
			self.pLbPoint:setVisible(true)
			self.nCurTabIndex = 1
		elseif _sKey == "tabhost_key_2" then
			self.pLbPoint:setVisible(false)
			self.nCurTabIndex = 2
		end

	-- 	if self.pMoBingTaoFa then
	-- 		self.pMoBingTaoFa:setCanShowGetItem(false)
	-- 	end
	-- end
end


return DlgAttkCity