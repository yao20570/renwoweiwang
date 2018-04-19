-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-04-24 17:23:23 星期一
-- Description: 背包界面
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local FCommonTabHost = require("app.common.tabhost.FCommonTabHost")
local BagEquipLayer = require("app.layer.bag.BagEquipLayer")
local BagNormalLayer = require("app.layer.bag.BagNormalLayer")


local DlgBagLayer = class("DlgBagLayer", function()
	-- body
	return DlgBase.new(e_dlg_index.bag)
end)

function DlgBagLayer:ctor( defIdx )--页面索引
	-- body
	self:myInit(defIdx)
	parseView("dlg_bag", handler(self, self.onParseViewCallback))
end

function DlgBagLayer:myInit(defIdx)
	-- body	
	self.nStartIdx = defIdx or 1
	self.tTitles = {getConvertedStr(6,10123),getConvertedStr(6,10124),getConvertedStr(6,10125),getConvertedStr(6,10126)}	
	self.tCommonTabs = {}
	self.pLayRedS = {}
	self.sCurKeys = nil
end

--解析布局回调事件
function DlgBagLayer:onParseViewCallback( pView )
	-- body
	self:addContentView(pView) --加入内容层
	self:addContentTopSpace(7)
	
	--self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgBagLayer",handler(self, self.onDlgBagLayerDestroy))
end

-- --初始化控件
-- function DlgBagLayer:setupViews(  )
-- 	-- body	
-- 	--设置标题
-- 	self:setTitle(getConvertedStr(6,10122))	
-- 	self.pLayRoot = self:findViewByName("root")
-- 	--顶部图片
-- 	self.pImgTop = self:findViewByName("img_top")
-- 	--数据层
-- 	self.pLayTable = self:findViewByName("lay_table")
-- 	local x = self.pLayTable:getPositionX()
-- 	local nWidOff = self.pLayTable:getWidth()/4
-- 	local y = self.pLayTable:getPositionY() + self.pLayTable:getHeight() - 13
-- 	for i = 1, 4 do
-- 		local pLayRed = MUI.MLayer.new(true)
-- 		pLayRed:setLayoutSize(26, 26)		
-- 		pLayRed:setPosition(x + nWidOff*i - 26, y)
-- 		self.pLayRoot:addView(pLayRed, 100)
-- 		self.pLayRedS[i] = pLayRed
-- 	end

-- 	self.pTabHost = FCommonTabHost.new(self.pLayTable,1,1,self.tTitles, handler(self, self.getLayerByKey))
-- 	self.pTabHost:setLayoutSize(self.pLayTable:getLayoutSize())
-- 	self.pTabHost:removeLayTmp1()
-- 	self.pTabHost:removeLayTmp2()
-- 	self.pLayTable:addView(self.pTabHost, 10)
-- 	centerInView(self.pLayTable, self.nTabHost)
-- 	self.pTabHost:setDefaultIndex(self.nStartIdx)
-- 	self.pTabHost:setTabChangedHandler(handler(self, self.onTabChanged))
-- end

--控件刷新
function DlgBagLayer:updateViews(  )
	-- body
	gRefreshViewsAsync(self, 3, function ( _bEnd, _index )
		if(_index == 1) then
			--设置标题
			self:setTitle(getConvertedStr(6,10122))				
			if not self.pLayRoot then
				self.pLayRoot = self:findViewByName("root")
				local pBannerImage 			= 		self:findViewByName("lay_banner_bg")
				setMBannerImage(pBannerImage,TypeBannerUsed.bb)
			end
			--数据层
			if not self.pLayTable then
				self.pLayTable = self:findViewByName("lay_table")
			end
			local x = self.pLayTable:getPositionX()
			local nWidOff = self.pLayTable:getWidth()/4
			local y = self.pLayTable:getPositionY() + self.pLayTable:getHeight() - 30
			for i = 1, 4 do
				if not self.pLayRedS[i] then
					local pLayRed = MUI.MLayer.new(true)
                    pLayRed:setIgnoreOtherHeight(true)
					pLayRed:setLayoutSize(30, 30)		
					pLayRed:setPosition(x + nWidOff*i - 30, y)
					self.pLayRoot:addView(pLayRed, 100)
					self.pLayRedS[i] = pLayRed
				end
			end
		elseif (_index == 2) then
			--红点刷新
			showRedTips(self.pLayRedS[1], 1, Player:getBagInfo():getBagRedNum(e_item_types.consum))	
			showRedTips(self.pLayRedS[2], 1, Player:getEquipData():getIdleEquipVosNewCnt())	
			showRedTips(self.pLayRedS[3], 1, Player:getBagInfo():getBagRedNum(e_item_types.material))	
			showRedTips(self.pLayRedS[4], 1, Player:getBagInfo():getBagRedNum(e_item_types.other))			
		elseif (_index == 3) then
			if not self.pTabHost then
				self.pTabHost = FCommonTabHost.new(self.pLayTable,1,1,self.tTitles, handler(self, self.getLayerByKey), 1)
				self.pTabHost:setLayoutSize(self.pLayTable:getLayoutSize())
				self.pTabHost:removeLayTmp1()
				self.pTabHost:removeLayTmp2()
				self.pLayTable:addView(self.pTabHost, 10)
				centerInView(self.pLayTable, self.nTabHost)
				self.pTabHost:setTabChangedHandler(handler(self, self.onTabChanged))
				self.pTabHost:setDefaultIndex(self.nStartIdx)	
			else
				self:onTabChanged(self.sCurKeys)
			end						
		end
	end)
end

