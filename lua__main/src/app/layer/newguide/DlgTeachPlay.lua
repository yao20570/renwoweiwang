--------------------------------------------
-- Author: dengshulan
-- Date: 2018-2-4 10:55:34 星期日
-- 新手向导
--------------------------------------------

local MDialog = require("app.common.dialog.MDialog")

local DlgTeachPlay = class("DlgTeachPlay", function ()
	return MDialog.new()
end)

--构造
function DlgTeachPlay:ctor( _eDlgType )	
	-- body
	self:myInit()
	self.eDlgType = _eDlgType or e_dlg_index.dlgteachplay
	parseView("dlg_teachplay", handler(self, self.onParseViewCallback))
	self:setName(UIAction.TAG_SMALL_DLG)
end

--初始化成员变量
function DlgTeachPlay:myInit()
	-- body
	self.tCurData = getAllHelpMenuData()
	self.tBtnGroup = {}

	self.tOperations = {}
end
  
--解析布局回调事件
function DlgTeachPlay:onParseViewCallback( pView )
	-- body
	self.pComDlgView = pView
	self:setContentView(self.pComDlgView)
	self:setupViews()
	self:updateViews()
	 --注册析构方法
    self:setDestroyHandler("DlgTeachPlay",handler(self, self.onDlgTeachPlayDestroy))
end

--初始化控件
function DlgTeachPlay:setupViews()
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
	if self.eDlgType == e_dlg_index.dlgteachplaydetail then
		self.pImgClose:setCurrentImage("#v1_btn_back2.png")
		self.pLayBtnClose:onMViewClicked(handler(self, self.onCloseFunc))
	else
		self.pImgClose:setCurrentImage("#v1_btn_closebig2.png")
		self.pLayBtnClose:onMViewClicked(handler(self, self.closeDlg))
	end

	--向导说话
	self.pLbSpeak = self:findViewByName("lb_speak")

	self.tLayBtns = {}
	for i = 1, 6 do
		local pLayBtn = self:findViewByName("lay_btn_"..i)
		self.tLayBtns[i] = pLayBtn
	end

end

--设置标题
function DlgTeachPlay:setTitle(_str)
	-- body
	self.pTxtTitle:setString(_str)
end

--设置关闭按钮事件
function DlgTeachPlay:onCloseFunc()
	self:closeDlg()
	local tOb = {}
	tOb.nType = e_dlg_index.dlgteachplay
	sendMsg(ghd_show_dlg_by_type, tOb)
end

-- 修改控件内容或者是刷新控件数据
function DlgTeachPlay:updateViews()
	-- body
	if not self.tCurData then
		return
	end
	--按钮
	self:updateBtnOperations()
end

--底部5个按钮
function DlgTeachPlay:updateBtnOperations(  )
	-- body
	self.tOperations = {}
	local nBtnNum = table.nums(self.tCurData)
	self.pLbSpeak:setString(self.tCurData[1][1].desc)
	for v = 1, nBtnNum do
		local tBtnData = self.tCurData[v]
		local tOperate = {}
		tOperate.bEnable = true
		tOperate.sTitle = tBtnData[1].menu

		if tBtnData[1].menu == getConvertedStr(7, 10333) then --特殊服务
			tOperate.nBtnType = TypeCommonBtn.M_YELLOW
			tOperate.nHandler = handler(self, function ( ... )
				-- body
				self:closeDlg()
				Player:getGirlGuideMgr():showGirlGuide(tBtnData[1].step)
			end)
		else
			tOperate.nBtnType = TypeCommonBtn.M_BLUE
			if table.nums(tBtnData) > 1 then --如果有多个按钮显示二级菜单
				tOperate.nHandler = handler(self, function ( ... )
					-- body
					local tOb = {}
					tOb.nType = e_dlg_index.dlgteachplaydetail
					tOb.tData = tBtnData
					sendMsg(ghd_show_dlg_by_type, tOb)
					self:closeDlg()
				end)
			else --只有一个二级菜单按钮直接执行步骤
				tOperate.nHandler = handler(self, function ( ... )
					-- body
					self:closeDlg()
					Player:getGirlGuideMgr():showGirlGuide(tBtnData[1].step)
				end)
			end
		end

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
function DlgTeachPlay:onDlgTeachPlayDestroy()
end

--设置数据
function DlgTeachPlay:setData( tData )
	self.tCurData = tData
	self:updateViews()
end



return DlgTeachPlay
