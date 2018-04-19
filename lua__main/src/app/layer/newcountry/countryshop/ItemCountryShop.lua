----------------------------------------------------- 
-- author: luwenjing
-- updatetime: 2018-03-30 09:47:20
-- Description: 国家商店列表子项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local IconGoods = require("app.common.iconview.IconGoods")
local MImgLabel = require("app.common.button.MImgLabel")

local ItemCountryShop = class("ItemCountryShop", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemCountryShop:ctor(  )
	--解析文件
	parseView("item_country_shop", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemCountryShop:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)
	self:myInit()
	self:setupViews()

	--注册析构方法
	self:setDestroyHandler("ItemCountryShop", handler(self, self.onItemCountryShopDestroy))
end

function ItemCountryShop:myInit()
	self.tShopData = nil

	self.nShopType = 1 --商店类型（1-个人商店，2-国家商店）
end

-- 析构方法
function ItemCountryShop:onItemCountryShopDestroy(  )
end

function ItemCountryShop:setupViews(  )
	self.pTxtName = self:findViewByName('txt_name')
	self.pTxtDesc = self:findViewByName('txt_desc')
	self.pLayBtn = self:findViewByName("lay_btn")
	self.pBtn = getCommonButtonOfContainer(self.pLayBtn,TypeCommonBtn.M_BLUE,"")
	setMCommonBtnScale(self.pLayBtn, self.pBtn, 0.8)
	self.pBtn:onCommonBtnClicked(handler(self, self.onBtnClicked))

	-- local tBtnTable ={}
	-- tBtnTable.img = getCostResImg(e_type_resdata.countrycoin)
	-- tBtnTable.tLabel={
	-- 	{"1",getC3B(_cc.white)}
	-- }
	-- tBtnTable.awayH=-55

	-- self.pBtn:setBtnExText(tBtnTable)
	-- self.pBtn:setExTextZorder(1000)

	--价格
	self.pImgLabel = MImgLabel.new({text="", size = 20, parent = self.pLayBtn})
	self.pImgLabel:setImg(getCostResImg(e_type_resdata.countrycoin), 0.35, "left")
	self.pImgLabel:followPos("center", self.pLayBtn:getContentSize().width/2, self.pLayBtn:getContentSize().height/2, 8)


	self.pLayIcon = self:findViewByName("lay_icon")

	self.pTxtNum = self:findViewByName("txt_num")
end

function ItemCountryShop:updateViews(  )
	-- body
	-- self.pTxtTitle:setString()
	if not self.tData then
		return
	end

	self.tShopData = getCountryShopDataById(self.tData.k)
	if self.tShopData then

		if not self.pIcon then
	        
		    self.pIcon = IconGoods.new(TypeIconGoods.NORMAL)
		    -- self.pIcon:setAnchorPoint(0,0)
		    self.pLayIcon:addView(self.pIcon)
		    centerInView(self.pLayIcon,self.pIcon)
		    -- pIcon:setIconScale(0.8)
	    end
	    local pGoodData = getGoodsByTidFromDB(self.tShopData.tItemData.k)
		if pGoodData then
	        self.pIcon:setCurData(pGoodData)
	        self.pIcon:setNumber(self.tShopData.tItemData.v)
	        self.pTxtName:setString(pGoodData.sName)
	        self.pTxtDesc:setString(pGoodData.sDes)
	        setTextCCColor(self.pTxtName, getColorByQuality(pGoodData.nQuality))
	    end

	    self.pTxtNum:setString(self.tData.v.."/"..self.tShopData.limittime)

	    local sColor = _cc.white
		if getMyGoodsCnt(e_type_resdata.countrycoin) < self.tShopData.dedicate then
			sColor = _cc.red
		end
		self.pImgLabel:setString(self.tShopData.dedicate)
		setTextCCColor(self.pImgLabel,sColor)
		-- self.pBtn:setExTextLbCnCr(1,self.tShopData.dedicate,getC3B(sColor))

		if self.tData.v >= self.tShopData.limittime then   --购买次数达上限
			self.pBtn:setBtnEnable(false)
		else
			self.pBtn:setBtnEnable(true)
		end

	end
end

function ItemCountryShop:setData( _tData ,_nShopType)
	-- body
	self.tData=_tData or self.tData

	self.nShopType = _nShopType or self.nShopType
	
	self:updateViews()

end

function ItemCountryShop:onBtnClicked( )
	-- body
	-- local tStr = {
	-- 	{color = _cc.pwhite, text = getConvertedStr(3, 10280)},
	-- 	{color = _cc.yellow, text = string.format(getConvertedStr(3, 10281), self.tShopData.g)},
	-- 	{color = _cc.pwhite, text = getConvertedStr(3, 10487)},
	-- 	{color = _cc.yellow, text = self.tAttrName},
	-- }
	-- 		--展示购买对话框
	-- showBuyDlg(tStr, self.tData.g,function (  )
	SocketManager:sendMsg("buyCountryShop",{tonumber(self.tData.k),self.nShopType},handler(self,self.onBuyCallback))
	-- end, 1)
end
function ItemCountryShop:onBuyCallback( __msg,__oldMsg )
	-- body
	if  __msg.head.state == SocketErrorType.success then 

		-- showGetItemsAction(__msg.body.atts)
		if __msg.body.ob then
			showGetAllItems(__msg.body.ob)
		end
		Player:getCountryShopData():refreshDatasByService(__msg.body)
		sendMsg(ghd_refresh_country_shop)
		-- local tData = Player:getActById(e_id_activity.mingjie)
		-- if tData then
		-- 	tData:refreshDatasByServer(__msg.body)
		-- 	tData:refreshAttrCost(__msg.body,__oldMsg[1])
		-- 	sendMsg(gud_refresh_activity)
		-- end
  	else
	   	--弹出错误提示语
	  	TOAST(SocketManager:getErrorStr(__msg.head.state))
	end  
end
return ItemCountryShop


