-----------------------------------------------------
-- Author: luwenjing
-- Date: 2017-10-31 10:38:41
-- Description: 触发礼包控制类
-----------------------------------------------------
local TriggerGiftData = require("app.layer.triggergift.data.TriggerGiftData")

--获得数据单例
function Player:getTriggerGiftData()
	-- body
	if not Player.triggerGiftData then
		self:initTriggerGiftData()
	end
	return Player.triggerGiftData
end

-- 初始化数据
function Player:initTriggerGiftData(  )
	if not Player.triggerGiftData then
		Player.triggerGiftData = TriggerGiftData.new()
	end
	return "Player.triggerGiftData"
end

--释放数据
function Player:releaseTriggerGiftData(  )
	if Player.triggerGiftData then
		Player.triggerGiftData = nil
	end
	return "Player.triggerGiftData"
end

--[-6007]加载触发礼包
SocketManager:registerDataCallBack("reqTriggerGift",function ( __type, __msg )
    -- dump(__msg, "reqTriggerGift __msg= ", 100)
	if  __msg.head.state == SocketErrorType.success then
        if __msg.head.type == MsgType.reqTriggerGift.id then
            -- __msg.body.ptgList = {
            --     {
            --         pid = 1,
            --         cd = 1000,
            --     },
            --     {
            --         pid = 2,
            --         cd = 2000,
            --     },
            --     {
            --         pid = 3,
            --         cd = 30000,
            --     },
            --     {
            --         pid = 4,
            --         cd = 40000,
            --     },
            --     {
            --         pid = 5,
            --         cd = 50000,
            --     },
            -- }

        	Player:getTriggerGiftData():setPlayTriGiftResList(__msg.body.ptgList)
        	sendMsg(gud_trigger_gift_list_refresh)
        end
    else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--[-6008]购买触发礼包返回
SocketManager:registerDataCallBack("reqBugTriggerGift",function ( __type, __msg, __oldMsg )
	-- dump(__msg.body, "reqBugTriggerGift __msg= ", 100)
	if  __msg.head.state == SocketErrorType.success then
        if __msg.head.type == MsgType.reqBugTriggerGift.id then
            if __msg.body.ptg then
                local nPid = __msg.body.ptg.pid
                if nPid then
                    Player:getTriggerGiftData():delPlayTriGiftRes(nPid, true)
                    sendMsg(gud_trigger_gift_list_refresh)
                end
            end
            --播放获得
            -- local tConf = getTriGiftData(nPid)
            -- if tConf then
            --     local tOb = {}
            --     local tGoodsList = getDropById(tConf.item)
            --     for i=1,#tGoodsList do
            --         if tGoodsList[i].sTid and tGoodsList[i].nCt then
            --             table.insert(tOb,{k = tGoodsList[i].sTid, v = tGoodsList[i].nCt})
            --         end
            --     end
            --     showGetAllItems(tOb)
            -- end
            showGetAllItems(__msg.body.o)
        end
    else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--[-6006]触发礼包推送
SocketManager:registerDataCallBack("pushTriggerGift",function ( __type, __msg )
	-- dump(__msg.body, "pushTriggerGift __msg= ", 100)
	if  __msg.head.state == SocketErrorType.success then
        if __msg.head.type == MsgType.pushTriggerGift.id then
        	Player:getTriggerGiftData():addPlayTriGiftRes(__msg.body)
        	sendMsg(gud_trigger_gift_list_refresh)

            --弹出
            local nPid = __msg.body.pid
            if nPid then
                showDlgTriggerGift(nPid)
            end
        end
    end
end)

---------------------------------------------------------------------------------------------------

--[-6016]加载新触发礼包
SocketManager:registerDataCallBack("loadNewTriggerGift",function ( __type, __msg )
    -- dump(__msg.body, "loadNewTriggerGift __msg= ", 100)
    if  __msg.head.state == SocketErrorType.success then
        if __msg.head.type == MsgType.loadNewTriggerGift.id then
            Player:getTriggerGiftData():loadAllTriggerGift(__msg.body)
        end
    end
end)

--[-6017]新触发礼包推送
SocketManager:registerDataCallBack("pushNewTriggerGift",function ( __type, __msg )
    -- dump(__msg.body, "pushNewTriggerGift __msg= ", 100)
    if  __msg.head.state == SocketErrorType.success then
        if __msg.head.type == MsgType.pushNewTriggerGift.id then
            local bPush = true
            Player:getTriggerGiftData():loadAllTriggerGift(__msg.body, bPush)
        end
    end
end)