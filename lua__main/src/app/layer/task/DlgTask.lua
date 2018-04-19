-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-05-08 18:28:23 星期一
-- Description: 任务界面
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local TaskItem = require("app.module.TaskItem")
local TCommonTabHost = require("app.common.tabhost.TCommonTabHost")
local DailyTaskScoreLayer = require("app.layer.task.DailyTaskScoreLayer")

local DlgTask = class("DlgTask", function()
	-- body
	return DlgBase.new(e_dlg_index.dlgtask)
end)

function DlgTask:ctor( _index )
	-- body
	self:myInit(_index)
	parseView("dlg_task_main", handler(self, self.onParseViewCallback))
end

function DlgTask:myInit( _index )
	-- body
	self.tTaskDataList = {}
	self.tDailyDataList = {}
	self.nGuideIndex = _index or nil
	self.nCurIndex = 1
	self.pTaskListView = nil
	self.pDailyListView = nil
end

--解析布局回调事件
function DlgTask:onParseViewCallback( pView )
	-- body
	-- --设置标题
	self:setTitle(getConvertedStr(6,10219))	
	self:addContentView(pView) --加入内容层
	--self:addContentTopSpace(3)

	self:setupViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("DlgTask",handler(self, self.onDlgTaskDestroy))
end

--初始化控件
function DlgTask:setupViews(  )
	-- body	
	if not self.nGuideIndex then
		self.nCurIndex = 1
		local nNotReadNum = Player:getPlayerTaskInfo():getMissionRedNum()
		if nNotReadNum > 0 then
			self.nCurIndex = 1
			return
		end
		nNotReadNum = Player:getPlayerTaskInfo():getDailyPrizeRed() + Player:getPlayerTaskInfo():getDailyBoxRed()
		if nNotReadNum > 0 then
			self.nCurIndex = 2
			return
		end		
	else
		self.nCurIndex = self.nGuideIndex
		self.nGuideIndex = nil
	end
end

