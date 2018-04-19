-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-05-16 11:47:52 星期二
-- Description: 玩家任务信息控制类
-----------------------------------------------------
require("app.layer.task.TaskFunc")
local PlayerTaskInfo = require("app.layer.task.PlayerTaskInfo")
--获得玩家基础信息单例
function Player:getPlayerTaskInfo()
	-- body
	if not Player.pTaskInfo then
		Player:initPlayerTaskInfo()
	end
	return Player.pTaskInfo
end

-- 初始化玩家基础数据
function Player:initPlayerTaskInfo(  )
	if not Player.pTaskInfo then
		Player.pTaskInfo = PlayerTaskInfo.new() --玩家的基础信息表
	end
	return "Player.pTaskInfo"
end

--释放玩家基础数据
function Player:releasePlayerTaskInfo(  )
	if Player.pTaskInfo then
		Player.pTaskInfo = nil --玩家的基础信息
	end
	return "Player.pTaskInfo"
end


--请求玩家资源数据回调
SocketManager:registerDataCallBack("loadMissions",function ( __type, __msg )
	-- body		
	if __msg.head.state == SocketErrorType.success then
		--dump( __msg.body,"加载loadMissions=",100)	
		if 	__msg.body then
			--刷新玩家任务数据			
			Player:getPlayerTaskInfo():refreshDatasByService(__msg.body)
			--发送玩家任务数据刷新消息
			sendMsg(gud_refresh_task_msg)
		end
    end
end)

--任务数据推送刷新回调
SocketManager:registerDataCallBack("refreshMission",function ( __type, __msg )
	-- body		
	if __msg.head.state == SocketErrorType.success then
		--dump( __msg.body,"加载refreshMission=",100)	
		if 	__msg.body then
			--刷新玩家任务数据
			Player:getPlayerTaskInfo():refreshDatasByService(__msg.body)
			--发送玩家任务数据刷新消息
			sendMsg(gud_refresh_task_msg)

			--判断是否会开启黄金队列
			if __msg.body.f and __msg.body.f == 1 then --完成了
				local nTeskId = tonumber(getMissionParam("secQueue"))
				if __msg.body.i and __msg.body.i == nTeskId then
					 Player:getBuildData().nHadSecondQue = 1
					--发送消息刷新对联
					local tObj = {}
					tObj.nType = 2
					sendMsg(ghd_refresh_homeitem_msg, tObj)
				end
			end
			
		end
    end
end)

--领取任务奖励回调
SocketManager:registerDataCallBack("getTaskPrize",function ( __type, __msg )
	-- body		
	if __msg.head.state == SocketErrorType.success then
		--dump( __msg.body,"加载getTaskPrize=",100)	
		--优先处理界面效果
		--显示领奖特效		
		sendMsg(ghd_player_get_taskprize_msg)
		--新手引导
		Player:getNewGuideMgr():setNewGuideFingerClicked(e_guide_finer.task_reward_btn)		
		closeDlgByType(e_dlg_index.gettaskprize, false)	
		if 	__msg.body then
			--刷新玩家任务数据
			Player:getPlayerTaskInfo():removeFinishedTask(__msg.body.i)
			Player:getPlayerTaskInfo():refreshDatasByService(__msg.body)
			--发送玩家任务数据刷新消息
			sendMsg(gud_refresh_task_msg)
			sendMsg(ghd_wildarmy_circle_effect)
			--奖励信息
			if __msg.body.o then
				--print("弹出奖励")
				showGetAllItems(__msg.body.o)
			end
		end
	else		
		TOAST(SocketManager:getErrorStr(__msg.head.state))		
    end
end)

--领取任务奖励回调
SocketManager:registerDataCallBack("getDailyTaskPrize",function ( __type, __msg )
	-- body		
	if __msg.head.state == SocketErrorType.success then
		--dump( __msg.body,"getDailyTaskPrize=",100)	
		sendMsg(ghd_player_get_taskprize_msg)
		if 	__msg.body then
			--日常任务完成
			Player:getPlayerTaskInfo():setGetDailyTaskPrizeStatus(__msg.body.i)
			--发送玩家任务数据刷新消息
			sendMsg(gud_refresh_task_msg)
			--奖励信息
			if __msg.body.o then
				--print("弹出奖励")
				showGetAllItems(__msg.body.o)
			end
		end
    end
end)


