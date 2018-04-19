-- DlgDayLoginAwards.lua
-----------------------------------------------------
-- author: dshulan
-- updatetime:  2017-06-30 13:57:23 星期五
-- Description: 每日登录奖励弹窗
-----------------------------------------------------

local DlgCommon = require("app.common.dialog.DlgCommon")
local ItemAwardsRow = require("app.layer.dayloginawd.ItemAwardsRow")

local DlgDayLoginAwards = class("DlgDayLoginAwards", function()
	-- body
	return DlgCommon.new(e_dlg_index.dayloginawards)
end)

function DlgDayLoginAwards:ctor()
	-- body
	self:myInit()

	parseView("dlg_day_login", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgDayLoginAwards:myInit(  )
	-- body
	-- self.tData = Player:getDayLoginData():getAwardsList()
	self.tData = Player:getDayLoginData():getCurAwardList()

	
-- 	self.tData = {
-- 	[1] = {k=3, v=3000},
-- 	[2] = {k=4, v=3000},
-- 	[3] = {k=2, v=3000},
-- 	[4] = {k=5, v=3000},
-- 	[5] = {k=3, v=3000},
-- 	[6] = {k=100083, v=2},
-- }
end


--解析布局回调事件
function DlgDayLoginAwards:onParseViewCallback( pView )
	-- body
	self.pView = pView
	self:retryContentHeight()
	self:addContentView(pView, true) --加入内容层
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgDayLoginAwards",handler(self, self.onDestroy))
end

--初始化控件
function DlgDayLoginAwards:setupViews( )
	--设置title
	self:setTitle(getConvertedStr(7, 10101))
	--收取民贡按钮
	self:setOnlyConfirm(getConvertedStr(7, 10103))
	self:setOnlyConfirmBtn(TypeCommonBtn.L_YELLOW)
	self:setRightHandler(handler(self, self.onBtnClicked))

	self.pLayRoot	        = 		self.pView:findViewByName("default")
	self.pImgGuid 			= 		self.pView:findViewByName("img_guid")
	--lb
	self.pLayTip			= 		self.pView:findViewByName("lay_tip")
	--list
	self.pLayListView   	= 		self.pView:findViewByName("lay_list")	
	local pLbTip =  MUI.MLabel.new({
		text = getConvertedStr(7, 10102),
		size = 20,
		align = cc.ui.TEXT_ALIGN_CENTER,
		valign = cc.ui.TEXT_VALIGN_TOP,
		dimensions = cc.size(260, 0),
		})
	self.pLayTip:addView(pLbTip,10)
	pLbTip:setPosition(cc.p(200, 39))

	local itemNum = table.nums(self.tData)
	--如果奖励大于4就创建列表	
	if itemNum > 4 then
		self.pListView = MUI.MListView.new {
		    viewRect = cc.rect(0, 0, self.pLayListView:getWidth(), self.pLayListView:getHeight()),
		    itemMargin = {
		    	left =  0,
			    right = 0,
			    top = 60,
			    bottom = 0},
		    direction = MUI.MScrollView.DIRECTION_VERTICAL}
		self.pLayListView:addView(self.pListView)
		local nCnt = math.ceil(table.nums(self.tData)/4)
		if nCnt > 2 then
			self.pListView:setBounceable(true)
		else
			self.pListView:setBounceable(false)
		end
		self.pListView:setItemCount(nCnt) 
		self.pListView:setItemCallback(function ( _index, _pView )
	        local pTempView = _pView
	    	if pTempView == nil then
	        	pTempView = ItemAwardsRow.new(_index)                        
	        end
	        pTempView:setItemData(self.tData)
	        return pTempView
	    end)
	    self.pListView:reload()
	else
		local pItemView = ItemAwardsRow.new(1)
		pItemView:setItemData(self.tData)
		self.pLayRoot:addView(pItemView, 10, 10)
		pItemView:setPosition(cc.p(0, (173 - pItemView:getHeight())/2))
	end
end

function DlgDayLoginAwards:retryContentHeight(  )
	-- body

	self.pLayRoot	        = 		self.pView:findViewByName("default")
	self.pImgGuid 			= 		self.pView:findViewByName("img_guid")
	--lb
	self.pLayTip			= 		self.pView:findViewByName("lay_tip")
	--list
	self.pLayListView   	= 		self.pView:findViewByName("lay_list")

	local nHeight = self.pLayRoot:getHeight()
	local itemNum = table.nums(self.tData)	
	local nOffY = 120
	if itemNum <= 4 then
		nHeight = nHeight - nOffY
		self.pLayListView:setLayoutSize(self.pLayListView:getWidth(), nHeight - self.pLayTip:getHeight())
		self.pLayTip:setPositionY(self.pLayTip:getPositionY() - nOffY)
		self.pImgGuid:setPositionY(self.pImgGuid:getPositionY() - nOffY)
		self.pLayRoot:setLayoutSize(self.pLayRoot:getWidth(), nHeight)
	end
end

--点击收取民贡按钮回调
function DlgDayLoginAwards:onBtnClicked(pView)
	-- body
	-- SocketManager:sendMsg("reqGetDayAwards", {}, function(__msg)
	-- 	-- body
	-- 	-- dump(__msg.body)
	-- 	if __msg.body and __msg.body.ob then
	-- 		--奖励动画展示
	-- 		showGetAllItems(__msg.body.ob, 1)
	-- 	end
	-- 	self:closeCommonDlg()
	-- end)
end

-- 修改控件内容或者是刷新控件数据
function DlgDayLoginAwards:updateViews()
	self:changeToOtherType()
end

-- 析构方法
function DlgDayLoginAwards:onDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function DlgDayLoginAwards:regMsgs( )
	-- body
end

-- 注销消息
function DlgDayLoginAwards:unregMsgs(  )
	-- body
end


--暂停方法
function DlgDayLoginAwards:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function DlgDayLoginAwards:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
	
end

return DlgDayLoginAwards