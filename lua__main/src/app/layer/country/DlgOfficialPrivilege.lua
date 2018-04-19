-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-06-9 11:57:24 星期五
-- Description: 官员特权
-----------------------------------------------------
local DlgCommon = require("app.common.dialog.DlgCommon")
local ItemInfo = require("app.module.ItemInfo")

local DlgOfficialPrivilege = class("DlgOfficialPrivilege", function()
	-- body
	return DlgCommon.new(e_dlg_index.dlgofficialprivilege)
end)

function DlgOfficialPrivilege:ctor(  )
	-- body
	self:myInit()
	parseView("office_privilege_layer", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgOfficialPrivilege:myInit(  )
	-- body
	self.tTitleStr = {getConvertedStr(6, 10340), getConvertedStr(6, 10366), getConvertedStr(6, 10367), getConvertedStr(6, 10368), getConvertedStr(6, 10369)}
	self.tLbTitle = nil
end

--解析布局回调事件
function DlgOfficialPrivilege:onParseViewCallback( pView )
	-- body
	self:addContentView(pView,true) --加入内容层
	
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgOfficialPrivilege",handler(self, self.onDlgOfficialPrivilegeDestroy))
end

--初始化控件
function DlgOfficialPrivilege:setupViews( )
	-- body
	self:setTitle(getConvertedStr(6, 10365))

	self.pLayTitle = self:findViewByName("lay_title")
	local width = self.pLayTitle:getWidth()/table.nums(self.tTitleStr)
	local x = width/2
	self.tLbTitle = {}
	for i, v in pairs(self.tTitleStr) do
		local pLabel = MUI.MLabel.new({
        text=v,
        size=20,
        anchorpoint=cc.p(0.5, 0.5)
        })
        x = width/2 + (i - 1)*width
		pLabel:setPosition(x, self.pLayTitle:getHeight()/2)
		setTextCCColor(pLabel, _cc.pwhite)
		self.pLayTitle:addView(pLabel, 10)
		self.tLbTitle[i] = pLabel
	end
	local tcountryprishow = getCountryPriShow()
	--dump(tcountryprishow, "tcountryprishow", 100)
	self.pLayList = self:findViewByName("lay_list")
	x = width/2
	local height = self.pLayList:getHeight()/5
	local y = self.pLayList:getHeight() - height/2
	for i, v in pairs(tcountryprishow) do
		local pLabel = MUI.MLabel.new({
        text=v.name,
        size=20,
        anchorpoint=cc.p(0.5, 0.5)
        })                 
		pLabel:setPosition(x, y)
		setTextCCColor(pLabel, _cc.pwhite)
		self.pLayList:addView(pLabel, 10)		
		self:createLabel(x + width, y, "king", v)
		self:createLabel(x + width*2, y, "minister", v)
		self:createLabel(x + width*3, y, "adviser", v)
		self:createLabel(x + width*4, y, "general", v)
		y = y - height
	end

	self:setOnlyConfirm(getConvertedStr(1, 10059))
	self:setOnlyConfirmBtn(TypeCommonBtn.L_BLUE)
	self.pBtn = self:getRightButton()

	self.pLayBtn = self:findViewByName("lay_btn")
	self.pLayBtn:setVisible(false)
	-- self.pBtn =	getCommonButtonOfContainer(self.pLayBtn, TypeCommonBtn.L_BLUE, getConvertedStr(1, 10059))
	self.pBtn:onCommonBtnClicked(handler(self, self.onBtnClicked))
end

-- 修改控件内容或者是刷新控件数据
function DlgOfficialPrivilege:updateViews(  )
	-- body

end

-- 析构方法
function DlgOfficialPrivilege:onDlgOfficialPrivilegeDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function DlgOfficialPrivilege:regMsgs( )
	-- body
end

-- 注销消息
function DlgOfficialPrivilege:unregMsgs(  )
	-- body
end


--暂停方法
function DlgOfficialPrivilege:onPause( )
	-- body
	self:unregMsgs()
end

--继续方法
function DlgOfficialPrivilege:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

function DlgOfficialPrivilege:onBtnClicked( pview )
	-- body
	self:closeCommonDlg()
end

function DlgOfficialPrivilege:createLabel( nx, ny, _skey,  _data)
	-- body
	local nvalue = tonumber(_data[_skey])
	if nvalue == 0 then
		return
	elseif nvalue == -1 then
		local pImg = MUI.MImage.new("#v1_img_zycz.png", {scale9=false})
		pImg:setPosition(nx, ny)
		self.pLayList:addView(pImg, 10)			
	else
		local pLabel = MUI.MLabel.new({
	    text=_data[_skey],
	    size=20,
	    anchorpoint=cc.p(0.5, 0.5)
	    })                 
		pLabel:setPosition(nx, ny)
		setTextCCColor(pLabel, _cc.pwhite)
		self.pLayList:addView(pLabel, 10)			
	end

end
return DlgOfficialPrivilege