--领取日常积分奖励回调
SocketManager:registerDataCallBack("getDailyScorePrize",function ( __type, __msg )
	-- body		
	if __msg.head.state == SocketErrorType.success then
		--dump( __msg.body,"getDailyScorePrize=",100)	
		if 	__msg.body then
			Player:getPlayerTaskInfo():refreshDatasByService(__msg.body)
			--发送玩家任务数据刷新消息
			sendMsg(gud_refresh_task_msg)
			--奖励信息
			if __msg.body.o then
				--print("弹出奖励")
				showGetAllItems(__msg.body.o)
			end
		end
    end
end)


--前端确定任务完成
SocketManager:registerDataCallBack("finishTask",function ( __type, __msg , __oldmsg)
	-- body		
	if __msg.head.state == SocketErrorType.success then
		if __msg.head.type == MsgType.finishTask.id then
			--dump( __msg.body,"加载finishTask=",100)	
			if 	__msg.body and __msg.body.rf then
				showFight(__msg.body.rf, function (  )
					local tData = {}
					tData.report = __msg.body.rf
					tData.taskPlayBack = true
					tData.star = __msg.body.star or 0
					showFightRst(tData)
        		end, true)	
			end
		end
	else
		--打开弹窗类提示信息
		setToastNCState(2)
		--允许提示弹框
		showNextSequenceFunc(e_show_seq.fight)
    end
end) 

--取得剧情任务数据
SocketManager:registerDataCallBack("loadChapter",function ( __type, __msg , __oldmsg)
	-- body
	-- dump(__msg, "loadChapter")
	if __msg.head.state == SocketErrorType.success then
		if __msg.head.type == MsgType.loadChapter.id then
			__msg.body["chatper"] = true
			Player:getPlayerTaskInfo():refreshDatasByService(__msg.body)
			--发送玩家任务数据新消息
			sendMsg(gud_refresh_task_msg)
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))		
    end
end) 

--取得剧情任务数据
SocketManager:registerDataCallBack("chapterPush",function ( __type, __msg , __oldmsg)
	-- body
	-- dump(__msg, "chapterPush  __msg :")
	if __msg.head.state == SocketErrorType.success then
		if __msg.head.type == MsgType.chapterPush.id then
			if __msg.body.c then
				__msg.body["chatper"] = true
				Player:getPlayerTaskInfo():refreshDatasByService(__msg.body)
			else
				local body = {}
				body.c = {}
				body.c.ts = {}
				table.insert(body.c.ts, __msg.body.t)

				body.chatper = true
				--刷新玩家任务数据
				Player:getPlayerTaskInfo():refreshDatasByService(body)
			end
			--发送玩家任务数据刷新消息
			sendMsg(gud_refresh_task_msg)
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))		
    end
end) 

--领取剧情目标奖励回调
SocketManager:registerDataCallBack("getChapterPrize",function ( __type, __msg , __oldmsg)
	-- body
	--dump(__msg ,"getChapterPrize  __msg :")
	if __msg.head.state == SocketErrorType.success then
		sendMsg(ghd_player_get_taskprize_msg)
		if __msg.head.type == MsgType.getChapterPrize.id then
			if __msg.body and __msg.body.cid then
				local chatper = Player:getPlayerTaskInfo():getChatperTask()
				--最后一章特殊处理
				if chatper and chatper.sTid == __msg.body.cid then
					Player:getPlayerTaskInfo():setOldChatperTask(copyTab(chatper))
					Player:getPlayerTaskInfo():resetChatperTask()
				end
			end
 			sendMsg(gud_refresh_task_msg)
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))		
    end
end) 

--领取剧情章节奖励回调
SocketManager:registerDataCallBack("getChapterTaskPrize",function ( __type, __msg , __oldmsg)
	-- body
	-- dump(__msg ,"getChapterTaskPrize  __msg :")
	if __msg.head.state == SocketErrorType.success then
		sendMsg(ghd_player_get_taskprize_msg)
		if __msg.head.type == MsgType.getChapterTaskPrize.id then
 			sendMsg(gud_refresh_task_msg)
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))		
    end
end) 



e_task_type = {
		main  		= 1,	--1主线
		equip		= 2,	--2装备
		tnoly 		= 3, 	--3科技
		build 		= 4, 	--4建筑
		Military 	= 5,	--5军事
		bandits 	= 6,	--6流寇
		fuben 		= 7,	--7副本
		guoqi 		= 8,	--8国旗
		juqing		= 9,	--9剧情
}

