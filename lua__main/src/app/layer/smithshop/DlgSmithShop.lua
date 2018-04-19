----------------------------------------------------- 
-- author: dshulan
-- updatetime: 2018-03-23 16:31:43
-- Description: 新版铁匠铺界面(原来的铁匠铺和洗炼铺合体)
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local FCommonTabHost = require("app.common.tabhost.FCommonTabHost")
local LaySmithShop = require("app.layer.smithshop.LaySmithShop")
local DlgRefineShop = require("app.layer.refineshop.DlgRefineShop")

local DlgSmithShop = class("DlgSmithShop", function()
	-- body
	return DlgBase.new(e_dlg_index.smithshop)
end)

function DlgSmithShop:ctor(sUuid, heroId, nFuncIdx, nEquipID, nKind)
	-- body
	self.sUuid = sUuid 			--指定的装备
	self.nJumpHeroId = heroId   --跳到指定的英雄分页
	self.nFuncIdx = nFuncIdx 	--指定的功能界面
	self.nEquipID = nEquipID 	--指定的装备id
	self.nKind = nKind 			--指定的装备种类
	self:myInit()
	parseView("dlg_smith_shop_new", handler(self, self.onParseViewCallback))
end

function DlgSmithShop:myInit(  )
	-- body
	--3个子层
	self.tItemLays = {}
	self.classes = {LaySmithShop, DlgRefineShop, DlgRefineShop}
 	self.tTitles = {getConvertedStr(7, 10402), getConvertedStr(7, 10315), getConvertedStr(7, 10316)}
 	self.nDefaultIdx = self.nFuncIdx or n_smith_func_type.build
end

--解析布局回调事件
function DlgSmithShop:onParseViewCallback( pView )
	-- body
	-- self:addContentTopSpace()
	
	self:addContentView(pView) --加入内容层

	self:setupViews()

	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgSmithShop",handler(self, self.onDlgDlgSmithShopDestroy))
end

--初始化控件
function DlgSmithShop:setupViews( )
	-- body
	--设置标题
	self:setTitle(getConvertedStr(3, 10265))

	--新手教程
	sendMsg(ghd_guide_finger_show_or_hide, true)

	self.pLyContent   = self:findViewByName("lay_cont")
	self.pTabHost = FCommonTabHost.new(self.pLyContent,1,1,self.tTitles,handler(self, self.getLayerByKey),1)
	self.pTabHost:setLayoutSize(self.pLyContent:getLayoutSize())
	self.tTabItems = self.pTabHost:getTabItems()
	self.pTabHost:removeLayTmp1()
	self.pTabHost:removeLayTmp2()
	self.pTabHost:setTabChangedHandler(handler(self, self.onTabChanged))
	self.pLyContent:addView(self.pTabHost, 10)
	self.pTabHost:setDefaultIndex(self.nDefaultIdx)
	--新手教程
	local tTabItems = self.pTabHost:getTabItems()
	local pTabRefind = tTabItems[3]
	if pTabRefind then
		Player:getNewGuideMgr():setNewGuideFinger(pTabRefind, e_guide_finer.smith_refine_tab)
	end

	--顶部功能层开启刷新
	self:topTabLockUpdate()
	--刷新顶部功能红点
	self:updateTopFuncItemRedTip()
end

function DlgSmithShop:getLayerByKey( _sKey, _tKeyTabLt )
	-- body
	local pLayer = nil	
	local tSize = self.pTabHost:getCurContentSize()
	if( _sKey == _tKeyTabLt[1]) then
		pLayer = self.classes[1].new(tSize)	
		if self.nEquipID then
			pLayer:setDefaultEquipShow(self.nEquipID)
		end
		if self.nKind then
			pLayer:setDefaultKindShow(self.nKind)
		end
		self.tItemLays[1] = pLayer
	elseif (_sKey == _tKeyTabLt[2]) then
		pLayer = self.classes[2].new(tSize, n_smith_func_type.strengthen, self.sUuid, self.nJumpHeroId)
		self.tItemLays[2] = pLayer
		self.sUuid = nil
		self.nJumpHeroId = nil
	elseif (_sKey == _tKeyTabLt[3]) then
		pLayer = self.classes[3].new(tSize, n_smith_func_type.train, self.sUuid, self.nJumpHeroId)
		self.tItemLays[3] = pLayer
		self.sUuid = nil
		self.nJumpHeroId = nil
	end
	return pLayer
end

