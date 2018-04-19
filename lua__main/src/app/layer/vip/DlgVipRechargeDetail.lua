-----------------------------------------------------
-- author: luwenjing
-- updatetime:  2018-01-08 16:27:19 星期一
-- Description: vip充值规则对话框
-----------------------------------------------------
local DlgCommon = require("app.common.dialog.DlgCommon")
local DlgAlert = require("app.common.dialog.DlgAlert")

local DlgVipRechargeDetail = class("DlgVipRechargeDetail", function ()
	-- body
	return DlgAlert.new(e_dlg_index.dlgviprechargedetail)
end)

function DlgVipRechargeDetail:ctor( _nType)
	-- body
	
	self.nType = _nType or self.nType
	self:myInit()
end

--初始化成员变量
function DlgVipRechargeDetail:myInit(  )
	self:setupViews()
	self:updateViews()
	self:setDestroyHandler("DlgVipRechargeDetail",handler(self, self.onDlgVipRechargeDetailDestroy))
end
function DlgVipRechargeDetail:setupViews( )
	-- body
	self:setTitle(getConvertedStr(5, 10087))
	self.pContent=MUI.MLayer.new()
	self.pContent:setLayoutSize(450,50)

	-- self.tActData=Player:getActById(self.nType)
	-- if self.tActData then
	-- 	
	-- 	local pTxt=MUI.MLabel.new({
	--         text = "",
	--         size = 22,
	--         anchorpoint = cc.p(0, 0),
	--         dimensions = cc.size(450, 0),
 --        })
 --        pTxt:setString(getConvertedStr(9, 10008))
 --        pTxt:updateTexture()

	-- 	local sStr=self.tActData.sDesc
	-- 	self.tLabelContent = MUI.MLabel.new({
 --        text = "",
 --        size = 20,
 --        anchorpoint = cc.p(0, 0),
 --        dimensions = cc.size(450, 0),
 --        })
	--     setTextCCColor(self.tLabelContent, _cc.pwhite)
	--     self.tLabelContent:setString(sStr)
	--     self.tLabelContent:setViewTouched(false)
	-- 	self.tLabelContent:updateTexture()

	-- 	self.pContent:setLayoutSize(self.tLabelContent:getWidth(),self.tLabelContent:getHeight()+pTxt:getHeight()+40)
	-- 	self.tLabelContent:setPosition(0,15)
	-- 	pTxt:setPosition(0,self.tLabelContent:getHeight()+25)
	-- 	self.pContent:addView(self.tLabelContent,10)
	-- 	self.pContent:addView(pTxt,10)
	-- 	self:addContentView(self.pContent, true) --加入内容层
	-- end

	--设置只有一个按钮
	self:setOnlyConfirm(getConvertedStr(1, 10059))
	self:setOnlyConfirmBtn(TypeCommonBtn.L_BLUE)
	self:setRightHandler(handler(self, self.onBtnClicked))
end

function DlgVipRechargeDetail:updateViews( )
	-- body

	local tData=getAvatarVIPData()
	-- local nIndex=0
	local nSize=table.nums(tData)
	local nIndex = nSize
	local nY= 10
	--tData的值是12 是下标最大的那个数
	for i = 1 ,#tData do
		local v=tData[i]
		local pTxt=MUI.MLabel.new({
	        text = "",
	        size = 20,
	        anchorpoint = cc.p(0, 0),
	        dimensions = cc.size(450, 0),
        })
        setTextCCColor(pTxt, _cc.pwhite)
        pTxt:setString(string.format(getConvertedStr(9,10084),v.exp,v.lv))
        
        pTxt:setPosition(10,nIndex * 30 -nY)
        nIndex=nIndex - 1
        self.pContent:addView(pTxt)
	end
	local nPer = tData[1].exp/tData[1].needmoney
	local pTxt=MUI.MLabel.new({
	        text = "",
	        size = 20,
	        anchorpoint = cc.p(0, 0),
	        dimensions = cc.size(450, 0),
        })
    setTextCCColor(pTxt, _cc.pwhite)
    pTxt:setString(string.format(getConvertedStr(9,10085),"1",tostring(nPer)))
    pTxt:setPosition(20,nIndex * 30 -nY)
    self.pContent:addView(pTxt)

	self.pContent:setLayoutSize(450,(nSize +1)* 30)
	self:addContentView(self.pContent, true) --加入内容层
end

function DlgVipRechargeDetail:onBtnClicked()
	self:closeDlg()
end

function DlgVipRechargeDetail:onDlgVipRechargeDetailDestroy( )
	-- body
end

return DlgVipRechargeDetail