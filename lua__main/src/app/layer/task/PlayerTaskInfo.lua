-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-05-16 11:48:43 星期二
-- Description: 玩家任务信息
-----------------------------------------------------

local DataChatperTask = require("app.layer.task.data.DataChatperTask")

local PlayerTaskInfo = class("PlayerTaskInfo")
local nUnLockCollectTask = 20017


function PlayerTaskInfo:ctor(  )
	self:myInit()
end

function PlayerTaskInfo:myInit(  )
	-- body
	self.tMissions = {}--读取任务配表中的任务基础信息
	self.tDailyTasks = {}--日常任务	
	self.tChatper  = nil--剧情任务当前章节
	self.tOldChater = nil
	self.tG 	= {} --领奖项
	self.nDp 	= 0  --任务积分
	self.nReSetTime = 0 --刷新时间
	self.tCurAgencyTask = nil --当前主线任务
	self.tCurSideTasks = nil --当前支线任务
	self.bIsOpenedNpc = false
	self.pDialogLayer = nil
end

function PlayerTaskInfo:getDialogLayer()
	return self.pDialogLayer
end

function PlayerTaskInfo:setDialogLayer(pLayer)
	self.pDialogLayer = pLayer
end

-- 根据服务端信息刷新任务数据
--单个任务的服务信息
function PlayerTaskInfo:refreshDatasByService( tData )
	--body
	--dump(tData, "tData", 10)
	if tData.missions then				--数据加载
		for k, v in pairs(tData.missions) do
			local tmpdata = self:getTaskDataById(v.i)
			if tmpdata then
				tmpdata:refreshItemDataByService(v)	
			else	
				tmpdata = getTaskDatasFromDB(v.i)
				if tmpdata then
					tmpdata:refreshItemDataByService(v)	
					table.insert(self.tMissions, tmpdata)	
				end							
			end			
		end
	end
	if tData.dailys then 			--每日目标
		for k, v in pairs(tData.dailys) do
			local tmpdata = self:getTaskDataById(v.i)
			if tmpdata then
				tmpdata:refreshItemDataByService(v)	
			else		
				tmpdata = getDailyTaskBaseDataFromDB(v.i)
				if tmpdata then
					tmpdata:refreshItemDataByService(v)	
					table.insert(self.tDailyTasks, tmpdata)	
				end		
			end			
		end
	end

	if tData.c and tData.chatper then 			--每日目标
		local tmpdata = self:getChatperTask()
		--判断是新的章节还是老章节
		if tmpdata and ( not tData.c.i  or tData.c.i == tmpdata.sTid) then			
			tmpdata:refreshItemDataByService(tData.c, tData.o)	
		else
			if tmpdata then
				--章节结束，可以弹出结束对话
				self.tOldChater = copyTab(tmpdata)
				--章节结束对话
			end
			tmpdata = DataChatperTask.new()
			if tmpdata then
				tmpdata:refreshItemDataByService(tData.c, tData.o)
				tmpdata:initDataByDB(getChatperData(tData.c.i))
				self.tChatper = tmpdata
				--有旧的先完成旧的对话再开启
				if tData.o == 1 and Player:getUIHomeLayer( ) and not self.tOldChater then
					openChatperOpen()
				end
			end
		end
		self.tChatper = tmpdata
	end

	if tData.i then--单条任务数据刷新
		local tmpdata = self:getTaskDataById(tData.i)
		if tmpdata then
			tmpdata:refreshItemDataByService(tData)
		end	
	end

	self.nDp = tData.dp or self.nDp --积分

	self.tG = tData.g or self.tG--领奖	
	if tData.cd then--每日目标刷新倒计时
		self.nReSetTime = tData.cd/1000
		self.nLastLoadTime  	= 		getSystemTime()
	end
	
	table.sort(self.tMissions, function (a, b )
		-- body
		if a.nIsFinished == b.nIsFinished then
			if a.nSequence == b.nSequence then
				if a.nType == b.nType then
					return a.sTid < b.sTid
				else
					return a.nType < b.nType --
				end
			else
				return a.nSequence < b.nSequence
			end
		else
			return a.nIsFinished > b.nIsFinished --已完成的优先
		end
	end)

	table.sort(self.tDailyTasks, function (a, b )
		-- body		
		return a.nSort < b.nSort
	end)


	--dump(self.tDailyTasks,"self.tDailyTasks=", 100)
	--刷新当前用于显示的主线任务和支线任务
	self:updateCurAgencyTask()
	self:updateCurSideTasks()


	sendMsg(ghd_task_home_menu_red_msg)
	--一键征收任务
	if self.tCurAgencyTask then
		if self.nPrevCurAgencyTask ~= self.tCurAgencyTask.sTid then
			self.nPrevCurAgencyTask = self.tCurAgencyTask.sTid
			if self.tCurAgencyTask.sTid == tonumber(getMissionParam("collection") or 0) then				
				sendMsg(ghd_unlock_one_collect_all)
			end
		end
	end

	for k, v in pairs(self.tMissions) do
		if v.bShowTips then
			v.bShowTips = false
			local tObject = {}
			tObject.nTaskId = v.sTid		
			sendMsg(ghd_open_dlg_gettaskprize,tObject) 
		end
	end	

