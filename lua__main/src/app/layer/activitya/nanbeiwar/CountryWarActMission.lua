----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-06-29 19:41:57
-- Description: 对应服务器的数据
-----------------------------------------------------
local CountryWarActMission = class("CountryWarActMission")

function CountryWarActMission:ctor( tData )
	self.sDesc = ""
	self.tAward = {}
	self:update(tData)
end

function CountryWarActMission:update( tData )
	self.nId = tData.id	or self.nId --Integer	任务ID
	self.nTimes = tData.times or self.nTimes --Integer	达成次数
	self.tAward = tData.award or self.tAward --	List<Pair<Integer,Long>>	奖励
	--物品排序
	sortGoodsList(self.tAward)
end

function CountryWarActMission:setDesc( tData )
	self.sDesc = tData or ""
end

function CountryWarActMission:getDesc( )
	return self.sDesc
end

return CountryWarActMission