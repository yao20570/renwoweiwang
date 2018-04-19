-----------------------------------------------------
-- author: 
-- updatetime:  2017-05-16 10:42:51 星期二
-- Description: 任务项信息
-----------------------------------------------------

local Goods = require("app.data.Goods")
local DataChatprtTatget = class("DataChatprtTatget", Goods)


function DataChatprtTatget:ctor(  )
	DataChatprtTatget.super.ctor(self,e_type_goods.type_chatper_t)
	-- body
	self:myInit()
end


function DataChatprtTatget:myInit( )

	--拓展字段
	self.nType 					= 		0		 --任务类型
	self.sOpenCond 				= 		nil		 --开启条件
	self.sParam 				=		nil         --目标参数
	self.nDrop					= 		0	     --掉落ID

	--任务进度
	self.nCurNum 				=		0 			--当前完成的次数
	self.nTargetNum 			= 		1
	self.nGetPrizeState 		= 		0 			--目标奖励状态 0不可领 1可以领 2已经领
	self.nIsFinished 			=		0 			--是否已经完成0未完成 1已完成

	self.bShowTips 				=		false  		--显示奖励提示
	self.nSort 					= 		0           --排序
	self.sLinked 				=		nil
end


-- 用配置表DB中的数据来重置基础数据
function DataChatprtTatget:initDataByDB( tData )
	-- body
	--基本信息
	self.sName 					= 		tData.describe or self.sName     --任务说明
	self.sDes 					= 		tData.describe or self.sDes		--任务描述
	self.sTid 					= 		tData.id or self.sTid		    --任务id

	--拓展字段
	self.nType 					= 		tData.type or self.nType		 --任务类型
	self.sIcon 					= 		getTaskIconByType(self.nType) 	 --显示图标
	self.sOpenCond 				= 		tData.opencond or self.sOpenCond --开启条件
	self.sParam 				=		tData.param or self.sParam       --目标参数
	self.nDrop					= 		tData.drop or self.nDrop 	     --掉落ID
	self.nCid					=       tData.cid or self.nCid 	     --所属章节
	self.tChatperInfo			=		getChatperData(self.nCid)    --对应的章节信息
	self.sLinked 				= 		tData.linked or self.sLinked --界面跳转
	if self.tChatperInfo then
		self.sName = self.tChatperInfo.title.." "..self.sName
	end
end	

--刷新根据服务端数据返回装备数据
function DataChatprtTatget:refreshItemDataByService( tData )
	-- body
	self.nCurNum 				=		tData.x or self.nCurNum	--当前完成的次数
	self.nTargetNum 			=		tData.y or self.nTargetNum	--目标总共进度
	self.nGetPrizeState 		= 		tData.t or self.nGetPrizeState	--目标奖励状态 0不可领 1可以领 2已经领
	if self.nCurNum >= self.nTargetNum then
		self.nIsFinished = 1
	end
	self:updateSort()	
end
 

function DataChatprtTatget:updateSort(  )
	-- 不可领取
	if self.nGetPrizeState == 0 then
		self.nSort = 1
	-- 可以领取
	elseif self.nGetPrizeState == 1 then
		self.nSort = 0
	--已经领取
	elseif self.nGetPrizeState == 2 then
		self.nSort = 2
	end
end

return DataChatprtTatget