e_task_modes = {
	playeruplv 		= 1, 	--1主公升级
	builduplv 		= 2, 	--2建筑升级
	proarmy 		= 3, 	--3生产兵种
	xmlj 			= 4, 	--4消灭乱军等级
	gytj 			= 5, 	--5雇佣铁匠
	zfsc	 		= 6, 	--6作坊生产
	fuben	 		= 7, 	--7副本
	science 		= 8, 	--8科技
	guoqi 			= 9, 	--9国器
	zxrw	 		= 10, 	--10完成支线任务
	check	 		= 11, 	--11查看
	djzb	 		= 12, 	--12打造装备
	collect 		= 13, 	--13征收
	cdzb	 		= 14, 	--14穿戴装备
	recruit 		= 15, 	--15招募
	buildsuplv 		= 16, 	--16多个建筑升级
	shzb 			= 17, 	--17收获装备
	wjsz 			= 18, 	--18武将上阵
	xmljnum	 		= 19, 	--19消灭乱军数量
	zbnpc	 		= 20, 	--20战报npc
	zbg	 			= 21, 	--21珍宝阁
	buildupfast	 	= 22, 	--22建筑升级立即完成
	fubenfast	 	= 23, 	--23副本立即完成
	countryfight	= 24, 	--24国战
	worldtarget     = 25, 	--25世界目标
	proarmynum      = 26, 	--26募兵数量

	localbuildpos   = 99    --建筑定位
}

--章节类型
e_plot_modes = {
 	buildsuplv  =  1,	--1建筑升级
 	playeruplv	=  2,	--2主公升级
 	gdlj 		=  3,	--3攻打乱军
 	cdzb		=  4,	--4穿戴装备
 	fuben		=  5,	--5副本
 	proarmynum 	=  6,	--6招募
 	zlts		=  7,   --7战力提升
 	science 	=  8, 	--8科技
 	yyzb		=  9,	--拥有装备
 	countryfight = 10,	--国战
 	cityfight	=  11,  --城战
 	dzsb		=  12,  --打造神兵
 	sjsb		=  13,	--升级神兵
 	travel 		=  14,  --武将游历
 	train  		=  15,  --武将培养
}

e_task_ids = {
	
}

e_box_status = {
	normal 		= 1, --不可点击
	prize 		= 2, --可以点击	
	opened		= 3, --已经打开
}
--通过任务类型获取icon
function getTaskIconByType( _nType )
	-- body
	_nType = _nType or 1
	local nType = tonumber(_nType)
	local sIcon = "#v1_btn_zxrw.png"
	if nType == 1 then --主线
		sIcon = "#v1_btn_zxrw.png"
	elseif nType == 2 then --装备
		sIcon = "#v1_btn_zbrw.png"
	elseif nType == 3 then --科技
		sIcon = "#v1_btn_kjrw.png"
	elseif nType == 4 then --建筑
		sIcon = "#v1_img_zjm_ptdl.png"
	elseif nType == 5 then --军事
		sIcon = "#v1_btn_jsrw.png"
	elseif nType == 6 then --乱军
		sIcon = "#v1_btn_ljrw.png"
	elseif nType == 7 then --副本
		sIcon = "#v1_img_tzfb.png"
	elseif nType == 8 then --神兵
		sIcon = "#v1_img_zjm_shenbing.png"
	end
	return sIcon
end
-- 1主线2装备3科技
-- 4建筑5军事6乱军7副本8城战
function getTaskTxIconByType( _nType )
	-- body
	_nType = _nType or 1
	local nType = tonumber(_nType)
	local sIcon = "#v1_btn_zxrw1.png"
	if nType == 1 then --主线
		sIcon = "#v1_btn_zxrw1.png"
	elseif nType == 2 then --装备
		sIcon = "#v1_btn_shenbing.png"
	elseif nType == 3 then --科技
		sIcon = "#v1_btn_kjrw3.png"
	elseif nType == 4 then --建筑
		sIcon = "#v1_btn_jianzhu.png"
	elseif nType == 5 then --军事
		sIcon = "#v1_btn_jsrw5.png"
	elseif nType == 6 then --乱军
		sIcon = "#v1_btn_ljrw6.png"
	elseif nType == 7 then --副本
		sIcon = "#v1_btn_zbrw2.png"
	elseif nType == 8 then --8城战
		sIcon = "#v1_btn_gongcheng.png"
	end
	return sIcon
end


