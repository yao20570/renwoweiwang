----------------------------------------------------- 
-- author: luwenjing
-- updatetime: 2018-03-30 10:13:33
-- Description: 国家商店数据
-----------------------------------------------------

--免费宝箱数据
local DataCountryShop = class("DataCountryShop")

function DataCountryShop:ctor(  )
	self:myInit()
end

function DataCountryShop:myInit(  )		
 	self.tPab = {}			                --个人限定商店数据 k-id,v-购买次数
 	self.tCob = {}                          --国家限定商店数据
end

-- 读取服务器中的数据
function DataCountryShop:refreshDatasByService( _tData )
	-- dump(_tData,"国家商店")
	if not _tData then
	 	return
	end
	self.tPab = _tData.pab or self.tPab
	self.tCab = _tData.cab or self.tCab
	-- self.tG = _tData.g or self.tG --	Set<Integer>	已领取的宝箱
	-- self.nCd=_tData.cd	--下一阶段的倒计时
	-- self.tNob = _tData.nob 	--将要获得的物品
	-- self.fLastLoadTime 		= getSystemTime() 					 --最后刷新时间
end

-- 获取下一阶段的倒计时
-- return(int):返回剩余时长
function DataCountryShop:getNextRewardTime(  )
	-- -- 单位是秒
	-- local fCurTime = getSystemTime()
	-- -- 总共剩余多少秒
	-- if self.nCd then
	-- 	local fLeft = self.nCd/1000 - (fCurTime - self.fLastLoadTime)
	-- 	if(fLeft < 0) then
	-- 		fLeft = 0
	-- 	end
	-- 	return fLeft
	-- else
	-- 	return self.nCd
	-- end

end

return DataCountryShop