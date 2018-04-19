-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-05-05 09:29:14 星期五
-- Description: 招募队列
-----------------------------------------------------

local RecruitTeam = class("RecruitTeam")

function RecruitTeam:ctor(  )
	self:myInit()
end

-- 初始化成员变量
function RecruitTeam:myInit()
	self.nId 				= 		0 			--队列id
	self.nNum 				= 		0 			--生产数量
	self.nSD 				= 		0 			--生产需要时间（秒）
	self.nCurNum 			= 		nil 		--当前数量(空闲队列才用到)
	self.nCurSD 			= 		nil 		--当前需要时间(空闲队列才用到)
	self.nCD 				= 		0 			--招募倒计时
	self.fLastLoadTime 		= 		nil 		--最后加载数据时间
	self.nType  			= 		0   		--类型 (服务端类型) 1.正在招募 2.等待招募 3.完成招募 100.可招募 200.兵量满 300.扩充
												--兵营募兵item类型（前端类型）
												-- e_camp_item = {
												-- 	ing 			= 		1, 				--募兵中
												-- 	free 			= 		2, 				--可募兵
												-- 	wait  			= 		3, 				--等待中
												-- 	fill 			= 		4, 				--兵力满
												-- 	finish 			= 		5, 				--完成募兵
												-- 	more 			= 		6, 				--扩充
												-- }
	self.nFree 				= 		0 			--免费加速标志 1:可加速 0:不可加速
end

--从服务端获取数据刷新
function RecruitTeam:refreshDatasByService( tData )
	-- body
	if tData then
		self.nId 				= 		tData.proId or self.nId 		--队列id
		self.nNum 				= 		tData.num or self.nNum 			--生产数量
		self.nSD 				= 		tData.sd or self.nSD			--生产需要时间（秒）
		self.nCD 				= 		tData.cd or self.nCD 			--招募倒计时
		if tData.cd then
			self.fLastLoadTime 	= 		getSystemTime()		            --最后加载数据时间
		end
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
end

--设置生产数量
function RecruitTeam:setCreateNum(_nNum)
	self.nNum = _nNum
end

-- --通过推送刷新数据
-- --_nType: 1:是否免费加速
-- function RecruitTeam:refreshByPush( _nType, _tData )
-- 	-- body
-- 	if _nType == 1 then
-- 		if self.nType == e_camp_item.ing then --招募中
-- 			if _tData.sp then
-- 				self.nFree 			= 		_tData.sp                       --1:可加速 0:不可加速
-- 			end
-- 		end
-- 	end
-- end

--刷新cd时间
function RecruitTeam:refreshCd(_tData)
	if _tData and _tData.cd then
		self.nCD = _tData.cd
		self.fLastLoadTime 	=  getSystemTime()	
	end
end

--获得募兵剩余时间
function RecruitTeam:getRecruitLeftTime( )
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
function RecruitTeam:getRecruitCurrentFinishValue(  )
	-- body
	--完成需要的时间
	local lCurLeftTime = self:getRecruitLeftTime()
	return getGoldByTime(lCurLeftTime)
end

return RecruitTeam
