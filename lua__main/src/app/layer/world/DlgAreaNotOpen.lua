-----------------------------------------------------
-- author: luwenjing
-- updatetime:  2017-12-04 16:19:17 星期一
-- Description: 区域未开启时的提示对话框
-----------------------------------------------------
local DlgAlert = require("app.common.dialog.DlgAlert")
local MBtnExText = require("app.common.button.MBtnExText")


local DlgAreaNotOpen = class("DlgAreaNotOpen", function ()
	return DlgAlert.new(e_dlg_index.dlgareanotopen)
end)

--构造
function DlgAreaNotOpen:ctor(_tCityData)
	-- body
	self.tCityData=_tCityData
	self:myInit()
	parseView("dlg_area_not_open", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgAreaNotOpen:myInit()
	-- body
	self.tCurData = nil --当前数据
end
  
--解析布局回调事件
function DlgAreaNotOpen:onParseViewCallback( pView )
	-- body
	
	self:addContentView(pView, true)
	self:setupViews()
	self:updateViews()
	self:onResume()
	 --注册析构方法
    self:setDestroyHandler("DlgAreaNotOpen",handler(self, self.onDlgAreaNotOpenDestroy))
end

--初始化控件
function DlgAreaNotOpen:setupViews()
	-- body
	--设置标题
	self:setTitle(getConvertedStr(3, 10514))

	--初始值
	self.pTxtTip 		= 		self:findViewByName("txt_tip")
	self.pTxtName 		= 		self:findViewByName("txt_name")


	--设置只有一个按钮
	self:setOnlyConfirm(getConvertedStr(3,10381))
	self:setOnlyConfirmBtn(TypeCommonBtn.L_BLUE)
end

-- 修改控件内容或者是刷新控件数据
function DlgAreaNotOpen:updateViews()
	-- body

	-- local tCityData = getWorldCityDataById(tLastMapData.maincity)
	if self.tCityData then
		local tStr = {
				{color=_cc.white,text=getConvertedStr(3, 10515)},
				{color=_cc.yellow,text=self.tCityData.name},
				{color=_cc.white,text=getConvertedStr(3, 10516)},
			}
		self.pTxtTip:setString(tStr)

		self.pTxtName:setString(self.tCityData.name)
		self.pTxtName:enableOutline(cc.c4b(0, 0, 0, 255),1)

		setTextCCColor(self.pTxtName, _cc.gjyellow)
	end
end


--析构方法
function DlgAreaNotOpen:onDlgAreaNotOpenDestroy()
	
end

-- 注册消息
function DlgAreaNotOpen:regMsgs( )
	-- body

end

-- 注销消息
function DlgAreaNotOpen:unregMsgs(  )
	-- body

end


--暂停方法
function DlgAreaNotOpen:onPause( )
	-- body
	
end

--继续方法
function DlgAreaNotOpen:onResume( )
	-- body

end



return DlgAreaNotOpen
