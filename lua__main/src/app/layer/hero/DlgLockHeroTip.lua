---------------------------------------------
-- Author: dshulan
-- Date: 2017-08-22 16:36:00
-- 解锁上阵武将提示对话框
---------------------------------------------

local DlgAlert = require("app.common.dialog.DlgAlert")
local DlgLockHeroTip = class("DlgLockHeroTip", function ()
	return DlgAlert.new(e_dlg_index.lockherotip)
end)

--构造
function DlgLockHeroTip:ctor(_tData)
	-- body
	self:myInit(_tData)
	parseView("lay_vip_good_tip", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgLockHeroTip:myInit(_tData)
	-- body
end
  
--解析布局回调事件
function DlgLockHeroTip:onParseViewCallback( pView )
	-- body
	self:addContentView(pView, true)
	self:setupViews()
	self:onResume()
	--注册析构方法
    self:setDestroyHandler("DlgLockHeroTip",handler(self, self.onDlgLockHeroTipDestroy))
end

function DlgLockHeroTip:setShowData(_tData, _sStr)
	-- body
	self.tData = _tData
	self.sStr = _sStr
	self:updateViews()
end

--初始化控件
function DlgLockHeroTip:setupViews()
	-- body
	--设置标题
	self:setTitle(getConvertedStr(3, 10091))

	self.pLayRoot 	= self:findViewByName("lay_def")
	self.pLayIcon 	= self:findViewByName("lay_icon")
	
	self:setRightBtnText(getConvertedStr(7, 10145))
	self:setRightBtnType(TypeCommonBtn.L_BLUE)
	self:setRightHandler(function ()
		-- body
		local tBuildInfo = Player:getBuildData():getBuildByCell(e_build_cell.tnoly)
		if tBuildInfo and tBuildInfo:getIsLocked() then
			local tBuildData = getBuildDatasByTid(e_build_ids.tnoly)
			if tBuildData then
				TOAST(getConvertedStr(7, 10149))
			end
			return
		end
		--跳转到科技树界面
		local tObject = {}
		tObject.nType = e_dlg_index.tnolytree --dlg类型
		tObject.tData = self.tData
		sendMsg(ghd_show_dlg_by_type,tObject)
		
		closeDlgByType(e_dlg_index.lockherotip)
	end)
end

-- 修改控件内容或者是刷新控件数据
function DlgLockHeroTip:updateViews()
	-- body
	if not self.pLbTip then
		self.pLbTip = MUI.MLabel.new({
		    text = "",
		    size = 20,
		    anchorpoint = cc.p(0.5, 0.5),
		    align = cc.ui.TEXT_ALIGN_CENTER,
    		valign = cc.ui.TEXT_VALIGN_CENTER,
		    color = cc.c3b(255, 255, 255),
		    dimensions = cc.size(350, 60),
		})
		self.pLbTip:setPosition(200, 53)
		self.pLayRoot:addView(self.pLbTip, 10)
	end
	self.pLbTip:setString(self.sStr, false)
	if self.tData then
		getIconGoodsByType(self.pLayIcon, TypeIconGoods.HADMORE, type_icongoods_show.item, self.tData)
	end
end

--析构方法
function DlgLockHeroTip:onDlgLockHeroTipDestroy()
	self:onPause()
end

-- 注册消息
function DlgLockHeroTip:regMsgs( )
	-- body
end

-- 注销消息
function DlgLockHeroTip:unregMsgs(  )
	-- body
end


--暂停方法
function DlgLockHeroTip:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function DlgLockHeroTip:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

return DlgLockHeroTip
