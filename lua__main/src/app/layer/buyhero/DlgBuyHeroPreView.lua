-----------------------------------------------------
-- author: liangzhaowei
-- Date: 2017-06-13 20:47:30
-- Description: 推演预览
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local ItemBuyHeroPreView = require("app.layer.buyhero.ItemBuyHeroPreView")


local TCommonTabHost = require("app.common.tabhost.TCommonTabHost")
local DlgBuyHeroPreView = class("DlgBuyHeroPreView", function()
	return DlgBase.new(e_dlg_index.buyheropreview)
end)

function DlgBuyHeroPreView:ctor(  )
	-- body
	self:myInit()
	self:setTitle(getConvertedStr(5, 10162))
	parseView("dlg_buy_hero_preview", handler(self, self.onParseViewCallback))
	
	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgBuyHeroPreView",handler(self, self.onDestroy))
end

--初始化成员变量
function DlgBuyHeroPreView:myInit()
	-- body
	self.tTitles = {getConvertedStr(5,10163),getConvertedStr(5,10164)}
	self.tDropItemData = {}
	self.tDropItemData[1] = getDropById(tonumber(getHeroInitData("fineNormal")))
	self.tDropItemData[2] = getDropById(tonumber(getHeroInitData("godNormal")))

	self.pCnLayer = nil --内容层
end

--解析布局回调事件
function DlgBuyHeroPreView:onParseViewCallback( pView )
	-- body
	self.pView = pView
	self:addContentView(pView) --加入内容层

end

--初始化控件
function DlgBuyHeroPreView:setupViews( )
	--ly
	--顶部按钮层
	self.pLyView     			= 		self.pView:findViewByName("ly_view")
	self.pLyBtn     			= 		self.pView:findViewByName("ly_btn")

	--img
	-- self.pImgBaner              =       self.pView:findViewByName("img_banner")


	--按钮
	self.pBtn = getCommonButtonOfContainer(self.pLyBtn,TypeCommonBtn.L_BLUE,getConvertedStr(5,10174))
	--按钮点击事件
	self.pBtn:onCommonBtnClicked(handler(self, self.onBtnClick))

	--创建内容层

	self.pTComTabHost = TCommonTabHost.new(self.pLyView,1,1,self.tTitles,handler(self, self.onIndexSelected))
	self.pLyView:addView(self.pTComTabHost,10)
	self.pCnLayer = ItemBuyHeroPreView.new()
	self.pCnLayer:setCurData(self.tDropItemData[1],1)
	self.pTComTabHost:getContentLayer():addView(self.pCnLayer,2)
	self.pTComTabHost:removeLayTmp1()
	--默认选中第一项
	self.pTComTabHost:setDefaultIndex(1)



end

-- 修改控件内容或者是刷新控件数据
function DlgBuyHeroPreView:updateViews(  )
	-- body
end

-- 按钮回调
function DlgBuyHeroPreView:onBtnClick(pView)
	closeDlgByType(e_dlg_index.buyheropreview, false)
end


--切换回调位置 _key 切换卡名字
function DlgBuyHeroPreView:onIndexSelected(_index)
	if self.tDropItemData[_index] then
		self.pCnLayer:setCurData(self.tDropItemData[_index],_index)
	end
end


-- 析构方法
function DlgBuyHeroPreView:onDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function DlgBuyHeroPreView:regMsgs( )
	-- body
end

-- 注销消息
function DlgBuyHeroPreView:unregMsgs(  )
	-- body
end


--暂停方法
function DlgBuyHeroPreView:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function DlgBuyHeroPreView:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
	
end

return DlgBuyHeroPreView