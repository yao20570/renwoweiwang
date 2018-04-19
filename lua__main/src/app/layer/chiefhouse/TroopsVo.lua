-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-12-22 14:52:14 星期五
-- Description: 高级御兵术
-----------------------------------------------------

local TroopsVo = class("TroopsVo")

function TroopsVo:ctor(  )
	self:myInit()
end

-- 初始化成员变量
function TroopsVo:myInit()
	self.nQType 		= 		0  -- int 队列类型
	self.nLv 			= 		0  -- int 等级
	self.nStage 		= 		0  -- int 进度
	self.nSec 			= 		0  --阶段
end

--从服务端获取数据刷新
function TroopsVo:refreshDatasByService( tData )
	-- body
	if not tData then
		return
	end
	self.nQType 		= 		tData.type or self.nQType --队列类型
	self.nLv 			= 		tData.lv 	or self.nLv  --等级
	self.nStage 		= 		tData.pg or self.nStage  --进度
	self.nSec 			= 		tData.sec 	or self.nSec --阶段
end

return TroopsVo