end


--删除已领奖任务
function PlayerTaskInfo:removeFinishedTask( _taskid )
	-- body	
	if _taskid then
		local nCnt = #self.tMissions
		local idx = nCnt
		for i = 1, #self.tMissions do 			
			if self.tMissions[idx] and self.tMissions[idx].sTid == _taskid then
				table.remove(self.tMissions, idx)						
			end
			idx = nCnt - i
		end
	end
end

--领取日常任务奖励
function PlayerTaskInfo:setGetDailyTaskPrizeStatus( _id )
	-- body
	local tDalilyData = self:getTaskDataById(_id)
	if tDalilyData then
		tDalilyData:setTaskGetPrize(1)
		table.sort(self.tDailyTasks, function (a, b )
			-- body		
			return a.nSort < b.nSort
		end)			
	end

end

--获取任务红点数量
function PlayerTaskInfo:getMissionRedNum(  )
	-- body
	local nNum = 0
	for i, v in pairs(self.tMissions) do
		if v.nIsFinished == 1 then
			nNum = nNum + 1
		end
	end
	return nNum
end

--获取日常任务奖励红点
function PlayerTaskInfo:getDailyPrizeRed(  )
	-- body
	local nNum = 0
	if getIsReachOpenCon(12, false) == false then
		return nNum
	end
	for k, v in pairs(self.tDailyTasks) do
		if v.nIsFinished == 1 and v.nIsGetPrize == 0 then
			nNum = nNum + 1
		end
	end
	return nNum
end

--获取任务menu红点
function PlayerTaskInfo:getTaskMenuRed(  )
	-- body
	return self:getMissionRedNum() + self:getDailyPrizeRed() + self:getDailyBoxRed()
end
--获取日常任务积分宝箱奖励红点数
function PlayerTaskInfo:getDailyBoxRed( )
	-- body	
	local nNum = 0
	if getIsReachOpenCon(12, false) == false then
		return nNum
	end	
	local tDailyTaskScore = getDailyTaskParam()	
	for k, v in pairs(tDailyTaskScore) do
		if self:getBoxStatus(v.nScore) ==  e_box_status.prize then
			nNum = nNum + 1
		end
	end
	return nNum
end
--刷新当前的主线任务
function PlayerTaskInfo:updateCurAgencyTask(  )
	-- body
	self.tCurAgencyTask = nil
	for i, v in pairs(self.tMissions) do
		if v.nType == e_task_type.main then
			self.tCurAgencyTask = v
			break
		end
	end		
	--dump(self.tCurAgencyTask, "self.tCurAgencyTask=", 100)
end
--支线任务排序比较
function campareTask(a, b )
	-- body
	if a.nIsFinished == b.nIsFinished then
		if a.nType == b.nType then
			return a.sTid < a.sTid
		else
			return a.nType < b.nType
		end
	else
		return a.nIsFinished > b.nIsFinished
	end
end
--刷新当前支线任务
function PlayerTaskInfo:updateCurSideTasks(  )
	-- body
	self.tCurSideTasks = {}
	for i, v in pairs(self.tMissions) do
		if v.nType ~= e_task_type.main then
			table.insert(self.tCurSideTasks, v)
		end
	end	
	--dump(self.tCurSideTasks, "self.tCurSideTasks=", 100)
end
--获取当前的主线任务数据
function PlayerTaskInfo:getCurAgencyTask()
	return self.tCurAgencyTask
end

--获取当前支线任务数据
function PlayerTaskInfo:getCurSideTasks(  )
	-- body
	return self.tCurSideTasks
end

--获取当前的每日目标
function PlayerTaskInfo:getDailyTasks(  )
	-- body
	return self.tDailyTasks
end

--获取主界面的任务限时
function PlayerTaskInfo:getHomeTaskData(  )
	-- body	
	local pTask = nil
	-- dump(self.tChatper, "11111  self.tChatper ", 100 )

	if getIsReachOpenCon(12, false) == true then--每日目标开启
		if self.tDailyTasks then
			pTask = self.tDailyTasks[1]			
		end		
	end	
	if pTask and pTask.nIsFinished == 1 and pTask.nIsGetPrize == 0 then
		return pTask
	else
		--主线可领优先显示
		if self.tMissions and self.tMissions[1] and self.tMissions[1].nIsFinished == 1 and self.tMissions[1].nIsGetPrize == 0 then
			return self.tMissions[1]
		end
	 	if self.tChatper then
	 		if self.tChatper:getCurTask() then
	 			return self.tChatper:getCurTask()
	 		end
		end 
		if not self.tMissions then
			return nil
		end
		return self.tMissions[1]		
	end
