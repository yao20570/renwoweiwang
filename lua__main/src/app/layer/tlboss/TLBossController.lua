----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-02-08 15:22:00
-- Description: 限时Boss
-----------------------------------------------------
local TLBossData = require("app.layer.tlboss.data.TLBossData")

--获取限时Boss数据单例
function Player:getTLBossData(  )
	if not Player.tlbossData then
		self:initTLBossData()
	end
	return Player.tlbossData
end

--初始化世界数据
function Player:initTLBossData(  )
	if not Player.tlbossData then
		Player.tlbossData = TLBossData.new()
	end
	return "Player.tlbossData"
end

--释放世界数据
function Player:releaseTLBossData()
	if Player.tlbossData then
		Player.tlbossData:release()
		Player.tlbossData = nil
	end
	return "Player.tlbossData"
end

--[6200]限时BOSS加载数据
SocketManager:registerDataCallBack("reqTLBossData",function ( __type, __msg, __oldMsg )
	-- dump(__msg.body,"reqTLBossData",100)
	if  __msg.head.state == SocketErrorType.success then
        if __msg.head.type == MsgType.reqTLBossData.id then
        	Player:getTLBossData():refreshDataByService(__msg.body, true)
        end
    else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--[6201]限时BOSS获取排行榜
SocketManager:registerDataCallBack("reqTLBossRank",function ( __type, __msg, __oldMsg )
	--dump(__msg.body,"reqTLBossRank",100)
	if  __msg.head.state == SocketErrorType.success then
        if __msg.head.type == MsgType.reqTLBossRank.id then
        	Player:getTLBossData():refreshDataByService(__msg.body)
        end
    else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--[6202]限时BOSS攻击
SocketManager:registerDataCallBack("reqTLBossAttack",function ( __type, __msg, __oldMsg )
	--dump(__msg.body,"reqTLBossAttack",100)
	if  __msg.head.state == SocketErrorType.success then
        if __msg.head.type == MsgType.reqTLBossAttack.id then
        	Player:getTLBossData():refreshDataByService(__msg.body)
            --播放战报
            if __msg.body.fight then
                showFight(__msg.body.fight,function (  )
                    -- --这里兼容旧方法
                    -- __msg.body.report = __msg.body.fight
                    -- __msg.body.awards = __msg.body.o
                    -- showFightRst(__msg.body)
                    --关闭战斗界面
                    if Player:getUIFightLayer() then
                        sendMsg(ghd_fight_close)
                        showNextSequenceFunc(e_show_seq.fight)

                    end
                    
                    local StormVo = require("app.layer.tlboss.data.StormVo")
                    local tStormVos = {}
                    for i=1,#__msg.body.storm do
                        local tStormVo = StormVo.new(__msg.body.storm[i])
                        table.insert(tStormVos, tStormVo)
                    end
                    --结算界面
                    local tObject = {
                        nType = e_dlg_index.tlbosshitresult, --dlg类型
                        tStormVos = tStormVos
                    }
                    sendMsg(ghd_show_dlg_by_type, tObject)
                end, true)
            end
        end
    else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--[6203]限时BOSS强击
SocketManager:registerDataCallBack("reqTLBossSAttack",function ( __type, __msg, __oldMsg )
	--dump(__msg.body,"reqTLBossSAttack",100)
	if  __msg.head.state == SocketErrorType.success then
        if __msg.head.type == MsgType.reqTLBossSAttack.id then
        	Player:getTLBossData():refreshDataByService(__msg.body)

            if __msg.body.storm then
                local StormVo = require("app.layer.tlboss.data.StormVo")
                local tStormVos = {}
                for i=1,#__msg.body.storm do
                    local tStormVo = StormVo.new(__msg.body.storm[i])
                    table.insert(tStormVos, tStormVo)
                end
                --结算界面
                local tObject = {
                    nType = e_dlg_index.tlbosshitresult, --dlg类型
                    tStormVos = tStormVos
                }
                sendMsg(ghd_show_dlg_by_type, tObject)
            end
        end
    else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)


--[-6204]限时BOSS数据更新推送
SocketManager:registerDataCallBack("pushTLBossData",function ( __type, __msg, __oldMsg )
	-- dump(__msg.body,"pushTLBossData",100)
	if  __msg.head.state == SocketErrorType.success then
        if __msg.head.type == MsgType.pushTLBossData.id then
            if __msg.body.w == 1 then --Integer boss来袭警名(w=1)
                sendMsg(ghd_show_tlboss_warning)
            end

            if __msg.body.fb then --Long 伤害飘血
                sendMsg(ghd_show_tlboss_hurt_num, {nNum = __msg.body.fb, bIsBest = false})
            end
            
            if __msg.body.bth then --bth Long    最强一击攻击伤害
                sendMsg(ghd_show_tlboss_hurt_num, {nNum = __msg.body.bth, bIsBest = true})
            end

            if __msg.body.dsn then --部位破坏玩家名字
                sendMsg(ghd_show_tlboss_atk_name, {sName = __msg.body.dsn, bIsBroke = true})
            end

            --btn String  最强一击玩家名字
            if __msg.body.btn then
                sendMsg(ghd_show_tlboss_atk_name, {sName = __msg.body.btn, bIsBroke = false})
            end

            --破坏奖励特效飘
            if __msg.body.o then
                showGetAllItems(__msg.body.o)
            end
            
        	Player:getTLBossData():refreshDataByService(__msg.body)

        end
    end
end)

----[6205]BOSS领取伤害排行奖励
SocketManager:registerDataCallBack("reqGetHarmRankAward",function ( __type, __msg, __oldMsg )
    -- dump(__msg.body,"reqGetHarmRankAward",100)
    if  __msg.head.state == SocketErrorType.success then
        if __msg.head.type == MsgType.reqGetHarmRankAward.id then
            Player:getTLBossData():refreshDataByService(__msg.body)
             --奖励特效飘
            if __msg.body.o then
                showGetAllItems(__msg.body.o)
            end
        end
    else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

----[6206]BOSS领取次数排行奖励
SocketManager:registerDataCallBack("reqGetHitNumRankAward",function ( __type, __msg, __oldMsg )
    -- dump(__msg.body,"reqGetHitNumRankAward",100)
    if  __msg.head.state == SocketErrorType.success then
        if __msg.head.type == MsgType.reqGetHitNumRankAward.id then
            Player:getTLBossData():refreshDataByService(__msg.body)
             --奖励特效飘
            if __msg.body.o then
                showGetAllItems(__msg.body.o)
            end
        end
    else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

----[6207]BOSS领取最终击杀奖励
SocketManager:registerDataCallBack("reqGetFinalKillAward",function ( __type, __msg, __oldMsg )
    -- dump(__msg.body,"reqGetFinalKillAward",100)
    if  __msg.head.state == SocketErrorType.success then
        if __msg.head.type == MsgType.reqGetFinalKillAward.id then
            Player:getTLBossData():refreshDataByService(__msg.body)
             --奖励特效飘
            if __msg.body.o then
                showGetAllItems(__msg.body.o)
            end
        end
    else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)


