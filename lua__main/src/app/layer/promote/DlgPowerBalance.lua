-----------------------------------------------------
-- author: maheng
-- updatetime:  2018-1-31 20:45:55 星期三
-- Description: 战力对比对话框
-----------------------------------------------------
local DlgAlert = require("app.common.dialog.DlgAlert")

local DlgPowerBalance = class("DlgPowerBalance", function ()
	return DlgAlert.new(e_dlg_index.dlgpowermark)
end)

--战力类型
local e_power_type  = {
	[1]				= getConvertedStr(7, 10305),	  --总战力
	[2]				= getConvertedStr(7, 10247),  --武将战力
	[3]				= getConvertedStr(6, 10124),  --装备战力
	[4]				= getConvertedStr(6, 10746),  --科技战力
	[5]				= getConvertedStr(7, 10009),  --神兵战力
	[6]				= getConvertedStr(6, 10748),  --爵位战力
}

--构造
--_bFromShare:是否从聊天分享弹过来的
function DlgPowerBalance:ctor(_playerId, _sName, _nLv)
	-- body
	self.nPlayerId = _playerId
	self.sPlayerName = _sName
	self.nPlayerLv = _nLv
	self.tData = nil	
	parseView("layout_power_balance", handler(self, self.onParseViewCallback))
end
  
--解析布局回调事件
function DlgPowerBalance:onParseViewCallback( pView )
	-- body
	self:addContentView(pView, false)
	self:setupViews()
	self:onResume()
	 --注册析构方法
    self:setDestroyHandler("DlgPowerBalance",handler(self, self.onDestroy))
end

--初始化控件
function DlgPowerBalance:setupViews()
	-- body
	--设置标题
	self:setTitle(getConvertedStr(6, 10745))
	self.pLayRoot = self:findViewByName("layout_power_balance")
	self.pLbPar1 = self:findViewByName("lb_par_1")
	setTextCCColor(self.pLbPar1, _cc.red)
	self.pLbPar2 = self:findViewByName("lb_par_2")
	setTextCCColor(self.pLbPar2, _cc.blue)
	self.pImgTip = self:findViewByName("img_bg") 
	
	self.tLabels = {}
	for i = 1, 6 do
		self.tLabels[i] = self:createLabels(i)
	end
end

--根据行数创建标签
function DlgPowerBalance:createLabels( _nRow )
	-- body
	local nY = self.pImgTip:getPositionY()
	nY = nY - (_nRow - 1)*40
	local tTip = {}
	local pLbPar1 = MUI.MLabel.new({
	    text = "",
	    size = 20,
	    anchorpoint = cc.p(0.5, 0.5),
	    align = cc.ui.TEXT_ALIGN_CENTER,
		valign = cc.ui.TEXT_VALIGN_CENTER,
	    color = cc.c3b(255, 255, 255)
	})
	pLbPar1:setPosition(55, nY)
	self.pLayRoot:addView(pLbPar1, 10)
	if i == 1 then
		setTextCCColor(pLbPar1, _cc.blue)
	else
		setTextCCColor(pLbPar1, _cc.pwhite)
	end
	tTip.pLb1 = pLbPar1

	local pLbPar2 = MUI.MLabel.new({
	    text = e_power_type[_nRow],
	    size = 20,
	    anchorpoint = cc.p(0.5, 0.5),
	    align = cc.ui.TEXT_ALIGN_CENTER,
		valign = cc.ui.TEXT_VALIGN_CENTER,
	    color = cc.c3b(255, 255, 255)
	})
	pLbPar2:setPosition(160, nY)
	self.pLayRoot:addView(pLbPar2, 10)
	if i == 1 then
		setTextCCColor(pLbPar2, _cc.blue)
	else
		setTextCCColor(pLbPar2, _cc.pwhite)
	end
	tTip.pLb2 = pLbPar2

	local pLbPar3 = MUI.MLabel.new({
	    text = "",
	    size = 20,
	    anchorpoint = cc.p(0.5, 0.5),
	    align = cc.ui.TEXT_ALIGN_CENTER,
		valign = cc.ui.TEXT_VALIGN_CENTER,
	    color = cc.c3b(255, 255, 255)
	})
	pLbPar3:setPosition(280, nY)
	self.pLayRoot:addView(pLbPar3, 10)
	if i == 1 then
		setTextCCColor(pLbPar3, _cc.blue)
	else
		setTextCCColor(pLbPar3, _cc.pwhite)
	end
	tTip.pLb3 = pLbPar3	

	local pLbPar4 = MUI.MLabel.new({
	    text = "",
	    size = 20,
	    anchorpoint = cc.p(0.5, 0.5),
	    align = cc.ui.TEXT_ALIGN_CENTER,
		valign = cc.ui.TEXT_VALIGN_CENTER,
	    color = cc.c3b(255, 255, 255)
	})
	pLbPar4:setPosition(375, nY)
	self.pLayRoot:addView(pLbPar4, 10)
	tTip.pLb4 = pLbPar4	

	local pImgArrow = MUI.MImage.new("#v1_img_xiangshangjiantou.png")	
	pImgArrow:setPosition(450, nY)
	self.pLayRoot:addView(pImgArrow, 10)
	tTip.pArrow = pImgArrow
	return tTip
end