end
--获取某个章节所有的数据
function PlayerTaskInfo:getChatperTask()
	if self.tChatper then
		return self.tChatper
	end
	return nil
end

--获取旧章节数据
function PlayerTaskInfo:getOldChatperTask()
	if self.tOldChater then
		return self.tOldChater
	end
	return nil
end


--获取旧章节数据
function PlayerTaskInfo:setOldChatperTask(_tOldChater)
	self.tOldChater = _tOldChater
end

--重置旧章节数据
function PlayerTaskInfo:resetOldChatperTask()
	self.tOldChater = nil
end

function PlayerTaskInfo:resetChatperTask()
	self.tChatper = nil
end

--获取某个任务的数据
function PlayerTaskInfo:getTaskDataById( _id )
	-- body
	if not _id then
		return nil
	end
	if  _id >= 20001  and _id <= 29999 then--任务列表
		for i, v in pairs(self.tMissions) do
			if v and v.sTid == _id then
				return v
			end
		end
	elseif _id >= 4001 and _id <= 4999 then--日常目标
		for i, v in pairs(self.tDailyTasks ) do
			if v and v.sTid == _id then
				return v
			end
		end
	elseif _id >= 101 and _id < 9999 then --章节任务
		if self.tChatper then
			local targets = self.tChatper:getTargets()
			for k, v in pairs(targets) do
				if v.sTid == _id then
					return v
				end
			end
		end
		return nil
	end
	return nil
end
--判断某个任务是否完成
function PlayerTaskInfo:isMissionFinished( _id )	
	-- body
	if not _id then
		return
	end
	local tmpdata = self:getTaskDataById(tonumber(_id))
	if tmpdata and tmpdata.nIsFinished == 1 then
		return true
	else
		return false
	end
end
--当前开放的任务中检查是否有查看类型的任务
function PlayerTaskInfo:checkOpenDlgTask( dlgTypeID )
	-- body
	if not dlgTypeID then
		return nil
	end
	--检查当前任务
	if self.tCurAgencyTask and self.tCurAgencyTask.nMode == e_task_modes.check and self.tCurAgencyTask.nIsFinished == 0 then
		local ndlgid = tonumber(self.tCurAgencyTask.sTarget or 0)	
		if ndlgid == dlgTypeID then
			return self.tCurAgencyTask
		end
	end
	--检查支线任务
	if not self.tCurSideTasks or #self.tCurSideTasks < 0 then
		return nil
	end
	for k, v in pairs(self.tCurSideTasks) do
		if v.nMode == e_task_modes.check and v.nIsFinished == 0 then
			local ndlgid = tonumber(v.sTarget or 0)	
			if ndlgid == dlgTypeID then
				return v
			end
		end
	end
	return nil
end

--获取任务是否解锁（znftodo 不怎么严谨，目前是判断当前主线任务是否参数任务id大)
function PlayerTaskInfo:getTaskIsUnLock( nTaskId )
	if self.tCurAgencyTask then
		if self.tCurAgencyTask.sTid < nTaskId then
			return false
		end
	end
	return true
end

--获取征收资源任务是否解锁
function PlayerTaskInfo:getLevyResTaskIsUnLock(  )
	return self:getTaskIsUnLock(tonumber(getMissionParam("collection") or 0))
end

function PlayerTaskInfo:getOpenedNpcTask(  )
	-- body
	local tTaskData = nil	
	if self.tCurAgencyTask and self.tCurAgencyTask.nMode == e_task_modes.zbnpc and self.tCurAgencyTask.nIsFinished == 0 then
		tTaskData = self.tCurAgencyTask
	end
	--检查支线任务
	if not self.tCurSideTasks or #self.tCurSideTasks < 0 then
		return nil
	end
	for k, v in pairs(self.tCurSideTasks) do
		if v.nMode == e_task_modes.zbnpc and v.nIsFinished == 0 then
			tTaskData = v
		end
	end	
	return tTaskData
end

function PlayerTaskInfo:getDailyResetCD(  )
	-- body
	local ncurtime = getSystemTime()
	local nlefttime = self.nReSetTime - (ncurtime - self.nLastLoadTime)
	if nlefttime < 0 then
		nlefttime = 0
	end
	return nlefttime
end


function PlayerTaskInfo:getBoxStatus( _nScore )
	-- body
	if not _nScore then
		return e_box_status.normal
	end
	if self.nDp >= _nScore then
		for k, v in pairs(self.tG) do
			if v == _nScore then
				return e_box_status.opened
			end
		end
		return e_box_status.prize
	else
		return e_box_status.normal
	end
end

return PlayerTaskInfo
