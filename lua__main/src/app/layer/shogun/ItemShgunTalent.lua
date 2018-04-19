-- Author: liangzhaowei
-- Date: 2017-05-10 15:08:28
-- 英雄资质展示界面

local MCommonView = require("app.common.MCommonView")
local ItemShgunTalent = class("ItemShgunTalent", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--_tData 英雄数据
function ItemShgunTalent:ctor(_tData)
	-- body
	self:myInit()

	self.pData = _tData

	parseView("item_shogun_hero_talent", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("ItemShgunTalent",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemShgunTalent:myInit()
	self.pData = nil
end

--解析布局回调事件
function ItemShgunTalent:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
end

--初始化控件
function ItemShgunTalent:setupViews( )
	--lb
	--总信息
	self.pLbInfo = self:findViewByName("lb_info")
	self.pLbInfo:setZOrder(10)


end

-- 修改控件内容或者是刷新控件数据
function ItemShgunTalent:updateViews(  )

	if not self.pData then
       return
	end

	local tStr = {
	}

	local tColor = {
		_cc.pwhite,
		_cc.red,
		_cc.blue,
		_cc.yellow,
	}

	for i=1,4 do

		table.insert(tStr,self:getText(getConvertedStr(5, 10062+i-1),tColor[i]))
		if i == 1 then
			table.insert(tStr,self:getText(" ",tColor[i]))
			table.insert(tStr,self:getText(self.pData:getBaseTotalTalent(),tColor[i]))
			table.insert(tStr,self:getText("+"..self.pData:getExTotalTalent().."\n".."\n",_cc.green))--额外资质
		elseif i == 2 then
			table.insert(tStr,self:getText(" ",tColor[i]))
			table.insert(tStr,self:getText(self.pData.nTa.."\n",tColor[i]))
		elseif i == 3 then
			table.insert(tStr,self:getText(" ",tColor[i]))
			table.insert(tStr,self:getText(self.pData.nTd.."\n",tColor[i]))
		elseif i == 4 then
			table.insert(tStr,self:getText(" ",tColor[i]))
			table.insert(tStr,self:getText(self.pData.nTr,tColor[i]))
		end
	end

	self.pLbInfo:setString(tStr)

end

--获取富文本格式
function ItemShgunTalent:getText(_text,_color)
	-- body
	local str = {}
	if _text and _color  then
		str.text = _text
		str.color = _color
	end
	return str
end

--析构方法
function ItemShgunTalent:onDestroy(  )
	-- body
end


return ItemShgunTalent