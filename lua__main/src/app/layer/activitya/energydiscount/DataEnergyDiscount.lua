-- Author: luwenjing
-- Date: 2017-12-14 16:14:12
-- 副本加速数据
local Activity = require("app.data.activity.Activity")

local DataEnergyDiscount = class("DataEnergyDiscount", function()
	return Activity.new(e_id_activity.expeditefuben) 
end)

--创建自己(方便管理)
tActivityDataList[e_id_activity.energydiscount] = function (  )
	return DataEnergyDiscount.new()
end

function DataEnergyDiscount:ctor()
	-- body
   self:myInit()
end


function DataEnergyDiscount:myInit( )
 	
end

-- 读取服务器中的数据
function DataEnergyDiscount:refreshDatasByServer( _tData )
	-- dump(_tData,"数据",20)
	if not _tData then
	 	return
	end
	self.nNum  = _tData.num or self.nNum
 	self.nTc  = _tData.tc or self.nTc

	self:refreshActService(_tData)--刷新活动共有的数据
end
function DataEnergyDiscount:getActDiscountTimes(  )
	-- body
	return self.nTc - self.nNum  
end

-- 获取红点方法
function DataEnergyDiscount:getRedNums()
	local nNums = 0
	nNums = self.nLoginRedNums + nNums
	return nNums
end

function DataEnergyDiscount:getEnergyDiscountCost(_nNum)
	-- body
	local tTemp=luaSplit(self.tParam, "=")
	if tTemp then

		local tCost = luaSplit(tTemp[2], ";")
		local nTotal=0
		if self.nNum>=self.nTc then
			return nTotal
		else
			for i=1 , _nNum do
				local nIndex=self.nNum + i
				if nIndex>self.nTc then
					break
				end

				nTotal= nTotal + tonumber(tCost[nIndex])
			end
			return nTotal
		end
	end
end

return DataEnergyDiscount