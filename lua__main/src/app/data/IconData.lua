----------------------------------------------------- 
-- author: maheng
-- updatetime: 2017-11-9 15:40:08
-- Description: 头像配置数据
-----------------------------------------------------

local Goods = require("app.data.Goods")

local IconData = class("IconData", Goods)

function IconData:ctor(  )
	IconData.super.ctor(self,e_type_goods.type_icon)
	-- body
	self:myInit()

end

function IconData:myInit(  )
	self.nGtype 	= e_type_goods.type_icon -- 数据类型，默认是物品类型(enum)
	self.sIntroduce = ""
	self.nTime 		= 0
	self.nCd 		= 0
	self.nShow 		= 1  --0不展示 1展示 2时间到隐藏
	self.nSequence 	= 1  --分类排序
	self.sImg 		= ""
	self.nLastLoadTime = nil --最后一次刷新cd的时间
end

-- 用配置表DB中的数据来重置基础数据
function IconData:initDatasByDB( _tData )
	if (not _tData) then
		return 
	end

	self.sTid       = _tData.id or self.sTid
	self.sName 		= _tData.name or self.sName
	self.sDes 		= _tData.desc or self.sDes
	if _tData.icon then
		self.sIcon = "#".._tData.icon..".png"
	end
	self.nTime 		= _tData.time or self.nTime
	self.nQuality 	= _tData.quality or self.nQuality
	self.sImg 		= _tData.img or self.sImg
	self.sIntroduce = _tData.introduce or self.sIntroduce
	--self.nTime 		= _tData.time or self.nTime
	self.nShow 		= _tData.show or self.nShow  --0不展示 1展示 2时间到隐藏
	self.nSequence 	= _tData.sequence or self.nSequence  --分类排序
end
--刷新头像数据
function IconData:refreshByService( tData )
	-- body
	if not tData then
		return
	end	
	self.nCd = tData.cd or self.nCd
	if tData.cd and tData.cd ~= -1 then
		self.nLastLoadTime = getSystemTime() --最后一次刷新cd的时间
	else
		self.nLastLoadTime = nil
	end
end
return IconData
