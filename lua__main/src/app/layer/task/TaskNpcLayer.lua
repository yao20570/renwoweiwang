-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-07-11 16:05:40 星期二
-- Description: 任务奖励
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")

local TaskNpcLayer = class("TaskNpcLayer", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function TaskNpcLayer:ctor(  )
	-- body
	self:myInit()
	
	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("TaskNpcLayer",handler(self, self.onTaskNpcLayerDestroy))
	
end

--初始化成员变量
function TaskNpcLayer:myInit(  )
	-- body
	self.nWidth = 80
	self.nHeight = 80
	self.nTaskID = nil
end

--初始化控件
function TaskNpcLayer:setupViews( )
	-- body
	self:setLayoutSize(self.nWidth, self.nHeight)
	-- local pImgDi = MUI.MImage.new("#v1_img_zjm_wzqph.png")
	-- self:addView(pImgDi)
	-- pImgDi:setPosition(cc.p(self.nWidth/2, self.nHeight/2))

	local pImg = MUI.MImage.new("#v1_img_luanjun_lv15_18.png", {scale9=false})
	pImg:setScale(2)
	self:addView(pImg, 100)
	centerInView(self, pImg)

	--WorldFunc.getWildArmyArmOfContainer(self, 13001, self.nWidth/2, self.nHeight/2)

	-- local pImgDayLogAwd = MUI.MImage.new("#v1_img_guojia_renwubaoxiang1.png")
	-- pImgDayLogAwd:setScale(0.8)
	-- self:addView(pImgDayLogAwd)
	-- pImgDayLogAwd:setPosition(cc.p(self.nWidth/2, self.nHeight/2))	

	self:onMViewClicked(handler(self, self.finishedNpcTask))
end

--修改控件内容或者是刷新控件数据
function TaskNpcLayer:updateViews( )
	-- body
	
end

function TaskNpcLayer:finishedNpcTask( pView )
	-- body
	if self.nTaskID then
		--不允许提示
      	setToastNCState(1)
		--禁止部分弹框
		showSequenceFunc(e_show_seq.fight)
		--
		SocketManager:sendMsg("finishTask", {self.nTaskID})
		--新手引导
		Player:getNewGuideMgr():setNewGuideFingerClicked(e_guide_finer.house3_army_btn)
	end
	-- local tObjs = {}
	-- tObjs.nCell = nil
	-- tObjs.nTaskId = nil
	-- tObjs.bOpen = false
	-- sendMsg(ghd_home_task_npc_msg, tObjs)		
end

function TaskNpcLayer:setTaskId( _nTaskId )
	-- body
	if not _nTaskId then
		self.nTaskID = nil
	else
		self.nTaskID = _nTaskId
	end	
end
--析构方法
function TaskNpcLayer:onTaskNpcLayerDestroy(  )
	-- body
end

return TaskNpcLayer