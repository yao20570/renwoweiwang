-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-08-12 17:08:23 星期六
-- Description: 免费福利
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")

local DlgFreeBenefits = class("DlgFreeBenefits", function()
	-- body
	return DlgBase.new(e_dlg_index.dlgfreebenefits)
end)

function DlgFreeBenefits:ctor(  )
	-- body
	self:myInit()	
end

function DlgFreeBenefits:myInit(  )
	-- body
	--设置标题
	self:setTitle(getConvertedStr(6,10521))

	local pContentLay = MUI.MLayer.new()
	pContentLay:setViewTouched(false)
	pContentLay:setLayoutSize(640, 1066)
	self:addContentView(pContentLay) --加入内容层	

	local pImg = MUI.MImage.new("ui/2012huodongtuceng.jpg", {scale9=false})
	pContentLay:addView(pImg, 5)
	centerInView(pContentLay, pImg)

	self:setupViews()
	self:onResume()
end

function DlgFreeBenefits:refreshData()

end

--初始化控件
function DlgFreeBenefits:setupViews(  )
	-- body
	
end

--控件刷新
function DlgFreeBenefits:updateViews()

end



--刷新界面
function DlgFreeBenefits:updateLayer()
	
end

--析构方法
function DlgFreeBenefits:onDlgFreeBenefitsDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgFreeBenefits:regMsgs(  )
	-- body	
end
--注销消息
function DlgFreeBenefits:unregMsgs(  )
	-- body
end
--暂停方法
function DlgFreeBenefits:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function DlgFreeBenefits:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end


return DlgFreeBenefits