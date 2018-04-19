----------------------------------------------------- 
-- author: luwenjing
-- updatetime: 2017-10-30 10:18:33
-- Description: 免费宝箱数据
-----------------------------------------------------

--免费宝箱数据
local DataDailyGift = class("DataDailyGift")

function DataDailyGift:ctor(  )
	self:myInit()
end

function DataDailyGift:myInit(  )
	self.tG = {}				--已获得的宝箱			
 	self.nCd = 0			--下一阶段的倒计时
 	self.tNob = {}
 	self.fLastLoadTime 		= 0					 --最后登录的时间
end

-- 读取服务器中的数据
function DataDailyGift:refreshDatasByServer( _tData )
	-- dump(_tData,"免费宝箱")
	if not _tData then
	 	return
	end
	self.tG = _tData.g or self.tG --	Set<Integer>	已领取的宝箱
	self.nCd=_tData.cd	--下一阶段的倒计时
	self.tNob = _tData.nob 	--将要获得的物品
	self.fLastLoadTime 		= getSystemTime() 					 --最后刷新时间
end

-- 获取下一阶段的倒计时
-- return(int):返回剩余时长
function DataDailyGift:getNextRewardTime(  )
	-- 单位是秒
	local fCurTime = getSystemTime()
	-- 总共剩余多少秒
	if self.nCd then
		local fLeft = self.nCd/1000 - (fCurTime - self.fLastLoadTime)
		if(fLeft < 0) then
			fLeft = 0
		end
		return fLeft
	else
		return self.nCd
	end

end

return DataDailyGift