-- 修改控件内容或者是刷新控件数据
function DlgPowerBalance:updateViews()
	-- body
	if self.tData == nil then
		return
	end
	self.pLbPar1:setString(self.tData.rn..getLvString(self.tData.rl, false), false)	
	self.pLbPar2:setString(self.tData.bn..getLvString(self.tData.bl, false), false)
	--红方
	local tRs = self.tData.rs
	local tBs = self.tData.bs
	--总战力
	local tLabels = self.tLabels[1]
	tLabels.pLb1:setString(tRs.t)	
	tLabels.pLb3:setString(tBs.t)
	tLabels.pLb4:setString(math.abs(tRs.t - tBs.t), false)
	if tRs.t - tBs.t < 0 then
		setTextCCColor(tLabels.pLb4, _cc.blue)
		tLabels.pArrow:setCurrentImage("#v1_img_xiangshangjiantou.png")
	elseif tRs.t - tBs.t > 0 then
		setTextCCColor(tLabels.pLb4, _cc.red)
		tLabels.pArrow:setCurrentImage("#v1_img_xiangxiajiantou.png")
	else
		setTextCCColor(tLabels.pLb4, _cc.pwhite)
	end
	tLabels.pArrow:setVisible(tRs.t ~= tBs.t)
	setTextCCColor(tLabels.pLb1, _cc.blue)	
	setTextCCColor(tLabels.pLb2, _cc.blue)	
	setTextCCColor(tLabels.pLb3, _cc.blue)	
	--武将
	local tLabels = self.tLabels[2]
	tLabels.pLb1:setString(tRs.h)
	tLabels.pLb3:setString(tBs.h)
	tLabels.pLb4:setString(math.abs(tRs.h - tBs.h), false)
	if tRs.h - tBs.h < 0 then
		setTextCCColor(tLabels.pLb4, _cc.blue)
		tLabels.pArrow:setCurrentImage("#v1_img_xiangshangjiantou.png")
	elseif tRs.h - tBs.h > 0 then
		setTextCCColor(tLabels.pLb4, _cc.red)
		tLabels.pArrow:setCurrentImage("#v1_img_xiangxiajiantou.png")
	else
		setTextCCColor(tLabels.pLb4, _cc.pwhite)		
	end	
	tLabels.pArrow:setVisible(tRs.h ~= tBs.h)
	--装备
	local tLabels = self.tLabels[3]
	tLabels.pLb1:setString(tRs.e)
	tLabels.pLb3:setString(tBs.e)
	tLabels.pLb4:setString(math.abs(tRs.e - tBs.e), false)
	if tRs.e - tBs.e < 0 then
		setTextCCColor(tLabels.pLb4, _cc.blue)
		tLabels.pArrow:setCurrentImage("#v1_img_xiangshangjiantou.png")
	elseif tRs.e - tBs.e > 0 then
		setTextCCColor(tLabels.pLb4, _cc.red)
		tLabels.pArrow:setCurrentImage("#v1_img_xiangxiajiantou.png")
	else
		setTextCCColor(tLabels.pLb4, _cc.pwhite)		
	end	
	tLabels.pArrow:setVisible(tRs.e ~= tBs.e)
	--科技
	local tLabels = self.tLabels[4]
	tLabels.pLb1:setString(tRs.s)
	tLabels.pLb3:setString(tBs.s)
	tLabels.pLb4:setString(math.abs(tRs.s - tBs.s), false)
	if tRs.s - tBs.s < 0 then
		setTextCCColor(tLabels.pLb4, _cc.blue)
		tLabels.pArrow:setCurrentImage("#v1_img_xiangshangjiantou.png")
	elseif tRs.s - tBs.s > 0 then
		setTextCCColor(tLabels.pLb4, _cc.red)
		tLabels.pArrow:setCurrentImage("#v1_img_xiangxiajiantou.png")
	else
		setTextCCColor(tLabels.pLb4, _cc.pwhite)		
	end	
	tLabels.pArrow:setVisible(tRs.s ~= tBs.s)
	--神兵
	local tLabels = self.tLabels[5]
	tLabels.pLb1:setString(tRs.a)
	tLabels.pLb3:setString(tBs.a)
	tLabels.pLb4:setString(math.abs(tRs.a - tBs.a), false)
	if tRs.a - tBs.a < 0 then
		setTextCCColor(tLabels.pLb4, _cc.blue)
		tLabels.pArrow:setCurrentImage("#v1_img_xiangshangjiantou.png")
	elseif tRs.a - tBs.a > 0 then
		setTextCCColor(tLabels.pLb4, _cc.red)
		tLabels.pArrow:setCurrentImage("#v1_img_xiangxiajiantou.png")
	else
		setTextCCColor(tLabels.pLb4, _cc.pwhite)		
	end	
	tLabels.pArrow:setVisible(tRs.a ~= tBs.a)
	--爵位
	local tLabels = self.tLabels[6]
	tLabels.pLb1:setString(tRs.b)
	tLabels.pLb3:setString(tBs.b)
	tLabels.pLb4:setString(math.abs(tRs.b - tBs.b), false)
	if tRs.b - tBs.b < 0 then
		setTextCCColor(tLabels.pLb4, _cc.blue)
		tLabels.pArrow:setCurrentImage("#v1_img_xiangshangjiantou.png")
	elseif tRs.b - tBs.b > 0 then
		setTextCCColor(tLabels.pLb4, _cc.red)
		tLabels.pArrow:setCurrentImage("#v1_img_xiangxiajiantou.png")
	else
		setTextCCColor(tLabels.pLb4, _cc.pwhite)		
	end	
	tLabels.pArrow:setVisible(tRs.b ~= tBs.b)		
end

function DlgPowerBalance:setCurData( _tData )
	-- body
	self.tData = _tData
	self:updateViews()
end

--析构方法
function DlgPowerBalance:onDestroy()
	self:onPause()
end

-- 注册消息
function DlgPowerBalance:regMsgs( )
	-- body
end

-- 注销消息
function DlgPowerBalance:unregMsgs(  )
	-- body
end


--暂停方法
function DlgPowerBalance:onPause( )
	-- body
	self:unregMsgs()

end

--继续方法
function DlgPowerBalance:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end



return DlgPowerBalance