function DlgSmithShop:onTabChanged( _sKey, _nType )
	if _sKey == "tabhost_key_1" then
		self.nSelect = n_smith_func_type.build
	elseif _sKey == "tabhost_key_2" then
		self.nSelect = n_smith_func_type.strengthen
	elseif _sKey == "tabhost_key_3" then
		self.nSelect = n_smith_func_type.train
		--新手教程
		Player:getNewGuideMgr():setNewGuideFingerClicked(e_guide_finer.smith_refine_tab)
	end
end

--设置默认打开分页
function DlgSmithShop:setDefOpenIndex(_index)
	self.pTabHost:setDefaultIndex(_index)
end

--顶部功能层开启刷新
function DlgSmithShop:topTabLockUpdate()
	-- body
	local bIsLock = true
	--洗炼功能是否开启
	local bOpen, sLockTip = getIsReachOpenCon(21, false)
	if bOpen then
		bIsLock = false
	end
	local pTopTabItem = self.tTabItems[n_smith_func_type.train]
	if bIsLock then
		pTopTabItem:showTabLock()
		pTopTabItem:setViewEnabled(false)
		pTopTabItem:onMViewDisabledClicked(handler(self, function (  )
		    -- body
		    TOAST(sLockTip)
		end))
	else
		pTopTabItem:hideTabLock()
		pTopTabItem:setViewEnabled(true)
	end
	--强化功能是否开启
	local bOpen, sLockTip = getIsReachOpenCon(20, false)
	local pTopTabItem = self.tTabItems[n_smith_func_type.strengthen]
	if not bOpen then
		pTopTabItem:showTabLock()
		pTopTabItem:setViewEnabled(false)
		pTopTabItem:onMViewDisabledClicked(handler(self, function (  )
		    -- body
		    TOAST(sLockTip)
		end))
	else
		pTopTabItem:hideTabLock()
		pTopTabItem:setViewEnabled(true)
	end
end

--刷新顶部功能按钮上的红点
function DlgSmithShop:updateTopFuncItemRedTip()
	-- body
	--获取所有已上阵的武将
	local tAllHeroList = Player:getHeroInfo():getOnlineHeroListByTeam(1)
	for i = 2, 3 do
		local tHeroList = Player:getHeroInfo():getOnlineHeroListByTeam(i)
		for k, v in pairs(tHeroList) do
			table.insert(tAllHeroList, v)
		end
	end

	local tEquipData = Player:getEquipData()
	
	for i, tab in pairs(self.tTabItems) do
		local bCan = false
		for _, pHero in pairs(tAllHeroList) do
			local tEquipVos = tEquipData:getEquipVosByKindInHero(pHero.nId)
			for _, equipVo in pairs(tEquipVos) do
				--如果是强化功能
				if i == n_smith_func_type.strengthen then
					local bOpen = getIsReachOpenCon(20, false)
					if bOpen and tEquipData:isCanStrengthen(equipVo) then
						bCan = true
						break
					end
				elseif i == n_smith_func_type.train then --如果是洗炼功能
					local bOpen = getIsReachOpenCon(21, false)
					if bOpen and tEquipData:isCanRefine(equipVo) then
						bCan = true
						break
					end
				end
			end
			if bCan then
				break
			end
		end
		if bCan then
			showRedTips(tab:getRedNumLayer(), 0, 1, 2)
		else
			showRedTips(tab:getRedNumLayer(), 0, 0, 2)
		end
	end
end


--控件刷新
function DlgSmithShop:updateViews(  )
	-- body	
	for k, v in pairs(self.tItemLays) do
		if v.updateViews then
			v:updateViews()
		end
	end
	
end

function DlgSmithShop:onHeroEquipChange(  )
	--刷新顶部功能红点
	self:updateTopFuncItemRedTip()
end

--析构方法
function DlgSmithShop:onDlgDlgSmithShopDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgSmithShop:regMsgs(  )
	-- body
	--武将装备发生变化
	regMsg(self, gud_equip_hero_equip_change, handler(self, self.onHeroEquipChange))
	--注册请求强化成功消息
	regMsg(self, gud_equip_strength_msg, handler(self, self.onHeroEquipChange))
end
--注销消息
function DlgSmithShop:unregMsgs(  )
	-- body

end

--暂停方法
function DlgSmithShop:onPause( )
	-- body	
	self:unregMsgs()	
end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgSmithShop:onResume( _bReshow )
	-- body	
	self:updateViews()
	self:regMsgs()
end



return DlgSmithShop