-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-04-20 15:23:23 星期四
-- Description: 仓库界面
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local FCommonTabHost = require("app.common.tabhost.FCommonTabHost")
local LayWareHouse = require("app.layer.warehouse.LayWareHouse")
local LayChangeRes = require("app.layer.merchants.LayChangeRes")
local LayResPack = require("app.layer.merchants.LayResPack")
local ItemHomeRes = require("app.layer.home.ItemHomeRes")

local DlgWareHouse = class("DlgWareHouse", function()
	-- body
	return DlgBase.new(e_dlg_index.warehouse)
end)

function DlgWareHouse:ctor(  )
	-- body
	self:myInit()
	parseView("dlg_warehouse", handler(self, self.onParseViewCallback))
end

function DlgWareHouse:myInit(  )
	-- body
	--3个子层
	self.tItemLays = {}
	self.classes = {LayWareHouse, LayChangeRes, LayResPack}
 	self.tTitles = {getConvertedStr(7, 10364), getConvertedStr(7, 10042), getConvertedStr(7, 10363)}
end

--解析布局回调事件
function DlgWareHouse:onParseViewCallback( pView )
	-- body
	self:addContentTopSpace()
	
	self:addContentView(pView) --加入内容层

	self:setupViews()

	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgWareHouse",handler(self, self.onDlgDlgWareHouseDestroy))
end

--初始化控件
function DlgWareHouse:setupViews( )
	-- body
	--设置标题
	self:setTitle(getConvertedStr(6,10100))
	self.pImgTop = self:findViewByName("img_top_fonts")
	self.pImgTop:setVisible(false)
	--头顶横条(banner)
	local pBannerImage 		= 		self:findViewByName("lay_banner_bg")
	setMBannerImage(pBannerImage,TypeBannerUsed.ck)

	self.pLyTopTip = self:findViewByName("lay_top_tip")
	--资源标题层
	self.pLyResInfoTitle = self:findViewByName("lay_resinfotitle")
	--资源保护量
	self.pLbProtectValue = self:findViewByName("lb_protect_value")
	--资源可被掠夺量
	self.pLbPlunderValue = self:findViewByName("lb_plunder_value")
	self.pImgHuang = self:findViewByName("img_huang")

	--我的资源层
	self.pLayResInfo = self:findViewByName("lay_res_info")
	self.pLbMyRes = self:findViewByName("lb_my_res")
	self.pLbMyRes:setString(getConvertedStr(7, 10368))
	setTextCCColor(self.pLbMyRes, _cc.white)
	self.pLayMyRes = self:findViewByName("lay_res")
	--资源打包顶部提示
	self.pLbPackTip              = self:findViewByName("lb_pack_tip")
	setTextCCColor(self.pLbPackTip, _cc.pwhite)
	self.pLbPackTip:setString(getConvertedStr(7, 10369))

	-- self:updateTabHost()
	self.pLyContent   = self:findViewByName("lay_content")
	self.pTabHost = FCommonTabHost.new(self.pLyContent,1,1,self.tTitles,handler(self, self.getLayerByKey),1)
	self.pTabHost:setLayoutSize(self.pLyContent:getLayoutSize())
	self.pTabItems = self.pTabHost:getTabItems()
	self.pTabHost:removeLayTmp1()
	self.pTabHost:removeLayTmp2()
	self.pTabHost:setTabChangedHandler(handler(self, self.onTabChanged))
	self.pLyContent:addView(self.pTabHost, 10)
	self.pTabHost:setDefaultIndex(1)

	--顶部功能层开启刷新
	self:topTabLockUpdate()
end

--设置默认打开分页
function DlgWareHouse:setDefOpenIndex(_index)
	self.pTabHost:setDefaultIndex(_index)
end

