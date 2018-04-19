-- Author: maheng
-- Date: 2017-07-10 10:32:24
-- 奖励进度


local DlgAlert = require("app.common.dialog.DlgAlert")
local IconGoods = require("app.common.iconview.IconGoods")

local DlgGetPrizeProgress = class("DlgGetPrizeProgress", function ()
	return DlgAlert.new(e_dlg_index.taskprizeprogress)
end)

--构造
function DlgGetPrizeProgress:ctor(scorebox, nhandler)
	-- body
	self:myInit(scorebox, nhandler)	
end

--初始化成员变量
function DlgGetPrizeProgress:myInit(scorebox, nhandler)
	-- body
	self.pCurData = scorebox or nil
	self.nHandler = nhandler or nil
	self.pLayCent = MUI.MLayer.new(true)
	self.pLayCent:setLayoutSize(500, 280)

	self:addContentView(self.pLayCent, false)
	self:setupViews()
	self:onResume()
	 --注册析构方法
    self:setDestroyHandler("DlgGetPrizeProgress",handler(self, self.onDlgGetPrizeProgressDestroy))	
end
  
--初始化控件
function DlgGetPrizeProgress:setupViews()
	-- body
	--设置标题
	self:setTitle(getConvertedStr(6, 10468))

	self.pLbTip = MUI.MLabel.new({
        text="",
        size=20,
        anchorpoint=cc.p(0.5, 0.5),    
        })
	self.pLbTip:setPosition(self.pLayCent:getWidth()/2, 100)
    self.pLbTip:setViewTouched(false)
    self.pLayCent:addView(self.pLbTip, 10)

    self.tIcons = {}
    local x = 250
   	local y = 120
    for i = 1, 4 do
    	local picon = IconGoods.new(TypeIconGoods.NORAML)
    	picon:setIconScale(0.8)
    	picon:setPosition(x + (i - 3)*(picon:getWidth()) , y)
    	self.pLayCent:addView(picon, 5)
    	self.tIcons[i] = picon
    end
    local nNewHeigth = 0
    if self.nHandler then
    	self:setOnlyConfirm(getConvertedStr(6, 10189))
    	self:setOnlyConfirmBtn(TypeCommonBtn.L_YELLOW)
    	self:setBottomBtnVisible(true)
    	self:setRightHandler(self.nHandler)
    	--self.pLbTip:setVisible(false)
    else
    	--self.pLbTip:setVisible(true)
    end
 	
	--设置原本背景透明
	--self:setContentBgTransparent()
end

function DlgGetPrizeProgress:updateViews(  )
	-- body
	if self.pCurData then
		local str = nil
		if self.pCurData.bIsGetAward == false then --未领奖
			str = {
				{color=_cc.pwhite, text=getConvertedStr(6, 10471)},
				{COLOR=_cc.blue, text=self.pCurData.nTargetNum},
				{color=_cc.pwhite,text=getConvertedStr(6, 10472)},
			}
		else--已经领奖
			str = {
				{color=_cc.green, text=getConvertedStr(6, 10357)}
			}
		end
		self.pLbTip:setString(str, false)

		local items = getDropById(self.pCurData.nDropId)
		if not items then
			items = {}
		end
		for i = 1, 4 do
			if items[i] then
				self.tIcons[i]:setCurData(items[i])					   
				self.tIcons[i]:setMoreTextColor(getColorByQuality(items[i].nQuality))
				self.tIcons[i]:setNumber(items[i].nCt)
				self.tIcons[i]:setVisible(true)
			else
				self.tIcons[i]:setVisible(false)
			end
			
		end
		--调整位置
		local nCnt = #items		
		local nStartX = (500 - (nCnt*108))/(nCnt + 1)
		local nDis = nStartX
		for i = 1, nCnt do
			self.tIcons[i]:setPositionX(nStartX + (i - 1)*(nDis + 108) + 10)
		end
	end
end

--析构方法
function DlgGetPrizeProgress:onDlgGetPrizeProgressDestroy()
	self:onPause()	   	
end

-- 注册消息
function DlgGetPrizeProgress:regMsgs( )
	-- body
end

-- 注销消息
function DlgGetPrizeProgress:unregMsgs(  )
	-- body
end


--暂停方法
function DlgGetPrizeProgress:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function DlgGetPrizeProgress:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

return DlgGetPrizeProgress
