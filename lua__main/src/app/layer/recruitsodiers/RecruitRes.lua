-- RecruitRes.lua
-----------------------------------------------------
-- author: dshulan
-- updatetime:  2018-4-2 14:51:49 星期一
-- Description: 募兵府招募队列数据
-----------------------------------------------------

local RecruitRes = class("RecruitRes")

function RecruitRes:ctor(  )
	self:myInit()
end

-- 初始化成员变量
function RecruitRes:myInit()
	self.nId 				= 		0 			--队列id
	self.nNum 				= 		0 			--生产数量
	self.nSD 				= 		0 			--生产需要时间（秒）
	self.nCurNum 			= 		nil 		--当前数量(空闲队列才用到)
	self.nCurSD 			= 		nil 		--当前需要时间(空闲队列才用到)
	self.nCD 				= 		0 			--招募倒计时
	self.fLastLoadTime 		= 		nil 		--最后加载数据时间
	self.nType  			= 		0   		--类型 (服务端类型) 1.正在招募 2.等待招募 3.完成招募 100.可招募 200.兵量满 300.扩充
												
	self.nFree 				= 		0 			--免费加速标志 1:可加速 0:不可加速
end

--从服务端获取数据刷新
function RecruitRes:refreshDatasByService( tData )
	-- body
	if tData then
		self.nId 				= 		tData.proId or self.nId 		--队列id
		self.nNum 				= 		tData.num or self.nNum 			--生产数量
		self.nSD 				= 		tData.sd or self.nSD			--生产需要时间（秒）
		self.nCD 				= 		tData.cd or self.nCD 			--招募倒计时
		self.fLastLoadTime 		= 		getSystemTime()		            --最后加载数据时间
		if tData.tp then
			if tData.tp == 1 then
				--正在招募中，需要判断是否有免费加速
				self.nFree 		= 		tData.sp 						--1:可加速 0:不可加速
				self.nType  	= 		e_camp_item.ing
			elseif tData.tp == 2 then
				self.nType  	= 		e_camp_item.wait
			elseif tData.tp == 3 then
				self.nType  	= 		e_camp_item.finish
			elseif tData.tp == 100 then
				self.nType  	= 		e_camp_item.free
			elseif tData.tp == 200 then
				self.nType  	= 		e_camp_item.fill
			elseif tData.tp == 300 then
				self.nType  	= 		e_camp_item.more
			end
		end
	end
	-- dump(self, "募兵府招募队列数据 :")
end

--设置生产数量
function RecruitRes:setCreateNum(_nNum)
	self.nNum = _nNum
end

--刷新cd时间
function RecruitRes:refreshCd(_tData)
	if _tData and _tData.cd then
		self.nCD = _tData.cd
		self.fLastLoadTime 	=  getSystemTime()	
	end
end

--获得募兵剩余时间
function RecruitRes:getRecruitLeftTime( )
	-- body
	if self.nCD and self.nCD > 0 then
		-- 单位是秒
		local fCurTime = getSystemTime()
		-- 总共剩余多少秒
		local fLeft = self.nCD - (fCurTime - self.fLastLoadTime or 0)
		if(fLeft < 0) then
			fLeft = 0
		end
		return fLeft
	else
		return 0
	end
end

--获得当前金币完成所需要的值
--注意：加速消耗金币会受到多方面影响，统一处理，统一调用
function RecruitRes:getRecruitCurrentFinishValue(  )
	-- body
	--完成需要的时间
	local lCurLeftTime = self:getRecruitLeftTime()
	return getGoldByTime(lCurLeftTime)
end

return RecruitRes