-----------------------------------------------------
-- author: luwenjing
-- updatetime:  2018-01-17 10:42:19 星期三
-- Description: 月卡说明对话框
-----------------------------------------------------
local DlgCommon = require("app.common.dialog.DlgCommon")
local DlgAlert = require("app.common.dialog.DlgAlert")

local DlgMonthCardDesc = class("DlgMonthCardDesc", function ()
	-- body
	return DlgAlert.new(e_dlg_index.DlgMonthCardDesc)
end)

function DlgMonthCardDesc:ctor( )
	-- body
	
	-- self.nType = _nType or self.nType
	self:myInit()
end

--初始化成员变量
function DlgMonthCardDesc:myInit(  )
	self:setupViews()
	self:setDestroyHandler("DlgMonthCardDesc",handler(self, self.onMonthCardDestroy))
end
function DlgMonthCardDesc:setupViews( )
	-- body
	self:setTitle(getConvertedStr(9, 10104))


	
	-- self.tActData=Player:getActById(self.nType)
	-- if self.tActData then
	self.pContent=MUI.MLayer.new()
		

	local sStr=getTextColorByConfigure(getTipsByIndex(20106))

	self.tLabelContent = MUI.MLabel.new({
       	text = "",
        size = 20,
        anchorpoint = cc.p(0, 0),
        dimensions = cc.size(450, 0),
    })
	    setTextCCColor(self.tLabelContent, _cc.pwhite)
	    self.tLabelContent:setString(sStr)
	    -- self.tLabelContent:setViewTouched(false)
		self.tLabelContent:updateTexture()

		self.pContent:setLayoutSize(self.tLabelContent:getWidth(),self.tLabelContent:getHeight()+40)
		self.tLabelContent:setPosition(0,15)
		self.pContent:addView(self.tLabelContent,10)
		self:addContentView(self.pContent, true) --加入内容层

	-- --设置只有一个按钮
	-- self:setOnlyConfirm(getConvertedStr(9, 10010))
	-- self:setOnlyConfirmBtn(TypeCommonBtn.L_BLUE)
	-- self:setRightHandler(handler(self, self.onClickGo))
end

function DlgMonthCardDesc:updateViews( )
	-- body

end



function DlgMonthCardDesc:onMonthCardDestroy( )
	-- body
end

return DlgMonthCardDesc