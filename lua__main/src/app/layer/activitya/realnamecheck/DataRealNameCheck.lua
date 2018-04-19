-- Author: wenzongyao
-- Date: 2018-3-8 17:08:13
-- 实名认证数据
local Activity = require("app.data.activity.Activity")
local CountryWarActMission = require("app.layer.activitya.nanbeiwar.CountryWarActMission")

local DataRealNameCheck = class("DataRealNameCheck", function()
	return Activity.new(e_id_activity.realnamecheck) 
end)

--创建自己(方便管理)
tActivityDataList[e_id_activity.realnamecheck] = function (  )
	return DataRealNameCheck.new()
end

-- _index
function DataRealNameCheck:ctor()
	-- body
   self:myInit()
end


function DataRealNameCheck:myInit( )
	self.tGetAwards = {}	--可领取奖励
	self.nState	= 1 		--活动状态
end

-- 获取红点方法
function DataRealNameCheck:getRedNums()
	local nNums = 0
	if self.nState == 0 or self.nState == 1 then
		nNums = 1 
	end
	return nNums
end

function DataRealNameCheck:sendNet(_state)
	if not _state then
		return
	end

    --协议4112
	SocketManager:sendMsg("realNameCheck", {_state}, handler(self, self.onGetDataFunc))	--认证	
	-- body
end

function DataRealNameCheck:onGetDataFunc( __msg )
    if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.realNameCheck.id then
       		if __msg.body.ob then
				--获取物品效果
				showGetAllItems(__msg.body.ob)
       		end
        end
    else
        --弹出错误提示语
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end

-- 读取服务器中的数据
function DataRealNameCheck:refreshDatasByServer( _tData )
	if not _tData then
	 	return
	end


	self.tGetAwards	   = _tData.rw   or self.tGetAwards   -- List<Pair<Integer,Long>>	cdkey领取的奖励
	self.nState	   	   = _tData.state    or self.nState	  -- 0未实名不可领取, 1已实名可领取, 2已领取

	self:refreshActService(_tData)--刷新活动共有的数据

    -- 实名检测
	self:checkRealName()
end

function DataRealNameCheck:checkRealName()
    
    -- 未实名需要检测,
    if self.nState == 0 then
        if device.platform == "android" then
            local className = "com/game/quickmgr/QuickMgr"
            local methodName = "doGetUserAge"
            -- sdk已实名,则通知服务端已实名
            local bRet, nAge = luaj.callStaticMethod(className, methodName, {}, "()I");             
        	AccountCenter.rn_sdk_age = tonumber(nAge) or 0 -- 实名认证的年龄
        	--print("实名认证年龄============================:", nAge)
            if AccountCenter.rn_sdk_age > 0 then
                self:sendNet(1)
            end
        elseif device.platform == "ios" then
            if AccountCenter.rn_sdk_age > 0 then
                self:sendNet(1)
            end
        else
            self:sendNet(1)
        end
    end
end


return DataRealNameCheck