-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-05-16 10:42:51 星期二
-- Description: 任务项信息
-----------------------------------------------------

local Goods = require("app.data.Goods")

local BTaskItemData = class("BTaskItemData", Goods)


function BTaskItemData:ctor(  )
	BTaskItemData.super.ctor(self,e_type_goods.type_task)
	-- body
	self:myInit()
end


function BTaskItemData:myInit( )

	--拓展字段
	self.nType 					= 		0		 	--任务类型
	self.sOpenCond 				= 		nil 		--开启条件
	self.nMode 					=		nil         --任务方式	
	self.sTarget				= 		nil  	 	--任务目标
	self.nTargetNum 			= 		0 			--目标数量	
	self.nDropId 				= 		nil 	 	--掉落ID
	self.sLinked				=		nil 		--前往界面类型
	self.sOpenBuild 			= 		nil 		--开放建筑
	self.nSequence 				= 		0 			--显示顺序
	self.sRebellv 				= 		nil 		--攻打乱军等级区间
	--任务进度
	self.nCurNum 				=		0 			--当前完成的次数
	self.nIsGetPrize 			= 		0 			--是否已经领取奖励0未领取 1已领取
	self.nIsFinished 			=		0 			--是否已经完成0未完成 1已完成

	self.bShowTips 				=		false  		--显示奖励提示
	self.nSort 					= 		0           --排序
end


-- 用配置表DB中的数据来重置基础数据
function BTaskItemData:initDataByDB( tData )
	-- body
	--基本信息
	self.sName 					= 		tData.describe or self.sName     --任务说明
	self.sDes 					= 		tData.taskdes or self.sDes		--任务描述
	self.sTid 					= 		tData.id or self.sTid		    --任务id
	if self.sTid >= 4001 and self.sTid <= 4999 then --每日目标
		self.nGtype = e_type_goods.type_daily
	elseif self.sTid >= 20001  and self.sTid <= 29999 then
		self.nGtype = e_type_goods.type_task
	end
	--拓展字段
	self.nType 					= 		tData.type or self.nType		 --任务类型
	self.sIcon 					= 		getTaskIconByType(self.nType) 	 --显示图标
	self.sOpenCond 				= 		tData.opencond or self.sOpenCond --开启条件
	self.nMode 					=		tData.mode or self.nMode         --任务方式
	self.sTarget				= 		tData.target or self.sTarget  	 --任务目标
	self.nTargetNum 			= 		tData.num or self.nTargetNum 	--目标数量	
	self.nDropId 				= 		tData.dropid or self.nDropId 	 --掉落ID
	self.sLinked				=		tData.linked or self.sLinked 		--前往界面类型
	self.sOpenBuild 			= 		tData.openbuild or self.sOpenBuild --开放建筑	
	self.nSequence 				= 		tData.sequence or self.nSequence --显示顺序
	self.sRebellv 				= 		tData.rebellv or self.sRebellv   --攻打乱军等级区间

end	
--刷新根据服务端数据返回刷新装备数据
function BTaskItemData:refreshItemDataByService( tData )
	-- body
	self.nCurNum 				=		tData.p or self.nCurNum	--当前完成的次数
	self.nIsGetPrize 			= 		tData.w or self.nIsGetPrize	--是否已经领取奖励0未领取 1已领取
	self.nIsFinished 			=		tData.f or self.nIsFinished --是否已经完成0未完成 1已完成
	--当前主线任务的弹窗提示
	if self.nIsFinished == 1 and self.nIsGetPrize == 0 and self.nType == e_task_type.main then
		self.bShowTips = true
	end	
	self:updateSort()	
end

--获取是否完成
function BTaskItemData:getIsFinished()
	return self.nIsFinished == 1
end

function BTaskItemData:setTaskGetPrize( _nStatus )
	-- body
	self.nIsGetPrize = _nStatus or 0
	self:updateSort()
end

function BTaskItemData:updateSort(  )
	-- body
	if self.nIsFinished == 1 then--已完成
		if self.nIsGetPrize == 1 then--已领取
			self.nSort = 2
		else
			self.nSort = 0
		end
	else
		self.nSort = 1
	end
end
return BTaskItemData
