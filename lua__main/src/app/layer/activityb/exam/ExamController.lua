-----------------------------------------------------
-- author: wenzongyao
-- updatetime:  2018-1-17 09:46:24
-- Description: 每日答题控制类
-----------------------------------------------------
local DataExam = require("app.layer.activityb.exam.DataExam")
local DataExamRankInfo = require("app.layer.activityb.exam.DataExamRankInfo")


--获得答题排行榜信息单例
function Player:getExamRankInfo()
	-- body
	if not Player.pExamRankInfo then
		self:initExamRankInfo()
	end
	return Player.pExamRankInfo
end

-- 初始化答题排行榜数据
function Player:initExamRankInfo(  )
	if not Player.pExamRankInfo then
		Player.pExamRankInfo = DataExamRankInfo.new() --每日答题排行榜
	end
	return "Player.pExamRankInfo"
end

--释放答题排行榜数据
function Player:releaseExamRankInfo(  )
	if Player.pExamRankInfo then
		Player.pExamRankInfo = nil --玩家的基础信息
	end
	return "Player.pExamRankInfo"
end

--获得答题数据单例
function Player:getExamData()
   if not Player.pDataExam then
		self:initDataExam()
	end
	return Player.pDataExam
end


-- 初始化答题数据
function Player:initDataExam(  )
	if not Player.pDataExam then
		Player.pDataExam = DataExam.new()
	end
	return "Player.pDataExam"
end

--释放答题数据
function Player:releaseDataExam(  )
	if Player.pDataExam then
		Player.pDataExam = nil
	end
	return "Player.pDataExam"
end

-- 获取第一名数据
function Player:getExamFristRankInfo()
    local tExamData = Player:getExamData()
    if tExamData:isActivityInOpen() then
        return
    end

    local rankInfo = Player:getExamRankInfo()
    if rankInfo.nRankType ~= e_rank_type.exam then
        return
    end

    local tListData = rankInfo:getRankDataList()
    return tListData[1]
end

-- [8551]题目推送
SocketManager:registerDataCallBack("pushExamQuestion", function(__type, __msg)
    -- body
    if __msg.head.state == SocketErrorType.success then
        --dump(__msg.body, "__msg.body", 100)
        
        -- 通知题目刷新 
        Player:getExamData():refreshQuestion(__msg.body)
        sendMsg(gud_exam_info_refresh_msg)
    end
end )

-- [8552]每次答题结算推送(注意:没答题不推)
SocketManager:registerDataCallBack("pushAnswerResult", function(__type, __msg)
    -- body
    if __msg.head.state == SocketErrorType.success then
        --dump(__msg.body, "__msg.body", 100)
        Player:getExamData():refreshAnswerResult(__msg.body)
        sendMsg(gud_exam_info_refresh_msg)
        SocketManager:sendMsg("getRankData", { e_rank_type.exam, 1, 20 })
    end
end )

-- [8553]答题活动结束推送
SocketManager:registerDataCallBack("pushExamActivityEnd", function(__type, __msg)
    -- body
    if __msg.head.state == SocketErrorType.success then
        --dump(__msg.body, "__msg.body", 100)
        Player:getExamData():refreshExamEnd(__msg.body)
        sendMsg(gud_exam_info_refresh_msg)
        sendMsg(gud_exam_activity_end_msg)
        SocketManager:sendMsg("getRankData", { e_rank_type.exam, 1, 20 })

        Player:getExamData():setReadyStart(false)
        sendMsg(gud_refresh_activity)
        sendMsg(gud_refresh_act_red)
    end
end )

-- [8559]答题活动准备(每次公告和第一次推送答题)推送
SocketManager:registerDataCallBack("pushEaxmRedPoint", function(__type, __msg)
    -- body
    if __msg.head.state == SocketErrorType.success then
        --dump(__msg.body, "__msg.body", 100)
        Player:getExamData():setReadyStart(true)
        sendMsg(gud_refresh_activity)
        sendMsg(gud_refresh_act_red)
    end
end )

-- [8554]玩家答题
SocketManager:registerDataCallBack("reqAnswerQuestion", function(__type, __msg)
    -- body
    if __msg.head.state == SocketErrorType.success then
        --dump(__msg.body, "__msg.body", 100)  
        Player:getExamData():setHasAnswer(true)
        sendMsg(gud_exam_info_refresh_msg)        
    end
end )

-- [8555]领取答题奖励
SocketManager:registerDataCallBack("reqExamReward", function(__type, __msg)
    -- body
    if __msg.head.state == SocketErrorType.success then        
        Player:getExamData():setRankRewardState(e_exam_reward_state.has_got)
        sendMsg(gud_exam_info_refresh_msg)
        showGetAllItems(__msg.body.ob)
        
        sendMsg(gud_refresh_activity)
        sendMsg(gud_refresh_act_red)
    end
end )

-- [8556]答题玩家列表刷新
SocketManager:registerDataCallBack("reqAnswerPlayers", function(__type, __msg)
    -- body
    if __msg.head.state == SocketErrorType.success then
        --dump(__msg.body, "__msg.body", 100)
        Player:getExamData():refreshAnswerPlayers(__msg.body)
        sendMsg(gud_exam_ansewer_players_msg)
            
    end
end )

-- [8557]领取答题奖励玩家答题状态请求
SocketManager:registerDataCallBack("reqExamState", function(__type, __msg)
    -- body
    if __msg.head.state == SocketErrorType.success then
        --dump(__msg.body, "__msg.body", 100)
        Player:getExamData():refreshQuestion(__msg.body)
        sendMsg(gud_exam_info_refresh_msg)
    end
end )

-- [8558]答题系统登陆请求
SocketManager:registerDataCallBack("reqEaxmBaseInfo", function(__type, __msg)
    -- body
    if __msg.head.state == SocketErrorType.success then
        --dump(__msg.body, "__msg.body", 100)
        Player:getExamData():refreshBaseInfo(__msg.body)
        sendMsg(gud_exam_info_refresh_msg)
    end
end )