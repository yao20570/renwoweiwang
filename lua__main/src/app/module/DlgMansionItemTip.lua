-- Author: maheng
-- Date: 2017-11-08 21:02:24
-- 登坛拜将物品提示


local DlgAlert = require("app.common.dialog.DlgAlert")
local MImgLabel = require("app.common.button.MImgLabel")
local DlgMansionItemTip = class("DlgMansionItemTip", function ()
	return DlgAlert.new(e_dlg_index.mansionitemtip)
end)

--构造
function DlgMansionItemTip:ctor()
	-- body
	self:myInit()	
	parseView("lay_mansion_item_tip", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgMansionItemTip:myInit()
	-- body

end
  
--解析布局回调事件
function DlgMansionItemTip:onParseViewCallback( pView )
	-- body
	self:addContentView(pView, true)
	self:setupViews()
	self:onResume()
	 --注册析构方法
    self:setDestroyHandler("DlgMansionItemTip",handler(self, self.onDestroy))
end

--初始化控件	
function DlgMansionItemTip:setupViews()
	-- body
	--设置标题
	self:setTitle(getConvertedStr(6, 10079))
	self.pLayIcon = self:findViewByName("lay_icon")
	self.pLbName = self:findViewByName("lb_name")
	self.pLbSale = self:findViewByName("lb_sale")
	self.pLbDesc = self:findViewByName("lb_desc")
	setTextCCColor(self.pLbDesc, _cc.pwhite)

    self:setOnlyConfirm(getConvertedStr(6, 10106))
    self:setOnlyConfirmBtn(TypeCommonBtn.L_YELLOW) 
	self.pImgLabel = MImgLabel.new({text="", size=20, parent=self.pLayRight})
	self.pImgLabel:setImg(getCostResImg(e_type_resdata.money), 1)
	self.pImgLabel:followPos("center", self.pLayRight:getContentSize().width/2, self.pLayRight:getContentSize().height + 5, 5)
	self.pImgLabel:setString("")
end

-- 修改控件内容或者是刷新控件数据
function DlgMansionItemTip:updateViews()
	-- body	
	local tActData = Player:getActById(e_id_activity.heromansion)	
	if not self.pData then
		return
	end
	--物品信息
	local pIconData = getGoodsByTidFromDB(self.pData.i)
	if pIconData then
		self.pLbName:setString(pIconData.sName)
		setTextCCColor(self.pLbName, getColorByQuality(pIconData.nQuality))
		pIconData.nCt = self.pData.n or 0
		self.pIcon = getIconGoodsByType(self.pLayIcon, TypeIconGoods.NORMAL, type_icongoods_show.itemnum, pIconData,TypeIconGoodsSize.L)
		self.pIcon:setIconIsCanTouched(false)
		self.pLbDesc:setString(pIconData.sDes)
	end
	local sSale = getTextColorByConfigure(string.format(getConvertedStr(6, 10592), (tActData:getSale()*100).."%")) 
	self.pLbSale:setString(sSale, false)
	self.pImgLabel:setString(self.pData.g*tActData:getSale())
end

--析构方法
function DlgMansionItemTip:onDestroy()
	self:onPause()	   	
end

-- 注册消息
function DlgMansionItemTip:regMsgs( )
	-- body
end

-- 注销消息
function DlgMansionItemTip:unregMsgs(  )
	-- body
end


--暂停方法
function DlgMansionItemTip:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function DlgMansionItemTip:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

function DlgMansionItemTip:setCurData(pData)
	-- body
	self.pData = pData or nil
	self:updateViews()
end

return DlgMansionItemTip
