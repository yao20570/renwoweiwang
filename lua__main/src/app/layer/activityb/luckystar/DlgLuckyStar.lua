----------------------------------------------------- 
-- author: luwenjing
-- updatetime: 2018-01-25 15:52:26
-- Description: 福星高照界面
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local IconGoods = require("app.common.iconview.IconGoods")
local FCommonTabHost = require("app.common.tabhost.FCommonTabHost")
local MImgLabel = require("app.common.button.MImgLabel")
local LuckStarReward = require("app.layer.activityb.luckystar.LuckStarReward")
local LuckyStarRank = require("app.layer.activityb.luckystar.LuckyStarRank")
local LuckyStarRedPocket = require("app.layer.activityb.luckystar.LuckyStarRedPocket")

local DlgLuckyStar = class("DlgLuckyStar", function()
	return DlgBase.new(e_dlg_index.attkcity)
end)

function DlgLuckyStar:ctor( nTabIndex )

	-- if nTabIndex then
	-- 	self.nFirstTabIndex = nTabIndex 
	-- else
	-- 	self.nFirstTabIndex = tonumber(getLocalInfo("attkcityTab", "2"))
	-- end

	self.nCurTabIndex = 1 -- self.nFirstTabIndex

	parseView("dlg_lucky_star", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgLuckyStar:onParseViewCallback( pView )
	self:addContentView(pView) --加入内容
	self:addContentTopSpace()
	self:myInit()
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgLuckyStar",handler(self, self.onDlgLuckyStarDestroy))
end

-- 析构方法
function DlgLuckyStar:onDlgLuckyStarDestroy(  )

    self:onPause()
end

function DlgLuckyStar:regMsgs(  )
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))
end

function DlgLuckyStar:unregMsgs(  )
	-- unregUpdateControl(self)--停止计时刷新
	unregMsg(self, gud_refresh_activity)

end

function DlgLuckyStar:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function DlgLuckyStar:onPause(  )
	-- saveLocalInfo("attkcityTab", tostring(self.nCurTabIndex))
	self:unregMsgs()
end

function DlgLuckyStar:myInit(  )
	-- body
	-- self.tActData=Player:getActById(e_id_activity.attackcity)
	
end

function DlgLuckyStar:setupViews(  )
	self:setTitle(getConvertedStr(9,10126))
	self.tTitles={getConvertedStr(9,10127),getConvertedStr(9,10128),getConvertedStr(9,10129)}
	
	local pLayTab=self:findViewByName("lay_tab")
	self.pTabHost = FCommonTabHost.new(pLayTab,1,1,self.tTitles,handler(self, self.getLayerByKey), 1)
	self.pTabHost:setLayoutSize(pLayTab:getLayoutSize())
	self.pTabHost:removeLayTmp1()
	self.pTabHost:removeLayTmp2()
	self.pTabHost:setTabChangedHandler(handler(self, self.onTabChanged))
	pLayTab:addView(self.pTabHost,10)

	--初始化红点
	local nWidOff = pLayTab:getWidth()/3
	local x = pLayTab:getPositionX()
	local y = pLayTab:getPositionY() + pLayTab:getHeight() - 28
	self.pLayRedS={}
	for i = 1, 3 do
		if not self.pLayRedS[i] then
			local pLayRed = MUI.MLayer.new(true)
			pLayRed:setLayoutSize(26, 26)		
			pLayRed:setPosition(x + nWidOff*i - 26, y)
            pLayRed:setIgnoreOtherHeight(true)
			pLayTab:addView(pLayRed, 100)
			self.pLayRedS[i] = pLayRed
		end
	end

	self.pTabHost:setDefaultIndex(self.nCurTabIndex)

	

	-- regUpdateControl(self,handler(self,self.updateCd))
end

function DlgLuckyStar:refreshRedNum( )
	-- body

	-- local nTotalNum , nFirst,nBx,nDaily = self.tActData:getRedNums() 
	-- if nFirst > 0  or nDaily >0 then
	-- 	showRedTips(self.pLayRedS[2], 0,1)
	-- else
	-- 	showRedTips(self.pLayRedS[2], 0,0)
	-- end
	-- showRedTips(self.pLayRedS[1], 0, nBx)
	

end



--控件刷新
function DlgLuckyStar:updateViews()
	self.tActData=Player:getActById(e_id_activity.luckystar)
	if not self.tActData then
		self:closeDlg(false)
		return
	end
	
	self:refreshRedNum()
	
end

--通过key值获取内容层的layer
function DlgLuckyStar:getLayerByKey( _sKey, _tKeyTabLt )
	local pLayer = nil

    local tSize = self.pTabHost:getCurContentSize()
	if( _sKey == _tKeyTabLt[1] ) then
		pLayer = LuckyStarRedPocket.new(tSize)	
		self.pLuckyStarRedPocket = pLayer
	elseif (_sKey == _tKeyTabLt[2] ) then
		pLayer = LuckyStarRank.new(tSize)
		self.pLuckyStarRank = pLayer
	elseif (_sKey == _tKeyTabLt[3] ) then
		pLayer = LuckStarReward.new(tSize)
		self.pLuckStarReward = pLayer
	end
	return pLayer
end

--时间更新函数
function DlgLuckyStar:updateCd()

	if not self.tActData then
		return
	end
	local sTime = self.tActData:getRemainTime()
	self.pLbTime:setString(sTime)
end

function DlgLuckyStar:onTabChanged( _sKey, _nType )

	-- if _sKey == "tabhost_key_1" then
	-- 	self.nCurTabIndex=1
	-- 	if self.pMoBingTaoFa then
	-- 		self.pMoBingTaoFa:setCanShowGetItem(true)
	-- 	end
	-- else
		-- if _sKey == "tabhost_key_1" then
		-- 	self.pLbPoint:setVisible(true)
		-- 	self.nCurTabIndex = 1
		-- elseif _sKey == "tabhost_key_2" then
		-- 	self.pLbPoint:setVisible(false)
		-- 	self.nCurTabIndex = 2
		-- end

	-- 	if self.pMoBingTaoFa then
	-- 		self.pMoBingTaoFa:setCanShowGetItem(false)
	-- 	end
	-- end

	if _sKey == "tabhost_key_2" then
		SocketManager:sendMsg("getRankData", {e_rank_type.ac_lucky_star, 1, 15})
	elseif _sKey == "tabhost_key_3" then

	elseif _sKey == "tabhost_key_4" then
	end

end


return DlgLuckyStar