--顶部功能层开启刷新(资源兑换和资源打包)
function DlgWareHouse:topTabLockUpdate()
	-- body
	local bIsLock = true
	--资源兑换是否开启
	local bOpen, sLockTip = getIsReachOpenCon(27, false)
	if bOpen then
		bIsLock = false
	end
	local pTabItem = self.pTabItems[2]
	if bIsLock then
		pTabItem:showTabLock()
		pTabItem:setViewEnabled(false)
		pTabItem:onMViewDisabledClicked(handler(self, function (  )
		    -- body
		    TOAST(sLockTip)
		end))
	else
		pTabItem:hideTabLock()
		pTabItem:setViewEnabled(true)
	end
	--资源打包是否开启
	local bIsLock = true
	local bOpen, sLockTip = getIsReachOpenCon(26, false)
	if bOpen then
		bIsLock = false
	end
	local pTabItem = self.pTabItems[3]
	if bIsLock then
		pTabItem:showTabLock()
		pTabItem:setViewEnabled(false)
		pTabItem:onMViewDisabledClicked(handler(self, function (  )
		    -- body
		    TOAST(sLockTip)
		end))
	else
		pTabItem:hideTabLock()
		pTabItem:setViewEnabled(true)
	end
end

function DlgWareHouse:getLayerByKey( _sKey, _tKeyTabLt )
	-- body
	local pLayer = nil	
	local tSize = self.pTabHost:getCurContentSize()
	if( _sKey == _tKeyTabLt[1] ) then
		pLayer = self.classes[1].new(tSize)	
		self.tItemLays[1] = pLayer
	elseif (_sKey == _tKeyTabLt[2] ) then
		pLayer = self.classes[2].new(tSize)
		self.tItemLays[2] = pLayer
	elseif (_sKey == _tKeyTabLt[3] ) then
		pLayer = self.classes[3].new(tSize)
		self.tItemLays[3] = pLayer
	end
	return pLayer
end

function DlgWareHouse:onTabChanged( _sKey, _nType )
	if _sKey == "tabhost_key_1" then
		self.nSelect = 1
	elseif _sKey == "tabhost_key_2" then
		self.nSelect = 2
	elseif _sKey == "tabhost_key_3" then
		self.nSelect = 3
	end
	self:updateTabHost()
end

--更新切换卡
function DlgWareHouse:updateTabHost()
	if self.nSelect == 3 then
		self.pLyTopTip:setLayoutSize(640, 74)
		self.pLyTopTip:setPositionY(0)
		self.pLayResInfo:setPositionY(36)
		self.pLbPackTip:setVisible(true)
	else
		self.pLyTopTip:setLayoutSize(640, 48)
		self.pLyTopTip:setPositionY(6)
		self.pLbPackTip:setVisible(false)
	end
	if self.nSelect == 2 then
		-- self.pImgTop:setVisible(true)
		self.pLayResInfo:setPositionY(8)
	else
		-- self.pImgTop:setVisible(false)
	end
	if self.nSelect == 1 then
		self.pLyResInfoTitle:setVisible(true)
		self.pLayResInfo:setVisible(false)
	else
		self.pLyResInfoTitle:setVisible(false)
		self.pLayResInfo:setVisible(true)
		if not self.pItemCoin then
			--平均宽度
			local nW = self.pLayMyRes:getWidth() / 3
			--银币
			self.pItemCoin 				= 		ItemHomeRes.new(1)
			self.pLayMyRes:addView(self.pItemCoin)
			self.pItemCoin:setPosition(0, 0)
			--木头
			self.pItemWood 				= 		ItemHomeRes.new(2)
			self.pLayMyRes:addView(self.pItemWood)
			self.pItemWood:setPosition(nW, 0)
			--粮食
			self.pItemFood 				= 		ItemHomeRes.new(3)
			self.pLayMyRes:addView(self.pItemFood)
			self.pItemFood:setPosition(nW * 2, 0)
		end
	end

end

