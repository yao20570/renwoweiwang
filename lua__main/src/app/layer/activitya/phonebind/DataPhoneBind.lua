-- Author: xiesite
-- Date: 2017-11-29 17:08:13
-- 手机绑定数据
local Activity = require("app.data.activity.Activity")
local CountryWarActMission = require("app.layer.activitya.nanbeiwar.CountryWarActMission")

local DataPhoneBind = class("DataPhoneBind", function()
	return Activity.new(e_id_activity.phonebind) 
end)

--创建自己(方便管理)
tActivityDataList[e_id_activity.phonebind] = function (  )
	return DataPhoneBind.new()
end

-- _index
function DataPhoneBind:ctor()
	-- body
   self:myInit()
end


function DataPhoneBind:myInit( )
	self.tGetAwards = {}	--可领取奖励
	self.nState	= 1 		--活动状态
end

-- 获取红点方法
function DataPhoneBind:getRedNums()
	local nNums = 0
	if self.nState == 0 or self.nState == 1 then
		nNums = 1 
	end
	return nNums
end

--研究科技请求回调
function DataPhoneBind:onPhoneBindResponse( __msg )
	-- body
	if __msg.head.type == MsgType.phoneBind.id then 			--研究科技
		if __msg.head.state == SocketErrorType.success	then
			TOAST("绑定手机")
		else		
			TOAST(SocketManager:getErrorStr(__msg.head.state))
		end
	end
	
end


function DataPhoneBind:sendNet(_state)
	if not _state then
		return
	end

	SocketManager:sendMsg("phoneBind", {_state}, handler(self, self.onGetDataFunc))	--绑定	
	-- body
end

function DataPhoneBind:onGetDataFunc( __msg )
    if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.phoneBind.id then
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
function DataPhoneBind:refreshDatasByServer( _tData )
	if not _tData then
	 	return
	end


	self.tGetAwards	   = _tData.rw   or self.tGetAwards   --List<Pair<Integer,Long>>	cdkey领取的奖励
	self.nState	   	   = _tData.state    or self.nState	

	self:refreshActService(_tData)--刷新活动共有的数据

	-- dump(_tData)
end



return DataPhoneBind