-- Author: maheng
-- Date: 2017-12-07 9:41:12
-- 神兵暴击
local Activity = require("app.data.activity.Activity")

local AfCritVo = require("app.layer.activitya.magiccrit.AfCritVo")

local DataMagicCrit = class("DataMagicCrit", function()
	return Activity.new(e_id_activity.magiccrit) 
end)

--创建自己(方便管理)
tActivityDataList[e_id_activity.magiccrit] = function (  )
	return DataMagicCrit.new()
end

function DataMagicCrit:ctor()
	-- body
   self:myInit()
end


function DataMagicCrit:myInit( )
 	self.tAfCritVos = {}
end

-- 读取服务器中的数据
function DataMagicCrit:refreshDatasByServer( _tData )
	-- dump(_tData,"数据",20)
	if not _tData then
	 	return
	end

	if _tData.ac then
		self.tAfCritVos = {}
		for i=1,#_tData.ac do
			local tData2 = _tData.ac[i]
			local tAfCritVo = AfCritVo.new(tData2)
			self.tAfCritVos[tData2.a] = tAfCritVo
		end		 
	end

	self:refreshActService(_tData)--刷新活动共有的数据
end

-- 获取红点方法
function DataMagicCrit:getRedNums()
	local nNums = 0
	nNums = self.nLoginRedNums + nNums
	return nNums
end

function DataMagicCrit:getCrit( nWeaponId )
	if self.tAfCritVos[nWeaponId] then
		return self.tAfCritVos[nWeaponId].nCrit
	end
	return 1 --默认是1倍
end

return DataMagicCrit