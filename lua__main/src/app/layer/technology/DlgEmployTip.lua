---------------------------------------------
-- Author: dshulan
-- Date: 2017-11-7 15:40:00
-- 科技院正在升级且已买vip5礼包时雇佣提示对话框
---------------------------------------------

local DlgAlert = require("app.common.dialog.DlgAlert")
local DlgEmployTip = class("DlgEmployTip", function ()
	return DlgAlert.new(e_dlg_index.dlgemploytip)
end)

--构造
function DlgEmployTip:ctor(_nTipIdx)
	-- body
	self:myInit(_nTipIdx)
	parseView("lay_vip_good_tip", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgEmployTip:myInit(_nTipIdx)
	-- body
	self.nTipIdx = _nTipIdx
end
  
--解析布局回调事件
function DlgEmployTip:onParseViewCallback( pView )
	-- body
	self:addContentView(pView, true)
	self:setupViews()
	self:onResume()
	--注册析构方法
    self:setDestroyHandler("DlgEmployTip",handler(self, self.onDlgEmployTipDestroy))
end


--初始化控件
function DlgEmployTip:setupViews()
	-- body
	--设置标题
	self:setTitle(getConvertedStr(3, 10091))

	self.pLayRoot 	= self:findViewByName("lay_def")
	self.pLayIcon 	= self:findViewByName("lay_icon")

	self.pLayIcon:setPosition(self.pLayIcon:getPositionX() + 10, self.pLayIcon:getPositionY() + 25)

	--紫色研究员头像
	self.pIcon = getIconHeroByType(self.pLayIcon, TypeIconHero.NORMAL, nil, TypeIconHeroSize.M)
	self.pIcon:setIconIsCanTouched(false)
	local tData = {}
	tData.sIcon = "#yanjiuyuan2.png"
	tData.nQuality = 4
	self.pIcon:setCurData(tData)

	--提示
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

	self.pLbTip:setString(getTipsByIndex(self.nTipIdx))

	
	self:setRightBtnText(getConvertedStr(7, 10221))
	self:setRightBtnType(TypeCommonBtn.L_BLUE)
	--右边按钮点击事件
	self:setRightHandler(function ()
		-- body
		local nBuildLv = Player:getBuildData():getBuildById(e_build_ids.tnoly).nLv
		local nLimitLv = getResearcherLimit()
		if nBuildLv < nLimitLv then --雇佣还未开启
			local str = string.format(getTipsByIndex(10029), nLimitLv)
			TOAST(str)
			return
		end
		--跳转到雇佣窗口
		local tObject = {}
		tObject.nType = e_dlg_index.civilemploy --dlg类型
		tObject.nEmployType = e_hire_type.researcher
		sendMsg(ghd_show_dlg_by_type, tObject)
		
		closeDlgByType(e_dlg_index.dlgemploytip)
	end)
end

--析构方法
function DlgEmployTip:onDlgEmployTipDestroy()
	self:onPause()
end

-- 注册消息
function DlgEmployTip:regMsgs( )
	-- body
end

-- 注销消息
function DlgEmployTip:unregMsgs(  )
	-- body
end


--暂停方法
function DlgEmployTip:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function DlgEmployTip:onResume( )
	-- body
	self:regMsgs()
end

return DlgEmployTip