--分页切换
function DlgBagLayer:onTabChanged(_sKey)
	-- body
	if _sKey then			
		--清理前一页的红点
		if self.sCurKeys then			
			self:clearItemRedNumByKey(self.sCurKeys)
			local pPrevLayer = self.tCommonTabs[self.sCurKeys]
			pPrevLayer:updateViews()			
		end
		--刷新在分页内部显示物品是否为新
		local pLayer = self.tCommonTabs[_sKey]--当前页
		if pLayer then
			pLayer:updateViews()
			self.sCurKeys = _sKey
		end				
		--红点刷新	
		if _sKey == "tabhost_key_1" then	
			showRedTips(self.pLayRedS[1], 1, 0)
		elseif _sKey == "tabhost_key_2" then
			showRedTips(self.pLayRedS[2], 1, 0)	
		elseif _sKey == "tabhost_key_3" then
			showRedTips(self.pLayRedS[3], 1, 0)
		elseif _sKey == "tabhost_key_4" then
			showRedTips(self.pLayRedS[4], 1, 0)
		end	
		--是否显示对话框默认内容
		local nCnt = 0 --当页的物品数量
		if 	_sKey == "tabhost_key_2" then --装备
			nCnt = self.tCommonTabs[_sKey]:getEquipCnt()
		else--物品页面
			nCnt = self.tCommonTabs[_sKey]:getItemCnt()
		end	
		self:setDefInfo(nCnt <= 0)
	end
end

--清理对应页面红点
function DlgBagLayer:clearItemRedNumByKey( _sKey )
	-- body
	if not _sKey then
		return 
	end
	if _sKey == "tabhost_key_1" then	
		Player:getBagInfo():clearItemRedNum(e_item_types.consum)				
	elseif _sKey == "tabhost_key_2" then
		Player:getEquipData():setIdleEquipNoNew()			
	elseif _sKey == "tabhost_key_3" then
		Player:getBagInfo():clearItemRedNum(e_item_types.material)			
	elseif _sKey == "tabhost_key_4" then
		Player:getBagInfo():clearItemRedNum(e_item_types.other)				
	end	
end
--析构方法
function DlgBagLayer:onDlgBagLayerDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgBagLayer:regMsgs(  )
	-- body
	--注册刷新背包消息
	regMsg(self, gud_refresh_baginfo, handler(self, self.refreshBagInfo))
	--注册装备数据刷新消息
	regMsg(self, gud_equip_hero_equip_change, handler(self, self.refreshBagInfo))	
end
--注销消息
function DlgBagLayer:unregMsgs(  )
	-- body
	--注销刷新背包消息
	unregMsg(self, gud_refresh_baginfo)	
	--注销装备数据刷新消息
	unregMsg(self, gud_equip_hero_equip_change)	
end

--暂停方法
function DlgBagLayer:onPause( )
	-- body	
	self:clearItemRedNumByKey(self.sCurKeys)
	self:unregMsgs()	
end

--继续方法
function DlgBagLayer:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

--通过key值获取内容层的layer
function DlgBagLayer:getLayerByKey( _sKey, _tKeyTabLt )
	-- body
    local tSize = self.pTabHost:getCurContentSize()
	local pLayer = nil
	if( _sKey == _tKeyTabLt[1] ) then		
		pLayer = BagNormalLayer.new(e_item_types.consum, tSize)			
	elseif ( _sKey == _tKeyTabLt[2] ) then		
		pLayer = BagEquipLayer.new(tSize)	
	elseif ( _sKey == _tKeyTabLt[3] ) then				
		pLayer = BagNormalLayer.new(e_item_types.material, tSize)
	elseif ( _sKey == _tKeyTabLt[4] ) then		
		pLayer = BagNormalLayer.new(e_item_types.other, tSize)
	end	
	if not self.tCommonTabs[_sKey] then
		self.tCommonTabs[_sKey] = pLayer
	end
	return pLayer
end

--刷新
function DlgBagLayer:refreshBagInfo()
	-- body
	self:updateViews()	
end

--设置背包默认显示
function DlgBagLayer:setDefInfo( _bShow )
	-- body
	local bShow = _bShow or false

	--没有数据提示
	local tLabel = {
	    str = getConvertedStr(3, 10220),
	}
	if not self.pNullUi then
		local pNullUi = getLayNullUiImgAndTxt(tLabel)
		pNullUi:setIgnoreOtherHeight(true)
		self.pLayTable:addView(pNullUi)
		centerInView(self.pLayTable, pNullUi)
		self.pNullUi = pNullUi
	end
	self.pNullUi:setVisible(bShow)
	
	--默认显示
	-- if not self.pLbTip then
	-- 	self.pLbTip = MUI.MLabel.new({
	-- 		    text = getConvertedStr(6, 10466),
	-- 		    size = 20,
	-- 		    anchorpoint = cc.p(0.5, 0.5),
	-- 		    align = cc.ui.TEXT_ALIGN_CENTER,
	--     		valign = cc.ui.TEXT_VALIGN_CENTER,
	-- 		    color = cc.c3b(255, 255, 255),
	-- 		})
	-- 	setTextCCColor(self.pLbTip, _cc.pwhite)
	-- 	centerInView(self.pLayTable, self.pLbTip)
	-- 	self.pLbTip:setVisible(false)				
	-- 	self.pLayTable:addView(self.pLbTip, 10)
	-- end
	-- if not self.pImg then
	-- 	self.pImg = MUI.MImage.new("#v1_img_biaoqing.png", {scale9=false})
	-- 	self.pImg:setVisible(false)
	-- 	self.pImg:setPosition(self.pLayTable:getWidth()/2, self.pLbTip:getPositionY() + self.pLbTip:getHeight()/2 + self.pImg:getHeight()/2 + 10)
	-- 	self.pLayTable:addView(self.pImg, 10)
	-- end
	-- self.pLbTip:setVisible(bShow)
	-- self.pImg:setVisible(bShow)
end

return DlgBagLayer