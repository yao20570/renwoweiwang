----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-05-12 11:20:08
-- Description: 资源相关数据
-----------------------------------------------------

local Goods = require("app.data.Goods")


e_type_resdata = { -- 资源的类型
	energy 		= 1, -- 体力
	food 		= 2, -- 粮草
	coin     	= 3, -- 银币
	wood 		= 4, -- 木材
	iron 		= 5, -- 镔铁
	infantry 	= 6, -- 步兵
	sowar 		= 7, -- 骑兵
	archer 		= 8, -- 弓兵
	person      = 9, -- 人口
	money 		= 10, -- 元宝
	prestige 	= 11, -- 威望
	exp 		= 12, -- 主公经验
	vipdot		= 13, -- VIP点数  

	luckypoint	= 17, --福气值
	medal		= 18, --奖章
	killheroexp	= 19, --积分
	royalscore  = 20, --皇家战积分
	countrycoin = 21, --国家商店货币
}

local ResData = class("ResData", Goods)

function ResData:ctor(  )
	ResData.super.ctor(self,e_type_goods.type_resdata)
	-- body
	self:myInit()

end

function ResData:myInit(  )
	self.nId 		= 0
	self.sName 		= nil   -- 物品名称（string）
	self.nType 		= 0     -- 类型（int）
	self.nQuality 	= 0     -- 品质（int）
	self.sIcon 		= "ui/daitu.png"   -- 对应的icon资源(string)
	self.sDes 		= nil   -- 说明(string)
	self.sTips 		= nil   -- TIPS显示(string)
end

-- 用配置表DB中的数据来重置基础数据
function ResData:initDatasByDB( _tData )
	if (not _tData) then
		return 
	end
	self.sTid       = _tData.id or self.sTid
	self.nId 		= _tData.id or self.nId
	self.sName 		= _tData.name or self.sName
	self.nType 		= _tData.type or self.nType
	self.nQuality 	= _tData.quality or self.nQuality
	self.sIcon 		= _tData.icon..".png" or self.sIcon
	if _tData.icon then
		self.sIcon = "#".._tData.icon..".png"
	end
	self.sDes 		= _tData.des or self.sDes
	self.sTips 		= _tData.tips or self.sTips
end

function ResData:getSmallIcon(  )
    if self.nId == e_type_resdata.food then
        return "#v1_img_liangshi.png"
    elseif self.nId == e_type_resdata.wood then
        return "#v1_img_mucai.png"
    elseif self.nId == e_type_resdata.iron  then
        return "#v1_img_tiekuai.png"
    elseif self.nId == e_type_resdata.coin then
        return "#v1_img_tongqian.png"
    elseif self.nId == e_type_resdata.money then
    	return "#v1_img_qianbi.png"
    elseif self.nId == e_type_resdata.medal then
    	return "#v1_img_jiangzhang.png"
    elseif self.nId == e_type_resdata.killheroexp then
    	return "#i19.png"
    elseif self.nId == e_type_resdata.royalscore then
    	return "#i20.png"
    elseif self.nId == e_type_resdata.countrycoin then
    	return "#i21.png"
    end
    return "ui/daitu.png"
end

return ResData
