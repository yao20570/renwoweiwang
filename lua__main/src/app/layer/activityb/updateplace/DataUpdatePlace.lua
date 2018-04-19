-- Author: liangzhaowei
-- Date: 2017-06-30 15:05:05
-- 王宫升级数据
local Activity = require("app.data.activity.Activity")

local DataUpdatePlace = class("DataUpdatePlace", function()
	return Activity.new(e_id_activity.updateplace) 
end)
--创建自己(方便管理)
tActivityDataList[e_id_activity.updateplace] = function (  )
	return DataUpdatePlace.new()
end

function DataUpdatePlace:ctor()
   self:myInit()
end


function DataUpdatePlace:myInit( )
	self.tAwards  	=	{}   --Set<Integer>	已领取的奖励(王宫等级)
	self.tConf	    =	{} --	List<PalaceUpgradesAward>	奖励配置
	if self.sRule then
    	self.tStrSp = luaSplitMuilt(self.sRule,";",":")  --获取显示信息
	end

	self.bFirstSort = false

end


-- 读取服务器中的数据
function DataUpdatePlace:refreshDatasByServer( _tData )
	-- dump(_tData, "DataUpdatePlace", 10)
	if not _tData then
	 	return
	end

	self.tAwards  	=	_tData.awards	or self.tAwards   --Set<Integer>	已领取的奖励(王宫等级)
	self.tConf	    =	_tData.conf   or self.tConf --	List<PalaceUpgradesAward>	奖励配置
	--物品排序
	for i=1,#self.tConf do
		sortGoodsList(self.tConf[i].award)
	end
	--
	-- if not  self.bFirstSort then
		-- self.bFirstSort = true
	-- 如果被服务端的数据重置了，那么重新刷新一下tShowInfo的数据
	if(_tData.conf) then
		for k,v in pairs(self.tConf) do
			v.tShowInfo = self.tStrSp[k]
		end
	end
	-- end


	self:refreshActService(_tData)--刷新活动共有的数据

end

--当前等级是领取状态 (_nLv 领取项中的等级)
function DataUpdatePlace:getStateByItemLv(_nLv)
	local nGetState = en_get_state_type.cannotget --不可领取

	local  palacedata = Player:getBuildData():getBuildById(e_build_ids.palace)--王宫数据
	if _nLv and palacedata and palacedata.nLv then
		if 	palacedata.nLv >=  _nLv then
			local bFind = false
			for k,v in pairs(self.tAwards) do
				if v == _nLv then
					bFind = true
				end
			end

			if bFind then
				nGetState = en_get_state_type.haveget --已经领取
			else
				nGetState = en_get_state_type.canget --可以领取
			end
		end
	end

	return  nGetState
end

--是否需要关闭 bClose true 为可以关闭
function DataUpdatePlace:bClose()
	local bClose = true
	for k,v in pairs(self.tConf) do
		local nSort = 0
		if self:getStateByItemLv(v.lv) ~= en_get_state_type.haveget  then
		 	bClose = false
		end 
	end
	return bClose
end

--获得排序
function DataUpdatePlace:resetSort()
	if not self.tConf then
       return
	end

	for k,v in pairs(self.tConf) do
		local nSort = 0
		if self:getStateByItemLv(v.lv) == en_get_state_type.haveget  then
		 	nSort = 1
		end 
		v.nSort = nSort
	end

	table.sort(self.tConf,function (a,b)
		if a.nSort == b.nSort then
			return a.lv < b.lv
		else
			return a.nSort < b.nSort
		end
	end)

end


-- 获取红点方法
function DataUpdatePlace:getRedNums()
	local nNums = 0

	--获取是否有领取的选项
	for k,v in pairs(self.tConf) do
		if v.lv then
			if self:getStateByItemLv(v.lv) == en_get_state_type.canget then
			 	nNums = 1 
			 	break
			end 
		end
	end
	-- dump(nNums,"nNums")

	nNums = self.nLoginRedNums + nNums

	return nNums
end




return DataUpdatePlace