--------------------------------------------
-- Author: dengshulan
-- Date: 2018-2-4 10:55:34 星期日
-- 新手向导
--------------------------------------------
local MDialog = require("app.common.dialog.MDialog")

local DlgTeachPlayDetail = class("DlgTeachPlayDetail", function ()
	return MDialog.new()
end)

--构造
--_nDefaultIndex：默认选择哪一项
function DlgTeachPlayDetail:ctor(tData)	
	-- body
	self:myInit(tData)
	self.eDlgType = e_dlg_index.dlgteachplaydetail
	parseView("dlg_teachplay", handler(self, self.onParseViewCallback))
	self:setName(UIAction.TAG_SMALL_DLG)
end


--初始化成员变量
function DlgTeachPlayDetail:myInit(tData)
	-- body	
	self.tBtnData = tData
	self.tBtnGroup = {}
	self.tOperations = {}
end

--解析布局回调事件
function DlgTeachPlayDetail:onParseViewCallback( pView )
	-- body
	self.pComDlgView = pView
	self:setContentView(self.pComDlgView)
	self:setupViews()
	self:updateViews()
	 --注册析构方法
    self:setDestroyHandler("DlgTeachPlayDetail",handler(self, self.onDlgTeachPlayDetailDestroy))
end

--初始化控件
function DlgTeachPlayDetail:setupViews()
	-- body
	self.pLayView = self:findViewByName("view")
	self.pTxtTitle = self:findViewByName("txt_title")
	setTextCCColor(self.pTxtTitle, _cc.white)
	--设置标题
	self.pTxtTitle:setString(getConvertedStr(7, 10332)) --新手向导

	--关闭按钮层
	self.pLayBtnClose = self:findViewByName("lay_btn_close")
	self.pImgClose = self:findViewByName("img_close")
	self.pLayBtnClose:setViewTouched(true)
	self.pLayBtnClose:setIsPressedNeedScale(false)
	self.pImgClose:setCurrentImage("#v1_btn_back2.png")
	self.pLayBtnClose:onMViewClicked(handler(self, self.onCloseFunc))

	--向导说话
	self.pLbSpeak = self:findViewByName("lb_speak")

	self.tLayBtns = {}
	for i = 1, 6 do
		local pLayBtn = self:findViewByName("lay_btn_"..i)
		self.tLayBtns[i] = pLayBtn
	end

end

--设置关闭按钮事件
function DlgTeachPlayDetail:onCloseFunc()
	self:closeDlg()
	local tOb = {}
	tOb.nType = e_dlg_index.dlgteachplay
	sendMsg(ghd_show_dlg_by_type, tOb)
end

function DlgTeachPlayDetail:updateViews()
	-- body
	if not self.tBtnData then
		return
	end
	--按钮
	self:updateBtnOperations()
end

--底部5个按钮
function DlgTeachPlayDetail:updateBtnOperations(  )
	-- body
	self.tOperations = {}
	local nBtnNum = table.nums(self.tBtnData)
	self.pLbSpeak:setString(self.tBtnData[1].desc2)
	for v = 1, nBtnNum do
		local tBtnData = self.tBtnData[v]
		local tOperate = {}
		tOperate.bEnable = true
		tOperate.sTitle = tBtnData.menu2

		tOperate.nBtnType = TypeCommonBtn.M_BLUE
		tOperate.nHandler = handler(self, function ( ... )
			self:closeDlg()
			--如果有开启条件判断一下要去的界面有没有开启
			if tBtnData.openid then
				local bOpen = getIsReachOpenCon(tBtnData.openid, true)
				if not bOpen then
					return
				end
			end
			if tBtnData.location then
				local tBuildInfo = Player:getBuildData():getBuildByCell(tBtnData.location)
				if not tBuildInfo or tBuildInfo:getIsLocked() then
					local tBuildData = getBuildDatasByTid(tBuildInfo.sTid)
					if tBuildData then
						TOAST(tBuildData.notopen)
					end
					return
				end
			end
			Player:getGirlGuideMgr():showGirlGuide(tBtnData.step)
		end)

		table.insert(self.tOperations, tOperate)
	end

	for i = 1, 6 do
		local tOperate = self.tOperations[i]
		
		if not self.tBtnGroup[i] and tOperate then	
			local pBtn = getCommonButtonOfContainer(self.tLayBtns[i], tOperate.nBtnType, tOperate.sTitle, false)			
			self.tBtnGroup[i] = pBtn		
		end
		if self.tBtnGroup[i] then
			if tOperate then
				self.tBtnGroup[i]:setVisible(true)
				self.tBtnGroup[i]:setBtnEnable(tOperate.bEnable)
				self.tBtnGroup[i]:setButton(tOperate.nBtnType, tOperate.sTitle)
				self.tBtnGroup[i]:onCommonBtnClicked(tOperate.nHandler)
			else
				self.tBtnGroup[i]:setVisible(false)
			end
		end
	end
	
end


--析构方法
function DlgTeachPlayDetail:onDlgTeachPlayDetailDestroy()
end



return DlgTeachPlayDetail
