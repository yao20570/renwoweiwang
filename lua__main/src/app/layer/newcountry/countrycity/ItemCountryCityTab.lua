----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-17 19:59:21
-- Description: 城池详细界面 侦查子界面
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemCountryCity = require("app.layer.newcountry.countrycity.ItemCountryCity")
local ItemCountryCityTab = class("ItemCountryCityTab", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemCountryCityTab:ctor( pFoldView )
	self.pFoldView = pFoldView
	--解析文件
	parseView("item_country_city_tab", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemCountryCityTab:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemCountryCityTab", handler(self, self.onItemCountryCityTabDestroy))
end

-- 析构方法
function ItemCountryCityTab:onItemCountryCityTabDestroy(  )
    self:onPause()
end

function ItemCountryCityTab:regMsgs(  )
end

function ItemCountryCityTab:unregMsgs(  )
end

function ItemCountryCityTab:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function ItemCountryCityTab:onPause(  )
	self:unregMsgs()
end

function ItemCountryCityTab:setupViews(  )
	self.pImgArrow = self:findViewByName("img_arrow")
	self.pImgCityName = self:findViewByName("img_city_name")
	self.pTxtCityNum = self:findViewByName("txt_city_num")
	self.bIsSelected = false
	self:setViewTouched(true)
	self:setIsPressedNeedScale(false)
	self:setIsPressedNeedColor(false)
	self:onMViewClicked(handler(self, self.onItemClicked))
end

function ItemCountryCityTab:updateViews(  )	
	self:updateOpenState()
	if not self.tData then
		return
	end
	local tStr = {
		{color=_cc.white,text= getConvertedStr(3, 10847)},
	    {color=_cc.blue,text=self.tData.nCount},
	}
	self.pTxtCityNum:setString(tStr)
	if self.tData.nBlockId == 9999 then
		self.pImgCityName:setCurrentImage("#v2_fonts_quanbuquyu.png")
	else
		local tBlockData = getWorldMapDataById(self.tData.nBlockId)
		if tBlockData then
			self.pImgCityName:setCurrentImage("#"..tBlockData.fontsicon..".png")
		end
	end
end

function ItemCountryCityTab:setData( nIndex, tData )	
	self.nIndex = nIndex
	self.tData = tData
	self:updateViews()
end

function ItemCountryCityTab:updateOpenState(  )
	if self.bIsSelected then
		self.pImgArrow:setRotation(-90)
		self.pImgArrow:setFlippedX(false)
	else
		self.pImgArrow:setRotation(0)
		self.pImgArrow:setFlippedX(true)
	end
end

function ItemCountryCityTab:onItemClicked( )
	if not self.tData then
		return
	end
	self.bIsSelected = not self.bIsSelected
	self:updateOpenState()
	if self.pFoldView then
		if self.bIsSelected then --打开
			local tInfo = {
				nWidth = 640, 
				nChildWidth = 600, 
				nChildHeight = 140, 
				nSubUiFunc = handler(self, self.onItemCallBack), 
				nChildCount = self.tData.nCount,
				nTopMargin = 5, 
				nBottomMargin = 5,
				nLeftMargin = 20,
			}
			self.pFoldView:openFoldListView(self.nIndex, tInfo)
		else
			self.pFoldView:closeFold(self.nIndex)
		end
	end
end

--关闭再找开子节点
function ItemCountryCityTab:reOpenSubLayer(  )
	if not self.tData then
		return
	end
	self.bIsSelected = true
	local tInfo = {
		nWidth = 640, 
		nChildWidth = 600, 
		nChildHeight = 140, 
		nSubUiFunc = handler(self, self.onItemCallBack), 
		nChildCount = self.tData.nCount,
		nTopMargin = 5, 
		nBottomMargin = 5,
		nLeftMargin = 20,
	}
	self.pFoldView:openFoldListView(self.nIndex, tInfo)
end

--更新打开的子节点
function ItemCountryCityTab:onUpdateSubLayer(  )
	if not self.bIsSelected then
		return
	end
	if not self.nIndex then
		return
	end
	local pFoldSub = self.pFoldView:getFoldSub(self.nIndex)
	if not pFoldSub then
		return
	end

	local tSubUiList = pFoldSub:getCurrUsingSubUis()
	for i=1,#tSubUiList do
		local pSubUi = tSubUiList[i]
		self:onItemCallBack(pSubUi, pSubUi.nIndex)
	end
end

function ItemCountryCityTab:onItemCallBack( _pView, _index )
	if not _pView then
		_pView = ItemCountryCity.new()
	end
	local tData = self.tData.tCountryCityVoList[_index]
	_pView:setData(tData)
	return _pView
end

return ItemCountryCityTab


