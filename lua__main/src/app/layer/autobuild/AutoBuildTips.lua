-----------------------------------------------------
-- author: maheng
-- updatetime:  2018-03-07 9:33:23 星期二
-- Description: 自动建造排序建造
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")


local AutoBuildTips = class("AutoBuildTips", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function AutoBuildTips:ctor()
	-- body
	self:myInit()
	parseView("layout_select_layer", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function AutoBuildTips:myInit()
	self.tLbTips = {}
	self.pImgFlag = nil
end

--解析布局回调事件
function AutoBuildTips:onParseViewCallback( pView )
	-- body
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("AutoBuildTips",handler(self, self.onDestroy))
end

--初始化控件
function AutoBuildTips:setupViews()
	-- body
	self.pLayRoot = self:findViewByName("lay_root")
	for i = 1, 3 do 
		local pLbTip = self:findViewByName("lb_tip_"..i)
		local nType = i - 1
		if nType == 0 then
			pLbTip:setString(getConvertedStr(6, 10773), false)
		elseif nType == 1 then
			pLbTip:setString(getConvertedStr(6, 10774), false)
		elseif nType == 2 then
			pLbTip:setString(getConvertedStr(6, 10775), false)
		end		
		self.tLbTips[i] = pLbTip

		local pLayClick = self:findViewByName("lay_type_"..i) 
		pLayClick:setViewTouched(true)
		pLayClick:setIsPressedNeedScale(false)
		pLayClick:onMViewClicked(function ( ... )
			-- body
			self:onSelectSortType(nType)
			self:setVisible(false)
		end)
	end	
end

function AutoBuildTips:updateViews()
	-- body
	if not self.pImgFlag then
		self.pImgFlag = MUI.MImage.new("#v1_img_zycz.png")
		self.pImgFlag:setAnchorPoint(cc.p(0, 0.5))
		self.pLayRoot:addChild(self.pImgFlag)
	end
	local pData = Player:getBuildData()
	if not pData then
		return
	end
	local nType = pData.nAbt	
	self.pImgFlag:setPosition(140, self.tLbTips[nType + 1]:getPositionY())
end

function AutoBuildTips:onSelectSortType( _nType )
	-- body
	print("_nType--", _nType)
	SocketManager:sendMsg("reqAutoBuildType", {_nType})
end

-- 析构方法
function AutoBuildTips:onDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function AutoBuildTips:regMsgs(  )
	-- body
	-- 注册自动建造数据刷新消息
	regMsg(self, ghd_auto_build_mgr_msg, handler(self, self.updateViews))	
end
--注销消息
function AutoBuildTips:unregMsgs(  )
	-- body
	-- 注销自动建造数据刷新消息
	unregMsg(self, ghd_auto_build_mgr_msg)	
end

-- 暂停方法
function AutoBuildTips:onPause()
	self:unregMsgs()	
end

--继续方法
function AutoBuildTips:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

return AutoBuildTips