-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-04-25 19:42:51 星期二
-- Description: 物品基本信息
-----------------------------------------------------

local Goods = require("app.data.Goods")

local ItemStuffData = class("ItemStuffData", Goods)

--e_id_item.dalaba
e_id_item = {
  dalaba =  100026, --大喇叭
  expItemS = 100034, --小经验丹	
  expItemM = 100035, --中经验丹	
  expItemB = 100036, --大经验丹	
  zdjz = 100095, --自动建造
  bccf = 100096, --补充城防
  bbgm = 100110, --步兵购买
  qbgm = 100111, --骑兵购买
  gbgm = 100112, --弓兵购买
  energy = 100083,  -- 体力购买
  recruitment = 100019, --募兵令
  gfys 	= 100115, 	--工坊预设
  kjky = 100113,	--可以快研究
  sjqc = 100027, 	--随机迁城
  bossCallS = 100172, --低级召唤物
  bossCallL = 100154, --中级召唤物
  bossCallH = 100155, --高级召唤物
  bossToken  = 100156, --Boss信物
  redT = 100157,--20红包
  redF = 100158,--50红包
  redH = 100159,--100红包
  redTH = 100160,--200红包
  zwpiece = 100214,--纣王碎片
  coinM = 100005,--50k银币
  arenaToken = 100218,--竞技场挑战令牌
}


function ItemStuffData:ctor(  )
	ItemStuffData.super.ctor(self,e_type_goods.type_item)
	-- body
	self:itemStuffDataInit()
end


function ItemStuffData:itemStuffDataInit( )

	self.nSequence				=		nil  --背包排序
	self.nType 					= 		nil 		--背包分类类型 1-消耗品 2-材料 3- 其他
	self.nEffectType 			= 		nil--效果1-加速
	self.sParam 				= 		nil 	--物品效果参数
	self.sBuffId 				= 		nil 	--BUFF ID
	self.nUseLevel 				= 		nil 	--使用等级
	self.sUseNeedItem 			= 		nil --使用需要的其他物品
	self.nPrice 				= 		nil 	--价格
	self.sDropId 				=		nil 	--掉落ID
	self.nCanbuy 				= 		nil    --是否可以购买
	self.sTips 					= 		nil 		--获得途径
	self.nIsShow				= 		nil 	--是否在背包中显示
	self.nSell 					= 		nil 		--出售价格 -1不能出售
	self.nCanExchange 			= 		nil  -- 是否可选择获得
	self.nBoxType				= 		nil  	-- 操作弹框 1-没有按钮 2使用 3使用后跳转
	self.nCanUse 				= 		nil 	--能否使用 0-不可以使用 1-可以使用 2-组合使用
	self.nBatchUseNum 			= 		nil  --一次批量使用的
	--self.nStackNum 				= 		nil  --背包最大数量	
	self.nDayUse 				= 		0
	self.nExchange 				= 		nil 	--商店兑换id

	self.nRedNum 				= 		0  --装备红点

	self.sSideIcon 				= 		nil
	self.nItemType 				=		nil --物品类型
end


-- 用配置表DB中的数据来重置基础数据
function ItemStuffData:initDataByDB( tData )
	-- body
	--基本信息
	self.sName 					= 		tData.name or self.sName 		--物品名字
	self.sDes 					= 		tData.desc or self.sDes		--描述
	self.sTid 					= 		tData.id or self.sTid		--物品id
	if tData.icon then
		self.sIcon 				= 		"#"..tData.icon..".png"
	else
		self.sIcon 				=	 	"ui/daitu.png" 		--显示图标
	end	
	self.sSideIcon 				= 		tData.sideicon or self.sSideIcon
	-- if tData.sideicon then
	-- 	self.sSideIcon 			= 		tData.sideicon
	-- else
	-- 	self.sSideIcon 			=	 	nil 		--显示图标
	-- end
	self.nQuality 				= 		tData.quality or self.nQuality 	--品质
	--拓展字段
	self.nSequence				=		tData.sequence or self.nSequence --背包排序
	self.nType 					= 		tData.category or self.nType		--背包分类类型 1-消耗品 2-材料 3- 其他
	self.nEffectType 			= 		tData.effecttype or self.nEffectType --效果1-加速
	self.sParam 				= 		tData.param or self.sParam 	--物品效果参数
	self.sBuffId 				= 		tData.vipbuff or self.sBuffId 	--BUFF ID
	self.nUseLevel 				= 		tData.uselevel or self.nUseLevel	--使用等级
	self.sUseNeedItem 			= 		tData.useneeditem or self.sUseNeedItem --使用需要的其他物品
	self.nPrice 				= 		tonumber(tData.price)  or self.nPrice 	--价格
	self.sDropId 				=		tData.dropid or self.sDropId 	--掉落ID
	self.nCanbuy 				= 		tData.canbuy or self.nCanbuy   --是否可以购买
	self.sTips 					= 		tData.tips or self.sTips 		--获得途径
	self.nIsShow				= 		tData.isshow or self.nIsShow	--是否在背包中显示
	self.sSell 					= 		tData.sell or self.sSell		--出售价格 -1不能出售
	self.nCanExchange 			= 		tData.canexchange or self.nCanExchange -- 是否可选择获得
	self.nBoxType				= 		tData.boxtype or self.nBoxType  	-- 操作弹框 1-没有按钮 2使用 3使用后跳转
	self.nCanUse 				= 		tData.canuse or self.nCanUse 	--能否使用 0-不可以使用 1-可以使用 2-组合使用
	self.nBatchUseNum 			= 		tData.batchusenum or self.nBatchUseNum  --一次批量使用的
	--self.nStackNum 			= 		tData.stacknum or self.nStackNum  --背包最大数量
	self.nDayUse 				= 		tData.dayuse or self.nDayUse
	self.nExchange 				= 		tData.exchange or self.nExchange 	--商店兑换id
	self.nItemType 				= 		tData.type or self.nItemType 	--物品类型
	self:initBuffs()
end	
--刷新根据服务端数据返回刷新装备数据
function ItemStuffData:refreshItemDataByService( tData, bRecordRed )
	-- body
	if tData and tData.c then
		local bRecord = bRecordRed or false --
		if bRecord == true then --and self.nIsShow == 1 then --记录红点 在背包中显示的物品才需要记录红点  有一些不在背包里显示 但在活动中显示的物品也需要记录红点
			if self.nCt < tData.c and tData.c > 0 then
				self.nRedNum = 1	
			end
		else
			self.nRedNum = 0
		end
		self.nCt = tData.c or self.nCt		
		if self.nCt == 0 then
			self:release()
		end
	end	
end
--构建物品VipBuff表
function ItemStuffData:initBuffs(  )
	-- body
	self.tBuffs = {}
	if self.sBuffId then		
		local tbuffs = luaSplit(self.sBuffId, ";")				
		for k, v in pairs(tbuffs) do	
			local buff = luaSplitMuilt(v, ":", "-")		
			local buffitem = {}
			buffitem.nL = tonumber(buff[1][1] or 0)
			buffitem.nR = tonumber(buff[1][2] or 0)
			buffitem.BuffId = tonumber(buff[2] or 0)
			table.insert(self.tBuffs, buffitem)
		end		
	end
end
--获取BuffIds 
function ItemStuffData:getVipBuffId( nvip )	
	-- body
	if not nvip then
		return
	end
	for k, v in pairs(self.tBuffs) do
		if nvip >= v.nL and nvip <= v.nR then
			return v.BuffId
		end
	end
end
--
function ItemStuffData:clearItemRed(  )
	-- body
	self.nRedNum = 0
end

return ItemStuffData
