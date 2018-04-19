-----------------------------------------------------
-- author: maheng
-- updatetime:  2018-04-02 20:44:23 星期一
-- Description: 国家任务
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local ItemCountryTask = require("app.layer.newcountry.countrytask.ItemCountryTask")
local DlgTaskCountry = class("DlgTaskCountry", function()
	-- body
	return DlgBase.new(e_dlg_index.dlgtaskcountry)
end)

function DlgTaskCountry:ctor(  )
	-- body
	self:myInit()	
	parseView("dlg_task_country", handler(self, self.onParseViewCallback))	
end

function DlgTaskCountry:myInit(  )
	-- body
	self.pTaskList = {}
end

--解析布局回调事件
function DlgTaskCountry:onParseViewCallback( pView )
	-- body
	--设置标题
	self:setTitle(getConvertedStr(6,10222))	
	self:addContentView(pView) --加入内容层
	self:setupViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("DlgTaskCountry",handler(self, self.onDestroy))
end

--初始化控件
function DlgTaskCountry:setupViews(  )
	-- body	
	self.pLayRoot = self:findViewByName("lay_default")
	self.pLayCont = self:findViewByName("lay_cont")

	self.pLayList = self:findViewByName("lay_list")
	self.pLbTime  = self:findViewByName("lb_time")
	self.pLbTip   = self:findViewByName("lb_tip")	

	self.pLbTip:setString(getTipsByIndex(20161), false)

end

--控件刷新
function DlgTaskCountry:updateViews(  )
	-- body
	local pData = Player:getCountryTaskData()
	if not pData then
		return
	end
	--倒计时刷新
	local nLeft = pData:getCdTime()
	if nLeft > 0 then
		local sStr = {
			{color=_cc.blue,text=getConvertedStr(6,10841)},
			{color=_cc.yellow,text=formatTimeToMs(nLeft)},
		}
		self.pLbTime:setString(sStr, false)
		regUpdateControl(self, handler(self, self.onUpdate))
	else
		self.pLbTime:setString("")
		unregUpdateControl(self)
	end
	--列表刷新
	self.pTaskList = pData:getCountryTaskList()
	local nItemCnt = #self.pTaskList
	if not self.pListView then
	    self.pListView = MUI.MListView.new {
            bgColor = cc.c4b(255, 255, 255, 250),
            viewRect = cc.rect(0, 0, 600, self.pLayList:getHeight()),
            itemMargin = {left = 0,
            right = 0,
            top = 0 ,
            bottom = 10 },
            direction = MUI.MScrollView.DIRECTION_VERTICAL ,--listView方向
        }
        self.pListView:setBounceable(true) --是否回弹
        self.pListView:setPosition((self.pLayList:getWidth() - self.pListView:getWidth())/2, 0)
        self.pLayList:addView(self.pListView, 10)
        --上下箭头
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)
		self.pListView:setItemCallback(handler(self, self.onEveryCallback))		
		self.pListView:setItemCount(nItemCnt)		
		self.pListView:reload(false)	
	else		
		self.pListView:notifyDataSetChange(false, nItemCnt)
	end		
end

function DlgTaskCountry:onEveryCallback ( _index, _pView ) 
    local pView = _pView
	if not pView then
		pView = ItemCountryTask.new()	
		pView:setBtnClickCallBack(handler(self, self.onTaskBtnCallBack))			
	end
	pView:setCurData(self.pTaskList[_index])	
	return pView
end
--任务项按钮点击回调
function DlgTaskCountry:onTaskBtnCallBack(_tData)
	-- body
	if not _tData or _tData.bGet then
		return
	end
	if _tData.bFinished then--已经完成 执行领取
		SocketManager:sendMsg("getCountryTaskReward", {_tData.nId}, handler(self, self.onGetTaskPrize))
	else--未完成 执行跳转
		--跳转到任务界面
		local tObject = {}
		tObject.sLinked = _tData.sLinked --dlg类型		
		sendMsg(ghd_daily_task_guide_msg, tObject) 
	end
end

--倒计时刷新
function DlgTaskCountry:onUpdate(  )
	-- body
	local pData = Player:getCountryTaskData()
	if not pData then
		return
	end
	--倒计时刷新
	local nLeft = pData:getCdTime()
	if nLeft > 0 then
		local sStr = {
			{color=_cc.blue,text=getConvertedStr(6,10841)},
			{color=_cc.yellow,text=formatTimeToMs(nLeft)},
		}		
		self.pLbTime:setString(sStr, false)		
	else
		self.pLbTime:setString("")
		unregUpdateControl(self)
	end	
end

function DlgTaskCountry:onGetTaskPrize( __msg )
	-- body
	if __msg.head.state == SocketErrorType.success	then
		if __msg.head.type == MsgType.getCountryTaskReward.id then			
			if __msg.body.ob then
				showGetAllItems(__msg.body.ob)
			end						
		end
	end	
end

--析构方法
function DlgTaskCountry:onDestroy(  )
	-- body
	self:onPause()	
end

--注册消息
function DlgTaskCountry:regMsgs(  )
	-- body
	--注册国家任务界面刷新消息
	regMsg(self, gud_refresh_countrytask, handler(self, self.updateViews))		
end
--注销消息
function DlgTaskCountry:unregMsgs(  )
	-- body
	--注销国家任务界面刷新消息
	unregMsg(self, gud_refresh_countrytask)
end

--暂停方法
function DlgTaskCountry:onPause( )
	-- body			
	unregUpdateControl(self)
	self:unregMsgs()		
end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgTaskCountry:onResume( _bReshow )
	-- body			
	self:updateViews()
	self:regMsgs()
end

return DlgTaskCountry