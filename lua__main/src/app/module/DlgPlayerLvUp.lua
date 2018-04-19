----------------------------------------------------- 
-- author: maheng
-- updatetime: 2017-08-3 28:45:39
-- Description: 玩家升级引导对话框
-----------------------------------------------------
local MDialog = require("app.common.dialog.MDialog")
local ItemPlayerLvUp = require("app.module.ItemPlayerLvUp")

local DlgPlayerLvUp = class("DlgPlayerLvUp", function()
	return MDialog.new(e_dlg_index.dlgplayerlvup)
end)

function DlgPlayerLvUp:ctor(  )
	self:myInit()
	parseView("dlg_player_lvup", handler(self, self.onParseViewCallback))
	self:setName(UIAction.TAG_SMALL_DLG)
end

function DlgPlayerLvUp:myInit(  )
	
end

--解析布局回调事件
function DlgPlayerLvUp:onParseViewCallback( pView )
	-- body
	self.pComDlgView = pView
	self:setContentView(self.pComDlgView)
	self:setupViews()

	--注册析构方法
	self:setDestroyHandler("DlgPlayerLvUp",handler(self, self.onDlgPlayerLvUpDestroy))
end

--初始化控件
function DlgPlayerLvUp:setupViews(  )--标题
	self.pLayDef = self:findViewByName("lay_def")
	
	self.pImgClose = self:findViewByName("img_close")
	self.pImgClose:setViewTouched(true)
	self.pImgClose:onMViewClicked(handler(self, function ( )
		-- body
		closeDlgByType(e_dlg_index.dlgplayerlvup)
	end))

	self.pImgRole = self:findViewByName("img_role")
	self.pLbTip = self:findViewByName("lb_tip")
	self.pLbTitle = self:findViewByName("lb_dlg_title")
	--设置标题
	self.pLbTitle:setString(getConvertedStr(6, 10514), false)
	--文字提示
	self.pLbTip:setString(getConvertedStr(6, 10515), false)
	setTextCCColor(self.pLbTip, _cc.blue)
	self.pLbTip:setZOrder(20)

	local pItem1 = ItemPlayerLvUp.new()
	pItem1:setItemTitle(getConvertedStr(6, 10516))
	pItem1:setImg("#v1_img_sjjz.png")
	pItem1:setPosition(46, 50)
	pItem1:setViewTouched(true)
	pItem1:setIsPressedNeedScale(false)
	pItem1:onMViewClicked(handler(self, function(  )
		-- body
		closeAllDlg()
		sendMsg(ghd_home_show_base_or_world, 1)--主城或世界跳转
		closeDlgByType(e_dlg_index.dlgplayerlvup)

		local tAllBuilds = Player:getBuildData():getCanUpBuildLists()
		if tAllBuilds and table.nums(tAllBuilds) > 0 then
			local tChoiceBuild = tAllBuilds[1] --选取第一个为目标建筑
			if tChoiceBuild then
				--移动到屏幕中点
				local tOb = {}
				tOb.nCell = tChoiceBuild.nCellIndex
				tOb.nFunc = function (  )
					-- body
					--模拟执行一次点击行为
					--发送消息关闭除了自身以外有打开的操作按钮，并且打开自身
					local tObject = {}
					tObject.nCell = tChoiceBuild.nCellIndex
					tObject.nFromWhat = _nType --标志从左对联进来的
					print("ghd_show_build_actionbtn_msg  6666666666666666666")
					sendMsg(ghd_show_build_actionbtn_msg,tObject)
				end
				sendMsg(ghd_move_to_build_dlg_msg, tOb)
				
			end
		else
			TOAST(getConvertedStr(1, 10263))
		end
	end))
	self.pLayDef:addView(pItem1, 10)
	
	local pItem2 = ItemPlayerLvUp.new()
	pItem2:setItemTitle(getConvertedStr(6, 10517))
	pItem2:setImg("#v1_img_wcrw.png")
	pItem2:setPosition(211, 50)
	pItem2:setViewTouched(true)
	pItem2:setIsPressedNeedScale(false)
	pItem2:onMViewClicked(handler(self, function (  )
		-- body
		local tObject = {}
		tObject.nType = e_dlg_index.dlgtask --dlg类型
		sendMsg(ghd_show_dlg_by_type,tObject)   
		closeDlgByType(e_dlg_index.dlgplayerlvup)
	end))
	self.pLayDef:addView(pItem2, 10)
	

	local pItem3 = ItemPlayerLvUp.new()
	pItem3:setItemTitle(getConvertedStr(6, 10518))
	pItem3:setImg("#v1_img_tzfb.png")
	pItem3:setPosition(376, 50)
	pItem3:setViewTouched(true)
	pItem3:setIsPressedNeedScale(false)
	pItem3:onMViewClicked(handler(self, function (  )
		-- body
		-- local tObject = {}
  --   	tObject.nType = e_dlg_index.fubenlayer --dlg类型
  --   	sendMsg(ghd_show_dlg_by_type,tObject)
  
  		--进入玩家已经开启的副本章节
    	local tObject = {}
		local tOpenChapters = Player:getFuben():getOpenChpater()
		tObject.tData = #tOpenChapters --章节id
		tObject.nType = e_dlg_index.fubenmap --dlg类型
		sendMsg(ghd_show_dlg_by_type,tObject)
    	closeDlgByType(e_dlg_index.dlgplayerlvup)
	end))
	self.pLayDef:addView(pItem3, 10)

end

--控件刷新
function DlgPlayerLvUp:updateViews(  )

end

--析构方法
function DlgPlayerLvUp:onDlgPlayerLvUpDestroy(  )
end

return DlgPlayerLvUp