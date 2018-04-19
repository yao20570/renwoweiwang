-----------------------------------------------------
-- author: luwenjing
-- updatetime:  2018-03-20 09:44:44 星期五
-- Description: 国家商店
-----------------------------------------------------
local DlgBase = require("app.common.dialog.DlgBase")
local MBtnExText = require("app.common.button.MBtnExText")
local MImgLabel = require("app.common.button.MImgLabel")
local TCommonTabHost = require("app.common.tabhost.TCommonTabHost")
local DlgAlert = require("app.common.dialog.DlgAlert")
local ItemCountryShop = require("app.layer.newcountry.countryshop.ItemCountryShop")
local DlgCountryShop = class("DlgCountryShop", function()
	-- body
	return DlgBase.new(e_dlg_index.dlgcountryshop)
end)

function DlgCountryShop:ctor(  )
	-- body
	self:myInit()
	parseView("dlg_country_shop", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgCountryShop:myInit(  )
	-- body

	self.tListData = {}
	
	self.nShopType = 2
	self.nTabIndex = 1 
end

--解析布局回调事件
function DlgCountryShop:onParseViewCallback( pView )
	-- body
	self:addContentView(pView) --加入内容层
	self:addContentTopSpace(3)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgCountryShop",handler(self, self.onDlgCountryTreasureDestroy))
end

--初始化控件
function DlgCountryShop:setupViews( )
	-- body
	--设置标题
	self:setTitle(getConvertedStr(9, 10200))
	-- self.pLayBtn = self:findViewByName("lay_btn")
	-- self.pBtn = getCommonButtonOfContainer(self.pLayBtn,TypeCommonBtn.L_YELLOW,getConvertedStr(9,10197))
	-- self.pBtn:onCommonBtnClicked(handler(self, self.onGoldRefreshClicked))

 	self.pLayList=self:findViewByName("lay_list")
 	self.pTxtNum=self:findViewByName("txt_coin_num")
 	self.pTxtNum:setString(getConvertedStr(9,10201))
 	setTextCCColor(self.pTxtNum,_cc.pwhite)
 	self.pTxtDesc=self:findViewByName("txt_desc")
 	setTextCCColor(self.pTxtDesc,_cc.pwhite)
 	self.pTxtDesc:setString(getConvertedStr(9,10201))

 	local pLayTip = self:findViewByName("lay_tip")
	--图片文字
	self.pImgLabel = MImgLabel.new({text="", size = 18, parent = pLayTip})
	self.pImgLabel:setAnchorPoint(cc.p(0,0.5))
	self.pImgLabel:setImg(getCostResImg(e_type_resdata.countrycoin), 0.35, "left")
	self.pImgLabel:followPos("right", self.pTxtNum:getPositionX() +self.pTxtNum:getContentSize().width +self.pImgLabel:getWidth()/2+ 60, self.pTxtNum:getPositionY(), 10)

	self.tTitles = {
		getConvertedStr(9, 10198),
		getConvertedStr(9, 10199)
	}

	self.pLayTabHost 			= 		self:findViewByName("lay_tab_btn")

	self.pTComTabHost = TCommonTabHost.new(self.pLayTabHost,1,1,self.tTitles,handler(self, self.onIndexSelected))
	self.pLayTabHost:addView(self.pTComTabHost)
	self.pTComTabHost:removeLayTmp1()
	self.pTComTabHost:setDefaultIndex(1)

	--按钮集
	self.pTabItems =  self.pTComTabHost:getTabItems()
end

-- 修改控件内容或者是刷新控件数据
function DlgCountryShop:updateViews(  )
	

	self.pImgLabel:setString(tostring(getMyGoodsCnt(e_type_resdata.countrycoin)))
	self.pImgLabel:followPos("right", self.pTxtNum:getPositionX() +self.pTxtNum:getContentSize().width +self.pImgLabel:getWidth()/2+ 55, self.pTxtNum:getPositionY(), 10)

	self:onIndexSelected(self.nTabIndex)
	
end

-- 析构方法
function DlgCountryShop:onDlgCountryTreasureDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function DlgCountryShop:regMsgs( )
	regMsg(self,ghd_refresh_country_shop,handler(self,self.updateViews))
end

-- 注销消息
function DlgCountryShop:unregMsgs(  )
	unregMsg(self,ghd_refresh_country_shop)
end


--暂停方法
function DlgCountryShop:onPause( )
	-- body
	self:unregMsgs()
end

--继续方法
function DlgCountryShop:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

--下标选择回调事件
function DlgCountryShop:onIndexSelected( _index )
	self.nTabIndex = _index
	if _index == 1 then --全国限定
		-- self:setBottomVisible(true)
		self.tListData = Player:getCountryShopData().tCab
		self.nShopType = 2
 		self.pTxtDesc:setString(getTipsByIndex(20156))


	elseif _index == 2 then --个人限定
		-- self:setBottomVisible(false)
		self.tListData = Player:getCountryShopData().tPab
		self.nShopType = 1
 		self.pTxtDesc:setString(getTipsByIndex(20157))

	end
	-- --记录当前类型
	-- if _index == 4 then
	-- 	self.nCategory = e_type_mail.activity--活动
	-- elseif _index == 5 then
	-- 	self.nCategory = e_type_mail.saved--已保存
	-- else
	-- 	self.nCategory = _index
	-- end
	self:createListView(_index)
end
--创建listView
function DlgCountryShop:createListView(_nIndex)
	-- --更新列表数据
	-- self.tListData = self.tTempData[_nIndex]

	if self.tListData then
		if not self.pListView then
			--列表
			local pSize = self.pLayList:getContentSize()
			self.pListView = MUI.MListView.new {
				viewRect   = cc.rect(0, 0, pSize.width, pSize.height),
				direction  = MUI.MScrollView.DIRECTION_VERTICAL,
				itemMargin = {
					left   = 20,
		            right  = 0,
		            top    = 0, 
		            bottom = 10}
		    }
		    self.pLayList:addView(self.pListView)
			local nCount = table.nums(self.tListData)
			self.pListView:setItemCount(nCount)
			self.pListView:setItemCallback(function ( _index, _pView ) 
			    local pTempView = _pView
			    if pTempView == nil then
			    	pTempView = ItemCountryShop.new()
				end
				pTempView:setData(self.tListData[_index],self.nShopType)
			    return pTempView
			end)
			self.pListView:reload()
			--上下箭头
			local pUpArrow, pDownArrow = getUpAndDownArrow()
			self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)
			

		else
			self.pListView:scrollToBegin()
			self.pListView:notifyDataSetChange(true,table.nums(self.tListData))
		end
	end
end


return DlgCountryShop