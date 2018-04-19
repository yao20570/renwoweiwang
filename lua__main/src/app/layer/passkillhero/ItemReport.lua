----------------------------------------------------- 
-- author: dshulan
-- updatetime: 2018-03-19 15:58:18
-- Description: 过关斩将 战报列表子项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local MailFunc = require("app.layer.mail.MailFunc")

local ItemReport = class("ItemReport", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemReport:ctor(  )
	--解析文件
	parseView("item_mail", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemReport:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)
	self:myInit()
	self:setupViews()
	self:onResume()

	local pTmpLayer = MUI.MLayer.new()
	pTmpLayer:setLayoutSize(pView:getContentSize().width, pView:getContentSize().height)
	self:addView(pTmpLayer, 10000)

	pTmpLayer:setViewTouched(true)
	pTmpLayer:setIsPressedNeedScale(false)
	pTmpLayer:setIsPressedNeedColor(true)
	pTmpLayer:onMViewClicked(handler(self, self.onMailDetailClicked))

	--注册析构方法
	self:setDestroyHandler("ItemReport", handler(self, self.onItemReportDestroy))
end

-- 析构方法
function ItemReport:onItemReportDestroy(  )
    self:onPause()
end

function ItemReport:regMsgs(  )
end

function ItemReport:unregMsgs(  )
end

function ItemReport:onResume(  )
	self:regMsgs()
end

function ItemReport:onPause(  )
	self:unregMsgs()
end

function ItemReport:setupViews(  )
	self.pTxtTitle = self:findViewByName("txt_title")
	self.pTxtTime = self:findViewByName("txt_time")
	setTextCCColor(self.pTxtTime, _cc.pwhite)
	self.pImgIcon = self:findViewByName("img_icon")
	self.pLayContent = self:findViewByName("lay_content")
	self.pImgBg      = self:findViewByName("img_bg")
	self.pImgJianbian = self:findViewByName("img_jianbian")

	self.pImgNew=self:findViewByName("img_new")
	self.pLayContents = {}
	--内容配置文件
	self.tMailConfigs = {
		[1] = {layContent = "lay_item_mail_content", updateContent = handler(self, self.updateItemContent)},
	}
end

function ItemReport:myInit(  )
	-- body
end

function ItemReport:updateViews(  )
	local tConf = self.tMailConfigs[1]
	if not tConf then
		return
	end

	--刷新或加载内容层，不存在就加载新的
	if not self.pLayContents[tConf.layContent] then
		parseView(tConf.layContent, handler(self, self.onParseContentViewCallback))
		return
	end
	--隐藏或显示邮件内容层
	for k,v in pairs(self.pLayContents) do
		v:setVisible(k == tConf.layContent)
	end
	--基本显示
	if self.tMailMsg then
		if self.tMailMsg.nWin == 1 then --胜利
			self.pTxtTitle:setString(getConvertedStr(7, 10393)) --进攻胜利
			setTextCCColor(self.pTxtTitle, _cc.white)
			self.pImgIcon:setCurrentImage("#v1_img_jingongchenggong.png")
		else
			self.pTxtTitle:setString(getConvertedStr(7, 10394)) --进攻失败
			setTextCCColor(self.pTxtTitle, _cc.red)
			self.pImgIcon:setCurrentImage("#v1_img_jingongshibai.png")
		end
		--显示时间
		self.pTxtTime:setString(formatTime(self.tMailMsg.nOt))

		if self.tMailMsg.bIsReaded then
			self.pImgNew:setVisible(false)

			self.pImgBg:setCurrentImage("#v1_img_kelashen6hui.png")
			self.pImgJianbian:setCurrentImage("#v2_img_kelashen6youjianyidu.png")
			setTextCCColor(self.pTxtTitle, _cc.white)		
		else
			self.pImgNew:setVisible(true)

			self.pImgBg:setCurrentImage("#v1_img_kelashen6.png")
			self.pImgJianbian:setCurrentImage("#v2_img_kelashen6youjianweidu.png")

		end
		self.pImgIcon:setToGray(self.tMailMsg.bIsReaded)
	end

	--显示内容层数据
	if tConf.updateContent then
		tConf.updateContent()
	end
end


--更新内容
function ItemReport:updateItemContent(  )
	if not self.tMailMsg then
		return
	end

	self.pTxtContent2:setString("")

	local tDefInfo = self.tMailMsg:getDefInfo()
	if tDefInfo then
		--显示文框内容
		local tStr = {
			{text = getConvertedStr(7, 10395), color = _cc.white},
			{text = self.tMailMsg.nOid, color = _cc.blue},
			{text = getConvertedStr(7, 10396), color = _cc.white},
			{text = tDefInfo.sName..getLvString(tDefInfo.nLv), color = _cc.blue}
		}
		self.pTxtContent1:setString(tStr)
	end
	self:showResultImg()
end


--nCategory 类别
--tMailMsg 邮件数据
function ItemReport:setData(nIndex, tMailMsg)
	self.nIndex = nIndex
	self.tMailMsg = tMailMsg
	self:updateViews()
end

--加载不同内容层
function ItemReport:onParseContentViewCallback( pContentView )
	local tConf = self.tMailConfigs[1]
	self.pLayContents[tConf.layContent] = pContentView
	self.pLayContent:addView(pContentView)
	--加载不同的文件内容子对象
	local sFile = tConf.layContent
	
	self.pTxtContent1 = pContentView:findViewByName("txt_content1")
	setTextCCColor(self.pTxtContent1, _cc.white)
	
	self.pTxtContent2 = pContentView:findViewByName("txt_content2")
	setTextCCColor(self.pTxtContent2, _cc.pwhite)
	--物品icon层
	self.pLayMailContentIcon = pContentView:findViewByName("lay_icon")
	self:updateViews()
end

--点击进入邮件
function ItemReport:onMailDetailClicked( pView )
	--发送消息打开dlg
	local tObject = {}
	tObject.nType = e_dlg_index.expeditefightdetail --dlg类型
	tObject.tFightDetail = self.tMailMsg
	tObject.bShare = true
	sendMsg(ghd_show_dlg_by_type,tObject)

	if not self.tMailMsg.bIsReaded then
		--请求阅读邮件
		SocketManager:sendMsg("reqReadPassKillHeroReport", {self.tMailMsg.nReportId})
		Player:getPassKillHeroData():setRead(self.tMailMsg.nReportId)
		--刷新界面
		sendMsg(gud_refresh_pass_kill_hero_msg)
	end
end
--展示胜利或失败的图片
function ItemReport:showResultImg( )
	-- body
	local sResultImg = "#v2_font_shibai.png"
	if self.tMailMsg.nWin == 1 then
		sResultImg = "#v2_font_shengli.png"
	end
	if not self.pResultImg then 
		self.pResultImg = MUI.MImage.new(sResultImg)
		self.pLayMailContentIcon:addView(self.pResultImg)
		centerInView(self.pLayMailContentIcon,self.pResultImg)
		self.pResultImg:setPositionY(self.pResultImg:getPositionY()-7)
	else
		self.pResultImg:setCurrentImage(sResultImg)
	end

	self.pResultImg:setVisible(true)

end



return ItemReport


