-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-04-25 19:42:51 星期二
-- Description: 装备基本信息
-----------------------------------------------------

local Goods = require("app.data.Goods")

local ItemEquipData = class("ItemEquipData", Goods)


function ItemEquipData:ctor(  )
	ItemEquipData.super.ctor(self,e_type_goods.type_equip)
	-- body
	self:itemStuffDataInit()
end


function ItemEquipData:itemStuffDataInit( )

	self.sIcon      = "ui/daitu.png"   -- 对应的icon资源(string)

	--拓展字段
	self.sAttributes			=		nil --装备属性
	self.nTrainLv 				= 		nil	--洗练等级
	self.nCanDecom		 		= 		nil --是否可以分解1-可以分解 0-不能分解	
	self.nDecomDrop				= 		nil --分解产出 掉落组ID
	self.nOpenLv 				= 		nil --开启等级
	self.nTimes					= 		nil --打造时间(s)
	self.nCost 					=		nil --打造耗费材料 掉落组ID
	self.nStars 				= 		nil --洗练星数
	self.nKind                  =       nil --装备种类
	self.bIsShow                =       nil --是否显示打造铺中
	self.nMakeLv                =       nil --打造所需等级
	self.sMakeCosts             =       nil --打造需求
	self.nMakeTimes             =       nil --打造时间
	self.sAttrs                 =       nil --属性
	self.nTrainNomlatb          =	    nil --洗练普通属性数
	self.nType                  =   	nil --装备种类
	self.nTrainLvTop            =       nil --单个属性上限，znftodo找老汤确认
end


-- 用配置表DB中的数据来重置基础数据
function ItemEquipData:initDataByDB( tData )
	-- body
	--基本信息
	self.sTid 					= 		tData.id or self.sTid		--物品id
	self.sName 					= 		tData.name or self.sName 		--物品名字
	self.sDes 					= 		tData.desc or self.sDes		--描述	
	if tData.icon then
		self.sIcon 				= 		"#"..tData.icon..".png" 		--显示图标
	else
		self.sIcon 				= 		"ui/daitu.png" 		--显示图标
	end
	self.nQuality 				= 		tData.quality or self.nQuality 	--品质
	--拓展字段
	self.sAttributes			=		tData.attrs or self.sAttributes --装备属性
	self.nTrainLv 				= 		tData.trainLv or self.nTrainLv		--洗练等级
	self.nCanDecom		 		= 		tData.candecom or self.nCanDecom 	--是否可以分解1-可以分解 0-不能分解	
	self.nDecomDrop				= 		tData.decomdrop or self.nDecomDrop --分解产出 掉落组ID
	self.nOpenLv 				= 		tData.openlv or self.nOpenLv --开启等级
	self.nTimes					= 		tData.times or self.nTimes --打造时间(s)
	self.nCost 					=		tData.cost or self.nCost --打造耗费材料 掉落组ID
	self.nStars 				= 		tData.stars or self.nStars --洗练星数
	self.nKind                  =       tData.kind or self.nKind --装备种类
	self.bIsShow                =       tData.isshow == 1 --是否显示打造铺中
	self.sTips 					= 		tData.tips or self.sTips 		--获得途径
	self.nMakeLv                =       tData.makelv or self.nMakeLv --打造所需等级
	self.sMakeCosts             =       tData.makecosts or self.sMakeCosts --打造需求
	self.nMakeTimes             =       tData.maketimes or self.nMakeTimes --打造时间
	self.sAttrs                 =       tData.attrs or self.sAttrs --属性
	if tData.attrs then
		local tAttrs = luaSplit(self.sAttrs, ":")
		if #tAttrs >= 2 then
			self.nAttrId = tonumber(tAttrs[1])
			self.nAttrValue = tonumber(tAttrs[2])
		end
	end

	self.nTrainNomlatb          =	    tData.trainnomlatb or self.nTrainNomlatb --洗练普通属性数
	self.nType                  =   	tData.type --物品类型
	self.nTrainLvTop            =       tData.trainlvtop --单个属性上限，znftodo找老汤确认
end	


function ItemEquipData:refreshEquipDataByService(tData)
	if not tData then
		return
	end
end

function ItemEquipData:isEquipCanDecom(  )
	-- body
	if not self.nCanDecom or  self.nCanDecom ~= 1 then
		return false	
	end
	return true
end

function ItemEquipData:getAttrId(  )
	return self.nAttrId
end

function ItemEquipData:getAttrValue(  )
	return self.nAttrValue
end

return ItemEquipData
