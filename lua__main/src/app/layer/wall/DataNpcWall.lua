-- author: liangzhaowei
-- Date: 2017-05-15 11:42:50
-- Description: 城门守卫数据 
-----------------------------------------------------

local Npc = require("app.data.npc.Npc")

local DataNpcWall = class("DataNpcWall", function()
	-- body
	return Npc.new()
end)

function DataNpcWall:ctor(  )
	-- body
	self:myInit()
end


function DataNpcWall:myInit(  )
	self.sCodeId = ""  --	守卫ID
	self.nTp = 0 --	当前带兵量
	self.nCt = 0 -- 剩余提升次数
end

--从服务端获取数据刷新
function DataNpcWall:refreshDatasByService( tData )
	-- body
	self.sCodeId	    =        tData.id	  or self.sCodeId        --	守卫ID
	self.sTid           =        tData.mid     or self.sTid        --  唯一ID   
	self.nLevel	        =        tData.lv	  or self.nLevel	     --	等级
	self.nTroops	    =        tData.max	  or self.nTroops        --	最高带兵量
	self.nTp	        =        tData.tp	  or self.nTp	         --	当前带兵量
	self.nQuality	    =        tData.q	  or self.nQuality       --	品质
	self.nCt	        =        tData.ct	  or self.nCt	         --	剩余提升次数
	if tData.img then
		self.sImg	    =        tData.img 				             --武将形象
	end
	

	-- dump(self.nCt,"self.nCt")

end

return DataNpcWall