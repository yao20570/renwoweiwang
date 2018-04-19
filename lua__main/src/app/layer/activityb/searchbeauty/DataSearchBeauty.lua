-- Author: xiesite
-- Date: 2018-01-22 16:15:36
-- 寻访美人数据
local Activity = require("app.data.activity.Activity")

local DataSearchBeauty = class("DataSearchBeauty", function()
	return Activity.new(e_id_activity.searchbeauty) 
end)
--创建自己(方便管理)
tActivityDataList[e_id_activity.searchbeauty] = function (  )
	return DataSearchBeauty.new()
end

function DataSearchBeauty:ctor()
    self:myInit()
end


function DataSearchBeauty:myInit( )
	self.nHeroId 	= nil -- 寻访的武将
	self.nDrop   	= nil  --  正常寻访掉落
	self.nSl 		= 0 --  招募所需推荐信
	self.nOg 		= 0 --  寻访一次花费元宝
	self.nTg 		= 0 --  寻访十次花费元宝
	self.nL 		= 0  --	已经获得的推荐信
	self.nS 		= 0	-- 	是否已经招募了武将 0否 1是
end

-- 读取服务器中的数据
function DataSearchBeauty:refreshDatasByServer( _tData )
	-- dump(_tData, "寻访美人数据 ====")
	if not _tData then
	 	return
	end

	self.nHeroId 	= _tData.h 		or self.nHeroId -- 寻访的武将
	self.nDrop   	= _tData.d 		or self.nDrop  --  正常寻访掉落
	self.nSl 		= _tData.sl 	or self.nSl --  招募所需推荐信
	self.nOg 		= _tData.og 	or self.nOg --  寻访一次花费元宝
	self.nTg 		= _tData.tg 	or self.nTg --  寻访十次花费元宝
	self.nL 		= _tData.l 		or self.nL  --	已经获得的推荐信
	self.nS 		= _tData.s 		or self.nSs	-- 	是否已经招募了武将 0否 1是

	self:refreshActService(_tData)--刷新活动共有的数据

end

function DataSearchBeauty:getCurLetter()
	return self.nL
end

function DataSearchBeauty:getNeedLetter()
	return self.nSl
end

function DataSearchBeauty:getHeroId()
	return self.nHeroId
end

function DataSearchBeauty:getBuyPrice()
	return self.nOg
end

function DataSearchBeauty:getBuyTenPrice()
	return self.nTg
end

function DataSearchBeauty:getIsGet()
	if self.nS == 0 then
		return false
	elseif self.nS == 1 then
		return true
	end
end

--是否可以招募
function DataSearchBeauty:isCanGet()
	--
end

--默认免费次数是0
function DataSearchBeauty:getFreeTurn()
	return 0
end

-- 获取红点方法
function DataSearchBeauty:getRedNums()
	local nNums = 0

	-- if self.nT == 1 then
	-- 	nNums =  1
	-- end

	nNums = self.nLoginRedNums + nNums

	return nNums
end




return DataSearchBeauty