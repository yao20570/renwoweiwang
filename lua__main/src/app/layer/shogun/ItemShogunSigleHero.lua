-- Author: liangzhaowei
-- Date: 2017-07-19 15:56:24
-- 英雄属性item

local MCommonView = require("app.common.MCommonView")
local StarAttrLayer = require("app.layer.hero.StarAttrLayer")
local ItemShogunSigleHero = class("ItemShogunSigleHero", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--创建函数
function ItemShogunSigleHero:ctor(nType)
	-- body
	self:myInit(nType)

	parseView("item_shogun_sigle_hero", handler(self, self.onParseViewCallback))


	--注册析构方法
	self:setDestroyHandler("ItemShogunSigleHero",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemShogunSigleHero:myInit(nType)
	self.pData = {} --数据
	self.nType = nType   --类型
end

--解析布局回调事件
function ItemShogunSigleHero:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)



	self:setupViews()
end

--初始化控件
function ItemShogunSigleHero:setupViews( )
	self.pLyQualityKuang  = self:findViewByName("ly_qulity_kuang")--英雄品质框层
	if self.nType == 1 then
		self.pLyQualityKuang:setVisible(false)
	else
		self.pLyQualityKuang:setVisible(true)
	end
end

-- 修改控件内容或者是刷新控件数据
function ItemShogunSigleHero:updateViews(  )

	if not self.pData then
		return
	end
	-- dump(self.pData, "self.pData")
	gRefreshViewsAsync(self, 4, function ( _bEnd, _index )
		if(_index == 1) then


			if not self.pLyMain then
				--ly
				self.pLyMain  = self:findViewByName("item_shogun_sigle_hero")
				self.pLyCover = self:findViewByName("ly_cover")--覆盖层
				self.pLyDown  = self:findViewByName("ly_down")
				self.pLyHero  = self:findViewByName("ly_hero")--英雄图片层
				self.pImgIg   = self:findViewByName("img_ig")--英雄图片层

				--img
				self.pImgBingType  = self:findViewByName("img_bing_type")--兵种

				
				--lb
				self.pLbHeroInfo = self:findViewByName("lb_hero_info")
				self.pLbInfo = self:findViewByName("lb_info")

				self:setViewTouched(true)
				self:setIsPressedNeedScale(false)
			    self:onMViewClicked(handler(self,self.onViewClick))

			    self.pLyHeroBg = creatHeroView(self.pData.sImg,2)
			    -- print(self.pData.sImg)
    			self.pLyHeroBg:setPosition(0, 0)
    			-- self.pLyHeroBg:adjustToScale(self.pLyHero)
    			self.pLyHero:addView(self.pLyHeroBg,0)
			end

			if not self.pAttrStart then
				self.pAttrStart 	=		StarAttrLayer.new(0, 0.6)								
				self.pLyDown:addView(self.pAttrStart, 1)					
			end
			self.pLyQualityKuang:setBackgroundImage(getHeroBgByQuality(self.pData.nQuality))

			--刷新武将半身像
			self.pLyHeroBg:updateHeroView(self.pData.sImg)
			self.pLyHeroBg:adjustToScale(self.pLyHero)
			
			if self.pData.nIg == 1 then
				self.pImgIg:setVisible(true)
			else
				self.pImgIg:setVisible(false)
			end

			--是否显示覆盖层
			self.pLyCover:setVisible(self.pData.bShowTl)

			--显示星级
			if self.pData.tSoulStar then
				self.pAttrStart:updateSoulStar(self.pData.tSoulStar)
				self.pAttrStart:setPosition(self:getWidth()/2 - self.pAttrStart:getWidth()/2, 27)				
			end

			--显示兵种
			local strBingTypeImg = self.pData:getHeroKindImg(1)
			if strBingTypeImg then
				self.pImgBingType:setCurrentImage(strBingTypeImg)
			end

			local strInfo = getConvertedStr(5, 10236)
			if self.pData.nHave and self.pData.nHave == 1 then
				if self.nType == 1 then
					strInfo = self.pData.sName
				else
					strInfo = self.pData.sName..getLvString(self.pData.nLv,true)
				end
				self:setToGray(false)
				self.pImgBingType:setToGray(false)
				setTextCCColor(self.pLbHeroInfo,getColorByQuality(self.pData.nQuality))
				self.pLbHeroInfo:setPositionY(15)
				self.pAttrStart:setVisible(true)
			else
				setTextCCColor(self.pLbHeroInfo,_cc.red)
				self.pLbHeroInfo:setPositionY(27)
				self:setToGray(true)
				self.pImgBingType:setToGray(true)
				self.pAttrStart:setVisible(false)
			end

			if strInfo then
				self.pLbHeroInfo:setString(strInfo)
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
					-- table.insert(tStr,self:getText("\n",tColor[i]))
				elseif i == 3 then
					table.insert(tStr,self:getText(" ",tColor[i]))
					table.insert(tStr,self:getText(self.pData.nTd.."\n",tColor[i]))
					-- table.insert(tStr,self:getText("\n",tColor[i]))
				elseif i == 4 then
					table.insert(tStr,self:getText(" ",tColor[i]))
					table.insert(tStr,self:getText(self.pData.nTr,tColor[i]))
				end
			end
			self.pLbInfo:setString(tStr)

		
			
		elseif(_index == 2) then



			
		elseif(_index == 3) then

			

		end
	end)




end


--点击回调
function ItemShogunSigleHero:onViewClick(pView)
	-- body
	if self.pData and self.pData.nHave and self.pData.nHave == 1 then
		local tObject = {}
		tObject.nType = e_dlg_index.heroinfo --dlg类型
		tObject.tData = self.pData
		sendMsg(ghd_show_dlg_by_type,tObject)
	else
		TOAST(getConvertedStr(5, 10237))
	end
end


--获取富文本格式
function ItemShogunSigleHero:getText(_text,_color)
	-- body
	local str = {}
	if _text and _color  then
		str.text = _text
		str.color = _color
	end
	return str
end


--析构方法
function ItemShogunSigleHero:onDestroy(  )
	-- body
end

--设置数据 _data
function ItemShogunSigleHero:setCurData(_tData)
	
	if not _tData then
		return
	end

	self.pData = _tData or {}

	self:updateViews()

end


return ItemShogunSigleHero