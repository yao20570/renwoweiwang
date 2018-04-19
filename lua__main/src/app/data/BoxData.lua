----------------------------------------------------- 
-- author: maheng
-- updatetime: 2017-11-9 15:40:08
-- Description: 头像配置数据
-----------------------------------------------------

local Goods = require("app.data.Goods")

local BoxData = class("BoxData", Goods)

function BoxData:ctor(  )
	BoxData.super.ctor(self,e_type_goods.type_box)
	-- body
	self:myInit()

end

function BoxData:myInit(  )
	self.nGtype 	= e_type_goods.type_box -- 数据类型，头像框
	self.sIntroduce = ""
	self.sCondition = ""
	self.nTime 		= 0
	self.sTips 		= ""
	self.nCd 		= 0
	self.nShow 		= 1  --0不展示 1展示 2时间到隐藏
	self.nSequence 	= 1  --分类排序	
	self.nLastLoadTime = nil --最后一次刷新cd的时间
end

-- 用配置表DB中的数据来重置基础数据
function BoxData:initDatasByDB( _tData )
	if (not _tData) then
		return 
	end

	self.sTid       = _tData.id or self.sTid
	self.sName 		= _tData.name or self.sName
	self.sDes 		= _tData.desc or self.sDes
	if _tData.icon then
		self.sIcon = "#".._tData.icon..".png"
	else
		self.sIcon = ""
	end
	self.sTips 		= _tData.tips or self.sTips
	self.sIntroduce = _tData.introduce or self.sIntroduce
	self.sCondition = _tData.condition or self.sCondition
	self.nTime 		= _tData.time or self.nTime
	self.nShow 		= _tData.show or self.nShow  --0不展示 1展示 2时间到隐藏
	self.nSequence 	= _tData.sequence or self.nSequence  --分类排序
end
--刷新头像数据
function BoxData:refreshByService( tData )
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

function BoxData:getBoxCdTime(  )
	-- body
	if self.nCd and self.nCd > 0 then
		local fCurTime = getSystemTime()
		local fLeft = self.nCd - (fCurTime - self.nLastLoadTime)
		if(fLeft < 0) then
			fLeft = 0
		end
		return fLeft
	else
		return 0
	end	
end

function BoxData:isNeedCheckBoxCd( ... )
	-- body
	local fCurTime = getSystemTime()
	local fLeft = self.nCd - (fCurTime - self.nLastLoadTime)
	if fLeft == -3 and self.nTime > 0 then
		return true
	else
		return false
	end
end
return BoxData
