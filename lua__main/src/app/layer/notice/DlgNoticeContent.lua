-- DlgNoticeContent.lua
-----------------------------------------------------
-- author: dshulan
-- updatetime:  2017-05-26 14:01:23 星期五
-- Description: 公告内容窗口
-----------------------------------------------------

local DlgCommon = require("app.common.dialog.DlgCommon")

local DlgNoticeContent = class("DlgNoticeContent", function ()
	return DlgCommon.new(e_dlg_index.dlgnoticecontent)
end)

--构造
function DlgNoticeContent:ctor(_nId)
	-- body
	self:myInit(_nId)
	-- parseView("dlg_help_content", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgNoticeContent:myInit(_nId)
	-- body
	self.nId = _nId                 -- 下标
	self:setupViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("DlgNoticeContent",handler(self, self.onDlgNoticeDestroy))
end

--解析布局回调事件
function DlgNoticeContent:onParseViewCallback( pView )
	-- body
	-- self:addContentView(pView, true) --加入内容层
	-- self:setupViews()
	-- self:onResume()
	-- --注册析构方法
	-- self:setDestroyHandler("DlgNoticeContent",handler(self, self.onDlgNoticeDestroy))
end

--初始化控件
function DlgNoticeContent:setupViews()
	-- body
	--公告数据
	local tNoticeMsgList = Player:getNoticeData():getNoticeMsgList()
	self.tNoticeInfo = tNoticeMsgList[self.nId]
	--设置标题
	self:setTitle(self.tNoticeInfo.sTitle)

end

function DlgNoticeContent:updateViews()
	-- body
	local pTmpLayer = MUI.MLayer.new()
	pTmpLayer:setLayoutSize(488, 20)
	self:addContentView(pTmpLayer, true)

	local pContentLayer = MUI.MLayer.new()
	pContentLayer:setBackgroundImage("#v1_bg_kelashen.png",{scale9 = true,capInsets=cc.rect(22,22, 1, 1)})

	local pTimeLabel = nil

	-- if self.tNoticeInfo.nStartTime > 0 then
	-- 	--公告展示开始时间
	-- 	local sStartTime = formatTimeYMD(self.tNoticeInfo.nStartTime)
	-- 	--公告展示结束时间
	-- 	local sEndTime = formatTimeYMD(self.tNoticeInfo.nEndTime)
	-- 	-- 创建两个label
	-- 	pTimeLabel = MUI.MLabel.new({
	-- 		text = sStartTime..getConvertedStr(7,10033)..sEndTime,
	-- 		size = 22,
	-- 		-- anchorPoint = cc.p(0, 1),
	-- 		color = getC3B(_cc.blue),
	-- 	})
	-- end
	local tStr =self.tNoticeInfo.sContent-- getTextColorByConfigure(self.tNoticeInfo.sContent)
	-- tStr = "<font color='#f5d93d'>2018年1月22日9点</font>开启新服S16_绝世双艳，这个天下，等着你来征服！"
	-- print(tStr)
	-- tStr="<font color='#44cfca'>本次更新奏折，还请主公查阅</font>"
	local pDetailLabel = MUI.MLabel.new({
		text = "",
		size = 20,
		anchorpoint = cc.p(0, 1),
		-- color = getC3B(_cc.pwhite),
		dimensions = cc.size(465, 0),
		})

	pDetailLabel:setString(tStr, false)

	-- if pTimeLabel then
	-- 	local nConHeight = pTimeLabel:getHeight()*2 + pDetailLabel:getHeight() + 120
	-- 	pContentLayer:setLayoutSize(488, nConHeight)
	-- 	pContentLayer:addView(pTimeLabel)
	-- 	pTimeLabel:setPosition(244, pTimeLabel:getPositionY() + nConHeight - pTimeLabel:getHeight())
	-- 	pContentLayer:addView(pDetailLabel)
	-- 	pDetailLabel:setPosition(10, pTimeLabel:getPositionY() - pTimeLabel:getHeight())
	-- else
		local nConHeight = pDetailLabel:getHeight() + 120
		pContentLayer:setLayoutSize(488, nConHeight)
		pContentLayer:addView(pDetailLabel)
		pDetailLabel:setPosition(10, nConHeight - 15)
	-- end

	self:addContentView( pContentLayer, true )

	self:setOnlyConfirm(getConvertedStr(7,10004))
end

-- 析构方法
function DlgNoticeContent:onDlgNoticeDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgNoticeContent:regMsgs(  )
	-- body
end
--注销消息
function DlgNoticeContent:unregMsgs(  )
	-- body	
end

-- 暂停方法
function DlgNoticeContent:onPause()
	self:unregMsgs()	
end

--继续方法
function DlgNoticeContent:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end


return DlgNoticeContent