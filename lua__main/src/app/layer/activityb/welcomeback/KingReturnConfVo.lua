-- KingReturnConfVo.lua
---------------------------------------------
-- Author: dshulan
-- Date: 2018-04-16 15:39:00
---------------------------------------------

local KingReturnConfVo = class("KingReturnConfVo")

function KingReturnConfVo:ctor( tData, tSubtitle )
	self.sTask = "" 								--任务描述
	self.nGot = e_get_state.cannotget 				--是否已领取
	self:update(tData, tSubtitle)
end

function KingReturnConfVo:update( tData, tSubtitle )
	if not tData then
		return
	end
	self.nDay 		= tData.day or self.nDay	--int 第几天
	self.nType 		= tData.type or self.nType 	--int 类型 (类型1=通关副本，类型2=使用加速道具，类型3=装备洗练，类型4=升级建筑，类型5=消耗体力，6=击败世界乱军，7=发起或参与城战）
	self.nNum 		= tData.num or self.nNum	--int 完成次数
	self.tAwards 	= tData.aw or self.tAwards	--list 奖励
	if tSubtitle then
		for k, v in ipairs(tSubtitle) do
			if k == self.nDay then
				self.sTask = v
			end
		end
	end
end


return KingReturnConfVo