----------------------------------------------------- 
-- author: maheng
-- updatetime: 2017-08-24 16:45:39
-- Description: 重建建筑对话框
-----------------------------------------------------
local MDialog = require("app.common.dialog.MDialog")
local ItemPlayerLvUp = require("app.module.ItemPlayerLvUp")

local DlgBuildSuburb = class("DlgBuildSuburb", function()
	return MDialog.new(e_dlg_index.dlgbuildsuburb)
end)

function DlgBuildSuburb:ctor( tData )
	self:myInit(tData)
	parseView("dlg_build_suburb", handler(self, self.onParseViewCallback))
	self:setName(UIAction.TAG_SMALL_DLG)
end

function DlgBuildSuburb:myInit( tData )
	self.pData = tData	
end

--解析布局回调事件
function DlgBuildSuburb:onParseViewCallback( pView )
	-- body
	self.pComDlgView = pView
	self:setContentView(self.pComDlgView)
	self:setupViews()

	--注册析构方法
	self:setDestroyHandler("DlgBuildSuburb",handler(self, self.onDlgBuildSuburbDestroy))
end

--初始化控件
function DlgBuildSuburb:setupViews(  )--标题
	self.pLayRoot = self:findViewByName("default")

	--标题
	self.pLbTitle = self:findViewByName("lb_title") 
	self.pLbTitle:setString(getConvertedStr(6, 10526))
	--提示
	self.pLbTip = self:findViewByName("lb_tip")
	self.pLbTip:setString(getConvertedStr(6, 10210))

	--描述
	self.pLbDes = self:findViewByName("lb_des")
	self.pLbDes:setString(getConvertedStr(6, 10533))
	setTextCCColor(self.pLbDes, _cc.pwhite)
	--关闭按钮	
	self.pImgBtn = self:findViewByName("img_close")
	self.pImgBtn:setViewTouched(true)
	self.pImgBtn:setIsPressedNeedScale(false)
	self.pImgBtn:onMViewClicked(function (  )
		-- body
		--关闭对话框
		closeDlgByType(e_dlg_index.dlgbuildsuburb)
	end)
	--dump(self.pData, "self.pData", 100)
	local tBSuburb = getSubBDatasFromDBByCell(self.pData.nCellIndex)
	--dump(tBSuburb, "tBSuburb", 100)
	self.nOutposts = tonumber(tBSuburb.outposts)
	--按钮
	self.pLayBtn = self:findViewByName("lay_btn")
	self.pBtn = getCommonButtonOfContainer(self.pLayBtn, TypeCommonBtn.M_BLUE, getConvertedStr(6, 10527))	

	self.pLayIcon = self:findViewByName("lay_tuzi")
	local sImgPath = "#"..tBSuburb.icon..".png"
	self.pImgDraw = self:findViewByName("img_tuzi")
	self.pImgDraw:setScale(0.8)
	self.pImgDraw:setCurrentImage(sImgPath)

	self.pImgBuild = self:findViewByName("img_build")
	self.pImgBuild:setScale(0.6)
	if self.pData.tShowData and self.pData.tShowData.img then
		self.pImgBuild:setCurrentImage(self.pData.tShowData.img)
	end
	
	self.pLbDrawName = self:findViewByName("lb_draw_name")--图纸名称
	self.pLbDrawName:setString(tBSuburb.drawingname, false)
	self.pLbBuildName = self:findViewByName("lb_buildName")--建筑名称
	self.pLbBuildName:setString(self.pData.sName)

	self.pLbCost = self:findViewByName("lb_cost")--图纸消耗
	local sStr = {
		{color=_cc.pwhite,	text=getConvertedStr(6, 10529)},
		{color=_cc.blue,	text=self.pData.nDraws},
		{color=_cc.pwhite,	text="/"..tBSuburb.num},
	}
	self.pLbCost:setString(sStr, false)
	if self.pData.nDraws >= tBSuburb.num then--可激活
		self.pBtn:updateBtnText(getConvertedStr(6, 10530))
		self.pBtn:onCommonBtnClicked(handler(self, self.onActivateBuild))
	else									--引导
		self.pBtn:updateBtnText(getConvertedStr(6, 10527))
		self.pBtn:onCommonBtnClicked(handler(self, self.goToFuben))
	end
end

--控件刷新
function DlgBuildSuburb:updateViews(  )

end

--析构方法
function DlgBuildSuburb:onDlgBuildSuburbDestroy(  )
end
--按钮 激活资源建筑
function DlgBuildSuburb:onActivateBuild(  )
	-- body
	SocketManager:sendMsg("openresbuild", {self.nOutposts},function ()
		sendMsg(gud_refresh_fuben) --通知刷新界面
		closeDlgByType(e_dlg_index.dlgbuildsuburb)
	end)
end

--按钮副本引导
function DlgBuildSuburb:goToFuben(  )
	-- body
	
	-- local tObject = {}
	-- tObject.nType = e_dlg_index.fubenmap
	-- local fuben = Player:getFuben():getLevelById(self.nOutposts)
	-- if fuben then 
	-- 	tObject.tData = fuben.nChapterid or 1
	-- 	tObject.nID = fuben.nId
	-- else
	-- 	tObject.tData = 1
	-- end	
	-- sendMsg(ghd_show_dlg_by_type,tObject)

	--跳到对应关卡战斗界面
	jumpToSpecialArmyLayer(self.nOutposts)

	closeDlgByType(e_dlg_index.dlgbuildsuburb)
end
return DlgBuildSuburb