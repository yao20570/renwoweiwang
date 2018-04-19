--
-- Author: liangzhaowei
-- Date: 2017-04-21 14:19:45
-- Description: 英雄属性数据
-----------------------------------------------------
local Goods = require("app.data.Goods")

--e_id_hero_att.bingli
e_id_hero_att = 
{
	 --英雄自身部分
	 gongji    = 100, --攻击
	 fangyu    = 101, --防御
	 bingli    = 102, --兵力
	 mingzhong = 103, --命中
	 shanbi	   = 104, --闪避
	 baoji     = 105, --暴击
	 jianyi    = 106, --坚韧
	 qianggong = 107, --强攻
	 qiangfang = 108, --强防
	 gongcheng = 109, --攻城
	 shoucheng = 110, --守城

	 --其它加成部分
	 gongjiper = 500, --攻击百分比
	 fangyuper = 501, --防御百分比
	 bingliper = 502, --兵力百分比
}

local HeroAtt = class("HeroAtt", Goods)

function HeroAtt:ctor(  )
	HeroAtt.super.ctor(self,e_type_goods.type_hero_att)
	self:myInit()
end

function HeroAtt:myInit()
   self.nDbBal = 0 --配表属性
   self.nVal = 0 --基础属性值
   self.nEx = 0 --额外属性值(其它系统所有添加)
   self.nId = nil -- 配表(属性)id

   --总的属性值
  self.nTotalVal = 0
end

-- 用配置表DB中的数据来重置基础数据
function HeroAtt:initDatasByDB( _tData )
	if (not _tData) then
		return 
	end

	self.nId = tonumber(_tData.id) or self.nId -- 配表(属性)id
	self.sName = _tData.name or self.sName -- 属性名字
	self.sIcon = "#".._tData.icon..".png" or self.sIcon
end

function HeroAtt:refreshDbBalFromDB( _nValue )
	-- body
	self.nDbBal = _nValue or 0
	self.nVal = self.nDbBal 
end

-- 根据服务器刷新属性数据
function HeroAtt:refreshDatasByService( _tData )
	if (not _tData) then
		return 
	end

	self.nVal = _tData.v  or  self.nVal --基础属性值

end

--设置
function HeroAtt:setVal(_nVal)
	-- body
	self.nVal = _nVal
end

--根据服务器刷新额外属性数据
function HeroAtt:refreshExData(_tData)
	if (not _tData) then
		return 
	end

	self.nEx = _tData.v or  self.nEx ----额外属性值(其它系统所有添加)

end

--获取属性总和
function HeroAtt:getTotalVal()
	local nTotal = 0
	nTotal = math.floor(self.nVal + self.nEx)
	return nTotal
end

--获取基础属性值
function HeroAtt:getBaseVal( )
	-- body
	return self.nVal
end

return HeroAtt