--控件刷新
function DlgTask:updateViews(  )
	-- body
	gRefreshViewsAsync(self, 4, function ( _bEnd, _index )
		if (_index == 1) then--主线任务
			if not self.pLayTask then
				self.pLayTask = self:findViewByName("lay_task_layer")				
				--头顶横条(banner)
				self.pBannerImage 			= 		self:findViewByName("lay_banner_bg")
				local pBanner1 = setMBannerImage(self.pBannerImage,TypeBannerUsed.zxrw)
				pBanner1:setMBannerOpacity(100)
				self.pLayTitle1 = self:findViewByName("lay_title_1")
				self.pLbTip1 = self:findViewByName("lb_tip_1")
				setTextCCColor(self.pLbTip1, _cc.white)	
				self.pLbTip1:setString(getConvertedStr(6, 10221))

				self.pLbTip4 = self:findViewByName("lb_tip_4")
				setTextCCColor(self.pLbTip4, _cc.pwhite)
				self.pLbTip4:setString(getTipsByIndex(20001), false)

				self.pLayTaskMain = self:findViewByName("lay_taskmain")
				self.pItemTaskMain = TaskItem.new(TypeTaskItemSize.H)--主线任务面板	
				self.pItemTaskMain:setPosition(0, 0)
				self.pItemTaskMain:hideDiBg()				
				self.pLayTaskMain:addView(self.pItemTaskMain, 10)
				centerInView(self.pLayTaskMain, self.pItemTaskMain)
				self.pItemTaskMain:setViewTouched(true)
				self.pItemTaskMain:setIsPressedNeedScale(false)
				self.pItemTaskMain:onMViewClicked(handler(self, function ( ... )
					if self.pItemTaskMain.tCurData then			
						showTaskDetails(self.pItemTaskMain.tCurData.sTid)
					end
				end))
				self.pItemTaskMain:setClickCallBack(handler(self, self.onTaskItemBtnClicked))--任务按钮点击回调		
				--任务列表				
				self.pLayList = self:findViewByName("lay_list")
				self.pLbTip3 = self:findViewByName("lb_tip_3")
				setTextCCColor(self.pLbTip3, _cc.pwhite)
				self.pLbTip3:setString(getTipsByIndex(10055), false)
				--无支线任务时候的默认表情
				self.pImg = MUI.MImage.new("#v2_img_kongwutishi.png", {scale9=false})
				self.pLayList:addView(self.pImg, 10)				
			end			

			local tAgencyTask = Player:getPlayerTaskInfo():getCurAgencyTask()
			--dump(self.pLayTaskMain:getPosition(), "self.pLayTaskMain:getPosition()=", 100)	
			if tAgencyTask then
				self.pItemTaskMain:setCurData(tAgencyTask)
				self.pItemTaskMain:setVisible(true)
				self.pLbTip4:setVisible(false)
			else
				self.pItemTaskMain:setVisible(false)
				self.pLbTip4:setVisible(true)
			end	
		elseif (_index == 2) then
			if not self.pLayDaily then
				self.pLayDaily = self:findViewByName("lay_daily_layer")
			
				self.pLayTitle2 = self:findViewByName("lay_title_2")
				self.pLbTip2 = self:findViewByName("lb_tip_2")
				setTextCCColor(self.pLbTip2, _cc.white)	
				self.pLbTip2:setString(getConvertedStr(6, 10554))		
			
				self.pBannerImage2 			= 		self:findViewByName("lay_banner_bg2")
				local pBanner2 = setMBannerImage(self.pBannerImage2,TypeBannerUsed.mrrw)
				pBanner2:setMBannerOpacity(100)			
			end
			if not self.pLayDailyTask then
				self.pLayDailyTask = self:findViewByName("lay_daily")
				self.pDailyTaskScoreLayer = DailyTaskScoreLayer.new()
				self.pLayDailyTask:addView(self.pDailyTaskScoreLayer, 5)
				centerInView(self.pLayDailyTask, self.pDailyTaskScoreLayer)				
			else
				self.pDailyTaskScoreLayer:updateViews()
			end
		elseif (_index == 3) then--支线任务列表

		elseif (_index == 4) then --			
			if not self.pTComTabHost then
				self.pLayTabHost = self:findViewByName("lay_tab")
				self.tTitles = {
					getConvertedStr(6, 10220),
					getConvertedStr(6, 10553),
				}
				self.pTComTabHost = TCommonTabHost.new(self.pLayTabHost,1,1,self.tTitles,handler(self, self.onIndexSelected))				
				self.pLayTabHost:addView(self.pTComTabHost, 1)
				self.pTComTabHost:removeLayTmp1()
				self.pTComTabHost:setDefaultIndex(self.nCurIndex)
				--按钮集
				self.pTabItems =  self.pTComTabHost:getTabItems()			
			else				
				self:updateListView()				
			end
			local bIsOpen = getIsReachOpenCon(12, false)		
			if bIsOpen == true then
				self.pTComTabHost.tTabItems[2]:setViewEnabled(true)				
				self.pTComTabHost.tTabItems[2]:hideTabLock()				
			else
				--每日目标未开启的时候，每日目标标签页关闭	
				self.nCurIndex = 1			
				self.pTComTabHost.tTabItems[2]:showTabLock()
				self.pTComTabHost.tTabItems[2]:setViewEnabled(false)
				self.pTComTabHost.tTabItems[2]:onMViewDisabledClicked(handler(self, function (  )
					-- body
					getIsReachOpenCon(12, true)
				end))				
			end
			self.pTComTabHost:setDefaultIndex(self.nCurIndex)	
		end

		if _bEnd then
			local nNotReadNum = 0
			local pTabItem = self.pTabItems[1]--任务
			if pTabItem then --报告
				nNotReadNum = Player:getPlayerTaskInfo():getMissionRedNum()
				showRedTips(pTabItem:getRedNumLayer(), 1, nNotReadNum, 2)		
			end	
			local pTabItem = self.pTabItems[2]--每日目标
			if pTabItem then --报告
				local nNotReadNum = Player:getPlayerTaskInfo():getDailyPrizeRed() + Player:getPlayerTaskInfo():getDailyBoxRed()
				showRedTips(pTabItem:getRedNumLayer(), 1, nNotReadNum, 2)		
			end			
		end
	end)
