-----------------------------------------------------
-- author: maheng
-- updatetime:  2018-04-11 14:49:23 星期三
-- Description: 发展礼包
-----------------------------------------------------
local Activity = require("app.data.activity.Activity")
local DataDevelopGift = class("DataDevelopGift", function()
	return Activity.new(e_id_activity.developgift) 
end)

--创建自己(方便管理)
tActivityDataList[e_id_activity.developgift] = function (  )
	return DataDevelopGift.new()
end


function DataDevelopGift:ctor()
	-- body
   self:myInit()
end


function DataDevelopGift:myInit( )
	self.tBuy = {}
	self.tGiftVOs = {}
	local tTitles = luaSplitMuilt(self.sRule, ";", ",")
	if tTitles and #tTitles > 0 then
		self.tTitles = {}
		for k, v in pairs(tTitles) do
			local nIdx = tonumber(v[1])
			local sStr = tostring(v[2])
			self.tTitles[nIdx] = sStr
		end
	end
end

-- 读取服务器中的数据
function DataDevelopGift:refreshDatasByServer( _tData )
	if not _tData then
	 	return
	end
	-- dump(_tData, "发展礼包", 100)
	-- dump(self.tTitles, "self.tTitles", 100)
	self.tBuy = _tData.buys or self.tBuy
	self.tGiftVOs = _tData.gfVOs or self.tGiftVOs
	for k, v in pairs(self.tGiftVOs) do
		v.nBuy = self:getBuyNumById(v.pid)	
		v.sTitle = self.tTitles[v.idx]	
	end
	table.sort(self.tGiftVOs, function ( a, b )
		-- body
		return a.idx < b.idx
	end)
	self:refreshActService(_tData)                        --刷新活动共有的数据
end

function DataDevelopGift:getBuyNumById( _nId )
	-- body
	local nNum = 0
	if _nId and self.tBuy[_nId] then
		nNum = self.tBuy[_nId]
	end
	return nNum
end

function DataDevelopGift:getDevelopGifts( ... )
	-- body
	return self.tGiftVOs
end

-- 获取红点方法
function DataDevelopGift:getRedNums()
	local nNums = 0

	return nNums
end

return DataDevelopGift