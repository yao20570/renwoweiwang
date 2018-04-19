-- Author: liangzhaowei
-- Date: 2017-04-27 19:35:39
-- Description: Buff 属性
-----------------------------------------------------
local Goods = require("app.data.Goods")


local Buff = class("Buff", Goods)

function Buff:ctor(  )
	Buff.super.ctor(self,e_type_goods.type_buff)
	self:myInit()
end

function Buff:myInit()
	self.tEffects 			=		{} 		--buff效果表 		
	self.tEffectDict        =       {}      --buff字典
end

-- 用配置表DB中的数据来重置基础数据
function Buff:initDatasByDB( _tData )
	if (not _tData) then
		return 
	end
	self.nTime       = _tData.time or self.nTime --持续时间(秒)
	self.sDesc       = _tData.desc or self.sDesc --描述
	self.sIcon       = string.format("#%s.png",tostring(_tData.icon))
	--初始化buff效果表
	self:initEffects(_tData.effects)
end

--buff效果表
function Buff:initEffects( _sStr )
	-- body
	if not _sStr then
		return
	end
	if string.find(_sStr, ";") then
		local tT = luaSplit(_sStr, ";")
		if tT and table.nums(tT) > 0 then
			for k, v in pairs (tT) do
				local tTmp = luaSplit(v, ":")
				if tTmp and table.nums(tTmp) > 0 then
					table.insert(self.tEffects, tTmp)
					local nKey = tonumber(tTmp[1])
					local nValue = tonumber(tTmp[2])
					if nKey and nValue then
						self.tEffectDict[nKey] = nValue
					end
				end
			end
		end
	else
		local tTmp = luaSplit(_sStr, ":")
		if tTmp and table.nums(tTmp) > 0 then
			table.insert(self.tEffects, tTmp)
			local nKey = tonumber(tTmp[1])
			local nValue = tonumber(tTmp[2])
			if nKey and nValue then
				self.tEffectDict[nKey] = nValue
			end
		end
	end
end

--获得buff效果表
function Buff:getEffects( )
	-- body
	return self.tEffects
end

--获取buff字典
function Buff:getEffectDict( )
	return self.tEffectDict
end

--获取buff相关加乘
function Buff:getBuffPercentAdd( nBuffKey )
	return self.tEffectDict[nBuffKey] or 0
end

return Buff

