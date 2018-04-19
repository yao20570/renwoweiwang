-- Author: xiesite
-- Date: 2017-12-26 17:58:23
-- 武将队列item

local MCommonView = require("app.common.MCommonView")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")
local ItemHeroInfoLb = require("app.layer.hero.ItemHeroInfoLb")
local ItemHeroAttrTwo = class("ItemHeroAttrTwo", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--_tData 数据
function ItemHeroAttrTwo:ctor(_tData)
	-- body
	self:myInit()


	self.tData = _tData
	parseView("dlg_hero_arr_2", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("ItemHeroAttrTwo",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemHeroAttrTwo:myInit()
	-- body
	self.tData = {} --数据
end

--解析布局回调事件
function ItemHeroAttrTwo:onParseViewCallback( pView )

	self.pItemView = pView
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)


	self:updateViews()

end

--初始化控件
function ItemHeroAttrTwo:updateViews( )
	if not self.tLyTalent then
		self.tLyTalent = {}
		for i=1,11 do
			local pView = self:findViewByName("ly_att_"..i)
			self.tLyTalent[i] = ItemHeroInfoLb.new(i, nil, 5)
			pView:addView(self.tLyTalent[i],100)
		end
	end
		
	--设置属性内容
	for k,v in pairs(self.tLyTalent) do
		if self.tData.tAttList[k] then
			v:setCurData(self.tData.tAttList[k])
		end
	end
	--攻击
	if self.tLyTalent[1] then
		local nValue = self.tData:getAtkLuo()
		local nValueEx = self.tData:getAtkMax() - nValue
		self.tLyTalent[1]:setCurDataEx(getAttrUiStr(e_id_hero_att.gongji), nValue, nValueEx)
	end
	
	--防御
	if self.tLyTalent[2] then
		local nValue = self.tData:getDefLuo()
		local nValueEx = self.tData:getDefMax() - nValue
		self.tLyTalent[2]:setCurDataEx(getAttrUiStr(e_id_hero_att.fangyu), nValue, nValueEx)
	end
	
	--兵力
	if self.tLyTalent[3] then
		local nValue = self.tData:getTroopsLuo()
		local nValueEx = self.tData:getTroopsMax() - nValue
		self.tLyTalent[3]:setCurDataEx(getAttrUiStr(e_id_hero_att.bingli), nValue, nValueEx)
	end
end

--析构方法
function ItemHeroAttrTwo:onDestroy(  )
	-- body
end

--设置数据 _data
function ItemHeroAttrTwo:setCurData(_tData, _nTarHeroId)
	if not _tData then
		return
	end

	self.tData = _tData or {}

	self:updateViews()


end

return ItemHeroAttrTwo