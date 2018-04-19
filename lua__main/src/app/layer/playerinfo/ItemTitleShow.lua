-----------------------------------------------------
-- author: maheng
-- updatetime:  2018-02-06 16:56:40 星期二
-- Description: 称号显示
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")

local ItemTitleShow = class("ItemTitleShow", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemTitleShow:ctor(_data , nId  )
	-- body
	self:myInit()
	if _data then
		self.tCurData = _data
	end
	if nId then
		self.sID = nId	
	end	
	parseView("item_title_show", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function ItemTitleShow:myInit(  )
	-- body
	self.sID = ""
	self.tCurData = nil
	self._nHandler = nil
end

--解析布局回调事件
function ItemTitleShow:onParseViewCallback( pView )
	-- body
	self.pView = pView
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("ItemTitleShow",handler(self, self.onDestroy))
end

--初始化控件
function ItemTitleShow:setupViews( )
	-- body
	self.pLayRoot = self.pView:findViewByName("item_title_show")
	self.pLayTitleBg = self.pView:findViewByName("lay_title")
	self.pImgTitle = self.pView:findViewByName("img_title") 
	self.pLbTime = self.pView:findViewByName("lb_time")
	self.pLbDesc = self.pView:findViewByName("lb_desc")	
	self.pTxtDesc = MUI.MLabel.new({
		    text = "",
		    size = 20,
		    anchorpoint = cc.p(0, 0.5),
		    align = cc.ui.TEXT_ALIGN_LEFT,
    		valign = cc.ui.TEXT_VALIGN_CENTER,
		    color = cc.c3b(255, 255, 255),
		    dimensions = cc.size(400, 0),
		})
	self.pTxtDesc:setPosition(20, 35)
	self.pLayRoot:addView(self.pTxtDesc, 10)

	self.pImgFlag = self.pView:findViewByName("img_flag")

	self.pLayRightBtn = self.pView:findViewByName("lay_right_btn")
    self.pBtn = getCommonButtonOfContainer(self.pLayRightBtn, TypeCommonBtn.M_BLUE, getConvertedStr(3, 10103))
    self.pBtn:onCommonBtnClicked(handler(self, self.onBtnClicked))	
end

-- 修改控件内容或者是刷新控件数据
function ItemTitleShow:updateViews( )
	-- body		
	if not self.tCurData then
		return
	end		
	unregUpdateControl(self)--停止计时刷新
	local pTitleData = self.tCurData	
	self.pImgTitle:setCurrentImage(pTitleData.sIcon)
	self.pTxtDesc:setString(getTextColorByConfigure(pTitleData.sDes), false)	
	--self.pLbDesc:setString(getTextColorByConfigure(pTitleData.sDes), false)
	if pTitleData.sTid == self.sID then--使用中 
		self.pImgFlag:setCurrentImage("#v2_fonts_shyonzho.png")
		self.pLayRightBtn:setVisible(false)
		self.pImgFlag:setVisible(true)
		self.pLbTime:setVisible(true)
	else
		if pTitleData:getCdTime() > 0 or pTitleData.nCd == -1 then--可以使用
			self.pLayRightBtn:setVisible(true)
			self.pImgFlag:setVisible(false)
			self.pLbTime:setVisible(true)
		else 															--未获得
			self.pLbTime:setVisible(false)
			self.pLayRightBtn:setVisible(false)
			self.pImgFlag:setVisible(true)
			self.pImgFlag:setCurrentImage("#v2_fonts_wskf.png")					
		end
	end	
	if pTitleData:isCanUse() then
		self.pLayTitleBg:setVisible(true)
		self.pLayRoot:setBackgroundImage("#v1_img_kelashen6.png",{scale9 = true,capInsets=cc.rect(50,50, 1, 1)})	
	else
		self.pLayTitleBg:setVisible(false)
		self.pLayRoot:setBackgroundImage("#v1_img_kelashen6hui.png",{scale9 = true,capInsets=cc.rect(50,50, 1, 1)})	
	end
	
	
	if pTitleData:getCdTime() > 0 then	--有效期	
		local sStr = {
			{color=_cc.pwhite, text= getConvertedStr(6, 10753)},
			{color=_cc.red, text= formatTimeToMs(pTitleData:getCdTime(), true)},
		}
		self.pLbTime:setString(sStr, false)	
		regUpdateControl(self, handler(self, self.onUpdateTime))
	elseif pTitleData.nCd == -1 then--永久
		local sStr = {
			{color=_cc.pwhite, text= getConvertedStr(6, 10753)},
			{color=_cc.white, text= getConvertedStr(6, 10650)},
		}
		self.pLbTime:setString(sStr, false)			
	end	
end

function ItemTitleShow:onUpdateTime(  )
	-- body
	if not self.tCurData then
		return
	end
	local pTitleData = self.tCurData	
	if pTitleData:getCdTime() > 0 then		
		local sStr = {
			{color=_cc.pwhite, text= getConvertedStr(6, 10753)},
			{color=_cc.red, text= formatTimeToMs(pTitleData:getCdTime())},
		}
		self.pLbTime:setString(sStr, false)			
	else
		self.pLbTime:setString("")
		unregUpdateControl(self)--停止计时刷新		
	end	
end

-- 析构方法
function ItemTitleShow:onDestroy(  )
	-- body
end

function ItemTitleShow:setCurData( _data , nId)
	-- body
	self.tCurData = _data
	self.sID = nId or ""
	self:updateViews()
end

function ItemTitleShow:setBtnClickHandler( _handler )
	-- body
	self._nHandler = _handler	
end

function ItemTitleShow:onBtnClicked( pView )
	-- body
	if self._nHandler then
		self._nHandler(self.tCurData)
	end
end
return ItemTitleShow