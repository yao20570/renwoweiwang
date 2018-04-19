-----------------------------------------------------
-- author: maheng
-- updatetime:  2018-1-16 11:05:40 星期二
-- Description: 竞技场 商店项
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local MBtnExText = require("app.common.button.MBtnExText")
local DlgAlert = require("app.common.dialog.DlgAlert")
local ItemArenaShop = class("ItemArenaShop", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemArenaShop:ctor(  )
	-- body
	self:myInit()
	parseView("item_arena_shop", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function ItemArenaShop:myInit(  )
	-- body
	self.tCurData 			= 	nil 				--当前数据	
	self.bIsIconCanTouched 	= 	false		
end

--解析布局回调事件
function ItemArenaShop:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("ItemArenaShop",handler(self, self.onDestroy))
end

--初始化控件
function ItemArenaShop:setupViews( )
	-- body
	self.pLayIcon 	= 	self:findViewByName("lay_icon")
	self.pLbName 	= 	self:findViewByName("lb_name")
	self.pLbDesc 	= 	self:findViewByName("lb_desc")	
	setTextCCColor(self.pLbDesc, _cc.pwhite)	

	self.pImgHadBuy =   self:findViewByName("img_buyed")
	self.pLayBtn 	= 	self:findViewByName("lay_btn")
	self.pBtn = getCommonButtonOfContainer(self.pLayBtn,TypeCommonBtn.M_YELLOW,getConvertedStr(1,10117))	
	self.pBtn:onCommonBtnClicked(handler(self, self.onBtnClicked))	
end

-- 修改控件内容或者是刷新控件数据
function ItemArenaShop:updateViews( )
	-- body
	if not self.tCurData then
		return
	end
	local tGood = self.tCurData.tGood
	--dump(self.tCurData, "self.tCurData", 100)
	self.pLbName:setString(tGood.sName, false)
	setTextCCColor(self.pLbName, getColorByQuality(tGood.nQuality))
	self.pLbDesc:setString(tGood.sDes, false)
	if not self.pIcon then
		self.pIcon = getIconGoodsByType(self.pLayIcon, TypeIconGoods.NORMAL,type_icongoods_show.itemnum, tGood)
		self.pIcon:setIconIsCanTouched(self.bIsIconCanTouched)
	else
		self.pIcon:setCurData(tGood)		
	end	
	self.pLayBtn:setVisible(not self.tCurData.bHadBuy)
	self.pImgHadBuy:setVisible(self.tCurData.bHadBuy)	
end

-- 析构方法
function ItemArenaShop:onDestroy(  )
	-- body
end

function ItemArenaShop:setCurData( _tData )
	-- body
	self.tCurData = _tData
	self:updateViews()
end

--按钮点击回调 购买
function ItemArenaShop:onBtnClicked( pView )
	-- body
	if not self.tCurData then
		return
	end
	dump(self.tCurData, "self.tCurData")
	if self._nBtnClickHandler then
        self._nBtnClickHandler()
    else
		local nResId = self.tCurData.nRes
		local nCost = self.tCurData.nCost
		if nCost > getMyGoodsCnt(nResId) then
			local pDlg, bNew = getDlgByType(e_dlg_index.alert)
	        if(not pDlg) then
	            pDlg = DlgAlert.new(e_dlg_index.alert)
	        end
	        pDlg:setTitle(getConvertedStr(3, 10091))
	        pDlg:setContent(getConvertedStr(6, 10731))
	        local btn = pDlg:getRightButton()
	        btn:updateBtnText(getConvertedStr(6, 10216))
	        btn:updateBtnType(TypeCommonBtn.L_BLUE)
	        pDlg:setRightHandler(function (  )            
	            local tObject = {}
	            tObject.nType = e_dlg_index.dlgarena --dlg类型
	            tObject.nFPage = 1
	            sendMsg(ghd_show_dlg_by_type,tObject)   
	            closeDlgByType(e_dlg_index.alert, false)  
	        end)
	        pDlg:showDlg(bNew)   
	        return pDlg   
		else
			local pDlg, bNew = getDlgByType(e_dlg_index.alert)
	        if(not pDlg) then
	            pDlg = DlgAlert.new(e_dlg_index.alert)
	        end
	        pDlg:setTitle(getConvertedStr(3, 10091))
	        pDlg:setContent(getTextColorByConfigure(string.format(getConvertedStr(6, 10829), nCost, self.tCurData.tGood.sName)), false)
	        local btn = pDlg:getRightButton()
	        pDlg:setRightHandler(function (  )            
	            SocketManager:sendMsg("buyArenaItem", {self.tCurData.idx, 1}) 
	            closeDlgByType(e_dlg_index.alert, false)  
	        end)
	        pDlg:showDlg(bNew)   
	        return pDlg
						
		end
    end
end
--设置花费
function ItemArenaShop:setCostTip( _nResId, _nCost )
	-- body
	local sColor = _cc.pwhite
	if _nCost > getMyGoodsCnt(_nResId) then
		sColor = _cc.red
	end
	if not self.pBtnExTextGold then
		local tBtnTable = {}
		tBtnTable.parent = self.pBtn
		tBtnTable.img = getCostResImg(_nResId)
		--文本
		tBtnTable.tLabel = {
			{_nCost,getC3B(sColor)}
		}
		self.pBtnExTextGold = MBtnExText.new(tBtnTable)
	else
		self.pBtnExTextGold:setLabelCnCr(1, _nCost, getC3B(sColor))
	end
end

--设置购买点击事件
function ItemArenaShop:setBuyHandler(_handler)
	self._nBtnClickHandler = _handler
end

return ItemArenaShop