----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-10-24 15:17:21
-- Description: 武王伐纣
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local FCommonTabHost = require("app.common.tabhost.FCommonTabHost")
local TabManager = require("app.common.TabManager")
local MoBingTaoFa = require("app.layer.activityb.wuwang.MoBingTaoFa")
local ZhouWangShiLian = require("app.layer.activityb.wuwang.ZhouWangShiLian")
local WuWangExchange = require("app.layer.activityb.wuwang.WuWangExchange")
local DlgWuWangKillRank = require("app.layer.wuwang.DlgWuWangKillRank")

local DlgWuWang = class("DlgWuWang", function()
	return DlgBase.new(e_dlg_index.wuwang)
end)

function DlgWuWang:ctor( nTabIndex )
	if nTabIndex then
		self.nFirstTabIndex = nTabIndex 
	else
		self.nFirstTabIndex = tonumber(getLocalInfo("wuwangTab", "1"))
	end

	self.nCurTabIndex = self.nFirstTabIndex
	parseView("dlg_wuwang", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgWuWang:onParseViewCallback( pView )
	self:addContentView(pView) --加入内容层
	self:addContentTopSpace(7)
	
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgWuWang",handler(self, self.onDlgWuWangDestroy))
end

-- 析构方法
function DlgWuWang:onDlgWuWangDestroy(  )
    self:onPause()
end

function DlgWuWang:regMsgs(  )
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))

    regMsg(self, gud_refresh_baginfo, handler(self, self.refreshRedNum))

end

function DlgWuWang:unregMsgs(  )
	unregMsg(self, gud_refresh_activity)
	unregMsg(self, gud_refresh_baginfo)
end

function DlgWuWang:onResume(  )
	self:regMsgs()
	self:updateViews()

	self:refreshRedNum()
end

function DlgWuWang:onPause(  )
	self:unregMsgs()

	saveLocalInfo("wuwangTab", tostring(self.nCurTabIndex))
end

function DlgWuWang:setupViews(  )
	self.pLayTime = self:findViewByName("lay_time")

	-- self.pLayTop = self:findViewByName("lay_top")

	--banner
	self.pLayBannerBg = self:findViewByName("lay_top")
	local pMBanner=setMBannerImage(self.pLayBannerBg,TypeBannerUsed.fl_wwfz)
	pMBanner:setMBannerOpacity(255*0.5)
	
	self.pLayRedS={}

	--内容层
	self.tTitles = {
		getConvertedStr(3, 10476),
		getConvertedStr(3, 10477),
		getConvertedStr(3, 10478),
		getConvertedStr(9, 10088),
	}
	self.pLyContent 	  = 		self:findViewByName("lay_content")
	self.pLyContent:setZOrder(10)
	--初始化红点
	local x = self.pLyContent:getPositionX()
	local nWidOff = self.pLyContent:getWidth()/4
	local y = self.pLyContent:getPositionY() + self.pLyContent:getHeight() - 35
	for i = 2, 3 do
		if not self.pLayRedS[i] then
			local pLayRed = MUI.MLayer.new(true)
			pLayRed:setLayoutSize(26, 26)		
			pLayRed:setPosition(x + nWidOff*i - 26, y)
            pLayRed:setIgnoreOtherHeight(true)
			self.pLyContent:addView(pLayRed, 100)
			self.pLayRedS[i] = pLayRed
		end
	end
	self:refreshRedNum()
	self.pTabHost = FCommonTabHost.new(self.pLyContent,1,1,self.tTitles,handler(self, self.getLayerByKey), 1)
	self.pTabHost:setLayoutSize(self.pLyContent:getLayoutSize())
	self.pTabHost:removeLayTmp1()
	self.pTabHost:removeLayTmp2()
	self.pTabHost:setTabChangedHandler(handler(self, self.onTabChanged))
	self.pLyContent:addView(self.pTabHost,10)

	self.pTabHost:setDefaultIndex(self.nFirstTabIndex)


	
end

