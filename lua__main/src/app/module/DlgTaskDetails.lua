-- Author: maheng
-- Date: 2017-05-16 19:56:24
-- 任务奖励


local DlgCommon = require("app.common.dialog.DlgCommon")
local ItemResPrize = require("app.layer.task.ItemResPrize")
local DlgTaskDetails = class("DlgTaskDetails", function ()
	return DlgCommon.new(e_dlg_index.taskdetails)
end)

--构造
function DlgTaskDetails:ctor()
	-- body
	self:myInit()	
	parseView("dlg_task_details", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgTaskDetails:myInit()
	-- body
	self._pdata = nil --任务数据	
end
  
--解析布局回调事件
function DlgTaskDetails:onParseViewCallback( pView )
	-- body
	self:addContentView(pView)
	self:setupViews()
	self:onResume()
	 --注册析构方法
    self:setDestroyHandler("DlgTaskDetails",handler(self, self.onDlgTaskDetailsDestroy))
end

--初始化控件
function DlgTaskDetails:setupViews()
	-- body
	--设置标题
	self:setTitle(getConvertedStr(6,10231))
	--标题层
	self.pLayTitle = self:findViewByName("lay_title")
	--固定标签
	self.pLbTip = self:findViewByName("lb_tip1")
	self.pLbTip:setString(getConvertedStr(6, 10232))

	--icon
	self.pLayIcon = self:findViewByName("lay_icon")

	self.pIconImg = MUI.MImage.new("ui/daitu.png")	
	self.pLayIcon:addView(self.pIconImg, 10)
	centerInView(self.pLayIcon, self.pIconImg)

	self.pLbTaskName = self:findViewByName("lb_name")
	setTextCCColor(self.pLbTaskName, _cc.blue)

	self.pLbTaskDes = self:findViewByName("lb_des")
	setTextCCColor(self.pLbTaskDes, _cc.pwhite)

	self.pLayPrize = self:findViewByName("lay_prize")
	self.tPrizeGroup = {}
	local x = 150--(self.pLayPrize:getWidth() - pItemResPrize:getWidth())/2
	local y = 180
	for i = 1, 4 do		
		local pItemResPrize = ItemResPrize.new(false)
		pItemResPrize:setValueColor(1, _cc.pwhite)
		pItemResPrize:setValueColor(2, _cc.yellow)
		pItemResPrize:setPosition(x, y-(pItemResPrize:getHeight()+ 20)*(i-1))
		self.pLayPrize:addView(pItemResPrize, 10)
		self.tPrizeGroup[i] = pItemResPrize		
	end	
end

-- 修改控件内容或者是刷新控件数据
function DlgTaskDetails:updateViews()
	-- body
	if self._pdata then
		--dump(self._pdata, "self._pdata=", 100)
		self.pLbTaskName:setString(self._pdata.sName)
		self.pLbTaskDes:setString(self._pdata.sDes)
		self.pIconImg:setCurrentImage(getTaskTxIconByType(self._pdata.nType))			
		--getIconGoodsByType(self.pLayIcon, TypeIconGoods.NORMAL, type_icongoods_show.item, self._pdata, TypeIconGoodsSize.L)
		local tdropitems = getDropById(self._pdata.nDropId)
		for k, v in pairs(self.tPrizeGroup) do			
			if tdropitems[k] then
				v:setCurData(tdropitems[k])			
			else
				v:setCurData(nil)
			end
		end		
	end	
end

--析构方法
function DlgTaskDetails:onDlgTaskDetailsDestroy()
	self:onPause()
end

-- 注册消息
function DlgTaskDetails:regMsgs( )
	-- body

end

-- 注销消息
function DlgTaskDetails:unregMsgs(  )
	-- body

end


--暂停方法
function DlgTaskDetails:onPause( )
	-- body
	self:unregMsgs()	
end

--继续方法
function DlgTaskDetails:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

--设置任务id数据
function DlgTaskDetails:setTaskId( _ntaskid )
	-- body
	self._pdata = Player:getPlayerTaskInfo():getTaskDataById(_ntaskid)
	self:updateViews()
end

return DlgTaskDetails
