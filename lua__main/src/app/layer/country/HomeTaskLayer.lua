----------------------------------------------------- 
-- author: maheng
-- updatetime: 2017-06-08 14:28:14
-- Description: 主界面主线任务层
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local HomeTaskLayer = class("HomeTaskLayer", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)


function HomeTaskLayer:ctor(  )
	-- body
	self:myInit()
	parseView("home_task_layer", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function HomeTaskLayer:myInit(  )
	-- body
	--动画特效
	self.pKuangEff = nil		
	self.pEffMid = nil
	self.pBgBreathTx = nil 		
	self.pIconKuangTx = nil
	self.bPressed = false	--界面正在响应的标志
end

--解析布局回调事件
function HomeTaskLayer:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("HomeTaskLayer",handler(self, self.onHomeTaskLayerDestroy))
end

--初始化控件
function HomeTaskLayer:setupViews( )
	-- body
	self.pLayRoot = self:findViewByName("root")
	self.pLayRoot:setIsPressedNeedScale(false)
	self.pLayRoot:setViewTouched(false)
	self.pLatClick = self:findViewByName("lay_click")
	self.pLatClick:setViewTouched(true)
	self.pLatClick:setIsPressedNeedScale(false)
	self.pLatClick:onMViewClicked(handler(self,self.jumpToTaskDlg))	

	self.pLayRight = self:findViewByName("lay_right")	
	self.pLayRight:setIsPressedNeedScale(false)
	self.pLayRight:setViewTouched(false)
	self.pLayRight:setAnchorPoint(cc.p(0, 0.5))
			



	--
	self.pImgRWXQB = self:findViewByName("img_rwxq_bot")
	self.pImgRWXQT = self:findViewByName("img_rwxq_top")
	self.pImgRWXQT:setVisible(false)
	-- self.pImgRWXQB:setAnchorPoint(cc.p(0.5, 0.5))
	-- self.pImgRWXQB:setPosition(self.pLayRight:getWidth()/2, self.pLayRight:getHeight()/2)
	-- self.pImgRWXQT:setAnchorPoint(cc.p(0.5, 0.5))
	-- self.pImgRWXQT:setPosition(self.pLayRight:getWidth()/2, self.pLayRight:getHeight()/2)
	--self.pLayRight:setScale(0.1, 1)	
	--dump(self.pImgRWXQT:getAnchorPoint(), "self.pImgRWXQT:getAnchorPoint()", 100)

	--任务名称
	self.pLbTaskName = self:findViewByName("lb_taskname")
	setTextCCColor(self.pLbTaskName, _cc.pwhite)
	--任务类型图标
	self.pImgType = self:findViewByName("img_task_type")	
	self.pImgTypeTX = self:findViewByName("img_task_type_tx")		
	
		
	--任务按钮
	self.pImgBtnTask = self:findViewByName("img_btn_task")
	self.pImgBtnTask:setIsPressedNeedScale(false)
	self.pImgBtnTask:setViewTouched(true)
	self.pImgBtnTask:onMViewClicked(handler(self, self.openTaskDlg))

	self.pLayRed = self:findViewByName("lay_red")
	self.pLayBlue = self:findViewByName("lay_blue")
	self.pLbBlueNum = self:findViewByName("lb_blue_num")
	self.pImgFinish = MUI.MImage.new("#v1_img_zycz.png")
	self.pImgFinish:setVisible(false)
	self.pImgFinish:setPosition(self.pLayRight:getWidth() - 20, self.pLayRight:getHeight() / 2)
	self.pLayRight:add(self.pImgFinish, 100)
				
	--新手引导
	Player:getNewGuideMgr():setNewGuideFinger(self.pLayRoot, e_guide_finer.home_task_layer)
	--教你玩
	Player:getGirlGuideMgr():setGirlGuideFinger(self.pLayRoot, e_guide_finer.home_task_layer)
end

-- 修改控件内容或者是刷新控件数据
function HomeTaskLayer:updateViews( )
	-- body
	local pAgencyTask = Player:getPlayerTaskInfo():getHomeTaskData()
	local tSideTasks = Player:getPlayerTaskInfo():getCurSideTasks()
	local nBlueNum = #tSideTasks
	local nRedNum = Player:getPlayerTaskInfo():getTaskMenuRed()	
	showRedTips(self.pLayRed, 1, nRedNum)
	self.pLayBlue:setVisible(nRedNum <= 0 and nBlueNum > 0)
	self.pLbBlueNum:setString(nBlueNum, false)

	if pAgencyTask then	
		self.pImgType:setVisible(true)
		self.pLayRight:setVisible(true)
		--剧情子章节
		if pAgencyTask.nGtype == e_type_goods.type_chatper_t then
			self.pImgType:setCurrentImage("#v2_btn__zjm_juqing.png")
			self.pImgTypeTX:setCurrentImage("#v2_btn__zjm_juqing.png")
		--剧情章节
		elseif pAgencyTask.nGtype == e_type_goods.type_chatper then
			self.pImgType:setCurrentImage("#v2_btn__zjm_juqing.png")
			self.pImgTypeTX:setCurrentImage("#v2_btn__zjm_juqing.png")

		elseif pAgencyTask.nGtype == e_type_goods.type_daily  then			
			self.pImgType:setCurrentImage("#v2_btn__zjm_txjj.png")
			self.pImgTypeTX:setCurrentImage("#v2_btn__zjm_txjj.png")
		else		
			if pAgencyTask.nType == 1 then
				self.pImgType:setCurrentImage("#v2_btn__zjm_zhuxian.png")
				self.pImgTypeTX:setCurrentImage("#v2_btn__zjm_zhuxian.png")
			else
				self.pImgType:setCurrentImage("#v2_btn__zjm_zhixian.png")
				self.pImgTypeTX:setCurrentImage("#v2_btn__zjm_zhixian.png")
			end			
		end
		if pAgencyTask.nTargetNum == 1 then
			self.pLbTaskName:setString(pAgencyTask.sName,false)
		else
			local str = {
				{color=_cc.white, text=pAgencyTask.sName},
				{color=_cc.white, text="("..pAgencyTask.nCurNum},
				{color=_cc.white, text="/"..pAgencyTask.nTargetNum..")"},
			}		
			self.pLbTaskName:setString(str,false)	
		end
		
		local nWid = self.pLbTaskName:getContentSize().width;
		self.pImgFinish:setPositionX(nWid + 40)
		
		--256是底图原始宽度
		-- local nWidth = 323
		-- local ncurwidth = self.pLbTaskName:getPositionX() + self.pLbTaskName:getWidth() + 20
		-- self.pImgFinish:setPosition(ncurwidth, self.pLayRight:getHeight()/2)
		-- if ncurwidth > nWidth then
		-- 	nWidth = ncurwidth
		-- end
		--动态设置背景大小
		--self.pLayRight:setLayoutSize(nWidth, self.pLayRight:getHeight())
		if pAgencyTask.nIsFinished == 1 then
			self.pImgFinish:setVisible(true)
			self:playerGetPrizeEffect(1)
		else	
			self.pImgFinish:setVisible(false)			
		end	
	else		
		self.pImgType:setVisible(false)
		self.pLayRight:setVisible(false)
		self.pLbTaskName:setString("")	
	end	
	--self.pLayRoot:setLayoutSize(self.pLayRight:getPositionX() + self.pLayRight:getWidth(), self.pLayRoot:getHeight())		
end

-- 析构方法
function HomeTaskLayer:onHomeTaskLayerDestroy(  )
	-- body
	-- removeTextureFromCache("tx/other/sg_zjm_rw")	
	-- removeTextureFromCache("tx/other/sg_zjm_rw_gq")	
	-- removeTextureFromCache("tx/other/sg_txkk_akl_gx")
end

function HomeTaskLayer:regMsgs(  )
	--注册任务刷新消息
	regMsg(self, gud_refresh_task_msg, handler(self, self.updateViews)) 
	--注册任务领奖特效
	regMsg(self, ghd_player_get_taskprize_msg, handler(self, self.displayGetTaskPrizeEffect)) 

	--任务引导刷新消息
	regMsg(self,ghd_refresh_home_bottom_msg, handler(self, self.showGuideFinger))
end

function HomeTaskLayer:unregMsgs(  )
	--注销任务刷新消息
	unregMsg(self, gud_refresh_task_msg) 
	--注册任务领奖特效
	unregMsg(self, ghd_player_get_taskprize_msg) 	
	--销毁引导刷新消息
  	unregMsg(self, ghd_refresh_home_bottom_msg)
end

function HomeTaskLayer:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function HomeTaskLayer:onPause(  )
	self:unregMsgs()
end

function HomeTaskLayer:openTaskDlg(  )
	-- body
	local tObject = {}
	tObject.nType = e_dlg_index.dlgtask --dlg类型		
	sendMsg(ghd_show_dlg_by_type,tObject)   
end

--位置移动到任务按钮可见
function HomeTaskLayer:showGuideFinger(sMsgName, pMsgObj)
	-- body
	if pMsgObj and pMsgObj.bIsShow then
		if not self.pLayFinger then
	        self.pLayFinger = MUI.MLayer.new()
	        self:addView(self.pLayFinger, 1000)        
	    end
	    self.pLayFinger:setPosition(self.pImgBtnTask:getPositionX()+5, self.pImgBtnTask:getPositionY()-10)
		local DlgFlow = require("app.common.dialog.DlgFlow")
	    local pDlg,bNew = getDlgByType(e_dlg_index.dotfinger)
	    if(not pDlg) then
	        pDlg = DlgFlow.new(e_dlg_index.dotfinger)
	    end 
	    local DotFinger = require("app.layer.world.DotFinger")
	    local nFingerType = 1
	    local pChildView = DotFinger.new(nFingerType)  
	    pDlg:showChildView(pView, pChildView)
	    pDlg:setToCenter()
	    pChildView:setData(self.pLayFinger)
	    UIAction.enterDialog( pDlg, RootLayerHelper:getCurRootLayer(), bNew)
	    pDlg:setDialogBgColor(GLOBAL_DIALOG_BG_COLOR_TRANSPARENT)
	else
		closeDlgByType( e_dlg_index.dotfinger, false )
	end
end

function HomeTaskLayer:jumpToTaskDlg(  )
	-- body
	local pAgencyTask = Player:getPlayerTaskInfo():getHomeTaskData()
	if not pAgencyTask then
		return
	end
	if self.bPressed == true then
		return
	end
	self.bPressed = true	
	--剧情的话直接跳转章节
	if Player:getPlayerTaskInfo():getChatperTask() and 
		(pAgencyTask.nGtype == e_type_goods.type_chatper or pAgencyTask.nGtype == e_type_goods.type_chatper_t) then
		local tObject = {}
		tObject.nType = e_dlg_index.chatperInfo --dlg类型
		tObject.tData = Player:getPlayerTaskInfo():getChatperTask()
		if tObject.tData then
			sendMsg(ghd_show_dlg_by_type,tObject)
		end
		self.bPressed = false
	elseif pAgencyTask.nGtype == e_type_goods.type_task then	
		if pAgencyTask.nIsFinished == 1 then--任务已经完成				
			--print("--------------1")		
			SocketManager:sendMsg("getTaskPrize", {pAgencyTask.sTid}, handler(self, self.onGetTaskPrize))
			--Player:getNewGuideMgr():setNewGuideFingerClicked(e_guide_finer.task_reward_btn)				
		else
			--跳转到任务界面		
			local tObject = {}
			tObject.nTaskID = pAgencyTask.sTid --dlg类型				
			sendMsg(ghd_task_goto_msg, tObject) 	
			Player:getNewGuideMgr():onClickedNewGuideFinger(self.pLayRoot)
			Player:getGirlGuideMgr():setGirlGuideFingerClicked(e_guide_finer.home_task_layer)
			self.bPressed = false
		end	
	else
		if pAgencyTask.nIsFinished == 1 then--任务已经完成		
			SocketManager:sendMsg("getDailyTaskPrize", {pAgencyTask.sTid}, handler(self, self.onGetTaskPrize))		
		else
			--跳转到任务界面
			local tObject = {}
			tObject.sLinked = pAgencyTask.sLinked --dlg类型		
			sendMsg(ghd_daily_task_guide_msg, tObject) 
			self.bPressed = false
		end	
	end
end

function HomeTaskLayer:onGetTaskPrize( __msg )
	-- body
	--dump(__msg, "__msg", 100)
	if __msg.head.state == SocketErrorType.success	then
		--显示下一条顺序显示
		if __msg.head.type == MsgType.getTaskPrize.id then
			--播放动画
			--self:playerGetPrizeEffect(2)
		elseif __msg.head.type == MsgType.getDailyTaskPrize.id then		
			--播放动画
			--self:playerGetPrizeEffect(2)
		end
	end
	self.bPressed = false
end
--播放领奖动画
function HomeTaskLayer:playerGetPrizeEffect( ntype )
	-- body		
	if ntype == 1 then--一般情况下的显示效果		
		TaskFunc:showCanGetPrizeTX(self.pLayRoot, self.pLayRight, self.pImgRWXQB, self.pImgRWXQT, self.pImgType, self.pImgTypeTX)
	elseif ntype == 2 then--领取奖励后的刷新
		TaskFunc:removeCanGetPrizeTX(self.pLayRoot, self.pLayRight, self.pImgRWXQB, self.pImgRWXQT, self.pImgType, self.pImgTypeTX)		
		TaskFunc:showClickTX(self.pLayRoot, self.pLayRight, self.pImgRWXQB, self.pImgRWXQT, self.pImgType, self.pImgTypeTX)
	end
end


function HomeTaskLayer:displayGetTaskPrizeEffect(  )
	-- body
	print("播放领取特效")
	self:playerGetPrizeEffect(2)
end
return HomeTaskLayer