--下标选择回调事件
-- function DlgWareHouse:onIndexSelected( _index )
-- 	if self.nSelect == _index then
-- 		return
-- 	end
-- 	self.nSelect = _index --当前所选下标
-- 	--刷新列表
-- 	self:updateTabHost()
-- end

--控件刷新
function DlgWareHouse:updateViews(  )
	-- body	
	--仓库数据
	local warehousedata = Player:getBuildData():getBuildById(e_build_ids.store)
	local playerinfo = Player:getPlayerInfo()
	if warehousedata and playerinfo then
		--总保护量
		local nLc = warehousedata:getBaseResProNum(e_resdata_ids.lc)		
		local nTLc = playerinfo:getBaseResNum(e_resdata_ids.lc)--基础资源总量

		local nYb = warehousedata:getBaseResProNum(e_resdata_ids.yb)		
		local nTYb = playerinfo:getBaseResNum(e_resdata_ids.yb)--基础资源总量

		local nMc = warehousedata:getBaseResProNum(e_resdata_ids.mc)		
		local nTMc = playerinfo:getBaseResNum(e_resdata_ids.mc)--基础资源总量					
		--可被掠夺总量
		local lplunder = 0
		if nTLc - nLc > 0 then
			lplunder = lplunder + nTLc - nLc					
		end  
		if nTYb - nYb > 0 then
			lplunder = lplunder + nTYb - nYb					
		end  
		if nTMc - nMc > 0 then
			lplunder = lplunder + nTMc - nMc					
		end  
		local sStr1 = {
			{color=_cc.white, text = getConvertedStr(6, 10116)},
			{color=_cc.yellow, text = getResourcesStr(warehousedata:getBaseResProNum(e_resdata_ids.lc))},
		}
		self.pLbProtectValue:setString(sStr1, false)
		local sStr2 = {
			{color=_cc.white, text = getConvertedStr(6, 10117)},
			{color=_cc.yellow, text = getResourcesStr(lplunder)},
		}					
		self.pLbPlunderValue:setString(sStr2, false)
	end	
	
	--数值数值引起的可被掠夺量标签位置调整
	local nX = self.pLbPlunderValue:getPositionX() - self.pLbPlunderValue:getWidth() - 5
	self.pImgHuang:setPositionX(nX)

	--重建家园道具数量数显刷新
	self:updateRebuildItem()

	if self.pItemCoin then
		self.pItemFood:updateValue()
		self.pItemWood:updateValue()
		self.pItemCoin:updateValue()
	end

	for k, v in pairs(self.tItemLays) do
		if v.updateViews then
			v:updateViews()
		end
	end
	
end

--析构方法
function DlgWareHouse:onDlgDlgWareHouseDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgWareHouse:regMsgs(  )
	-- body
	--注册仓库数据刷新消息
	regMsg(self, ghd_refresh_warehouse_msg, handler(self, self.updateViews))
	--注册玩家数据据刷新消息
	regMsg(self, gud_refresh_playerinfo, handler(self, self.updateViews))
	--注册背包数据刷新
	regMsg(self, gud_refresh_baginfo, handler(self, self.updateRebuildItem))
end
--注销消息
function DlgWareHouse:unregMsgs(  )
	-- body
	--销毁仓库数据刷新消息
	unregMsg(self, ghd_refresh_warehouse_msg)
	--销毁玩家数据据刷新消息
	unregMsg(self, gud_refresh_playerinfo)
	--注销背包数据刷新
	unregMsg(self, gud_refresh_baginfo)
end

--暂停方法
function DlgWareHouse:onPause( )
	-- body	
	self:unregMsgs()	
end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgWareHouse:onResume( _bReshow )
	-- body	
	self:updateViews()
	self:regMsgs()
end
--刷新高级城建刷新
function DlgWareHouse:updateRebuildItem(  )
	-- body
	--重建家园道具数量数显刷新
	self.tItemLays[1]:updateViews()	
end
return DlgWareHouse