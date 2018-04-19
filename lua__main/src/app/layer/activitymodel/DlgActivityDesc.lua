-----------------------------------------------------
-- author: luwenjing
-- updatetime:  2017-11-17 15:14:19 星期五
-- Description: 活动介绍对话框
-----------------------------------------------------
local DlgCommon = require("app.common.dialog.DlgCommon")
local DlgAlert = require("app.common.dialog.DlgAlert")

local DlgActivityDesc = class("DlgActivityDesc", function ()
	-- body
	return DlgAlert.new(e_dlg_index.dlgactivitydesc)
end)
--_nBtnType 按钮类型 1 前往活动 2 确定关闭界面 
function DlgActivityDesc:ctor( _nType,_nBtnType)
	-- body
	
	self.nType = _nType or self.nType
	self.nBtnType = _nBtnType or 1
	self:myInit()
end

--初始化成员变量
function DlgActivityDesc:myInit(  )
	self:setupViews()
	self:setDestroyHandler("DlgActivityDesc",handler(self, self.onItemActBtnDestroy))
end
function DlgActivityDesc:setupViews( )
	-- body
	self:setTitle(getConvertedStr(9, 10009))
	
	self.tActData=Player:getActById(self.nType)
	if self.tActData then
		self.pContent=MUI.MLayer.new()
		local pTxt=MUI.MLabel.new({
	        text = "",
	        size = 22,
	        anchorpoint = cc.p(0, 0),
	        dimensions = cc.size(450, 0),
        })
        pTxt:setString(getConvertedStr(9, 10008))
        pTxt:updateTexture()

		local sStr=self.tActData.sDesc
		self.tLabelContent = MUI.MLabel.new({
        text = "",
        size = 20,
        anchorpoint = cc.p(0, 0),
        dimensions = cc.size(450, 0),
        })
	    setTextCCColor(self.tLabelContent, _cc.pwhite)
	    self.tLabelContent:setString(sStr)
	    self.tLabelContent:setViewTouched(false)
		self.tLabelContent:updateTexture()

		self.pContent:setLayoutSize(self.tLabelContent:getWidth(),self.tLabelContent:getHeight()+pTxt:getHeight()+40)
		self.tLabelContent:setPosition(0,15)
		pTxt:setPosition(0,self.tLabelContent:getHeight()+25)
		self.pContent:addView(self.tLabelContent,10)
		self.pContent:addView(pTxt,10)
		self:addContentView(self.pContent, true) --加入内容层
	end
	if self.nBtnType == 1 then

		--设置只有一个按钮
		self:setOnlyConfirm(getConvertedStr(9, 10010))
		self:setOnlyConfirmBtn(TypeCommonBtn.L_BLUE)
		self:setRightHandler(handler(self, self.onClickGo))
	elseif self.nBtnType == 2 then
		self:setOnlyConfirm()
	    self:setRightHandler(function ()            
	        self:closeDlg()
	    end)
	end
end

function DlgActivityDesc:updateViews( )
	-- body

end

function DlgActivityDesc:onClickGo()
	if self.nType then
		local nActModle=math.floor(tonumber(self.nType)/1000)
		if nActModle==1 then
			local tObject = {}
			tObject.nType = e_dlg_index.actmodela --dlg类型
			tObject.nActID = tonumber(self.nType) or 0 --活动id
			closeAllDlg(false)
			sendMsg(ghd_show_dlg_by_type,tObject)

		else
			-- local tObject = {}
			-- tObject.nType = e_dlg_index.actmodela --dlg类型
		end
	end

end

function DlgActivityDesc:onItemActBtnDestroy( )
	-- body
end

return DlgActivityDesc