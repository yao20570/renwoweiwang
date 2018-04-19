-- DlgFarmTroopsPlan.lua

----------------------------------------------------- 
-- author: dengshulan
-- updatetime: 2017-08-07 15:39:52
-- Description: 屯田计划
-----------------------------------------------------
local DlgBase = require("app.common.dialog.DlgBase")
local ItemFarmTroopsGetReward  = require("app.layer.activityb.farmtroopsplan.ItemFarmTroopsGetReward")
local DlgFarmTroopsPlan = class("DlgFarmTroopsPlan", function()
	return DlgBase.new(e_dlg_index.dlgfarmtroopsplan)
end)

function DlgFarmTroopsPlan:ctor(  )
	parseView("dlg_farmtroops_plan", handler(self, self.onParseViewCallback))
end

--解析布局回调事件
function DlgFarmTroopsPlan:onParseViewCallback( pView )
	-- body
	self:addContentView(pView) --加入内容层
	self:addContentTopSpace()
	self:setupViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("DlgFarmTroopsPlan",handler(self, self.onDlgFarmTroopsPlanDestroy))
end

function DlgFarmTroopsPlan:setupViews()
	local tData = Player:getActById(e_id_activity.farmtroopsplan)
	-- body
	--设置标题
	self:setTitle(tData.sName)
	--描述
	self.pLayTip = self:findViewByName("lay_jianbian")
	local pLbDesc = self:findViewByName("lb_tip")

	self.pLbDesc = MUI.MLabel.new({
		    text = "",
		    size = 20,
		    anchorpoint = cc.p(0, 0),
		    align = cc.ui.TEXT_ALIGN_LEFT,
			valign = cc.ui.TEXT_VALIGN_TOP,
		    color = cc.c3b(255, 255, 255),
		    dimensions = cc.size(560, 0),
		})
	self.pLbDesc:setPosition(15, 5)
	self.pLayTip:addView(self.pLbDesc, 10)

	--banner
	self.pLayBannerBg = self:findViewByName("lay_banner_bg")
	setMBannerImage(self.pLayBannerBg,TypeBannerUsed.fl_ttjh)
end


--控件刷新
function DlgFarmTroopsPlan:updateViews()
	local tData = Player:getActById(e_id_activity.farmtroopsplan)
	if not tData then
		self:closeDlg(false)
	 	return 
	end
	if tData.sDesc then
		self.pLbDesc:setString(tData.sDesc)
		local nHeight = 90
		if nHeight < self.pLbDesc:getHeight() + 10 then
			nHeight = self.pLbDesc:getHeight() + 10
			self.pLbDesc:setPositionY(5)
		else
			self.pLbDesc:setPositionY((nHeight - self.pLbDesc:getHeight() + 10)/2)
		end
		self.pLayTip:setContentSize(self.pLayTip:getWidth(), nHeight)		
		self.pLayTip:setBackgroundImage("#v1_img_blackjianbian.png",{scale9 = true,capInsets=cc.rect(134,32, 1, 1)})
	end

	if not self.pActTime then
		--活动时间
		self.pActTime = createActTime(self.pLayBannerBg, tData, cc.p(0, 242))
	else
		self.pActTime:setCurData(tData)
	end

	self.tAllAwdInfo = tData.tPlans or self.tAllAwdInfo

	--更新列表数据
	if not self.pListView then
		--列表
		if not self.pLayList then
			self.pLayList = self:findViewByName("lay_list")
		end
		local pSize = self.pLayList:getContentSize()
		self.pListView = MUI.MListView.new {
			viewRect   = cc.rect(0, 0, pSize.width, pSize.height),
			direction  = MUI.MScrollView.DIRECTION_VERTICAL,
			itemMargin = {
				left   = 0,
	            right  = 0,
	            top    = 33, 
	            bottom = 0}
	    }
	    self.pLayList:addView(self.pListView)
		local nCount = table.nums(self.tAllAwdInfo)
		self.pListView:setItemCount(nCount)
		self.pListView:setItemCallback(function ( _index, _pView ) 
		    local pTempView = _pView
		    if pTempView == nil then
		    	pTempView = ItemFarmTroopsGetReward.new()
			end
			pTempView:setItemAwdInfo(self.tAllAwdInfo[_index], tData)
		    return pTempView
		end)
		self.pListView:reload()
	else
		self.pListView:notifyDataSetChange(true)
	end
end


--析构方法
function DlgFarmTroopsPlan:onDlgFarmTroopsPlanDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgFarmTroopsPlan:regMsgs(  )
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))
end
--注销消息
function DlgFarmTroopsPlan:unregMsgs(  )
	unregMsg(self, gud_refresh_activity)
end

--暂停方法
function DlgFarmTroopsPlan:onPause( )
	self:unregMsgs()	
end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgFarmTroopsPlan:onResume(_bReshow)
	self:updateViews()
	self:regMsgs()
end


return DlgFarmTroopsPlan