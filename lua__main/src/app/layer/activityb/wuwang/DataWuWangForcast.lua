-----------------------------------------------------------------
-- Author: luwenjing
-- Date: 2017-12-21 15:32:36
-- 多次充值数据
-----------------------------------------------------------------
local Activity = require("app.data.activity.Activity")

local DataWuWangForcast = class("DataWuWangForcast", function()
	return Activity.new(e_id_activity.wuwangforcast) 
end)
--创建自己(方便管理)
tActivityDataList[e_id_activity.wuwangforcast] = function (  )
	return DataWuWangForcast.new()
end

function DataWuWangForcast:ctor()
    self:myInit()
end


function DataWuWangForcast:myInit( )
	self.nCd =	0		--开启倒计时
	self.fLastLoadTime 		= getSystemTime() 					 --最后刷新时间

end


-- 读取服务器中的数据
function DataWuWangForcast:refreshDatasByServer( _tData )
	-- dump(_tData,"lllll")
	if not _tData then
	 	return
	end
	self.nCd =	_tData.cd or self.nCd 		--开启倒计时
	self:refreshActService(_tData)
end

-- 获取下一阶段的倒计时
-- return(int):返回剩余时长
function DataWuWangForcast:getOpenTime(  )
	-- 单位是秒
	local fCurTime = getSystemTime()
	-- 总共剩余多少秒
	if self.nCd then
		local fLeft = self.nCd/1000 - (fCurTime - self.fLastLoadTime)
		if(fLeft < 0) then
			fLeft = 0
		end
		return fLeft
	else
		return 0
	end
end


-- 获取红点方法
function DataWuWangForcast:getRedNums()
	local nNums = 0

	-- if self.nT == 1 then
	-- 	nNums =  1
	-- end

	-- nNums = self.nLoginRedNums + nNums

	return nNums
end




return DataWuWangForcast