end

--下标选择回调事件
function DlgTask:onIndexSelected( _index )
	--dump(_index, "_index=", 100)
	local nListHeight = 0

	--界面调整
	self.nCurIndex = _index
	if _index == 1 then 											--任务
		self.pLayTask:setVisible(true)
		self.pLayDaily:setVisible(false)
				
		--默认内容
		self.pImg:setVisible(nItemCnt == 0)
		self.pLbTip3:setVisible(nItemCnt == 0)		
	else 															--日常目标
		self.pLayTask:setVisible(false)
		self.pLayDaily:setVisible(true)


	end
	self.pLbTip3:setPosition(self.pLayList:getWidth()/2, self.pLayList:getHeight()/2)
	self.pImg:setPosition(self.pLayList:getWidth()/2, self.pLbTip3:getPositionY() + self.pLbTip3:getHeight()/2 + self.pImg:getHeight()/2 + 20)			
	
	self:updateListView()
end

--刷新主线任务和积分面板
function DlgTask:updateTopInfo(  )
	-- body
	if not self.pItemTaskMain then
		self.pItemTaskMain = TaskItem.new(TypeTaskItemSize.H)--主线任务面板	
		self.pItemTaskMain:setPosition(0, 0)
		self.pItemTaskMain:hideDiBg()				
		self.pLayTaskMain:addView(self.pItemTaskMain, 10)
		centerInView(self.pLayTaskMain, self.pItemTaskMain)
		self.pItemTaskMain:setViewTouched(true)
		self.pItemTaskMain:setIsPressedNeedScale(false)
		self.pItemTaskMain:onMViewClicked(handler(self, function ( ... )
			if self.pItemTaskMain.tCurData then			
				showTaskDetails(self.pItemTaskMain.tCurData.sTid)
			end
		end))
		self.pItemTaskMain:setClickCallBack(handler(self, self.onTaskItemBtnClicked))--任务按钮点击回调	
	end

end