function DlgWuWang:refreshRedNum( )
	-- body
	
	--获取活动数据
	local tData = Player:getActById(e_id_activity.wuwang)
	if tData then
		tData:setZeroPush(false)
		-- tData:getRedNums()
		sendMsg(gud_refresh_activity)
		sendMsg(gud_refresh_act_red)
		-- showRedTips(self.pLayRedS[2], 0, tData:isHaveNewZhq())	
		showRedTips(self.pLayRedS[3], 0,tData:isHaveNewExchange())	
	end

end

--通过key值获取内容层的layer
function DlgWuWang:getLayerByKey( _sKey, _tKeyTabLt )
	local pLayer = nil
	local pdata = {}

	--红点刷新	
	if _sKey == "tabhost_key_3" then

		-- local tItemData1=Player:getBagInfo():getItemDataById(100154)
		-- local tItemData2=Player:getBagInfo():getItemDataById(100155)
		-- local bIsNeedRefresh = false
		-- if tItemData1 then	
		-- 	if tItemData1.nRedNum>0 then
		-- 		tItemData1:clearItemRed()
		-- 		bIsNeedRefresh = true
		-- 	end
		-- end
		-- if tItemData2 then	
		-- 	if tItemData2.nRedNum>0 then
		-- 		tItemData2:clearItemRed()
		-- 		bIsNeedRefresh = true
		-- 	end
		-- end
		local tData = Player:getActById(e_id_activity.wuwang)
		if tData then
			local nItemId = tData:getExchangeId()
			if nItemId then
				local tItemData=Player:getBagInfo():getItemDataById(nItemId)
				if tItemData then	
					if tItemData.nRedNum>0 then
						tItemData:clearItemRed()
						bIsNeedRefresh = true
					end
				end
			end

			if bIsNeedRefresh then
							
				-- showRedTips(self.pLayRedS[2], 1, 0)
				self:refreshRedNum()
			end
		end
	end	

    local tSize = self.pTabHost:getCurContentSize()
	if( _sKey == _tKeyTabLt[1] ) then
		pLayer = MoBingTaoFa.new(tSize)	
		self.pMoBingTaoFa = pLayer
	elseif (_sKey == _tKeyTabLt[2] ) then
		pLayer = ZhouWangShiLian.new(tSize)
		self.pZhouWangShiLian = pLayer
	elseif (_sKey == _tKeyTabLt[3] ) then
		pLayer = WuWangExchange.new(tSize)
		self.pWuWangExchange = pLayer
	elseif (_sKey == _tKeyTabLt[4] ) then
		pLayer = DlgWuWangKillRank.new(tSize)
		self.pWuWangKillRank = pLayer
	end
	return pLayer
end

function DlgWuWang:onTabChanged( _sKey, _nType )
	if _sKey == "tabhost_key_1" then
		self.nCurTabIndex=1
		if self.pMoBingTaoFa then
			self.pMoBingTaoFa:setCanShowGetItem(true)
		end
	else
		if _sKey == "tabhost_key_2" then
			self.nCurTabIndex=2
		elseif _sKey == "tabhost_key_3" then
			self.nCurTabIndex=3
		elseif _sKey == "tabhost_key_4" then
			self.nCurTabIndex=4
			--请求排行榜信息
			SocketManager:sendMsg("getRankData", {e_rank_type.wuwang_kill, 1, 15})
		end

		if self.pMoBingTaoFa then
			self.pMoBingTaoFa:setCanShowGetItem(false)
		end
	end
end
--控件刷新
function DlgWuWang:updateViews()
	local tData = Player:getActById(e_id_activity.wuwang)
	if not tData then
		self:closeDlg(false)
		return
	end

	if tData then
		--设置标题
		self:setTitle(tData.sName)

		--活动时间
		if not self.pActTime then
			self.pActTime = createActTime(self.pLayTime, tData, cc.p(0,0))
		else
			self.pActTime:setCurData(tData)
		end


	end

	--更新子面板(只有兑换才与活动相关)
	if self.pWuWangExchange then
		self.pWuWangExchange:updateViews()
	end

	if self.pWuWangKillRank then
		self.pWuWangKillRank:updateViews()
	end
end

return DlgWuWang