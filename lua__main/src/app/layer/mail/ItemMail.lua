----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-05-18 10:58:18
-- Description: 邮件界面 邮件列表子项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local MailFunc = require("app.layer.mail.MailFunc")

local ItemMail = class("ItemMail", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemMail:ctor(  )
	--解析文件
	parseView("item_mail", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemMail:onParseViewCallback( pView )
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
	self:setDestroyHandler("ItemMail", handler(self, self.onItemMailDestroy))
end

-- 析构方法
function ItemMail:onItemMailDestroy(  )
    self:onPause()
end

function ItemMail:regMsgs(  )
end

function ItemMail:unregMsgs(  )
end

function ItemMail:onResume(  )
	self:regMsgs()
end

function ItemMail:onPause(  )
	self:unregMsgs()
end

function ItemMail:setupViews(  )
	self.pTxtTitle = self:findViewByName("txt_title")
	-- setTextCCColor(self.pTxtTitle, _cc.white)

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
		[e_type_mail.report] = {layContent = "lay_item_mail_content", updateContent = handler(self, self.updateItemContent)},

		[e_type_mail.detect] = {layContent = "lay_item_mail_content", updateContent = handler(self, self.updateItemContent)},

		[e_type_mail.system] = {layContent = "lay_item_mail_sys_content", updateContent = handler(self, self.updateSystemContent)},

		[e_type_mail.saved] = {layContent = "lay_item_mail_content", updateContent = handler(self, self.updateItemContent)},

		[e_type_mail.activity] = {layContent = "lay_item_mail_sys_content", updateContent = handler(self, self.updateSystemContent)},
	}
end

function ItemMail:myInit(  )
	-- body
	self.nY1 = 0
	self.nY2 = 0
	self.nOriginY1 = 0
	self.nOriginY2 = 0
end

function ItemMail:updateViews(  )
	if not self.nCategory then
		return
	end
	local tConf = self.tMailConfigs[self.nCategory]
	if not tConf then
		return
	end

	if self.tMailReport then
		self.tMailReport=nil
	end


	--刷新或加载不同邮件类型的邮件内容层，不存在就加载新的
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
		--显示标题
		if self.nCategory == e_type_mail.system or self.nCategory == e_type_mail.activity then
			if self.tMailMsg.nId == nil or self.tMailMsg.nId == 0 then --没模板状态
				self.pTxtTitle:setString(self.tMailMsg.sTitle)

			else
				local tMailSystem = getMailDataById(self.tMailMsg.nId)
				if tMailSystem then
					self.pTxtTitle:setString(tMailSystem.sendname)
				end
			end
			setTextCCColor(self.pTxtTitle, _cc.white)

			--更改图标
			if self.tMailMsg.bIsReaded then
				self.pImgIcon:setCurrentImage("#v1_img_mail_opened.png")
			else
				self.pImgIcon:setCurrentImage("#v1_img_mail.png")
			end
		else
			if not self.tMailReport then
				self.tMailReport = getMailReport(self.tMailMsg.nId)
			end
			if self.tMailReport then
				self.pTxtTitle:setString(self.tMailReport.sTitle)
				setTextCCColor(self.pTxtTitle, self.tMailReport.sColor)
				--图标
				local sIcon = MailFunc.getMailIcon(self.tMailMsg)
				if sIcon then
					self.pImgIcon:setCurrentImage(sIcon)
				end
			end
		end
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
		-- self:setToGray(self.tMailMsg.bIsReaded)

		--显示时间
		self.pTxtTime:setString(formatTime(self.tMailMsg.nSendTime))
	end

	--显示内容层数据
	if tConf.updateContent then
		tConf.updateContent()
	end
end


--更新内容
function ItemMail:updateItemContent(  )
	if not self.tMailMsg then
		return
	end

	--隐藏不共用的控件
	-- self.pLayMailContentIcon:setVisible(false)
	self:removeIconImg()
	-- self.pLayMailContent2:setVisible(false)
	self:removeResultImg()
	self.pTxtContent2:setString("")
	
	--富文本1宽度
	local nWidth = nil
	local nTargetType = self.tMailMsg.nFightType
	if nTargetType == e_type_mail_fight.wileArmy or 
		nTargetType == e_type_mail_fight.awakeBoss or 
		nTargetType == e_type_mail_fight.ghost or
		nTargetType == e_type_mail_fight.ghostWar or
		nTargetType == e_type_mail_fight.zhouwang  then
		--有机率获得物品
		if self.tMailMsg.tRandomItem then
			local tItem = getGoodsByTidFromDB(self.tMailMsg.tRandomItem.k)
			if tItem then
				getIconGoodsByType(self.pLayMailContentIcon, TypeIconGoods.NORMAL, type_icongoods_show.item, tItem, 0.5)
			end
			self.pLayMailContentIcon:setVisible(true)
			-- nWidth = self.pLayMailContent1:getContentSize().width - self.pLayMailContentIcon:getContentSize().width
		end

	elseif nTargetType == e_type_mail_fight.res then --资源田
		--显示收获资源
		local tStr = MailFunc.getGetResTextColor(self.tMailMsg.tItemList)
		-- if self.pMailContent2 then
		-- 	self.pMailContent2:removeFromParent(true)
		-- 	self.pMailContent2 = nil
		-- end
		if tStr then
			-- self.pMailContent2 = getRichLabelOfContainer(self.pLayMailContent2, tStr)
			-- self.pLayMailContent2:setVisible(true)
			self.pTxtContent2:setString(tStr)
		end

		


	elseif nTargetType == e_type_mail_fight.cityWar then --城战
	elseif nTargetType == e_type_mail_fight.countryWar then --国战
	end

	--显示文框内容
	local tStr = MailFunc.getContentTextColor(self.tMailMsg)
	-- if self.pMailContent1 then
	-- 	self.pMailContent1:removeFromParent(true)
	-- 	self.pMailContent1 = nil
	-- end
	if tStr then
		-- self.pMailContent1 = getRichLabelOfContainer(self.pLayMailContent1, tStr, nil, nWidth)
		self.pTxtContent1:setString(tStr)
	end

	if not self.pLayMailContentIcon:isVisible() then
		self:showResultImg()
	end
end

--更新系统
function ItemMail:updateSystemContent(  )
	--自定义内容
	local nSubOffset = 60
	local nResetYLen =60 --需要调整y轴的长度
	local nThreePointLen = 3
	local tStrNew = {}
	if self.nOriginY1 ==0 then 		--因为四个一起赋值 就判断一个就好了
		self.nOriginY1 = self.pTxtMailSysTitle:getPositionY()
		self.nOriginY2 = self.pTxtContent:getPositionY()
		self.nY1 = self.pTxtMailSysTitle:getPositionY() - 13
		self.nY2 = self.pTxtContent:getPositionY() - 13
	end
	if self.tMailMsg.nId == nil or self.tMailMsg.nId == 0 then --没模板状态 --znftodo优化
		--标题
		self.pTxtMailSysTitle:setString("")

		local sStr = self.tMailMsg.sContent
		if string.len(sStr) > nSubOffset then
			local sSubStr, sSubStr2 = SubUTF8String(sStr, nSubOffset - nThreePointLen)
			sStr = sSubStr .. "..."
		end
		sStr = string.gsub(sStr, "\\n", "")
		sStr = string.gsub(sStr, "\n", "")
		if string.len(sStr) <= nResetYLen then

			self.pTxtMailSysTitle:setPositionY(self.nY1)
			self.pTxtContent:setPositionY(self.nY2 + 15)
		else
			self.pTxtMailSysTitle:setPositionY(self.nOriginY1)
			self.pTxtContent:setPositionY(self.nOriginY2 + 15)
		end
		tStrNew = getTextColorByConfigure(sStr)

		local nLength = 0
		for i=1,#tStrNew do
			nLength = nLength + string.len(tStrNew[i].text)
		end
	else
		--标题
		local tMailSystem = getMailDataById(self.tMailMsg.nId)
		if tMailSystem then
			self.pTxtMailSysTitle:setString(tMailSystem.title)
		end

		local tStr = MailFunc.getContentTextColor(self.tMailMsg)
		if tStr then
			local nCurrLen = 0
			for i=1,#tStr do
				tStr[i].text= string.gsub(tStr[i].text, "\\n", "")
				nCurrLen = nCurrLen + string.len(tStr[i].text)
				if nCurrLen > nSubOffset then
					
					local sSubStr, sSubStr2 = SubUTF8String(tStr[i].text, nSubOffset - nThreePointLen)

					tStr[i].text = sSubStr .. "..."
					table.insert(tStrNew, tStr[i])
					break
				end
				table.insert(tStrNew, tStr[i])
			end
			local nLength = 0
			for i=1,#tStrNew do
				nLength = nLength + string.len(tStrNew[i].text)
			end

			if nLength <= nResetYLen then
				self.pTxtMailSysTitle:setPositionY(self.nY1)
				self.pTxtContent:setPositionY(self.nY2)
			else
				self.pTxtMailSysTitle:setPositionY(self.nOriginY1)
				self.pTxtContent:setPositionY(self.nOriginY2)

			end
		end
	end

	--显示收获资源
	-- if self.pMailContent then
	-- 	self.pMailContent:removeFromParent(true)
	-- 	self.pMailContent = nil
	-- end
	-- if tStrNew then
	-- 	self.pMailContent = getRichLabelOfContainer(self.pLayMailContent, tStrNew)
	-- end
	if #tStrNew > 0 then
		self.pTxtContent:setString(tStrNew)
	end

	-- if self.tMailMsg.nId == 35 then
	-- 	dump(self.tMailMsg.tRewardItemList,"mailreward")
	-- end
	--隐藏或显示物品
	if self.tMailMsg.tRewardItemList and #self.tMailMsg.tRewardItemList > 0 then
		if self.tMailMsg.bIsGot then
			self.pImgItem:setVisible(false)
		else
			self.pImgItem:setVisible(true)
		end
	else
		self.pImgItem:setVisible(false)
	end
end

--nCategory 类别
--tMailMsg 邮件数据
function ItemMail:setData( nCategory, tMailMsg)
	self.nCategory = nCategory
	self.tMailMsg = tMailMsg
	self:updateViews()
end

--加载不同内容层
function ItemMail:onParseContentViewCallback( pContentView )
	local tConf = self.tMailConfigs[self.nCategory]
	self.pLayContents[tConf.layContent] = pContentView
	self.pLayContent:addView(pContentView)
	--加载不同的文件内容子对象
	local sFile = tConf.layContent
	if sFile == "lay_item_mail_content" then
		
		self.pTxtContent1 = pContentView:findViewByName("txt_content1")
		setTextCCColor(self.pTxtContent1, _cc.white)
		
		self.pTxtContent2 = pContentView:findViewByName("txt_content2")
		setTextCCColor(self.pTxtContent2, _cc.pwhite)
		--物品icon层
		self.pLayMailContentIcon = pContentView:findViewByName("lay_icon")
	elseif sFile == "lay_item_mail_sys_content" then
		--文本标题
		self.pTxtMailSysTitle = pContentView:findViewByName("txt_title")
		setTextCCColor(self.pTxtMailSysTitle, _cc.white)
		
		--文本内容
		self.pTxtContent = pContentView:findViewByName("txt_content")
		setTextCCColor(self.pTxtContent, _cc.pwhite) 
		--物品图片
		self.pImgItem = pContentView:findViewByName("img_item")
	end
	self:updateViews()
end

--点击进入邮件
function ItemMail:onMailDetailClicked( pView )
	--发送消息打开dlg
	--nIndex = 1,
	local tObject = {
	    nType = e_dlg_index.maildetail, --dlg类型
	    tMailMsg = self.tMailMsg,
	}
	sendMsg(ghd_show_dlg_by_type, tObject)
end
--展示胜利或失败的图片
function ItemMail:showResultImg( )
	-- body
	if self.tMailReport  and self.tMailReport.sIcon2 then
		if not self.pResultImg then 
			
			self.pResultImg = MUI.MImage.new(self.tMailReport.sIcon2)
			self.pLayMailContentIcon:addView(self.pResultImg)
			centerInView(self.pLayMailContentIcon,self.pResultImg)
			self.pResultImg:setPositionY(self.pResultImg:getPositionY()-7)
		else 
			self.pResultImg:setCurrentImage(self.tMailReport.sIcon2)
		end
		self.pLayMailContentIcon:setVisible(true)
		self.pResultImg:setVisible(true)
	end

end

function ItemMail:removeIconImg( )
	-- body
	self.pLayMailContentIcon:setVisible(false)
	local pIcon=self.pLayMailContentIcon:findViewByName("p_icon_goods_name")
	if pIcon then 
		pIcon:removeSelf()
		pIcon=nil
	end
end

function ItemMail:removeResultImg( )
	-- body
	if self.pResultImg then

		self.pResultImg:setVisible(false)
	end
end
return ItemMail


