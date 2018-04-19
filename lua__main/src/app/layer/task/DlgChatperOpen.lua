-----------------------------------------------------
-- author: xiesite
-- Date: 2018-1-09 16:24:47
-- Description: 章节开启界面
-----------------------------------------------------
local DlgBase = require("app.common.dialog.DlgBase")

local DlgChatperOpen = class("DlgChatperOpen", function()
	return DlgBase.new(e_dlg_index.chatperopen)
end)

function DlgChatperOpen:ctor(_tData)
	-- body
	self:myInit()
	self:hideTopTitle()
	parseView("dlg_chatper_open", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("DlgChatperOpen",handler(self, self.onDestroy))

end

--初始化成员变量
function DlgChatperOpen:myInit(  )
	-- body
	self.tData = nil --章节数据
end

--解析布局回调事件
function DlgChatperOpen:onParseViewCallback( pView )
	-- body
	self.pView = pView
	self:addContentView(pView) --加入内容层
	self:setupViews()
	self:onResume()

end


--初始化控件
function DlgChatperOpen:setupViews( )
 	self:hideTopTitle()

 	self.pLyTuiYan    	= 		self.pView:findViewByName("ly_tuiyan")
 	self.pLyTuiYan:setOpacity(0)

 	self.pLyTx    	= 		self.pView:findViewByName("ly_tx")
 	self.pImgBg    	= 		self.pView:findViewByName("img_bg")
 	self.pImgBg:setOpacity(0)
 	self.pImgBg:setScaleY(0)
 	self.pImgTou    	= 		self.pView:findViewByName("img_tou")
 	self.pImgTou:setOpacity(15)
 	self.pImgTitle    	= 		self.pView:findViewByName("img_title") --第几章
 	self.pImgTitle:setOpacity(0)
 	self.pImgDes    	= 		self.pView:findViewByName("img_des")	--描述
 	self.pImgDes:setOpacity(0)
	self.pImgWei    	= 		self.pView:findViewByName("img_wei")
 	self.pImgWei:setOpacity(0)

 	self.pLbNum = MUI.MLabelAtlas.new({text="0", 
		png="ui/atlas/v2_fonts_djz_1z6.png", pngw=66, pngh=66, scm=48})
 	self.pLbNum:setPosition(320,130)
 	self.pLyTx:addView(self.pLbNum, 99)
 	self.pLbNum:setOpacity(0)

end
 

-- 修改控件内容或者是刷新控件数据
function DlgChatperOpen:updateViews( )
	--展示特效
	if not Player:getPlayerTaskInfo():getChatperTask() then
		closeDlgByType(self.eDlgType, false)
	end

	local chatper =  Player:getPlayerTaskInfo():getChatperTask()
	if chatper and chatper.sTid then
		self.pLbNum:setString(chatper.sTid-1)
		self.pImgDes:setCurrentImage("#v2_fonts_zjt_"..chatper.sTid ..".png")
	end
 	self:showTx()
end

function DlgChatperOpen:showTx()

	local action_1 = cc.FadeIn:create(0.25)
	local action_2 = cc.DelayTime:create(1.95)
	local action_3 = cc.FadeOut:create(0.25)
	self.pLyTuiYan:runAction(cc.Sequence:create(action_1,action_2,action_3 , cc.CallFunc:create(function ()
			local tChatperData = Player:getPlayerTaskInfo():getChatperTask()
			tChatperData:setOpenStatus(false)
			tChatperData:showDialog(1)
			closeDlgByType(self.eDlgType, false)
	 	end)))


	local action_4 = cc.DelayTime:create(0.24)
	local action_5 = cc.Spawn:create(cc.ScaleTo:create(0.01, 1, 0.07), cc.FadeIn:create(0.01))
	local action_6 = cc.ScaleTo:create(0.3, 1, 1.02)
	local action_7 = cc.ScaleTo:create(0.2, 1, 1)
	local action_8 = cc.DelayTime:create(1.45)
	local action_9 = cc.FadeOut:create(0.25)
	self.pImgBg:runAction(cc.Sequence:create(action_4,action_5,action_6,action_7,action_8, action_9))


	local action_10 = cc.Spawn:create(cc.MoveBy:create(0.25,cc.p(0,60)), cc.FadeIn:create(0.25))
	local action_11 = cc.DelayTime:create(1.95)
	local action_12 = cc.FadeOut:create(0.25)
 	self.pImgTou:runAction(cc.Sequence:create(action_10,action_11,action_12))

 	local action_13 = cc.DelayTime:create(0.24)
	local action_14 = cc.FadeIn:create(0.01)
	local action_15 = cc.MoveBy:create(0.3,cc.p(0,-151))
	local action_16 = cc.MoveBy:create(0.2, cc.p(0,5))
	local action_17 = cc.DelayTime:create(1.45)
	local action_18 = cc.FadeOut:create(0.25)
 	self.pImgWei:runAction(cc.Sequence:create(action_13,action_14,action_15,action_16,action_17,action_18))


 	local action_19 = cc.DelayTime:create(0.45)
	local action_20 = cc.FadeIn:create(0.35)
	local action_21 = cc.DelayTime:create(1.4)
	local action_22 = cc.FadeOut:create(0.25)
 	self.pImgTitle:runAction(cc.Sequence:create(action_19,action_20,action_21,action_22))

 	local action_25 = cc.DelayTime:create(0.45)
	local action_26 = cc.FadeIn:create(0.35)
	local action_27 = cc.DelayTime:create(1.4)
	local action_28 = cc.FadeOut:create(0.25)
 	self.pLbNum:runAction(cc.Sequence:create(action_25,action_26,action_27,action_28))


 	local action_30 = cc.DelayTime:create(0.75)
	local action_31 = cc.FadeIn:create(0.35)
	local action_32 = cc.DelayTime:create(1.1)
	local action_33 = cc.FadeOut:create(0.25)
 	self.pImgDes:runAction(cc.Sequence:create(action_30,action_31,action_32,action_33))

end

-- 析构方法
function DlgChatperOpen:onDestroy( )
	-- body
	self:onPause()
end

-- 注册消息
function DlgChatperOpen:regMsgs(  )
	-- body
end

function DlgChatperOpen:setCurData( _data )
 	self.tData = _tData
 	self:updateViews()
end


-- 注销消息
function DlgChatperOpen:unregMsgs(  )
	-- body
end


--暂停方法
function DlgChatperOpen:onPause( )
	-- body
	self:unregMsgs()
end

--继续方法
function DlgChatperOpen:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
	
end

return DlgChatperOpen