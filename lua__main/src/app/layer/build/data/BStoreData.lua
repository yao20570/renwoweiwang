-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-04-21 18:14:15 星期五
-- Description: 仓库数据 
-----------------------------------------------------

local Build = require("app.layer.build.data.Build")

local BStoreData = class("BStoreData", function()
	-- body
	return Build.new()
end)

function BStoreData:ctor(  )
	-- body
	self:myInit()
end


function BStoreData:myInit(  )
	self.lWoodPro 			= 		0 			--目前木保护量
	self.lFoodPro 			= 		0 			--目前粮食保护量
	self.lCoinPro 			= 		0 			--目前铜保护量
end

--从服务端获取数据刷新
function BStoreData:refreshDatasByService( tData )
	--dump(tData, "BStoreData=", 100)
	-- body
	self.lWoodPro 				= 		tData.woodPro or self.lWoodPro     --木保护量
	self.lFoodPro 				= 		tData.foodPro or self.lFoodPro     --粮食保护量
	self.lCoinPro 				= 		tData.coinPro or self.lCoinPro 	   --铜保护量

	self.nCellIndex 			= 		tData.loc or self.nCellIndex  --建筑格子下标（位置）
	self.nLv 					= 		tData.lv or self.nLv 		  --等级
	--发送仓库数据刷新
	sendMsg(ghd_refresh_warehouse_msg)
end

--获取基础资源数量
--参数_resid 资源id  
--返回值对应ID的资源的保护量
--参数为空返回所有资源的总保护量
function BStoreData:getBaseResProNum( _resid )
	-- body
	if _resid then
		if _resid == e_resdata_ids.lc then --粮草
			return self.lFoodPro
		elseif _resid == e_resdata_ids.yb then--钱币
			return self.lCoinPro
		elseif _resid == e_resdata_ids.mc then--木材
			return self.lWoodPro
		end
	else
		return self.lWoodPro + self.lFoodPro + self.lCoinPro
	end
	return 0
end
return BStoreData