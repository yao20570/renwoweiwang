-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-04-27 17:05:40 星期四
-- Description: 物品 item 项目  TypeItemInfoSize（大小类型） 532*100 570*130
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local MBtnExText = require("app.common.button.MBtnExText")

local ItemInfo = class("ItemInfo", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--_nType：TypeItemInfoSize（大小类型）
function ItemInfo:ctor( _nType )
	-- body
	self:myInit()
	self.nSizeType = _nType or self.nSizeType
	if self.nSizeType == TypeItemInfoSize.L then
		parseView("item_itemmsg_l", handler(self, self.onParseViewCallback))
	elseif self.nSizeType == TypeItemInfoSize.M then
		parseView("item_itemmsg_m", handler(self, self.onParseViewCallback))
	end
	
end

--初始化成员变量
function ItemInfo:myInit(  )
	-- body
	self.nSizeType 			= 	TypeItemInfoSize.L  --item大小 	
	self.tCurData 			= 	nil 				--当前数据	
	self.nHandler 			= 	nil 				--回调事件
	self.bIsIconCanTouched 	= 	false
end

--解析布局回调事件
function ItemInfo:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("ItemInfo",handler(self, self.onItemInfoDestroy))
end

--初始化控件
function ItemInfo:setupViews( )
	-- body
	--背景
	self.pLayBg				=		self:findViewByName("default")
	--名字
	self.pLbName 			= 		self:findViewByName("lb_name")
	--icon
	self.pLayIcon 			= 		self:findViewByName("lay_icon")

	self.pImgShade 			= 		self:findViewByName("Image_2")
	--信息
	self.pLbMsg 			= 		self:findViewByName("lb_content")
	setTextCCColor(self.pLbMsg, _cc.pwhite)
	--按钮层
	self.pLayBtn 			= 		self:findViewByName("lay_btn")
	self.pBtn = getCommonButtonOfContainer(self.pLayBtn, TypeCommonBtn.M_BLUE, getConvertedStr(6, 10128))	
	self.pBtn:onCommonBtnClicked(handler(self, self.onBtnClicked))

	--额外信息
	local tBtnTable = {}
	tBtnTable.parent = self.pBtn
	--文本
	tBtnTable.tLabel = {
		{getConvertedStr(6, 10135), getC3B(_cc.white)},
		{0,getC3B(_cc.blue)}		
	}
	self.pBtnExTextHad = MBtnExText.new(tBtnTable)
end

-- 修改控件内容或者是刷新控件数据
function ItemInfo:updateViews( )
	-- body
	if self.tCurData then		
		--名字
		self.pLbName:setString(self.tCurData.sName,false)
		--描述		
		self.pLbMsg:setString(self.tCurData.sDes,false)
		--数量更新
		self.pBtnExTextHad:setLabelCnCr(2, self.tCurData.nCt)
		--从更新
		local nIconType = TypeIconGoods.NORMAL
		if self.nSizeType == TypeItemInfoSize.M then
			nIconType = TypeIconHeroSize.M
		end	
		local picon = getIconGoodsByType(self.pLayIcon,TypeIconGoods.NORMAL, type_icongoods_show.item, self.tCurData, nIconType)
		picon:setIconIsCanTouched(self.bIsIconCanTouched)
		--picon:setIconClickedCallBack(handler(self, self.onIconClickCallBack))
		setLbTextColorByQuality(self.pLbName, self.tCurData.nQuality)
	end
end

-- 析构方法
function ItemInfo:onItemInfoDestroy(  )
	-- body
end

function ItemInfo:setCurData( _data )
	-- body
	self.tCurData = _data
	self:updateViews()
end

--设置点击事件回到
function ItemInfo:setClickCallBack( _handler)
	-- body
	self.nHandler = _handler
end

--按钮点击回调
function ItemInfo:onBtnClicked( pView )
	-- body
	if self.nHandler then
		self.nHandler(self.tCurData)
		--新手引导点击完成
		Player:getNewGuideMgr():setNewGuideFingerClicked(e_guide_finer.five_min_speed_btn)
	end	
end

--改为金币消耗提示
function ItemInfo:changeExToGold(  )
	-- body
	if self.tCurData then
		if self.pBtnExTextHad then
			self.pBtnExTextHad:setBtnExTextEnabled(false)
		end
		if not self.pBtnExTextGold then
			local tBtnTable = {}
			tBtnTable.parent = self.pBtn
			tBtnTable.img = "#v1_img_qianbi.png"
			--文本
			tBtnTable.tLabel = {
				{"0",getC3B(_cc.blue)},
				{"/",getC3B(_cc.white)},
				{0,getC3B(_cc.white)},
			}
			if self.nSizeType == TypeItemInfoSize.M then
				tBtnTable.awayH = 6
			end
			self.pBtnExTextGold = MBtnExText.new(tBtnTable)
		end
		self.pBtn:updateBtnType(TypeCommonBtn.M_YELLOW)
		self.pBtn:updateBtnText(getConvertedStr(1,10113))

		self.pBtnExTextGold:setBtnExTextEnabled(true)
		local sColor = getC3B(_cc.blue)
		if self.tCurData.nPrice > Player:getPlayerInfo().nMoney then
			sColor = getC3B(_cc.red)
		end
		self.pBtnExTextGold:setLabelCnCr(3,self.tCurData.nPrice)
		self.pBtnExTextGold:setLabelCnCr(1,Player:getPlayerInfo().nMoney, sColor)
	end
end

--刷新金币需求
function ItemInfo:refreshExGold( _nValue )
	-- body
	if self.pBtnExTextGold then
		local sColor = getC3B(_cc.blue)
		if _nValue > Player:getPlayerInfo().nMoney then
			sColor = getC3B(_cc.red)
		end
		self.pBtnExTextGold:setLabelCnCr(3,_nValue)
		self.pBtnExTextGold:setLabelCnCr(1,Player:getPlayerInfo().nMoney, sColor)
	end
end

--改为拥有提示
function ItemInfo:changeExToHad( sBtnStr )
	-- body
	if self.tCurData then
		if self.pBtnExTextHad then
			self.pBtnExTextHad:setBtnExTextEnabled(true)
		end
		if self.pBtnExTextGold then
			self.pBtnExTextGold:setBtnExTextEnabled(false)
		end
		self.pBtnExTextHad:setLabelCnCr(1, getConvertedStr(6, 10135), getC3B(_cc.white))
		self.pBtnExTextHad:setLabelCnCr(2, getMyGoodsCnt(self.tCurData.sTid), getC3B(_cc.blue))
		self.pBtn:updateBtnType(TypeCommonBtn.M_BLUE)
		self.pBtn:updateBtnText(sBtnStr or getConvertedStr(6, 10128))

		--新手引导加速
		local nCurrStepId = Player:getNewGuideMgr():getCurrStepId()
		local tGuideData = getGuideData(nCurrStepId)
		if tGuideData and tGuideData.interface then
			local tInterface = luaSplit(tGuideData.interface, ":")
			if tInterface[2] and self.tCurData.sTid == tonumber(tInterface[2]) then
				self.pBtn:showLingTx()
				Player:getNewGuideMgr():setNewGuideFinger(self.pBtn, e_guide_finer.five_min_speed_btn)
			else
				self.pBtn:removeLingTx()
			end
		end
		
	end

end

--改为免费提示
function ItemInfo:changeExToFree( nFree, nMax )
	-- body
	if self.tCurData then
		if self.pBtnExTextHad then
			self.pBtnExTextHad:setBtnExTextEnabled(true)
		end
		if self.pBtnExTextGold then
			self.pBtnExTextGold:setBtnExTextEnabled(false)
		end
		self.pBtnExTextHad:setLabelCnCr(1, getConvertedStr(3, 10438), getC3B(_cc.white))
		self.pBtnExTextHad:setLabelCnCr(2, string.format("%s/%s", nFree, nMax), getC3B(_cc.white))
		self.pBtn:updateBtnType(TypeCommonBtn.M_BLUE)
		self.pBtn:updateBtnText(getConvertedStr(6, 10128))
	end
end

--改为获得提示
function ItemInfo:changeExToGet(  )
	-- body
	if self.tCurData then
		if self.pBtnExTextHad then
			self.pBtnExTextHad:setBtnExTextEnabled(true)
		end
		if self.pBtnExTextGold then
			self.pBtnExTextGold:setBtnExTextEnabled(false)
		end
		self.pBtnExTextHad:setLabelCnCr(1, getConvertedStr(6, 10135), getC3B(_cc.white))
		self.pBtnExTextHad:setLabelCnCr(2, getMyGoodsCnt(self.tCurData.sTid), getC3B(_cc.blue))
		self.pBtn:updateBtnType(TypeCommonBtn.M_YELLOW)
		self.pBtn:updateBtnText(getConvertedStr(3, 10499))
	end
end


--获得操作按钮
function ItemInfo:getAcionBtn(  )
	-- body
	return self.pBtn
end

--获得金币提示
function ItemInfo:getExGold(  )
	-- body
	return self.pBtnExTextGold 
end

--获得拥有提示
function ItemInfo:getExHad(  )
	-- body
	return self.pBtnExTextHad 
end

--设置按钮是否可见
function ItemInfo:setBtnVisible(_bVisible)
	-- body
	local bisVisible = _bVisible or false
	if self.pBtn then--设置按钮可见状态对应其是否响应
		self.pBtn:setVisible(bisVisible)
		self.pLayBtn:setViewTouched(bisVisible)
	end
end

-- --icon点击消息
-- function ItemInfo:onIconClickCallBack( pView )
-- 	-- body
-- 	if self.tCurData then--显示物品详情对话框
-- 		showItemInfoDlg(self.tCurData.sTid)
-- 	end
-- end

--设置Icon是否响应
function ItemInfo:setIsIconCanTouched( _istouched )
	-- body
	self.bIsIconCanTouched = _istouched or false
	self:updateViews()
end

--设置新品
function ItemInfo:setIconNew()
	-- body	
    local pIconGoods = self.pLayIcon:findViewByName("p_icon_goods_name")   
    if pIconGoods and self.tCurData then    
    	-- dump(self.tCurData, "self.tCurData",100)
    	if self.tCurData.nRedNum >= 1 then
    		pIconGoods:setDiscount(getConvertedStr(6, 10313))
    	else
    		pIconGoods:setDiscount()
    	end
    end
end

--加速物品不显示背景图
function ItemInfo:setProsBg( )
	-- body
	self.pLayBg:removeBackground()
	self.pImgShade:setVisible(false)
	if not self.pLine then
		self.pLine=self:findViewByName("line")
		
	end
	self.pLine:setVisible(true)
end

function ItemInfo:hideBottomLine( )
	-- body
	if not self.pLine then
		self.pLine=self:findViewByName("line")
	end
	self.pLine:setVisible(false)
end
return ItemInfo