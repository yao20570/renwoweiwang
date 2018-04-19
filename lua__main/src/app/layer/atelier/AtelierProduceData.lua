-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-05-09 16:42:51 星期二
-- Description: 作坊生产线数据 
-----------------------------------------------------

local AtelierProduceData = class("AtelierProduceData")
--该数据是否刷新cd
function AtelierProduceData:ctor(_isUseCd)
	-- body
	self:myInit(_isUseCd)
end


function AtelierProduceData:myInit(_isUseCd)
	self.bIsUseCD = _isUseCd or false
	self.nId  = nil 		--队列id
	self.nType = nil 		--材料类型
	self.nCD = 0 		--倒计时用于刷新
	self.nLastLoadTime = 0 --最新的加载时间
	self.nNd = 0 		--生产总时间
	self.fPs = 0 		---用于计算进度
	self.tGs = nil 		--生产物品
end

--从服务端获取数据刷新
function AtelierProduceData:refreshDatasByService( tData )
	-- body
	self.nId  = tData.proId or self.nId 		--队列id
	self.nType = tData.type or self.nType 		--材料类型
	self.nNd = tData.nd or self.nNd 			--生产总时间	
	self.tGs = tData.gs or self.tGs 			--生产物品	
	
	self.nCD = tData.cd or self.nCD 			--倒计时
	if tData.cd then
		self.nLastLoadTime = getSystemTime()
	end
	self.fPs = tData.ps or self.fPs 			--刷新时的进度
end	

--获取生产cd
function AtelierProduceData:getProduceCD(  )
	-- body
	-- 单位是秒
	if self.nCD then
		local fCurTime = getSystemTime()
		-- 总共剩余多少秒
		local fLeft = self.nCD - (fCurTime - self.nLastLoadTime)
		return fLeft
	else
		return 0
	end
end

--获取生产百分比
function AtelierProduceData:getProducePercent(  )
	-- body
	local fCurTime = getSystemTime()
	local fCurPs = self.fPs + (1-self.fPs)*(fCurTime - self.nLastLoadTime)/self.nCD
	if fCurPs >= 1 then
		fCurPs = 1
	elseif fCurPs < 0 then
		fCurPs = 0
	else
		if roundOff(fCurPs*100, 1) == 100 then --当计算误差范围内达到100%的情况下特殊处理
			fCurPs = 0.99
		else
			fCurPs = roundOff(fCurPs*100, 1)/100
		end
	end
	return fCurPs
end

--获取生产物品
function AtelierProduceData:getProduct()
	-- body
	return getBaseItemDataByID(tonumber(self.tGs.k))
end

return AtelierProduceData