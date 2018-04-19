-----------------------------------------------------
-- author: luwenjing
-- updatetime:  2017-12-21 15:42:15 星期四
-- Description: 多次充值活动
-----------------------------------------------------

local MDialog = require("app.common.dialog.MDialog")

local DlgSeveralRecharge = class("DlgSeveralRecharge", function()
	-- body
	return MDialog.new()
end)

function DlgSeveralRecharge:ctor( _eDlgType )
	-- body
	self.eDlgType = _eDlgType or e_dlg_index.dlgseveralrecharge
	self:myInit()
	parseView("dlg_new_first_recharge", handler(self, self.onParseViewCallback))
	self:setName(UIAction.TAG_SMALL_DLG)
end

function DlgSeveralRecharge:myInit(  )
	-- body
	self.tItemIcons = {}
	self.tActData  = nil --活动数据
	self.tPackage = nil --当前展示的礼包
end


--解析布局回调事件
function DlgSeveralRecharge:onParseViewCallback( pView )
	-- body
	self.pComDlgView = pView
	self:setContentView(self.pComDlgView)
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgSeveralRecharge",handler(self, self.onDestroy))
end

--初始化控件
function DlgSeveralRecharge:setupViews(  )
	-- body
	--设置标题

	--ly
	self.pLyMain = self:findViewByName("default")

	--背景图
	self.pImgBg = self:findViewByName("lay_bg")

	--底部按钮
	self.pImgBtnBuy = self:findViewByName("img_btn_buy")
	self.pImgBtnBuy:setViewTouched(true)
	self.pImgBtnBuy:setIsPressedNeedColor(false)
	self.pImgBtnBuy:onMViewClicked(handler(self, self.onGoRecharge))

	--右上角关闭按钮
	local pLayBtnClose = self:findViewByName("lay_btn_close")
	pLayBtnClose:setViewTouched(true)
	pLayBtnClose:setIsPressedNeedScale(false)
	pLayBtnClose:setIsPressedNeedColor(false)
	pLayBtnClose:onMViewClicked(handler(self, self.onClickClose))

	self.tImgBg = {
		{
			"ui/v2_img_ljlbv.jpg",
			"ui/v2_img_lqlbl.jpg",
			"ui/v2_img_ljlbl.jpg",
		},
		{
			"ui/v2_img_ljlbv2.jpg",
			"ui/v2_img_lqlbl2.jpg",
			"ui/v2_img_ljlbl2.jpg",
		}

	}
end

--控件刷新
function DlgSeveralRecharge:updateViews()
	self.tPackage=nil
	self.tActData = Player:getActById(e_id_activity.severalrecharge)
	if not self.tActData then
		self:closeDlg(false)
		return
	end

	if not self.pLbTip then
		self.pLbTip= MUI.MLabel.new({text = "", size = 20})

		self.pImgBg:addChild(self.pLbTip)
		self.pLbTip:setPosition(self.pImgBg:getWidth()/2,320)
	end
	self.pLbTip:setString(string.format(getConvertedStr(9,10057),self.tActData.nM) or "")

	local nIndex=0
	for k,v in pairs(self.tActData.tPs) do
		if v.t == 0 or v.t == 1 then		--找到一个未领取或可领取的 就展示这个
			self.tPackage=v
			break
		end
		nIndex= nIndex + 1
	end
	if not self.tPackage then
		self.tPackage =self.tActData.tPs[nIndex]
	end
	if self.tPackage then
		--不同的UI版本顶部艺术字图片不同

		if self.tActData.nUiVer == 0 then 
			self.pImgBg:setBackgroundImage(self.tImgBg[1][self.tPackage.i])
		elseif self.tActData.nUiVer == 1 then
			self.pImgBg:setBackgroundImage(self.tImgBg[2][self.tPackage.i])
		end
		
		if self.tPackage.t then
			if self.tPackage.t == 0 then --不可领取
				self.pImgBtnBuy:setCurrentImage("#v2_btn_chongzhi.png")
				self.pImgBtnBuy:setToGray(false)
			elseif self.tPackage.t == 1 then --可领取
				self.pImgBtnBuy:setCurrentImage("#v2_btn_lingqu.png")
				self.pImgBtnBuy:setToGray(false)
			elseif self.tPackage.t == 2 then --已领取
				self.pImgBtnBuy:setCurrentImage("#v2_btn_lingqu.png")
				self.pImgBtnBuy:setToGray(true)
				self.pImgBtnBuy:setViewTouched(false)
			end
		end
	end

end

--关闭界面
function DlgSeveralRecharge:onClickClose( )
	self:closeDlg(false)
end


--底部按钮回调
function DlgSeveralRecharge:onGoRecharge()	
	if self.tPackage.t  then
		if self.tPackage.t == 0 then --不可领取			
	        local tObject = {}
	        tObject.nType = e_dlg_index.dlgrecharge --dlg类型
	        sendMsg(ghd_show_dlg_by_type,tObject)   
		elseif self.tPackage.t == 1 then --可领取
			SocketManager:sendMsg("getSeveralRecharge", {self.tPackage.i},handler(self, self.onGetDataFunc))	
		elseif self.tPackage.t == 2 then --已领取

		end
	end
end

--接收服务端发回的登录回调
function DlgSeveralRecharge:onGetDataFunc( __msg )
    if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.getSeveralRecharge.id then
       		if __msg.body.o then
				--获取物品效果
				showGetItemsAction(__msg.body.o)

				self.tActData:refreshRewardState(__msg.body)
				self:updateViews()
       		end
        end
    else
        --弹出错误提示语
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end



--析构方法
function DlgSeveralRecharge:onDestroy(  )
	-- body
	self:onPause()
	
	if self.tActData  and self.tActData:isCanGetRecharge() == 2 then --已经领取
		Player:removeActById(e_id_activity.severalrecharge)
	end
	
	
end

--注册消息
function DlgSeveralRecharge:regMsgs(  )
	-- body
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))


end
--注销消息
function DlgSeveralRecharge:unregMsgs(  )
	-- body
	unregMsg(self, gud_refresh_activity)

end
--暂停方法
function DlgSeveralRecharge:onPause( )
	-- body	
	self:unregMsgs()
	
end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgSeveralRecharge:onResume( _bReshow )
	-- body	
	self:updateViews()
	self:regMsgs()
end


return DlgSeveralRecharge