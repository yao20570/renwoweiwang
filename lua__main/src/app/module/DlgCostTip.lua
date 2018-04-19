-- Author: maheng
-- Date: 2017-04-21 11:56:24
-- 玩家花费对话框 富文本内容显示 复选框以及按钮上的文字图片提示


local DlgAlert = require("app.common.dialog.DlgAlert")
local MRichLabel = require("app.common.richview.MRichLabel")
local MBtnExText = require("app.common.button.MBtnExText")

local DlgCostTip = class("DlgCostTip", function ()
	return DlgAlert.new(e_dlg_index.costtip)
end)

local e_cost_tip = 
{
	pchat = 2,
}
--构造
--nTipType:默认是黄金二次确认，2:私聊花费确认
function DlgCostTip:ctor( nTipType )
	self.nTipType = nTipType
	self:myInit()
	parseView("dlg_costtip", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgCostTip:myInit()
	-- body
	self.nNeedCost = 0   --需求金币
	self.prichText = nil --富文本提示内容
	self._nHandler = nil --回到事件 
	self.bSelect = false
end
  
--解析布局回调事件
function DlgCostTip:onParseViewCallback( pView )
	-- body
	self:addContentView(pView, true)
	self:setupViews()
	self:onResume()
	 --注册析构方法
    self:setDestroyHandler("DlgCostTip",handler(self, self.onDlgCostTipDestroy))
end

--初始化控件
function DlgCostTip:setupViews()
	-- body
	--设置右边按钮样式
	self:setRightBtnType(TypeCommonBtn.L_YELLOW)
	--设置标题
	self:setTitle(getConvertedStr(6,10079))

	self.pLayRoot = self:findViewByName("root")	
	--提示内容层
	self.pLayTip = self:findViewByName("lay_tip")


	--复选框层
	self.pLayCheck = self:findViewByName("lay_check")
	self.pLayCheck:setViewTouched(true)
	self.pLayCheck:setIsPressedNeedScale(false)
	self.pLayCheck:onMViewClicked(handler(self, self.switchCheckBox))

	--复选按钮层
	self.pLayCheckBox = self:findViewByName("lay_checkbox")
	self.pCheckBox = MUI.MCheckBoxButton.new(
        {on="#v2_img_gouxuan.png", off="#v2_img_gouxuankuang.png"})
	self.pCheckBox:setButtonSelected(false)
	self.pLayCheckBox:addView(self.pCheckBox)
	centerInView(self.pLayCheckBox, self.pCheckBox)
	self.pCheckBox:onButtonStateChanged(function ( bChecked )
		-- body
		self.bSelect = bChecked
	end)
	--复选说明
	self.pLbCheckText = self:findViewByName("lb_checktext")
	if self.nTipType == e_cost_tip.pchat then
		self.pLbCheckText:setString(getConvertedStr(3, 10737))
		self:setRightBtnText(getConvertedStr(3, 10739))
	else
		self.pLbCheckText:setString(getConvertedStr(6, 10104))
	end
	setTextCCColor(self.pLbCheckText, _cc.pwhite)

	--按钮上的金币提示
	local tBtnTable = {}
	tBtnTable.parent = self.pBtnRight
	tBtnTable.img = "#v1_img_qianbi.png"
	--文本
	tBtnTable.tLabel = {
		{"0",getC3B(_cc.blue)},
		{"/",getC3B(_cc.pwhite)},
		{self.nNeedCost,getC3B(_cc.pwhite)}
	}
	self.pBtnExText = MBtnExText.new(tBtnTable)
	-- self.pBtnExText:addHeight(0)

	--设置右键按钮点击事件
	self:setRightHandler(handler(self, self.onCostClicked))
	--默认背景隐藏
	self:setContentBgTransparent()

    -- 设置左右按钮层的高度
	self:setBtnLayHeight(self.pLayRight:getPositionY() - 15)
end

--切换勾选
function DlgCostTip:switchCheckBox()
	local bSelected = self.pCheckBox:isButtonSelected()
	if bSelected then
		self.pCheckBox:setButtonSelected(false)
		self.bSelect = false
	else
		self.pCheckBox:setButtonSelected(true)
		self.bSelect = true
	end
end

-- 修改控件内容或者是刷新控件数据
function DlgCostTip:updateViews()
	-- body

end

--析构方法
function DlgCostTip:onDlgCostTipDestroy()
	if self.nTipType == e_cost_tip.pchat then
		if self.bSelect == true then
			setSettingInfo("PChatGoldTip", "0")
		else
			setSettingInfo("PChatGoldTip", "1")
		end
	else
		if self.bSelect == true then
			setSettingInfo("GoldCostTip", "0")
		else
			setSettingInfo("GoldCostTip", "1")
		end
	end
	self:onPause()
end

-- 注册消息
function DlgCostTip:regMsgs( )
	-- body
end

-- 注销消息
function DlgCostTip:unregMsgs(  )
	-- body
end


--暂停方法
function DlgCostTip:onPause( )
	-- body
	self:unregMsgs()
end

--继续方法
function DlgCostTip:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

--_tLabel 需要显示文字与颜色集合 
--_nType 默认为 0 (添加是否花费前缀) 1直接显示传入 文本
function DlgCostTip:setRichTextTip( _tLabel,_nType )
	-- body
	local nType = _nType or 0
	if self.prichText then
		self.prichText:removeSelf()
	end

	if not (type(_tLabel) == "table") then
		return
	end    

    local strTips = {}
    if nType == 0 then
    	strTips = 
    	{
			{color=_cc.pwhite,text=getConvertedStr(6, 10101)},--是否花费
	    	{color=_cc.yellow,text=self.nNeedCost or 0 },
	    	{color=_cc.yellow,text=getConvertedStr(6, 10103)},
		}
	elseif nType == 1 then
		strTips = {}
    end

	if table.nums(_tLabel)> 0 then
		for k,v in pairs(_tLabel) do
			table.insert(strTips,v)
		end
	end
    --self.prichText = MRichLabel.new({str=strTips, fontSize=20, rowWidth=450})  
    self.prichText = MUI.MLabel.new({
		    text = "",
		    size = _nFontSize or 20,
		    anchorpoint = _anchorPoint or cc.p(0.5, 0.5),
		    align = cc.ui.TEXT_ALIGN_CENTER,
			valign = cc.ui.TEXT_VALIGN_TOP,
		    color = getC3B(_sColor),
		    dimensions = cc.size(450, 0),
		})
    self.prichText:setString(strTips, false)
	self.pLayTip:addView(self.prichText)
	-- self.prichText:setAnchorPoint(0,0.5)
	-- self.prichText:setPosition( (self.pLayTip:getWidth()-self.prichText:getWidth())
	centerInView(self.pLayTip,self.prichText)
	--self.prichText:setPositionY(self.pLayTip:getHeight()/2 - self.prichText:getHeight()/2 + 30)

end

--设置当前需求值
function DlgCostTip:setNeedCost(_nCost, _costId)
	-- body
	--拥有量
	local nHasMoney = Player:getPlayerInfo().nMoney
	
	self.nNeedCost = _nCost or self.nNeedCost	
	if _costId == 3 then  --目前只判断铜钱,其他的就不要在这里加了
		nHasMoney = Player:getPlayerInfo().nCoin
	end
	
	
	--设置当前需求值
	if self.nNeedCost > nHasMoney then
		self.pBtnExText:setLabelCnCr(3,self.nNeedCost)
		--设置拥有量
		self.pBtnExText:setLabelCnCr(1, nHasMoney, getC3B(_cc.red))
	else	
		self.pBtnExText:setLabelCnCr(3,self.nNeedCost)
		--设置拥有量
		self.pBtnExText:setLabelCnCr(1, nHasMoney, getC3B(_cc.blue))
	end
	if self.nNeedCost <= 0 then
		self.pBtnExText:setLabelCnCr(1,getConvertedStr(6, 10319), getC3B(_cc.green))
		self.pBtnExText:setLabelCnCr(2,"", getC3B(_cc.green))
		self.pBtnExText:setLabelCnCr(3,"", getC3B(_cc.green))
		self.pBtnExText:setImg(nil)
	end	
end

--设置回调事件
function DlgCostTip:setCostHandler( _handler )
	-- body
	self._nHandler = _handler
end

--消费按钮点击事件回调
function DlgCostTip:onCostClicked( pView )
	-- body
	local nHasMoney = Player:getPlayerInfo().nMoney
	if self.nCostId then
		if self.nCostId == 3 then  --目前只判断铜钱,其他的就不要在这里加了
			nHasMoney = Player:getPlayerInfo().nCoin
		end
	end
	if nHasMoney >= self.nNeedCost  then
		if self._nHandler then
			self._nHandler()
		end
		self:closeAlertDlg()		
	else
		if self.nCostId then
			local sCostName = getCostResName(self.nCostId)
        	TOAST(sCostName..getConvertedStr(7, 10118))--银币不足
			self:closeAlertDlg()		
        	return        
		else
        	-- TOAST(getConvertedStr(1, 10160))--黄金不足        
		end
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

--隐藏复选框
function DlgCostTip:hideCheckBox( _bHide )
	-- body
	self.pLayCheck:setVisible(not _bHide)
	if self.pLayCheck:isVisible() then
		self.pLayTip:setPositionY(self.pLayCheck:getHeight())
	else
		self.pLayTip:setPositionY((self.pLayRoot:getHeight() - self.pLayTip:getHeight())/2)
	end
end

--设置花费货币类型
function DlgCostTip:setCostId( _costId )
	-- body
	self.nCostId = _costId
	local sImg = getCostResImg(_costId)
	self.pBtnExText:setImg(sImg)
	if _costId == 3 then
		self.pBtnExText:setLabelCnCr(3,Player:getPlayerInfo().nCoin)
	end
end

return DlgCostTip
