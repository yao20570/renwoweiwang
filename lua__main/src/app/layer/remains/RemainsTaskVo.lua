----------------------------------------------------- 
-- author: maheng
-- Date: 2018-3-2 19:30:41
-- Description: 韬光养晦任务数据
-----------------------------------------------------

local RemainsTaskVo = class("RemainsTaskVo")

function RemainsTaskVo:ctor(  )
	self.nId 		= 0 --序号
	self.nStage 	= 1 --开启阶段
	self.nType  	= 1 --任务类型
	self.nTargetNum = 0 --目标次数
	self.nDropID 	= 0 --掉落ID
	self.sTitle 	= ""--标题

	self.nNum 		= 0 --已完成次数 完成进度
	self.bGet 		= false --已领取奖励
	self.bFinished 	= false --是否已经完成
end

function RemainsTaskVo:rerfeshDataByDB(_tData )
	-- body
	if not _tData then
		return
	end
	self.nId 		= _tData.id or self.nId  --序号	
	self.nStage 	= _tData.stage or self.nStage --开启阶段
	self.nType  	= _tData.type or self.nType --任务类型
	self.nTargetNum = _tData.time or self.nTargetNum --目标次数
	self.nDropID 	= _tData.drop or self.nDropID --掉落ID
	self.sTitle 	= _tData.title or self.sTitle --标题	
end
--设置进度
function RemainsTaskVo:setTaskSchedule( _nNum )
	-- body
	if not _nNum then
		return
	end
	self.nNum = _nNum or self.nNum
	self.bFinished = self.nNum >= self.nTargetNum
end
--_bGet 是否已经获取
function RemainsTaskVo:updateRewardStatus( _bGet )
	-- body
	local bGet = false
	if _bGet ~= nil then
		bGet = _bGet
	end
	self.bGet = bGet
end

function RemainsTaskVo:isCanGetReward()
	return (self.bFinished) and (not self.bGet)
end
return RemainsTaskVo