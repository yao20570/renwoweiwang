----------------------------------------------------- 
-- author: xiesite
-- updatetime: 2018-02-26 19:59:52
-- Description: 周卡月卡
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local ItemMonthWeekCard = require("app.layer.activityb.monthweekcard.ItemMonthWeekCard")
local DlgMonthWeekCard = class("DlgMonthWeekCard", function()
	return DlgBase.new(e_dlg_index.monthweekcard)
end)

function DlgMonthWeekCard:ctor(  )
	parseView("dlg_month_week_card", handler(self, self.onParseViewCallback))
end

--解析布局回调事件
function DlgMonthWeekCard:onParseViewCallback( pView )
	-- body
	self:addContentView(pView) --加入内容层
	self:addContentTopSpace()
	
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgMonthWeekCard",handler(self, self.onDlgPeopleRebateDestroy))
end

--初始化控件
function DlgMonthWeekCard:setupViews()
 	local tData = Player:getActById(e_id_activity.monthweekcard)
	--设置标题
	self:setTitle(tData.sName)
	self.pImgTips = self:findViewByName("img_tips")
	self.pImgTips:setViewTouched(true)
	self.pImgTips:onMViewClicked(handler(self, self.showTips))

	self.pLbTips = self:findViewByName("lb_tip")
	self.pLbTips:setString(getConvertedStr(1,10374))

	self.pLayBannerBg  = self:findViewByName("lay_banner_bg")
	setMBannerImage(self.pLayBannerBg,TypeBannerUsed.ac_ykzk)
end

function DlgMonthWeekCard:showTips()
	-- if not self.pData then
	-- 	return
	-- end
	local DlgAlert = require("app.common.dialog.DlgAlert")
    local pDlg, bNew = getDlgByType(e_dlg_index.alert)
    if(not pDlg) then
        pDlg = DlgAlert.new(e_dlg_index.alert)
    end
    local tData = Player:getActById(e_id_activity.monthweekcard)
    pDlg:setTitle(getConvertedStr(3, 10091))
    local sStr = tData.sDesc or ""
    pDlg:setContentLetter(sStr)
    pDlg:setOnlyConfirm(getConvertedStr(1, 10364))
    pDlg:setRightHandler(function ()            
        closeDlgByType(e_dlg_index.alert, false)  
    end)
    pDlg:showDlg(bNew)
end

--控件刷新
function DlgMonthWeekCard:updateViews()
	local tData = Player:getActById(e_id_activity.monthweekcard)
	if not tData then
		self:closeDlg(false)
	 	return 
	end

	if not self.pActTime then
		--活动时间
		self.pActTime = createActTime(self.pLayBannerBg, tData, cc.p(0, 186))
	else
		self.pActTime:setCurData(tData)
	end

	self.tAllAwdInfo = tData.tCs or {}
	table.sort(self.tAllAwdInfo, function(a, b)
		return a.id < b.id
	end)

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
	            top    = 10, 
	            bottom = 10}
	    }
	    self.pLayList:addView(self.pListView)
		local nCount = table.nums(self.tAllAwdInfo)
		self.pListView:setItemCount(nCount)
		self.pListView:setItemCallback(function ( _index, _pView ) 
		    local pTempView = _pView
		    if pTempView == nil then
		    	pTempView = ItemMonthWeekCard.new()
			end
			pTempView:setCurData(self.tAllAwdInfo[_index])
		    return pTempView
		end)
		--上下箭头
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)
		self.pListView:reload()

	else
		self.pListView:notifyDataSetChange(true)
	end

end

--析构方法
function DlgMonthWeekCard:onDlgPeopleRebateDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgMonthWeekCard:regMsgs(  )
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))
end
--注销消息
function DlgMonthWeekCard:unregMsgs(  )
	unregMsg(self, gud_refresh_activity)
end

--暂停方法
function DlgMonthWeekCard:onPause( )
	self:unregMsgs()	
end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgMonthWeekCard:onResume( _bReshow )
	self:updateViews()
	self:regMsgs()
end

return DlgMonthWeekCard