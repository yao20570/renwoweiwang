-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-04-21 18:15:26 星期五
-- Description: 科技院数据 
-----------------------------------------------------

local Build = require("app.layer.build.data.Build")

local BTnolyData = class("BTnolyData", function()
	-- body
	return Build.new()
end)

function BTnolyData:ctor(  )
	-- body
	self:myInit()
end


function BTnolyData:myInit(  )
	
end

--从服务端获取数据刷新
function BTnolyData:refreshDatasByService( tData )
	-- body
	self.nCellIndex 			= 		tData.loc or self.nCellIndex  --建筑格子下标（位置）
	self.nLv 					= 		tData.lv or self.nLv 		  --等级
end

return BTnolyData