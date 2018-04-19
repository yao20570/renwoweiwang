-----------------------------------------------------
-- author: zhangnianfeng
-- updatetime:  2017-05-17 15:05:40 星期三
-- Description: 伤害排名
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")

local ItemNianHurtRank = class("ItemNianHurtRank", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemNianHurtRank:ctor( )
	-- body	
	self:myInit()	
	parseView("item_nian_rank", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function ItemNianHurtRank:myInit()
end

--解析布局回调事件
function ItemNianHurtRank:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("ItemNianHurtRank",handler(self, self.onItemNianHurtRankDestroy))
end

--初始化控件
function ItemNianHurtRank:setupViews( )
	self.pImgRank = self:findViewByName("img_rank")
	self.pImgRank:setScale(0.6)
	self.pTxtRank = self:findViewByName("txt_rank")
	self.pTxtCountry = self:findViewByName("txt_country")
	self.pTxtName = self:findViewByName("txt_name")
	self.pTxtHurt = self:findViewByName("txt_hurt")

	self:setIsPressedNeedScale(false)                      
	self:setViewTouched(true)
	self:onMViewClicked(handler(self, self.onClick))
end

-- 修改控件内容或者是刷新控件数据
function ItemNianHurtRank:updateViews( )
	if not self.tCurData then
		return
	end
	local nRank = self.tCurData.x
	if nRank then
		if nRank <= 3 then
			self.pImgRank:setVisible(true)
			local sImg = nil
			if nRank == 1 then
				sImg = "#v1_img_paixingbang1.png"
			elseif nRank == 2 then
				sImg = "#v1_img_paixingbang2.png"
			elseif nRank == 3 then
				sImg = "#v1_img_paixingbang3.png"
			end
			self.pImgRank:setCurrentImage(sImg)
			self.pTxtRank:setVisible(false)
		else
			self.pImgRank:setVisible(false)
			self.pTxtRank:setVisible(true)
			self.pTxtRank:setString(tostring(nRank))
		end
	end
	local nCountry = self.tCurData.c
	if nCountry then
		local sCountry = getCountryShortName(nCountry)
		self.pTxtCountry:setString(sCountry)
	end
	local sName = self.tCurData.n
	if sName then
		self.pTxtName:setString(sName)
	end
	local nHarm = self.tCurData.harm
	if nHarm then
		self.pTxtHurt:setString(getResourcesStr(nHarm))
	end
end

-- 析构方法
function ItemNianHurtRank:onItemNianHurtRankDestroy( )
end

function ItemNianHurtRank:setCurData( _data )
	-- dump(_data, "self.tListData[_index]==========", 100)
	-- "self.tListData[_index]==========" = {
 --    "box"  = "140000"
 --    "c"    = 1
 --    "harm" = 3513
 --    "i"    = 7000120
 --    "l"    = 90
 --    "n"    = "连进"
 --    "p"    = "130000"
 --    "x"    = 1
	-- }
	-- body	
	self.tCurData = _data
	self:updateViews()
end

function ItemNianHurtRank:setHandler( _nhandler )
	-- body
	self.nHandler = _nhandler
end

function ItemNianHurtRank:onClick(  )
	if self.nHandler then
		self.nHandler(self.tCurData)
	end
end

return ItemNianHurtRank