----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-02-08 15:22:00
-- Description: 限时Boss
-----------------------------------------------------
e_imperwar_tab = {
    server = 1,
    country = 2,
    mine = 3,
}

e_tech_type = {
    addHurt = 1,
    subHurt = 2,
    attack = 3,
    fire = 4,
    rain = 5,
    together = 6,
}

e_epwaward_state = {
    no = 0,--不可领取 
    get = 1, --可以领取 
    got = 2, --已经领取
}

local ImperialWarData = require("app.layer.imperialwar.data.ImperialWarData")

--获取限时Boss数据单例
function Player:getImperWarData(  )
	if not Player.imperWarData then
		self:initImperWarData()
	end
	return Player.imperWarData
end

--初始化世界数据
function Player:initImperWarData(  )
	if not Player.imperWarData then
		Player.imperWarData = ImperialWarData.new()
	end
	return "Player.imperWarData"
end

--释放世界数据
function Player:releaseImperWarData()
	if Player.imperWarData then
		Player.imperWarData:release()
		Player.imperWarData = nil
	end
	return "Player.imperWarData"
end

--加载战况6401
SocketManager:registerDataCallBack("reqImperWarFight",function ( __type, __msg )
    if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.reqImperWarFight.id then
            Player:getImperWarData():setImperWarFights(__msg.body.rs)
            sendMsg(ghd_imperialwar_fight_refresh)
        end
    else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)


--战况推送6402
SocketManager:registerDataCallBack("pushImperWarFight",function ( __type, __msg )
    if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.pushImperWarFight.id then
            local nSysCityId = Player:getImperWarData():getCurrImperialWarId()
            if __msg.body.cid == nSysCityId then
                local Replay = require("app.layer.imperialwar.data.Replay")
                local tReplay = Replay.new(__msg.body)
                Player:getImperWarData():addImperWarFight(tReplay)
                sendMsg(ghd_imperialwar_fight_refresh, tReplay)
            end
        end
    end
end)

--活动起始或关闭
SocketManager:registerDataCallBack("reqImperWarOpen",function ( __type, __msg )
    if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.reqImperWarOpen.id then
            Player:getImperWarData():setImperWarOpen(__msg.body)
            sendMsg(ghd_imperialwar_open_state)
        end
    else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--活动起始或关闭
SocketManager:registerDataCallBack("pushImperWarOpen",function ( __type, __msg )
    if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.pushImperWarOpen.id then
            Player:getImperWarData():setImperWarOpen(__msg.body)
            sendMsg(ghd_imperialwar_open_state)
        end
    end
end)


--皇城秘库兑换
SocketManager:registerDataCallBack("reqRoyalBankExchange", function ( __type, __msg)
    if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.reqRoyalBankExchange.id then
            showGetAllItems(__msg.body.ob)
        end
    else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--使用战术
SocketManager:registerDataCallBack("reqImperWarTech", function ( __type, __msg, __oldMsg)
    if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.reqImperWarTech.id then
            if __oldMsg and __oldMsg[1] == e_tech_type.together then
                TOAST(getConvertedStr(3, 10945))
            else
                TOAST(getConvertedStr(3, 10842))
            end
            --更新当前的Vo数据
            local tImperialWarVo = Player:getImperWarData():getCurrImperialWarVo()
            if tImperialWarVo then
                if tImperialWarVo:getCityId() == __msg.body.cid then
                    tImperialWarVo:update(__msg.body)
                    sendMsg(gud_imperialwar_vo_refresh)
                end
            end
        end
    else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--推送战场数据
SocketManager:registerDataCallBack("pushImperBattlefield",function ( __type, __msg )
    -- dump(__msg, "pushImperBattlefield=========", 100)
    if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.pushImperBattlefield.id then
            --更新当前的Vo数据
            local tImperialWarVo = Player:getImperWarData():getCurrImperialWarVo()
            if tImperialWarVo then
                if tImperialWarVo:getCityId() == __msg.body.cid then
                    tImperialWarVo:update(__msg.body)
                    sendMsg(gud_imperialwar_vo_refresh)
                end
            end
        end
    end
end)

--推送战斗结果
SocketManager:registerDataCallBack("pushIWarFightNotice",function ( __type, __msg )
    -- dump(__msg, "pushIWarFightNotice=========", 100)
    if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.pushIWarFightNotice.id then
            --战斗中不播放
            if Player:getUIFightLayer() then
                return
            end

            local nResult = __msg.body.r --0:轮空 1：战胜N个部队 2：被xx击杀
            local nArmy = __msg.body.n --战胜n个部队
            local nName = __msg.body.en --死于谁的剑下

            if nResult == 0 then
                TOAST(getConvertedStr(3, 10952))
            elseif nResult == 1 then
                TOAST(string.format(getConvertedStr(3, 10953), nArmy))
            elseif nResult == 2 then
                TOAST(string.format(getConvertedStr(3, 10954), nName))
            end
        end
    end
end)

--请求我的积分数据
SocketManager:registerDataCallBack("reqImperWarMyScore", function( __type, __msg)
    if __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.reqImperWarMyScore.id then
            Player:getImperWarData():setMyWarScore(__msg.body.p)
            Player:getImperWarData():setCountryWarScore(__msg.body.cp)
            sendMsg(gud_imperialwar_score_refresh)
        end
    else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--请求加载线路
SocketManager:registerDataCallBack("reqEpwLine", function( __type, __msg )
    if __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.reqEpwLine.id then
            if __msg.body then
                Player:getImperWarData():setLines(__msg.body.lineVos)
            end
        end
    else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--更新线路
SocketManager:registerDataCallBack("pushEpwLine", function( __type, __msg )
    if __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.pushEpwLine.id then
            if __msg.body then
                if __msg.body.al then
                    Player:getImperWarData():addLines(__msg.body.al)
                end
                if __msg.body.rl then
                    Player:getImperWarData():delLines(__msg.body.rl)
                end
            end
        end
    end
end)

--请求皇城战领取奖励
SocketManager:registerDataCallBack("reqEpwAward", function( __type, __msg )
    if __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.reqEpwAward.id then
            if __msg.body then
                Player:getImperWarData():setEpwAwards(__msg.body)
            end
        end
    else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--更新皇城战领取奖励
SocketManager:registerDataCallBack("pushEpwAward", function( __type, __msg )
    if __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.pushEpwAward.id then
            if __msg.body then
                Player:getImperWarData():setEpwAwards(__msg.body)
            end
        end
    end
end)