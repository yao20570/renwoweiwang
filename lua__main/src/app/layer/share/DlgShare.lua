-- DlgShare.lua
-----------------------------------------------------
-- author: dshulan
-- updatetime:  2017-06-26 15:33:23 星期一
-- Description: 分享小弹窗
--_dlgFlow: 分享按钮
--_nShareId: 分享通告编号
--_param: json字符串
--_nId: 如果是分享装备或武将或神兵的话传它的id过来
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local json = require("framework.json")

local DlgShare = class("DlgShare", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--_nType 只有邮件用到
function DlgShare:ctor(_dlgFlow, _nShareId, _param, _nId, _nType)
	-- body
	self:myInit(_dlgFlow, _nShareId, _param, _nId,_nType)
	parseView("dlg_share", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgShare:myInit(_dlgFlow, _nShareId, _param, _nId , _nType)
	-- dump(_param)
	-- print("分享id: ", _nShareId, _nId)
	-- body
	self.dlgFlow              = _dlgFlow                                  --悬浮窗口
	self.nShareId             = _nShareId                                 --分享的编号
	self.sParam               = _param or " "                             --字符串table
	self.nId                  = _nId                                      --装备或武将或神兵的id
	self.nType                = _nType                                    --邮件类型

	-- self.sJsonStr             = json.encode(self.sParam)                  --json字符串
	-- self.sJsonStr             = json.encode(self.sParam)                  --json字符串
end

--解析布局回调事件
function DlgShare:onParseViewCallback( pView )
	-- body
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("DlgShare",handler(self, self.onDlgShareDestroy))
end

--初始化控件
function DlgShare:setupViews()
	-- body
	self.pLayDef 					= self:findViewByName("default")
	self.pLayShare					= self:findViewByName("lay_share")
	--三个按钮
	self.pLayCountryBtn             = self:findViewByName("lay_country_btn")
	self.pLayWorldBtn               = self:findViewByName("lay_world_btn")
	self.pLayFriendBtn              = self:findViewByName("lay_friend_btn")

	self.pCountryBtn = getCommonButtonOfContainer(self.pLayCountryBtn, TypeCommonBtn.M_BLUE, getConvertedStr(7,10063))
	self.pWorldBtn = getCommonButtonOfContainer(self.pLayWorldBtn, TypeCommonBtn.M_BLUE, getConvertedStr(7,10064))
	self.pFriendBtn = getCommonButtonOfContainer(self.pLayFriendBtn, TypeCommonBtn.M_BLUE, getConvertedStr(7,10065))

	self.pCountryBtn:onCommonBtnClicked(handler(self, self.onCountyClicked))
	self.pWorldBtn:onCommonBtnClicked(handler(self, self.onWorldClicked))
	self.pFriendBtn:onCommonBtnClicked(handler(self, self.onFriendClicked))

	--上下见图
	self.pImgUpArrow               = self:findViewByName("img_up_arrow")
	self.pImgDownArrow             = self:findViewByName("img_down_arrow")
	self.pImgUpArrow:setVisible(false)
	self.pImgDownArrow:setVisible(false)

	self.pLbShare                  = self:findViewByName("lb_share")
	self.pLbShare:setString(getConvertedStr(7,10066))

	--获取分享配表内容
	self.tShare = getChatCommonNotice(self.nShareId)
	self.nShareTp = self.tShare.type
	self.nTarget = self.tShare.target

	--重置内容
	self:resetContent()
end

--重置内容
function DlgShare:resetContent()
	if self.nTarget == 1 then
		self.pLayFriendBtn:setVisible(false)
		self.pLayWorldBtn:setVisible(false)
	else
		self.pLayFriendBtn:setVisible(false)
	end
	--新服屏蔽世界聊天
	if isNewServer() == true then
		self.pLayWorldBtn:setVisible(false)
	end
	
	local nHContent = 20
	--按钮位置
	if self.pLayFriendBtn:isVisible() then
		self.pLayFriendBtn:setPositionY(nHContent)
		nHContent = nHContent + 70
	end
	if self.pLayWorldBtn:isVisible() then
		self.pLayWorldBtn:setPositionY(nHContent)
		nHContent = nHContent + 70
	end
	if self.pLayCountryBtn:isVisible() then
		self.pLayCountryBtn:setPositionY(nHContent)
		nHContent = nHContent + 70
	end
	--文字标签
	nHContent = nHContent + 10
	self.pLbShare:setPositionY(nHContent)
	nHContent = nHContent + self.pLbShare:getHeight() + 20
	self.pLayShare:setLayoutSize(self.pLayShare:getWidth(), nHContent)
	--
	self.pImgUpArrow:setPositionY(self.pImgDownArrow:getHeight() + nHContent + self.pImgUpArrow:getHeight())
	self.pLayDef:setLayoutSize(self.pLayShare:getWidth(), self.pImgUpArrow:getPositionY())
	self:setLayoutSize(self.pLayDef:getLayoutSize())
end	

function DlgShare:updateViews()
	-- body
end

--向下箭头是否可见
function DlgShare:setDownArrow(_bIsShow)
	-- body
	self.pImgDownArrow:setVisible(_bIsShow)
	self.pImgUpArrow:setVisible(not _bIsShow)
end

--国家分享按钮点击事件
function DlgShare:onCountyClicked()
	-- body
	-- dump(self.sJsonStr)
	self:sendShare(2)
end

--世界分享按钮点击事件
function DlgShare:onWorldClicked()
	-- body
	self:sendShare(1)
end

function DlgShare:sendShare(_nChannel)
	--装备武将或神兵或者竞技场战报分享

	if self.nShareTp <= 3 or self.nShareTp == 11 or self.nShareTp == 13 then
		SocketManager:sendMsg("reqShare", {self.nShareId, self.sParam, _nChannel, self.nId})
	else
		if self.nType then
			SocketManager:sendMsg("reqShare", {self.nShareId, self.sParam, _nChannel,self.nId,self.nType})
		else
			SocketManager:sendMsg("reqShare", {self.nShareId, self.sParam, _nChannel})
		end
	end
	self.dlgFlow:onCloseFlowDlg()
end

--好友分享按钮点击事件
function DlgShare:onFriendClicked()
	-- body	
	local tObject = {}
	tObject.nType = e_dlg_index.dlgfriendshare --dlg类型
	sendMsg(ghd_show_dlg_by_type,tObject)

	self.dlgFlow:onCloseFlowDlg()
end

-- 析构方法
function DlgShare:onDlgShareDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgShare:regMsgs(  )
	-- body
end
--注销消息
function DlgShare:unregMsgs(  )
	-- body
end

-- 暂停方法
function DlgShare:onPause()
	self:unregMsgs()	
end

--继续方法
function DlgShare:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

return DlgShare