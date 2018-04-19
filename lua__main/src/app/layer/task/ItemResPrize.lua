-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-07-11 16:05:40 星期二
-- Description: 任务奖励
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")

local ItemResPrize = class("ItemResPrize", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemResPrize:ctor( _bIsIndent )
	-- body
	self:myInit(_bIsIndent)
	
	parseView("item_res_prize", handler(self, self.onParseViewCallback))
	
end

--初始化成员变量
function ItemResPrize:myInit( _bIsIndent )
	-- body
	self.tCurData 			= 	nil 				--当前数据
	self.bIsIndent 			= _bIsIndent or false	
	self.nImgWidth = 40
	self.tColor = {_cc.pwhite, _cc.yellow}
end

--解析布局回调事件
function ItemResPrize:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("ItemResPrize",handler(self, self.onItemResPrizeDestroy))
end

--初始化控件
function ItemResPrize:setupViews( )
	-- body
	self.pLayRoot = self:findViewByName("lay_root")
	self.pImg = self:findViewByName("img_res")	
	self.pLbValue = self:findViewByName("lb_value")
	self.pLbValue:setPosition(40, self.pLayRoot:getHeight()/2)
end

-- 修改控件内容或者是刷新控件数据
function ItemResPrize:updateViews( )
	-- body
	if self.tCurData then
		--dump(self.tCurData, "self.tCurData", 100)
		self:setVisible(true)
		local simg = self.tCurData:getSmallIcon()
		if simg == "ui/daitu.png" then					
			self.pImg:setScale(0.3)
			self.pImg:setCurrentImage(self.tCurData.sIcon)	
			self.nImgWidth = self.pImg:getWidth()*0.3
		else
			self.pImg:setScale(1)
			self.pImg:setCurrentImage(simg)	
			self.nImgWidth = self.pImg:getWidth()
		end
		local resname = self.tCurData.sName
		if self.bIsIndent == true then
			resname = ""
		end
		local str = {
			{color=self.tColor[1], text=resname},
			{color=self.tColor[2], text="x"..formatCountToStr(self.tCurData.nCt)},
		}
		self.pLbValue:setString(str, false)	
		if self.bIsIndent == true then			
			self.pImg:setPositionX(self.nImgWidth/2)
			self.pLbValue:setPositionX(self.nImgWidth + 5)		
		else
			self.pImg:setPositionX(20)
			self.pLbValue:setPositionX(40)	
		end
	else
		self:setVisible(false)
	end
	self.pLayRoot:setLayoutSize(self.pLbValue:getPositionX() + self.pLbValue:getWidth(), self.pLayRoot:getHeight())
	self:setLayoutSize(self.pLayRoot:getWidth(), self.pLayRoot:getHeight())
end

-- 析构方法
function ItemResPrize:onItemResPrizeDestroy(  )
	-- body
end

function ItemResPrize:setCurData( _data )
	-- body
	self.tCurData = _data
	self:updateViews()
end
function ItemResPrize:setValueColor( idx, color )
	-- body
	if not idx or not color then
		return
	end	
	self.tColor[idx] = color
end

--设置排版
function ItemResPrize:setIndentMode( isindent )
	-- body
	self.bIsIndent = isindent or self.bIsIndent
end
return ItemResPrize