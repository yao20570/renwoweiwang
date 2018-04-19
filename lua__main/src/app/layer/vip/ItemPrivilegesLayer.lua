-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-05-31 10:12:23 星期三
-- Description: vip特权项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local DlgAlert = require("app.common.dialog.DlgAlert")
local MImgLabel = require("app.common.button.MImgLabel")
local ItemPrivilegesLayer = class("ItemPrivilegesLayer", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)


function ItemPrivilegesLayer:ctor()
	-- body
	self:myInit()

	parseView("item_privileges_layer", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("ItemPrivilegesLayer",handler(self, self.onItemPrivilegesLayerDestroy))	
end

--初始化参数
function ItemPrivilegesLayer:myInit()
	-- body
	self.pCurData = nil
end

--解析布局回调事件
function ItemPrivilegesLayer:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)
	self:setupViews()
	self:updateViews()
end

--初始化控件
function ItemPrivilegesLayer:setupViews( )
	--body	
	self.pLayRoot = self:findViewByName("lay_root")
	self.pLbTitle = self:findViewByName("lb_title")
	self.pLayItems = self:findViewByName("lay_items")
	self.pImgFlag = self:findViewByName("img_flag")
	self.pLbTip1 = self:findViewByName("lb_tip1")
	setTextCCColor(self.pLbTip1, _cc.red)
	self.pLayBtn = self:findViewByName("lay_btn")
	self.pBtnBuy = getCommonButtonOfContainer(self.pLayBtn, TypeCommonBtn.L_YELLOW,"", false)
	self.pBtnBuy:onCommonBtnClicked(handler(self, self.onBuyBtnClicked))
	self.pBtnBuy:onCommonBtnDisabledClicked(handler(self, self.onDisBuybtnClicked))

	local tBtnTable = {}
	tBtnTable.img = getCostResImg(e_resdata_ids.ybao)
	--文本
	tBtnTable.tLabel = {
		{"",getC3B(_cc.white)},
	}
	tBtnTable.awayH = -40 -- 扩展内容层离存放按钮的父层 的高度 (默认self.nAwayH 的高度)
	self.pBtnBuy:setBtnExText(tBtnTable, false)

	self.pImgLabel = MImgLabel.new({text="", size = 20, parent = self.pLayBtn})
	self.pImgLabel:setImg(getCostResImg(e_resdata_ids.ybao), 1, "left")
	self.pImgLabel:followPos("center", 65, 70, 10)			
end

-- 修改控件内容或者是刷新控件数据
function ItemPrivilegesLayer:updateViews(  )
	-- body	
	if not self.pCurData then
		return
	end	
	local nLv = tonumber(self.pCurData.lv or 0)
	self.pLbTitle:setString(getVipLvString(nLv)..getConvertedStr(6, 10295))
	local tDropList = getDropById(self.pCurData.giftid)
	-- dump(tDropList, "tDropList", 100)
	if not tDropList then
		tDropList = {}
	end
	table.sort(tDropList, function ( tGoodsA, tGoodsB )
        if tGoodsA and tGoodsB then
            if tGoodsA.nQuality == tGoodsB.nQuality then
                return tGoodsA.sTid > tGoodsB.sTid
            end
            return tGoodsA.nQuality > tGoodsB.nQuality
        end
    end)

	gRefreshHorizontalList(self.pLayItems, tDropList)	
	self.pBtnBuy:setExTextLbCnCr(1, self.pCurData.nowprice)
	local tLabel = {
		{text = self.pCurData.orgprice, color = getC3B(_cc.white)}
	}
	local nLen = string.len(tostring(self.pCurData.orgprice))
	-- local fScale = nLen*1.8	
	self.pImgLabel:setString(tLabel)
	self.pImgLabel:showRedLine(true, nil, "all")    	

    if Player:getPlayerInfo().nVip < self.pCurData.lv then    	
    	self.pBtnBuy:setBtnVisible(false)
    	self.pImgFlag:setVisible(false)
    	self.pBtnBuy:removeLingTx()

		self.pLbTip1:setVisible(true)
    	self.pLbTip1:setString(getVipLvString(self.pCurData.lv) .. getConvertedStr(3, 10334))
    else
    	self.pLbTip1:setVisible(false)
		if Player:getPlayerInfo():getIsBoughtVipGift(self.pCurData.lv) then
			self.pBtnBuy:setBtnEnable(false)			
			self.pBtnBuy:setBtnVisible(false)
			self.pImgFlag:setVisible(true)

			self.pBtnBuy:removeLingTx()
		else
			self.pBtnBuy:setBtnEnable(true)
			self.pBtnBuy:setBtnVisible(true)
			self.pImgFlag:setVisible(false)

			self.pBtnBuy:showLingTx()
		end	
	end
end

--析构方法
function ItemPrivilegesLayer:onItemPrivilegesLayerDestroy(  )
	-- body
end


--设置数据
function ItemPrivilegesLayer:setCurData( _data )
	-- body
	if _data then
		self.pCurData = _data		
	else
		self.pCurData = nil
	end
	self:updateViews()
end

--购买按钮点击回调
function ItemPrivilegesLayer:onBuyBtnClicked( pview )
	-- body	
	if self.pCurData then
		if self.pCurData.nowprice <= Player:getPlayerInfo().nMoney then
			local giftid = tonumber(self.pCurData.lv)
			--print("giftid="..giftid)
			SocketManager:sendMsg("buyVipGift", {giftid})
		else
	        local pDlg, bNew = getDlgByType(e_dlg_index.alert)
	        if(not pDlg) then
	            pDlg = DlgAlert.new(e_dlg_index.alert)
	        end
	        pDlg:setTitle(getConvertedStr(3, 10091))
	        pDlg:setContent(getConvertedStr(6, 10081))
	        local btn = pDlg:getRightButton()
	        btn:updateBtnText(getConvertedStr(6, 10291))
	        btn:updateBtnType(TypeCommonBtn.L_YELLOW)
	        pDlg:setRightHandler(function (  )            
	            local tObject = {}
	            tObject.nType = e_dlg_index.dlgrecharge --dlg类型
	            sendMsg(ghd_show_dlg_by_type,tObject) 
	            closeDlgByType(e_dlg_index.alert)  
	        end)
	        pDlg:showDlg(bNew)   			
		end
	end
end

function ItemPrivilegesLayer:onDisBuybtnClicked( pView )
	-- body
	print("无法购买")
	local pDlg, bNew = getDlgByType(e_dlg_index.alert)
    if(not pDlg) then
        pDlg = DlgAlert.new(e_dlg_index.alert)
    end
    pDlg:setTitle(getConvertedStr(3, 10091))		
    pDlg:setContent(getConvertedStr(6, 10513), _cc.white, 20, 400)
    pDlg:setRightHandler(function (  )
        local tObject = {}
        tObject.nType = e_dlg_index.dlgrecharge --dlg类型
        sendMsg(ghd_show_dlg_by_type,tObject)  
        pDlg:closeDlg(false)
    end)
    pDlg:showDlg(bNew)	
end
return ItemPrivilegesLayer