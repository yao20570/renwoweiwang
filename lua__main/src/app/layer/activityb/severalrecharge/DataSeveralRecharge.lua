-----------------------------------------------------------------
-- Author: luwenjing
-- Date: 2017-12-21 15:32:36
-- 多次充值数据
-----------------------------------------------------------------
local Activity = require("app.data.activity.Activity")

local DataSeveralRecharge = class("DataSeveralRecharge", function()
	return Activity.new(e_id_activity.severalrecharge) 
end)
--创建自己(方便管理)
tActivityDataList[e_id_activity.severalrecharge] = function (  )
	return DataSeveralRecharge.new()
end

function DataSeveralRecharge:ctor()
    self:myInit()
end


function DataSeveralRecharge:myInit( )
	self.nM  	=	0   --Integer	领取状态 0不可领取 1可领取 2已经领取
	self.tPs	=	nil --	List<RechargeGiftPackVo>	礼包相关数据[礼包更新也使用该字段]
end


-- 读取服务器中的数据
function DataSeveralRecharge:refreshDatasByServer( _tData )
	-- dump(_tData.ps, "多次充值活动数据 ====",100)
	if not _tData then
	 	return
	end
	self.nM =	_tData.m or self.nM 		--Float 已经冲值的金额

	-- self.tPs	=	_tData.ps   or self.tPs --	List<RechargeGiftPackVo>	礼包相关数据[礼包更新也使用该字段]
	self:refreshRewardState(_tData)  --刷新礼包列表
	self:refreshActService(_tData)--刷新活动共有的数据

end

--是否有待完成的礼包
function DataSeveralRecharge:isCanGetRecharge()
	-- body
	-- dump(self.tPs,"isCanGetRecharge")
	-- print("m",self.nM)
	-- dump(self.tPs,"DataSeveralRecharge 46")
	for k,v in pairs(self.tPs) do
		if v.t == 0 then
			return 0 		--有未完成的礼包
		elseif v.t == 1 then
			return 1  		--有可领取的礼包
		end
	end
	return 2    		--全都已经领完
end

function DataSeveralRecharge:refreshRewardState(_tData )
	-- body
	-- dump(_tData,"rewardstate")
	if not _tData then
		return
	end

	if _tData.ps then
		if not self.tPs then
			self.tPs= _tData.ps
		else
			for k,v in pairs(_tData.ps) do
				for kk,vv in pairs(self.tPs) do 
					if vv.i == v.i then
						vv.t = v.t
					end
				end
			end
			sendMsg( gud_refresh_activity)
			
		end
	end
	-- dump(self.tPs,"tps")
end

function DataSeveralRecharge:getCurRewardIndex( )
	-- body
	local nIndex=1
	for k,v in pairs(self.tPs) do
		if v.t == 0 or v.t == 1 then		--找到一个未领取或可领取的 就展示这个
			break
		end
		nIndex= nIndex + 1
	end

	return nIndex
end


-- 获取红点方法
function DataSeveralRecharge:getRedNums()
	local nNums = 0

	-- if self.nT == 1 then
	-- 	nNums =  1
	-- end

	-- nNums = self.nLoginRedNums + nNums

	return nNums
end




return DataSeveralRecharge