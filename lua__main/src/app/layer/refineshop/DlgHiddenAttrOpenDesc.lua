----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-06-05 14:54:38
-- Description: 隐藏属性打开说明
-----------------------------------------------------
local MDialog = require("app.common.dialog.MDialog")
local DlgGetReward = require("app.module.DlgGetReward")

local DlgHiddenAttrOpenDesc = class("DlgHiddenAttrOpenDesc", function()
	-- body
	return MDialog.new(e_dlg_index.hiddenattropendesc)
end)

function DlgHiddenAttrOpenDesc:ctor(  )
	parseView("dlg_hidden_attr_open_desc", handler(self, self.onParseViewCallback))
	self:setName(UIAction.TAG_SMALL_DLG)
end

--解析布局回调事件
function DlgHiddenAttrOpenDesc:onParseViewCallback(pView)
	-- body
	self:setContentView(pView) --加入内容层
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgHiddenAttrOpenDesc",handler(self, self.onDlgDlgHiddenAttrOpenDescDestroy))
end


--初始化控件
function DlgHiddenAttrOpenDesc:setupViews(  )
	local pLayView = self:findViewByName("view")
	local pTxtInfo = self:findViewByName("txt_info")

	local pTxtTitle = self:findViewByName("txt_title")
	pTxtTitle:setString(getConvertedStr(3, 10294))
	local pContentLb = MUI.MLabel.new({
		    text = getTipsByIndex(20008),
		    size = 20,
		    anchorpoint = cc.p(0, 1),
		    align = cc.ui.TEXT_ALIGN_LEFT,
			valign = cc.ui.TEXT_VALIGN_TOP,
		    dimensions = cc.size(300, 0),
		})
	pLayView:addView(pContentLb, 2)
	pContentLb:setPosition(pTxtInfo:getPosition())

	local pTxtCloseTip = self:findViewByName("txt_close_tip") --点击屏幕任意位置关闭
	setTextCCColor(pTxtCloseTip, _cc.blue)
	pTxtCloseTip:setString(getConvertedStr(3, 10295))

	--右上角关闭
	local pImgBtnClose = self:findViewByName("img_btn_close")
	pImgBtnClose:setViewTouched(true)
	pImgBtnClose:setIsPressedNeedScale(false)
	pImgBtnClose:onMViewClicked(handler(self, self.closeDlg))
end

--控件刷新
function DlgHiddenAttrOpenDesc:updateViews(  )
end

--析构方法
function DlgHiddenAttrOpenDesc:onDlgDlgHiddenAttrOpenDescDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgHiddenAttrOpenDesc:regMsgs(  )
	-- body

end
--注销消息
function DlgHiddenAttrOpenDesc:unregMsgs(  )
	-- body

end

--暂停方法
function DlgHiddenAttrOpenDesc:onPause( )
	-- body
	self:unregMsgs()	
end

--继续方法
function DlgHiddenAttrOpenDesc:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

return DlgHiddenAttrOpenDesc