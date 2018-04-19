-- DlgSpeedUpAdvance.lua
-----------------------------------------------------
-- author: dshulan
-- updatetime:  2017-06-06 19:59:10 星期二
-- Description: 加速生产对话框
-----------------------------------------------------


local DlgAlert = require("app.common.dialog.DlgAlert")

local DlgSpeedUpAdvance = class("DlgSpeedUpAdvance", function ()
	return DlgAlert.new(e_dlg_index.dlgspeedupadvance)
end)

--构造
function DlgSpeedUpAdvance:ctor(_money, _speedType, _weaponId)
	-- body
	self:myInit(_money, _speedType, _weaponId)
end

--初始化成员变量
function DlgSpeedUpAdvance:myInit(_money, _speedType, _weaponId)
	-- body
	self.nCostMoney = _money or 500
	self.nSpeedType = _speedType
	self.nWeaponId  = _weaponId
	self:setupViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("DlgSpeedUpAdvance",handler(self, self.onDlgSpeedUpDestroy))
end

--解析布局回调事件
function DlgSpeedUpAdvance:onParseViewCallback( pView )
	-- body
end

--初始化控件
function DlgSpeedUpAdvance:setupViews()
	-- body
	--设置标题
	self:setTitle(getConvertedStr(7, 10034))

	--设置提示文本
	local tConTableTip = {}
	local tSpeedTxt = getConvertedStr(7, 10037)
	--加速进阶
	if self.nSpeedType == e_cd_type.advance then
		tSpeedTxt = getConvertedStr(7, 10058)
	end
	tConTableTip.tLabel = {
		{getConvertedStr(7, 10035), getC3B(_cc.pwhite)},
		{self.nCostMoney..getConvertedStr(7, 10036), getC3B(_cc.yellow)},
		{tSpeedTxt, getC3B(_cc.pwhite)},
	}
	local pTextTip = createGroupText(tConTableTip)
	pTextTip:setAnchorPoint(0.5, 0.5)

	local pContentLayer = MUI.MLayer.new()
	pContentLayer:setLayoutSize(450, 210)
	pContentLayer:addView(pTextTip, 10)
	pTextTip:setPosition(pContentLayer:getWidth()/2, pContentLayer:getHeight()/2)

	self.pLayContent:addView(pContentLayer, 10)

	--设置右边按钮的按钮事件
	self:setRightHandler(handler(self, self.onBtnRightClicked))
end

function DlgSpeedUpAdvance:updateViews()
	-- body
	
end

-- 析构方法
function DlgSpeedUpAdvance:onDlgSpeedUpDestroy(  )
	-- body
	self:onPause()
end

-- 右边按钮点击事件
function DlgSpeedUpAdvance:onBtnRightClicked()
	-- body
	if Player:getPlayerInfo().nMoney >= self.nCostMoney then
		-- body
		if not self.nWeaponId then return end
		if self.nSpeedType == e_cd_type.build then          --请求加速打造
			SocketManager:sendMsg("reqSpeedBuilding", {self.nWeaponId}, handler(self, self.speedBuildCallBack))
		elseif self.nSpeedType == e_cd_type.advance then      --请求加速进阶
			SocketManager:sendMsg("reqSpeedAdvance", {self.nWeaponId}, handler(self, self.speedAdvanceCallBack))
		end
		
	else
		local tObject = {}
		tObject.nType = e_dlg_index.dlgrechargetip --dlg类型
		sendMsg(ghd_show_dlg_by_type,tObject)   
		self:closeAlertDlg()
	end
end

--请求加速打造回调
function DlgSpeedUpAdvance:speedBuildCallBack( __msg)
	self:closeAlertDlg()
end

--请求加速进阶回调(播放进阶成功特效)
function DlgSpeedUpAdvance:speedAdvanceCallBack()
	-- body
	-- TOAST("进阶成功")
	self:closeAlertDlg()
end

--注册消息
function DlgSpeedUpAdvance:regMsgs(  )
	-- body
end
--注销消息
function DlgSpeedUpAdvance:unregMsgs(  )
	-- body	
end

-- 暂停方法
function DlgSpeedUpAdvance:onPause()
	self:unregMsgs()	
end

--继续方法
function DlgSpeedUpAdvance:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end


return DlgSpeedUpAdvance