----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-19 14:03:42
-- Description: 世界左边部分
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local FCommonTabHost = require("app.common.tabhost.FCommonTabHost")
local TabManager = require("app.common.TabManager")
local WorldLeftHeroDetail = require("app.layer.world.WorldLeftHeroDetail")
local WorldLeftCountryWarDetail = require("app.layer.world.WorldLeftCountryWarDetail")
local WorldLeft = class("WorldLeft", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function WorldLeft:ctor(  )
	--解析文件
	parseView("layout_world_left", handler(self, self.onParseViewCallback))
end

--解析界面回调
function WorldLeft:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("WorldLeft",handler(self, self.onWorldLeftDestroy))
end

-- 析构方法
function WorldLeft:onWorldLeftDestroy(  )
    self:onPause()
end

function WorldLeft:regMsgs(  )
	regMsg(self, gud_my_country_war_list_change, handler(self, self.updateCountryWarTip))
	regMsg(self, gud_world_task_change_msg, handler(self, self.updateHeroRedTip))
	
end

function WorldLeft:unregMsgs(  )
	unregMsg(self, gud_my_country_war_list_change)
	unregMsg(self, gud_world_task_change_msg)
end

function WorldLeft:onResume(  )
	self:regMsgs()
end

function WorldLeft:onPause(  )
	self:unregMsgs()
end

function WorldLeft:setupViews(  )
	--图标层
	self.pLayIcon = self:findViewByName("lay_icon")
	--移出的X
	self.nIconOutX = self.pLayIcon:getContentSize().width * -1

	local pLayBtnCountryWar = self:findViewByName("lay_btn_country_war")
	pLayBtnCountryWar:setViewTouched(true)
	pLayBtnCountryWar:setIsPressedNeedScale(false)
	pLayBtnCountryWar:onMViewClicked(handler(self, self.onCountryWarIconClicked))

	local pLayBtnHero = self:findViewByName("lay_btn_hero")
	pLayBtnHero:setViewTouched(true)
	pLayBtnHero:setIsPressedNeedScale(false)
	pLayBtnHero:onMViewClicked(handler(self, self.onHeroIconClicked))

	--出征数量
	self.pLayIconHeroRedTip = self:findViewByName("lay_icon_hero_red_tip")
	self.pLayTabHeroRedTip = self:findViewByName("lay_tab_hero_red_tip")


	--图标详细层
	self.pLayIconDetail = self:findViewByName("lay_icon_detail")
	self.pLayMain = self:findViewByName("lay_icon_main")
	addViewConsiderTargetForSep(self.pLayIconDetail,self.pLayMain,1)

	--移出的X
	self.nIconDetailOutX = self.pLayIconDetail:getContentSize().width * -1

	local pLayBtnBack = self:findViewByName("lay_btn_back")
	pLayBtnBack:setViewTouched(true)
	pLayBtnBack:setIsPressedNeedScale(false)
	pLayBtnBack:onMViewClicked(handler(self, self.onBtnBackClicked))
	local pTxtBack = self:findViewByName("txt_back")
	pTxtBack:setString(getConvertedStr(3, 10176),false)

	--国战数量
	self.pLayIconWarRedTip = self:findViewByName("lay_icon_war_red_tip")
	--国战详细列表数量
	self.pLayCountryWarRedTip = self:findViewByName("lay_country_war_red_tip")
	
	--分页控件
	self.pLayContent = self:findViewByName("lay_content")
	self.tTitles = {
		getConvertedStr(3, 10053),
		getConvertedStr(3, 10054),
	}
	self.pTabHost = FCommonTabHost.new(self.pLayContent,2,1,self.tTitles,handler(self, self.getLayerByKey))
	self.pTabHost:setLayoutSize(self.pLayContent:getLayoutSize())
	self.pTabHost:removeLayTmp1()
	self.pTabHost:removeLayTmp2()
	self.pLayContent:addView(self.pTabHost,10)

	--默认隐藏
	self:setVisible(false)
	--延迟展示
	doDelayForSomething(self,function (  )
		-- body
		self:setIconLayerInOut(true, true)
		self:setIconDetailInOut(false, true)
		self:setVisible(true)
	end,0.1)
end

function WorldLeft:updateViews(  )
	self:updateHeroRedTip()
	self:updateCountryWarTip()
end

function WorldLeft:onTabChanged(  )
	-- body
end

--通过key值获取内容层的layer
function WorldLeft:getLayerByKey( _sKey, _tKeyTabLt )
	local pSize = cc.size(240,696)
	if( _sKey == _tKeyTabLt[1] ) then
		pLayer = WorldLeftHeroDetail.new(pSize)
		self.pWorldLeftHeroDetail = pLayer
	elseif (_sKey == _tKeyTabLt[2] ) then
		pLayer = WorldLeftCountryWarDetail.new(pSize)
		self.pWorldLeftCountryWarDetail = pLayer
	end
	return pLayer
end

--图标层收放
--bIsIn true:移入 false:移出
function WorldLeft:setIconLayerInOut(bIsIn, bIsNoAmin)
	local fX,fY = self.pLayIcon:getPosition()
	if bIsIn then
		local fEndX = 0
		if bIsNoAmin then
			self.pLayIcon:setPosition(cc.p(fEndX, fY))
		else
			self.pLayIcon:stopAllActions()
			self.pLayIcon:runAction(cc.MoveTo:create(0.1, cc.p(fEndX, fY)))
		end
	else
		local fEndX = self.nIconOutX
		if bIsNoAmin then
			self.pLayIcon:setPosition(cc.p(fEndX, fY))
		else
			self.pLayIcon:stopAllActions()
			self.pLayIcon:runAction(cc.MoveTo:create(0.1, cc.p(fEndX, fY)))
		end
	end
end

--图标层详细层收放
--bIsIn : true:移入 false:移出
--bIsNoAnim: 不需要动作
function WorldLeft:setIconDetailInOut( bIsIn, bIsNoAnim)
	local fX,fY = self.pLayIconDetail:getPosition()
	if bIsIn then
		local fEndX = 0
		if bIsNoAnim then
			self.pLayIconDetail:setPosition(cc.p(fEndX, fY))
		else
			self.pLayIconDetail:stopAllActions()
			self.pLayIconDetail:runAction(cc.MoveTo:create(0.1, cc.p(fEndX, fY)))
		end

		--继续国战检测
		if not gIsNull(self.pWorldLeftHeroDetail) then
			self.pWorldLeftHeroDetail:onResume()
		end
		if not gIsNull(self.pWorldLeftCountryWarDetail) then
			self.pWorldLeftCountryWarDetail:onResume()
		end

	else
		local fEndX = self.nIconDetailOutX
		if bIsNoAnim then
			self.pLayIconDetail:setPosition(cc.p(fEndX, fY))
		else
			self.pLayIconDetail:stopAllActions()
			self.pLayIconDetail:runAction(cc.MoveTo:create(0.1, cc.p(fEndX, fY)))
		end

		if not gIsNull(self.pWorldLeftHeroDetail) then
			self.pWorldLeftHeroDetail:onPause()
		end
		if not gIsNull(self.pWorldLeftCountryWarDetail) then
			self.pWorldLeftCountryWarDetail:onPause()
		end
	end
end

--点击国点图标
function WorldLeft:onCountryWarIconClicked(  )
	self:setIconLayerInOut(false)
	self:setIconDetailInOut(true)
	--侦查或城战
	self.pTabHost:setDefaultIndex(2)
end

--点击英雄图标
function WorldLeft:onHeroIconClicked(  )
	self:setIconLayerInOut(false)
	self:setIconDetailInOut(true)
	self.pTabHost:setDefaultIndex(1)
end

--点击收回图标
function WorldLeft:onBtnBackClicked(  )
	self:setIconLayerInOut(true)
	self:setIconDetailInOut(false)
end

--更新武将出征数字红点
function WorldLeft:updateHeroRedTip( )
	--显示出征数量
	local nCurrCount = 0
	local tTaskMsgs = Player:getWorldData():getTaskMsgs()
	if tTaskMsgs then
		nCurrCount = table.nums(tTaskMsgs)
	end
	showRedTips(self.pLayIconHeroRedTip, 1, nCurrCount, 1)
	showRedTips(self.pLayTabHeroRedTip, 1, nCurrCount, 1)
end

--更新国战数字红点
function WorldLeft:updateCountryWarTip(  )
	--显示国战数量
	local nCurrCount = Player:getWorldData():getMyCountryWarNum()
	showRedTips(self.pLayIconWarRedTip, 1, nCurrCount, 1)
	showRedTips(self.pLayCountryWarRedTip, 1, nCurrCount, 1)
end

--获取
function WorldLeft:getLayIcon( )
	return self.pLayIcon
end

return WorldLeft