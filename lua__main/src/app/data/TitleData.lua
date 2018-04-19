----------------------------------------------------- 
-- author: maheng
-- updatetime: 2018-02-06 11:51:08
-- Description: 头像称号
-----------------------------------------------------

local Goods = require("app.data.Goods")

local TitleData = class("TitleData", Goods)

function TitleData:ctor(  )
	TitleData.super.ctor(self,e_type_goods.type_icon)
	-- body
	self:myInit()

end

function TitleData:myInit(  )
	self.nGtype 	= e_type_goods.type_title -- 数据类型，默认是物品类型(enum)
	--self.sIntroduce = ""
	self.nTime 		= 0
	self.nCd 		= 0
	self.nShow 		= 1  --0不展示 1展示 2时间到隐藏
	self.nPriority 	= 0  --分类排序
	--self.sImg 		= ""
	self.nLastLoadTime = nil --最后一次刷新cd的时间
end

-- 用配置表DB中的数据来重置基础数据
function TitleData:initDatasByDB( _tData )
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
	self.nShow 		= _tData.show or self.nShow  --0不展示 1展示 2时间到隐藏
	self.nPriority 	= _tData.priority or self.nPriority  --分类排序
end
--刷新头像数据
function TitleData:refreshByService( tData )
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

function TitleData:getCdTime(  )
	-- body
	if self.nCd and self.nCd > 0 then
		local fCurTime = getSystemTime()
		local fLeft = self.nCd - (fCurTime - self.nLastLoadTime or 0)
		if(fLeft < 0) then
			fLeft = 0
		end
		return fLeft
	else
		return 0
	end	
end

function TitleData:isNeedCheckCd( ... )
	-- body
	local fCurTime = getSystemTime()
	local fLeft = self.nCd - (fCurTime - self.nLastLoadTime or 0)
	if fLeft == -3 and self.nTime > 0 then
		return true
	else
		return false
	end
end

function TitleData:isCanUse(  )
	-- body
	if self:getCdTime() > 0 or self.nCd == -1  then
		return true
	end
	return false
end

function TitleData:getSortNum( )
	-- body
	if self:isCanUse() then
		return 1
	else
		return 0
	end
end
return TitleData
