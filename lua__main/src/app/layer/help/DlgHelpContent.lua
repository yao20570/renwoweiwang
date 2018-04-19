-----------------------------------------------------
-- author: dshulan
-- updatetime:  2017-05-23 16:01:23 星期二
-- Description: 帮助中心
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")


local DlgHelpContent = class("DlgHelpContent", function()
	-- body
	return DlgBase.new(e_dlg_index.dlghelpcontent)
end)

function DlgHelpContent:ctor(_nId, _nOpenDlgType, _nDlgSecType)
	-- body
	print("DlgHelpContent == ",_nId, _nOpenDlgType, _nDlgSecType)
	self:myInit(_nId, _nOpenDlgType, _nDlgSecType)
	parseView("dlg_help_content", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgHelpContent:myInit(_nId, _nOpenDlgType, _nDlgSecType)
	-- body
	self.nId = _nId or getHelpIdByDlgType(_nOpenDlgType, _nDlgSecType)
	self.tHelpData = nil                -- 帮助内容
end

--解析布局回调事件
function DlgHelpContent:onParseViewCallback( pView )
	-- body
	self:addContentView(pView) --加入内容层
	self:setupViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("DlgHelpContent",handler(self, self.onDlgHelpDestroy))
end

--初始化控件
function DlgHelpContent:setupViews()
	-- body
	self.pLayTop    = self:findViewByName("lay_top")
	self.pLayScroll = self:findViewByName("lay_content")
	--设置标题
	self:setTitle(getConvertedStr(7, 10001))
	--两个按钮
	self.pLayLast = self:findViewByName("lay_btn_last")
	self.pLayNext = self:findViewByName("lay_btn_next")

	self.pBtnLast = getCommonButtonOfContainer(self.pLayLast,TypeCommonBtn.L_BLUE,getConvertedStr(7,10002))
	self.pBtnNext = getCommonButtonOfContainer(self.pLayNext,TypeCommonBtn.L_BLUE,getConvertedStr(7,10003))

	--上一条按钮点击事件
	self.pBtnLast:onCommonBtnClicked(handler(self, self.onLeftClicked))
    --下一条按钮点击事件
	self.pBtnNext:onCommonBtnClicked(handler(self, self.onRightClicked))

	self.tHelpData = getHelpDataById(self.nId)
	self.tHelpAllData = getHelpData()
	self.nMaxId = table.nums(self.tHelpAllData)

	self:createLabels()
	self:setContent()
end

-- 析构方法
function DlgHelpContent:onDlgHelpDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgHelpContent:regMsgs(  )
	-- body
end
--注销消息
function DlgHelpContent:unregMsgs(  )
	-- body	
end

-- 暂停方法
function DlgHelpContent:onPause()
	self:unregMsgs()	
end

--继续方法
function DlgHelpContent:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

function DlgHelpContent:updateViews()
	-- body
	if not self.tHelpData then
		return
	end
	if self.tHelpData.desc then
		self.tLabel:setString(self.tHelpData.desc)
	else
		self.tLabel:setString(self.tHelpData.name)
	end
	self.tLabelContent:removeSelf()
	self:setContent()
end

-- 设置帮助内容
function DlgHelpContent:setContent()
	self.pScrollView = MUI.MScrollLayer.new({
		viewRect = cc.rect(0, 0, self.pLayScroll:getWidth(), self.pLayScroll:getHeight()),
        touchOnContent = false,
        direction = MUI.MScrollLayer.DIRECTION_VERTICAL})
	self.pScrollView:setBounceable(true)
	self.pLayScroll:addView(self.pScrollView)

	self:createContentLable()
end

-- 创建内容纯文本
function DlgHelpContent:createContentLable()
	self.tLabelContent = MUI.MLabel.new({
        text = self.tHelpData.content,
        size = 25,
        anchorpoint = cc.p(0.5, 0.5),
        dimensions = cc.size(580, 0),
        })
    -- self.tLabelContent:setPosition(self.pLayTop:getWidth()/2, self.pLayTop:getHeight())
    setTextCCColor(self.tLabelContent, _cc.pwhite)
    self.tLabelContent:setViewTouched(false)
    self.pScrollView:addView(self.tLabelContent)
end

function DlgHelpContent:createLabels()
	-- body
	self.tLabel = MUI.MLabel.new({
    text = "",
    size = 25,
    anchorpoint = cc.p(0, 0.5)})
    self.tLabel:setPosition(self.pLayTop:getPositionX(), self.pLayTop:getHeight()/2)
    setTextCCColor(self.tLabel, _cc.pwhite)
    self.pLayTop:addView(self.tLabel)    
end

--左边按钮点击事件
function DlgHelpContent:onLeftClicked( pView )
	-- body
	self.nId = self.nId - 1
	if self.nId <= 0 then
		TOAST(getConvertedStr(7, 10055))
		self.nId = 1
	end
	self.tHelpData = getHelpDataById(self.nId)
	self:updateViews()
end

--右边按钮点击事件
function DlgHelpContent:onRightClicked( pView )
	-- body
	self.nId = self.nId + 1
	if self.nId > self.nMaxId then
		TOAST(getConvertedStr(7, 10056))
		self.nId = self.nMaxId
	end
	self.tHelpData = getHelpDataById(self.nId)
	self:updateViews()
end

return DlgHelpContent