-- Author: maheng
-- Date: 2017-04-27 14:43:24
-- 物品详情显示对话框 目前仅仅显示功能


local DlgAlert = require("app.common.dialog.DlgAlert")

local DlgItemInfo = class("DlgItemInfo", function ()
	return DlgAlert.new(e_dlg_index.iteminfo)
end)

--构造
function DlgItemInfo:ctor()
	-- body
	self:myInit()
	parseView("dlg_item_info", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgItemInfo:myInit()
	-- body
	self.pCurData = nil
end
  
--解析布局回调事件
function DlgItemInfo:onParseViewCallback( pView )
	-- body
	self:addContentView(pView, false)
	self:setupViews()
	self:onResume()
	 --注册析构方法
    self:setDestroyHandler("DlgItemInfo",handler(self, self.onDlgItemInfoDestroy))
end

--初始化控件
function DlgItemInfo:setupViews()
	-- body
	--设置标题
	self:setTitle(getConvertedStr(6,10136))

	--内容层
	self.pLaycontent = self:findViewByName("lay_content")
	--物品头像层
	self.pLayIcon 			= 		self:findViewByName("lay_icon")
	--物品名称
	self.pLbName 			= 		self:findViewByName("lb_name")
	self.pLbName:setString("")
	--物品说明
	self.pLbDes 			= 		self:findViewByName("lb_des")
	self.pLbDes:setString("")
	setTextCCColor(self.pLbDes, _cc.white)

	--物品获取途径标签
	self.pLbItemSource = self:findViewByName("lb_tujing")
	self.pLbItemSource:setString(getConvertedStr(6, 10137))
	setTextCCColor(self.pLbItemSource, _cc.blue)
	--获取途径
	self.pLbTips = self:findViewByName("lb_tips")
	self.pLbTips:setString(getConvertedStr(6, 10137))
	setTextCCColor(self.pLbItemSource, _cc.pwhite)

	--按钮
	self.pLayBtn = self:findViewByName("lay_btn")
	self.pbtn = getCommonButtonOfContainer(self.pLayBtn, TypeCommonBtn.L_BLUE, getConvertedStr(6, 10106))
	self.pbtn:onCommonBtnClicked(handler(self, self.onBtnClicked))

	--背景透明
	self:setContentBgTransparent()
end

-- 修改控件内容或者是刷新控件数据
function DlgItemInfo:updateViews()
	-- body
	if self.pCurData then
		--物品名字
		self.pLbName:setString(self.pCurData.sName)
		setLbTextColorByQuality(self.pLbName, self.pCurData.nQuality)
		--物品描述
		self.pLbDes:setString(self.pCurData.sDes)
		--物品获取途径
		self.pLbTips:setString(self.pCurData.sTips)
		--
		getIconGoodsByType(self.pLayIcon,TypeIconGoods.NORMAL,type_icongoods_show.item,self.pCurData)
	end
end

--析构方法
function DlgItemInfo:onDlgItemInfoDestroy()
	self:onPause()
end

-- 注册消息
function DlgItemInfo:regMsgs( )
	-- body
end

-- 注销消息
function DlgItemInfo:unregMsgs(  )
	-- body
end


--暂停方法
function DlgItemInfo:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function DlgItemInfo:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

--按钮响应
function DlgItemInfo:onBtnClicked( pView )
	-- body
	self:closeAlertDlg()--关闭对话框
end
--设置物品数据 _itemid-物品配表id
function DlgItemInfo:setItemDataById( _itemid )
	-- body
	local pitemdata = Player:getBagInfo():getItemDataById(_itemid) or getBaseItemDataByID(_itemid)
	if pitemdata then		
		self.pCurData= pitemdata
		self:updateViews()
	else
		print("设置显示对话框的物品数据错误...")
	end	
end
return DlgItemInfo
