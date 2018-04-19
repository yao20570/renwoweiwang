-- Author: liangzhaowei
-- Date: 2017-04-24 16:45:45
-- 英雄属性item

local MCommonView = require("app.common.MCommonView")
local ItemHeroInfoLb = class("ItemHeroInfoLb", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--_index 下标 _type 类型
function ItemHeroInfoLb:ctor(_index,_type,_nDistan)
	-- body
	self:myInit()

	if not _type then
		self.nType = 1
	else
		self.nType = _type
	end

	if _nDistan then
		self.nDistan = _nDistan
	end

	self.nIndex = _index or self.nIndex

	if self.nType == 1 then
		parseView("item_hero_info_lb", handler(self, self.onParseViewCallback))
	elseif self.nType == 2 then
		parseView("item_hero_info_lb_m", handler(self, self.onParseViewCallback))
	end

	--注册析构方法
	self:setDestroyHandler("ItemHeroInfoLb",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemHeroInfoLb:myInit()
	-- body
	self.nIndex = 1
	self.nType = 1

	self.pData = {} --章节数据
end

--解析布局回调事件
function ItemHeroInfoLb:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	--ly         	

	--lb
	self.pLbN = self:findViewByName("lb_n")
	setTextCCColor(self.pLbN,_cc.pwhite)
	self.pLbV = self:findViewByName("lb_v")
	setTextCCColor(self.pLbV,_cc.blue)
	if self.nType ==1 then
		self.pLbE = self:findViewByName("lb_e")
		setTextCCColor(self.pLbE,_cc.green)
	end



	self:setupViews()
	self:updateViews()
end

--初始化控件
function ItemHeroInfoLb:setupViews( )

end

-- 修改控件内容或者是刷新控件数据
function ItemHeroInfoLb:updateViews(  )
	-- body
end

--析构方法
function ItemHeroInfoLb:onDestroy(  )
	-- body
end

--设置数据 _data _nHold 1为 基础值(还显示额外属性) 2,为全部值  3基础值,不显示额外熟悉
function ItemHeroInfoLb:setCurData(_tData,_nHold)
	if not _tData then
		return
	end

	self.pData = _tData or {}

	self.pLbN:setString(self.pData.sName or "")

	local nHold = 1

	if not _nHold then
		nHold = 1
	else
		nHold = _nHold
	end

	if nHold == 1 or nHold == 3 then
		local sStr=tostring(math.floor(self.pData.nVal))
		--命中，闪避，暴击，坚韧以百分比形式显示, 其他属性用数字显示
		if self.pData.nId == e_id_hero_att.mingzhong or self.pData.nId == e_id_hero_att.shanbi or
			self.pData.nId == e_id_hero_att.baoji or self.pData.nId == e_id_hero_att.jianyi then
			if self.pData.nVal > 0 then
				-- local nTemp = math.floor(self.pData.nVal*1000)/10
				local nTemp = roundOff(self.pData.nVal*100, 0.1) --四舍五入, 取一位小数
				sStr= tostring(nTemp) .. "%"
			end
		end
		self.pLbV:setString(sStr or "")
	elseif nHold == 2 then
		self.pLbV:setString(tostring(self.pData:getTotalVal()) or "")
	end


	if self.nType ==1 and  nHold ~= 3  then
		--额外属性
		if self.pData.nEx and self.pData.nEx > 0 then
			self.pLbE:setString("+"..self.pData.nEx)
			if self.nDistan then
				self.pLbE:setPositionX(self.pLbV:getPositionX() + self.pLbV:getWidth() + self.nDistan)
			end
		else
			self.pLbE:setString("")
		end
	end

end

--设置数据
--属性名，属性，额外属性
function ItemHeroInfoLb:setCurDataEx( sAttrName, nAttr, nAttrEx )
	self.pLbN:setString(tostring(sAttrName))
	if nAttr then
		self.pLbV:setString(tostring(nAttr))
	end
	if nAttrEx and nAttrEx > 0 then
		self.pLbE:setString("+"..tostring(nAttrEx))
		if self.nDistan then
			self.pLbE:setPositionX(self.pLbV:getPositionX() + self.pLbV:getWidth() + self.nDistan)
		end
	else
		if self.pLbE then
			self.pLbE:setString("")
		end
	end
end


return ItemHeroInfoLb