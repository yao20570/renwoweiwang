-- NoticeItem.lua
-----------------------------------------------------
-- author: dshulan
-- updatetime:  2017-05-26 14:01:23 星期五
-- Description: 公告单项层
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")

local NoticeItem = class("NoticeItem", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function NoticeItem:ctor(_index)
	-- body	
	self:myInit(_index)	
	parseView("notice_item", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function NoticeItem:myInit(_index)
	-- body
	self.idx = _index
	self.tCurData  = nil 				--当前数据
	self.tShowCont = nil                --显示的公告内容
end

--解析布局回调事件
function NoticeItem:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("NoticeItem",handler(self, self.onNoticeItemDestroy))
end

--初始化控件
function NoticeItem:setupViews()
	-- body
	self.pLayRoot    = self:findViewByName("default")
	self.pTTitle     = self:findViewByName("txt_title")
	self.pTSignal    = self:findViewByName("txt_signal")
	self.pImgSignal  = self:findViewByName("img_r_signal")
	self.pLayContent = self:findViewByName("lay_gg_content")
	self.pTContent   = self:findViewByName("txt_content")
	self.pTMore      = self:findViewByName("txt_more")
	self.pTMore:setVisible(false)
	self:setIsPressedNeedScale(false)
	self:setIsPressedNeedColor(false)

end

-- 修改控件内容或者是刷新控件数据
function NoticeItem:updateViews()
	if not self.tCurData then return end
	self.pTTitle:setString(self.tCurData.sTitle)
	setTextCCColor(self.pTTitle, _cc.blue)	
	local sNewContent = luaSplit(self.tCurData.sContent,"\\n") --用换行符截取
	local str
	if sNewContent[2] then
		str = sNewContent[2]
	else
		str = self.tCurData.sContent
	end
	local nStrLen = string.utf8len(str)
	if nStrLen > 42 then
		self.tShowCont = SubUTF8String(str, 126)
	elseif nStrLen < 28 then --如果字数不超过一行, 就在14个字的长度截取
		self.tShowCont = SubUTF8String(str, 42)
	else
		self.tShowCont = str
	end
	
	self.pTContent:setString(self.tShowCont.."...",false)
	
	-- self.pTMore:setString(getConvertedStr(7, 10008))
	-- self.pTMore:setViewTouched(true)
	-- self.pTMore:setIsPressedNeedScale(false)
	-- self.pTMore:onMViewClicked(function()
	-- 	-- body
	-- 	local tObject = {}
	-- 	tObject.nType = e_dlg_index.dlgnoticecontent --dlg类型
	-- 	tObject.nId   = self.idx                     --下标
	-- 	sendMsg(ghd_show_dlg_by_type,tObject)
	-- 	SocketManager:sendMsg("reqReadNoticeData", {self.tCurData.nNoticeId, self.tCurData.nVersion})
	-- end)
	-- setTextCCColor(self.pTMore, _cc.green)
	self:setIconBgToGray(self.tCurData.bHasRead)

	--重新设置位置
	self.pTContent:updateTexture()
	-- self.pTMore:setPositionX(self.pTContent:getPositionX() + 400)  --14个字的长度（长度*字体大小） + ...的长度—— 就是一行中的中间多一点
	-- self.pTMore:updateTexture()
	-- self.pTMore:setAnchorPoint(cc.p(0, 1))
	-- --一行显示28个字
	-- if string.utf8len(self.pTContent:getString()) > 28 then  --行数大于1
	-- 	self.pTMore:setPositionY(self.pTContent:getPositionY() - 40 )  --32是self.pTContent高度的一半

	-- else
	-- 	self.pTMore:setPositionY(self.pTContent:getPositionY() - 2)
	-- end
	
	
end

-- 析构方法
function NoticeItem:onNoticeItemDestroy()
	-- body
end

-- 设置单项数据
function NoticeItem:setItemData(_data)
	self.tCurData = _data
	self:updateViews()
end

-- 创建内容文本和"查看详情"文本
function NoticeItem:createContentLabels()
	local tConLabel = MUI.MLabel.new({
	text = "",
    size = 20,
    anchorpoint = cc.p(0, 0),
    dimensions = cc.size(580, 0),})
    self.pLayContent:setAnchorPoint(cc.p(0, 0.5))
    self.pLayContent:addView(tConLabel)
    local tConShow = SubUTF8String(tContent, 99)
    tConLabel:setString(tConShow)

    -- 查看详情
    local tMoreLabel = MUI.MLabel.new({
	text = "",
    size = 20,
    anchorpoint = cc.p(0, 0)})
    self.pLayContent:addView(tMoreLabel)
end

-- 设置右上角图片高亮和置灰
function NoticeItem:setIconBgToGray(_bHasRead)
	-- body
	self.pImgSignal:setToGray(_bHasRead)
	self:setSignalTxt(_bHasRead)
end

-- 设置右上角标签文本
function NoticeItem:setSignalTxt(_bHasRead)
	-- body
	if _bHasRead then
		self.pTSignal:setString(getConvertedStr(7, 10007))
	else
		self.pTSignal:setString(getConvertedStr(7, 10006))
	end
end

-- 设置标题文本
function NoticeItem:createTitleLabel()
	-- body
	self.tLabel = MUI.MLabel.new({
    text = "公告标题",
    size = 22,
    anchorpoint = cc.p(0, 0)})
    setTextCCColor(self.tLabel, _cc.blue)
    -- self.tLabel:setPositionY(self.tLabel:getPositionY() + self.pLayTitle:getWidth()/2-5)
    self.pLayTitle:addView(self.tLabel)    
end

return NoticeItem
