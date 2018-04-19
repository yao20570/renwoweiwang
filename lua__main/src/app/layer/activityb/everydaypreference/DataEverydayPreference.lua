----------------------------------------------------- 
-- Author: luwenjing
-- Date: 2018-01-05 11:57:45
-- 每日特惠数据
----------------------------------------------------- 
local Activity = require("app.data.activity.Activity")

local DataEverydayPreference = class("DataEverydayPreference", function()
	return Activity.new(e_id_activity.everydaypreference) 
end)

--创建自己(方便管理)
tActivityDataList[e_id_activity.everydaypreference] = function (  )
	return DataEverydayPreference.new()
end

-- _index
function DataEverydayPreference:ctor()
	-- body
   self:myInit()
   -- self.nLastLoginTime = 0 --最后登陆的时间
end


function DataEverydayPreference:myInit( )

	self.nT = 0 		--Integer 今天是否领取免费赠品 0否 1是
	self.tPs = {}		--List<DealPackVo> 特惠礼包数据<或者更新数据>
end


-- 读取服务器中的数据
function DataEverydayPreference:refreshDatasByServer( _tData )
	-- dump(_tData,"，每日特惠数据", 20)
	if not _tData then
	 	return
	end
	self.nT = _tData.t   or self.nT  		--Integer 今天是否领取免费赠品 0否 1是
	self:refreshPackage(_tData)
	-- self.tPs = _tData.ps   or self.tPs  		--List<DealPackVo> 特惠礼包数据<或者更新数据>

	table.sort( self.tPs, function (a,b)
			return a.i < b.i
	end )

	self:refreshActService(_tData)--刷新活动共有的数据

end

function DataEverydayPreference:refreshPackage( _tData )
	-- body
	if #self.tPs == 0 then
		self.tPs=_tData.ps 
	elseif _tData.ps then
		for k,v in pairs(self.tPs) do
			for i=1 ,#_tData.ps do
				local vv=_tData.ps[i]
				if vv.i == v.i and vv.b then
					v.b=vv.b
				end
			end
		end
		if _tData.o then
			showGetItemsAction(_tData.o)
		end
	end
end
function DataEverydayPreference:updateEverydayRewardState( _tData )
	-- body
	-- dump(_tData)
	self.nT = _tData.t   or self.nT  		--Integer 今天是否领取免费赠品 0否 1是

end
-- 获取红点方法
function DataEverydayPreference:getRedNums()
	if self.nT == 0 then
		return 1
	else
		return 0
	end
end



return DataEverydayPreference