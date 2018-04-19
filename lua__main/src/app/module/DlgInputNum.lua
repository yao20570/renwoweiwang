-----------------------------------------------------
-- author: maheng
-- updatetime:  2018-1-30 14:41:23 星期二
-- Description: 数字输入
-----------------------------------------------------

local MDialog = require("app.common.dialog.MDialog")
local RichText = require("app.common.richview.RichText")
local DlgInputNum = class("DlgInputNum", function()
	-- body
	return MDialog.new(e_dlg_index.inputnum)
end)

function DlgInputNum:ctor(  _nSelect, _nMaxNum  )
	-- body
	self:myInit( _nSelect, _nMaxNum )
	parseView("dlg_input_num", handler(self, self.onParseViewCallback))
	self:setName(UIAction.TAG_SMALL_DLG)
end

function DlgInputNum:myInit(  _nSelect, _nMaxNum  )
	-- body
	self.nSelect = _nSelect or 1
	self.nMaxNum = _nMaxNum or 1
	self.sNum = tonumber(self.nSelect)
end

--解析布局回调事件
function DlgInputNum:onParseViewCallback( pView )
	-- body
	self:setContentView(pView) --加入内容层
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgInputNum",handler(self, self.onDestroy))
end

--初始化控件
function DlgInputNum:setupViews(  )
	--body	
	self.pLayRoot = self:findViewByName("root")

	self.pLayTop = self:findViewByName("lay_top")

	self.pLbTitle = self:findViewByName("lb_title")
	self.pLbTitle:setString(getConvertedStr(6, 10742))	

	self.pLbCurNum = self:findViewByName("lb_cur_num")
	self.pLbCurNum:setString(self.nSelect)
	self.pLayClose = self:findViewByName("lay_close")
	self.pLayClose:setViewTouched(true)
	self.pLayClose:onMViewClicked(handler(self, self.closeDlg))
	self.pLayClose:setIsPressedNeedScale(false)
	self.pLayClose:setIsPressedNeedColor(false)	

	self.pLayCancel = self:findViewByName("lay_cancel")
	self.pLayCancel:setViewTouched(true)
	self.pLayCancel:onMViewClicked(handler(self, self.onBtnCancelClicked))
	self.pLayCancel:setIsPressedNeedScale(false)

	local pLbCancel = MUI.MLabel.new({
	    text = getConvertedStr(3, 10161),
	    size = 20,
	    anchorpoint = cc.p(0.5, 0.5),
	    align = cc.ui.TEXT_ALIGN_CENTER,
		valign = cc.ui.TEXT_VALIGN_CENTER,
	    color = cc.c3b(255, 255, 255),
	})
	pLbCancel:setPosition(self.pLayCancel:getWidth()/2, self.pLayCancel:getHeight()/2)
	self.pLayCancel:addView(pLbCancel, 10)	

	self.pLaySure = self:findViewByName("lay_sure")
	self.pLaySure:setViewTouched(true)
	self.pLaySure:onMViewClicked(handler(self, self.onBtnSureClicked))
	self.pLaySure:setIsPressedNeedScale(false)

	local pLbSure = MUI.MLabel.new({
	    text = getConvertedStr(6, 10106),
	    size = 20,
	    anchorpoint = cc.p(0.5, 0.5),
	    align = cc.ui.TEXT_ALIGN_CENTER,
		valign = cc.ui.TEXT_VALIGN_CENTER,
	    color = cc.c3b(255, 255, 255),
	})
	pLbSure:setPosition(self.pLaySure:getWidth()/2, self.pLaySure:getHeight()/2)
	self.pLaySure:addView(pLbSure, 10)

	for i = 0, 9 do
		local pLayNum = self:findViewByName("lay_num_"..i)
		pLayNum:setViewTouched(true)
		local pLbNum = MUI.MLabel.new({
		    text = i,
		    size = 20,
		    anchorpoint = cc.p(0.5, 0.5),
		    align = cc.ui.TEXT_ALIGN_CENTER,
    		valign = cc.ui.TEXT_VALIGN_CENTER,
		    color = cc.c3b(255, 255, 255),
		})
		pLbNum:setPosition(pLayNum:getWidth()/2, pLayNum:getHeight()/2)
		pLayNum:addView(pLbNum, 10)
		pLayNum:onMViewClicked(function (  )
			-- body
			self:onBtnNumClicked(i)
		end)
		pLayNum:setIsPressedNeedScale(false)
	end
	
end

--控件刷新
function DlgInputNum:updateViews(  )
	-- body	

end

function DlgInputNum:onBtnNumClicked( _nNum )
	-- body	
	local sCurNum = self.sNum
	sCurNum = sCurNum.._nNum
	local nCurNum = tonumber(sCurNum)
	if nCurNum <= self.nMaxNum then
		self.sNum = sCurNum
		self.pLbCurNum:setString(self.sNum)
	else
		TOAST(string.format(getConvertedStr(6, 10743), self.nMaxNum))
	end
end

--删除
function DlgInputNum:onBtnCancelClicked(  )
	-- body
	print("删除按钮")
	self.sNum = ""
	self.pLbCurNum:setString(self.sNum)
end

--确定
function DlgInputNum:onBtnSureClicked(  )
	-- body
	print("确定按钮")
	local nCurNum = tonumber(self.sNum)
	if nCurNum == nil or nCurNum == 0 then
		TOAST(getConvertedStr(7, 10348))
		return
	end
	if nCurNum > 0 and nCurNum <= self.nMaxNum then
		sendMsg(ghd_inputnum_setting_num_msg, nCurNum)
		self:closeDlg()
	end 
end

--设置
function DlgInputNum:setNumMaxLimit( _nSelect, _nMaxNum )
	-- body
	self.nSelect = _nSelect or 1
	self.nMaxNum = _nMaxNum or 1
	self.sNum = tonumber(self.nSelect)
	self.pLbCurNum:setString(self.nSelect)
end

--析构方法
function DlgInputNum:onDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgInputNum:regMsgs(  )
	-- body
	--活动数据刷新
	--regMsg(self, gud_refresh_activity, handler(self, self.updateViews))	
end
--注销消息
function DlgInputNum:unregMsgs(  )
	-- body
	--注销活动数据刷新
	--unregMsg(self, gud_refresh_activity)
end

--暂停方法
function DlgInputNum:onPause( )
	-- body
	self:unregMsgs()	
end

--继续方法
function DlgInputNum:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

return DlgInputNum