function DlgTask:updateListView(  )
	-- body
	self.tTaskDataList = {}	
	self.tDailyDataList = {}
	if self.nCurIndex == 1 then
		self.tTaskDataList = Player:getPlayerTaskInfo():getCurSideTasks()		
	else
		self.tDailyDataList = Player:getPlayerTaskInfo():getDailyTasks()			
	end
	if not self.pTaskListView then
		self.pTaskListView = createNewListView(self.pLayList)	
		self.pTaskListView:setItemCallback(handler(self, self.onListViewItemCallBack))
		self.pTaskListView:setItemCount(#self.tTaskDataList)
		self.pTaskListView:reload(false)		
	else		
		self.pTaskListView:setItemCount(#self.tTaskDataList)	
		self.pTaskListView:notifyDataSetChange(false)
	end	

	if not self.pDailyListView then
		local pDailyListLayer = self:findViewByName("lay_daily_list")
		self.pDailyListView = createNewListView(pDailyListLayer)	
		self.pDailyListView:setItemCallback(handler(self, self.onDailyListItemCallBack))
		self.pDailyListView:setItemCount(#self.tDailyDataList)
		self.pDailyListView:reload(false)		
	else		
		self.pDailyListView:setItemCount(#self.tDailyDataList)	
		self.pDailyListView:notifyDataSetChange(false)
	end

end

--析构方法
function DlgTask:onDlgTaskDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgTask:regMsgs(  )
	-- body
	--注册任务数据刷新新消息
	regMsg(self, gud_refresh_task_msg, handler(self, self.updateViews))	
end
--注销消息
function DlgTask:unregMsgs(  )
	-- body
	--注销任务数据刷新新消息
	unregMsg(self, gud_refresh_task_msg)
end

--暂停方法
function DlgTask:onPause( )
	-- body
	removeTextureFromCache("tx/other/tx_treasurebox")--清理宝箱特效文件
	removeTextureFromCache("ui/p2_banner2", 3)--
	self:unregMsgs()	
end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgTask:onResume( _bReshow )
	-- body		
	addTextureToCache("tx/other/tx_treasurebox")	--添加宝箱特效文件
	addTextureToCache("ui/p2_banner2", 3)	--
	self:updateViews()
	self:regMsgs()
end

--列表项回调
function DlgTask:onListViewItemCallBack(_index, _pView)
	-- body	
    local pTempView = _pView
    if pTempView == nil then
        pTempView = TaskItem.new(TypeTaskItemSize.N)                        
        pTempView:setViewTouched(true)
        pTempView:setIsPressedNeedScale(false)
        pTempView:setIsIconCanTouched(false)
        pTempView:setClickCallBack(handler(self, self.onTaskItemBtnClicked))
    end
    local tCurTask = self.tTaskDataList[_index]
	pTempView:setCurData(tCurTask)	
	pTempView:onMViewClicked(function ()
        if pTempView.tCurData then
        	showTaskDetails(pTempView.tCurData.sTid)
    	end    
    end)
    return pTempView
end

function DlgTask:onDailyListItemCallBack(_index, _pView)
	-- body	
    local pTempView = _pView
    if pTempView == nil then
        pTempView = TaskItem.new(TypeTaskItemSize.N)                        
        pTempView:setViewTouched(true)
        pTempView:setIsPressedNeedScale(false)
        pTempView:setIsIconCanTouched(false)
        pTempView:setClickCallBack(handler(self, self.onTaskItemBtnClicked))
    end
    local tCurTask = self.tDailyDataList[_index]
	pTempView:setCurData(tCurTask)	
	pTempView:onMViewClicked(function ()
        if pTempView.tCurData then
        	showTaskDetails(pTempView.tCurData.sTid)
    	end    
    end)
    return pTempView
end


--item按钮回调
function DlgTask:onTaskItemBtnClicked( _taskdata )
	-- body
	--dump(_taskdata, "_taskdata", 100)
	if _taskdata.nGtype == e_type_goods.type_task then
		if _taskdata.nIsFinished == 1 then--任务已经完成		
			SocketManager:sendMsg("getTaskPrize", {_taskdata.sTid}, handler(self, self.onGetTaskPrize))		
		else
			--跳转到任务界面
			local tObject = {}
			tObject.nTaskID = _taskdata.sTid --dlg类型		
			sendMsg(ghd_task_goto_msg, tObject) 
		end
	elseif _taskdata.nGtype == e_type_goods.type_daily then
		if _taskdata.nIsFinished == 1 then--任务已经完成		
			SocketManager:sendMsg("getDailyTaskPrize", {_taskdata.sTid}, handler(self, self.onGetTaskPrize))		
		else
			--跳转到任务界面
			local tObject = {}
			tObject.sLinked = _taskdata.sLinked --dlg类型		
			sendMsg(ghd_daily_task_guide_msg, tObject) 
		end	
	end
	
end

function DlgTask:onGetTaskPrize( __msg )
	-- body
	if __msg.head.state == SocketErrorType.success	then
		if __msg.head.type == MsgType.getTaskPrize.id then
			--显示领奖特效		
			--sendMsg(ghd_player_get_taskprize_msg)	
		elseif __msg.head.type == MsgType.getDailyTaskPrize.id then		
			--sendMsg(ghd_player_get_taskprize_msg)
		end
	end
end

function DlgTask:setGuideIndex( _index )
	-- body
	if _index then
		self.nCurIndex = _index
	end
end
return DlgTask