----------------------------------------------------- 
-- author: luwenjing
-- updatetime: 2018-01-09 15:46:36
-- Description: 腊八拉霸
-----------------------------------------------------
local Activity = require("app.data.activity.Activity")

local DataLaba = class("DataLaba", function()
	return Activity.new(e_id_activity.laba) 
end)
--创建自己(方便管理)
tActivityDataList[e_id_activity.laba] = function (  )
	return DataLaba.new()
end

function DataLaba:ctor()
   self:myInit()
end


function DataLaba:myInit( )
	self.nFn = 0 		--已使用的免费次数
	self.nTfn = 0 		--总的免费次数
	self.tShow = {} 	--最佳奖励
	self.tFir = {}		--一等奖
	self.tSec = {}		--二等奖
	self.tThr = {}		--三等奖
	self.nPrice = 0 	--单价
	self.nR10 = 0 	    --抽十次的折扣
	self.nR50 = 0 	    --抽五十次的折扣
	-- self.tGotGrids = {}
end


-- 读取服务器中的数据
--_tData(ConsumeIronRes)
function DataLaba:refreshDatasByServer( _tData )
	-- dump(_tData,"laba",100)
	if not _tData then
	 	return
	end
	self.nFn = _tData.fn or self.nFn 		--已使用的免费次数
	self.nTfn = _tData.tfn or self.nTfn 		--总的免费次数
	self.tShow = _tData.show or self.tShow 	--最佳奖励
	self.tFir = _tData.fir or self.tFir		--一等奖
	self.tSec = _tData.sec or self.tSec		--二等奖
	self.tThr = _tData.thr or self.tThr		--三等奖
	self.nPrice = _tData.price or self.nPrice 	--单价
	self.nR10 = _tData.r10 or self.nR10 	    --抽十次的折扣
	self.nR50 = _tData.r50 or self.nR50 	    --抽五十次的折扣
	

	self:refreshActService(_tData)--刷新活动共有的数据
end
function DataLaba:isHaveFree(  )
	-- body

	return self.nFn < self.nTfn
end

function DataLaba:getFreeNum(  )
	-- body
	return self.nTfn - self.nFn 
end

function DataLaba:getPrice(_nNum)
	local nNum = _nNum or 1
	if nNum == 1 then
		return self.nPrice
	elseif nNum == 10 then
		return self.nPrice * 10 * self.nR10
	elseif nNum == 50 then
		--todo
		return self.nPrice * 50 * self.nR50
	end
end

function DataLaba:updateFn( _tData )
	-- body
	if not _tData then
		return
	end
	self.nFn = _tData.fn or self.nFn
end


-- 获取红点方法
function DataLaba:getRedNums()
	if self:getFreeNum() <= 0 then
		return 0
	else
		return self:getFreeNum()
	end

end




return DataLaba