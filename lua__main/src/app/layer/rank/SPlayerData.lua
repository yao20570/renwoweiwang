-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-05-23 14:3:23 星期二
-- Description: 排行榜数据
-----------------------------------------------------
local SPlayerData = class("SPlayerData")

function SPlayerData:ctor(  )
	self:myInit()
end

function SPlayerData:myInit(  )
	-- body
	self.nID 							= 			0		--玩家ID
	self.sName 							= 			"" 		--玩家名
	self.nCombat 						= 			0 		--历史最高战力
	self.nInfluence 					= 			0 		--玩家势力
	self.nZan							= 			0 		--点赞数量
	self.nVipLV							= 			0 		--VIP等级
	self.nLv							= 			0 		--玩家等级
	self.nPLv 							= 			0 		--玩家城池等级
	self.nOfficial						= 			0 		--官衔
	self.nArea 							= 			0 		--区域
	self.tHeroList 						= 			{} 		--武将信息
	self.nHadZan 						= 			0       --是否对当前玩家已经点赞 0没有 1已经点赞

	self.nPower 						= 			0 		--阵容战力
	--头像
	self.sI 		= 	nil
	self.sB 		=   nil
	self.sT 		= 	nil
	self.sIcon							= 			"ui/daitu.png"    --玩家头像
	self.sIconBg 						= 			"ui/daitu.png"		--玩家头像框	
	self.sTitle 						= 			nil
	self.bIsRb 							= 			nil
end

-- 根据服务端信息调整数据
function SPlayerData:refreshDatasByService( tData)
	-- body
	--dump(tData, "tData", 100)
	self.nID 			= 			tData.i or self.nID
	self.sName 			= 			tData.n or self.sName
	self.nCombat 		= 			tData.o or self.nCombat
	self.nInfluence 	= 			tData.c or self.nInfluence
	self.nZan 			= 			tData.d or self.nZan
	self.nVipLV 		= 			tData.v or self.nVipLV
	self.nLv 			= 			tData.l or self.nLv
	self.nPLv 			= 			tData.pl or self.nPLv
	self.nOfficial 		= 			tData.b or self.nOfficial
	self.nArea 			= 			tData.s or self.nArea
	self.nHadZan 		= 			tData.isP or self.nHadZan

	self.nPower 		= 			tData.tsc or self.nPower

	self.tHeroList 		= 			{}	
	if tData.bhs then
		for i, v in pairs(tData.bhs) do
			table.insert(self.tHeroList, v)
		end
	end

	self.sI 		= 	tData.p or self.sI
	self.sB 		=   tData.box or self.sB
	self.sT 		=   tData.tit or self.sT
	if tData.p then
		self.sIcon 	= 	getPlayerIconStr(tData.p)		--i	String	当前头像
	end
	if tData.box then
		self.sIconBg 	= 	getPlayerIconBg(tData.box)
	end	
	if tData.tit then
		self.sTitle 	= 	getPlayerTitle(tData.tit)
	end	
	if tData.rb then
		self.bIsRb = tData.rb == 1
	end
end

--点赞刷新
function SPlayerData:refreshZan( tData )
	-- body
	self.nZan = tData.pnum or self.nZan
	self.nHadZan = tData.isP or self.nHadZan
end

return SPlayerData