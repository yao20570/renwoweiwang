-- Author: maheng
-- Date: 2017-04-27 14:43:24
-- 物品详情显示对话框 目前仅仅显示功能


local DlgAlert = require("app.common.dialog.DlgAlert")

local DlgItemTips = class("DlgItemInfo", function ()
	return DlgAlert.new(e_dlg_index.iteminfoTips)
end)

--构造
function DlgItemTips:ctor()
	-- body
	self:myInit()
	parseView("item_info_tips", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgItemTips:myInit()
	-- body
	self.nRecommonNum = 0
end
  
--解析布局回调事件
function DlgItemTips:onParseViewCallback( pView )
	-- body
 	self:addContentView(pView, true)
	self:setupViews()
	self:setOnlyConfirm()
	self:onResume()
	--注册析构方法
    self:setDestroyHandler("DlgItemTips",handler(self, self.onDlgItemTipsDestroy))
end

--初始化控件
function DlgItemTips:setupViews()
	self:setTitle(getConvertedStr(5, 10045))

	self.pLayIcon 	= self:findViewByName("lay_icon")
	self.pLayIcon:setPositionX(self.pLayIcon:getPositionX()+11)
	self.pLbTips 	= self:findViewByName("lb_tip")
	self.pLbTips:setPositionY(self.pLbTips:getPositionY()+10)
 	
end

-- 修改控件内容或者是刷新控件数据
function DlgItemTips:updateViews()

	if self.pCurData then
		local sStr = getConvertedStr(1, 10351)..getConvertedStr(1, 10352)
		if self.pCurData.sTid == 100177 then
			local sStr_1 = "<font color='#f5d93d'>"..self.pCurData.sName.."</font>"
			local sStr_2 = tostring(NEED_RECOMMON)
			local sStr_3 = "<font color='#bc46ff'>"..getConvertedStr(1, 10353).."</font>"
			sStr = string.format(sStr, sStr_1, sStr_2, sStr_3) .. string.format(getConvertedStr(1, 10350), self.nRecommonNum)
		end
		 
		self.pLbTips:setString(sStr)
		-- --
		self.pIcon = getIconGoodsByType(self.pLayIcon,TypeIconGoods.HADMORE,type_icongoods_show.item,self.pCurData)
		self.pIcon:setScale(0.8)
	end
end


function DlgItemTips:setTips(_tips)
	self.pLbTips:setString(_tips)
end

--析构方法
function DlgItemTips:onDlgItemTipsDestroy()
	self:onPause()
end

-- 注册消息
function DlgItemTips:regMsgs( )
	-- body
end

-- 注销消息
function DlgItemTips:unregMsgs(  )
	-- body
end


--暂停方法
function DlgItemTips:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function DlgItemTips:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

--按钮响应
function DlgItemTips:onBtnClicked( pView )
	-- body
	if self._nRightHandler then
		self._nRightHandler()
	end
	self:closeAlertDlg()--关闭对话框
end

--设置物品数据 _itemid-物品配表id
function DlgItemTips:setItemDataById( _itemid , _data)
	self.nRecommonNum = 0
	-- body
	local pitemdata = nil
	if _itemid > 100000 then
		pitemdata = getBaseItemDataByID(_itemid)

	--装备
	elseif _itemid > 2000 and _itemid < 10000 then
		pitemdata = getBaseEquipDataByID(_itemid)
	end

	if pitemdata then		
		self.pCurData= pitemdata
		if _data then
			if _data.tCallback then
				self:setRightHandler(
					function()
						_data.tCallback()
						self:closeAlertDlg()--关闭对话框
				end)
				self:setCloseHandler(_data.tCallback)
				self:setOutSideHandler(
					function()
						_data.tCallback()
						self:closeAlertDlg()--关闭对话框
				end)
			end
			if _data.nRecommonNum then
				self.nRecommonNum = _data.nRecommonNum
			end
		end
		self:updateViews()
	else
		print("设置显示对话框的物品数据错误...")
	end	
end
return DlgItemTips
