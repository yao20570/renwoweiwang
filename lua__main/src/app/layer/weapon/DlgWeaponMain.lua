-- DlgWeaponMain.lua
-----------------------------------------------------
-- author: dshulan
-- updatetime:  2017-05-31 10:01:23 星期三
-- Description: 神兵列表
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local WeaponRow = require("app.layer.weapon.WeaponRow")

local DlgWeaponMain = class("DlgWeaponMain", function()
	-- body
	return DlgBase.new(e_dlg_index.dlgweaponmain)
end)

function DlgWeaponMain:ctor(  )
	-- body
	--测试数据用
	-- Player:getWeaponInfo():onLoadTestData()
	self:myInit()
	parseView("dlg_weapon_main", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgWeaponMain:myInit(  )
	-- body
end

--解析布局回调事件
function DlgWeaponMain:onParseViewCallback( pView )
	-- body
	self:addContentView(pView) --加入内容层
	self:addContentTopSpace(7)
	
	--设置标题
	self:setTitle(getConvertedStr(7, 10009))
	-- 提示
	self.pTxtTopTip = self:findViewByName("lb_toptip")
	self.pTxtTopTip:setString(getConvertedStr(7, 10010))
	--头顶横条(banner)
	local pBannerImage 		= 		self:findViewByName("lay_banner_bg")
	setMBannerImage(pBannerImage,TypeBannerUsed.sb)

	self:onResume()
	--注册析构方法
	self:setDestroyHandler("DlgWeaponMain",handler(self, self.onDlgWeaponMainDestroy))
end

function DlgWeaponMain:updateViews()
	-- body
	--列表层
	if not self.pListView then 
		self.pLayList = self:findViewByName("lay_list")
		self.pListView = MUI.MListView.new{
		bgColor = cc.c4b(255, 255, 255, 250),
	        viewRect = cc.rect(0, 0, 600, 826),
	        direction = MUI.MScrollView.DIRECTION_VERTICAL,
	        itemMargin = {left =  0,
	        right =  0,
	        top =  10,
	        bottom =  2},
		}
		self.pLayList:addView(self.pListView)
		self.pListView:setBounceable(false)
	    self.pListView:setItemCount(3)      
	    self.pListView:setItemCallback(function ( _index, _pView )
	        local pTempView = _pView
	    	if pTempView == nil then
	        	pTempView = WeaponRow.new()                        
	        end
	        pTempView:setRowIndex(_index)
	        return pTempView
	    end)
	    self.pListView:reload(true)
	else
		self.pListView:notifyDataSetChange(true)
	end
end

-- 析构方法
function DlgWeaponMain:onDlgWeaponMainDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgWeaponMain:regMsgs(  )
	-- body
	--刷新神兵列表信息
	regMsg(self, gud_refresh_weaponInfo, handler(self, self.updateViews))
end
--注销消息
function DlgWeaponMain:unregMsgs(  )
	-- body
	unregMsg(self, gud_refresh_weaponInfo)
end

-- 暂停方法
function DlgWeaponMain:onPause()
	self:unregMsgs()	
end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgWeaponMain:onResume(_bReshow)
	-- body
	self:updateViews()
	self:regMsgs()
end

return DlgWeaponMain