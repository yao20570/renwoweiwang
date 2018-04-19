----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-10-26 15:53:22
-- Description: 世界Boss列表
-----------------------------------------------------

local DlgUnableTouch = require("app.common.dialog.DlgUnableTouch")
local ItemBossWar = require("app.layer.wuwang.ItemBossWar")
local DlgBossWar = class("DlgBossWar", function ()
	return DlgUnableTouch.new(e_dlg_index.bosswar)
end)

function DlgBossWar:ctor(  )
	parseView("dlg_zhouwang_war", handler(self, self.onParseViewCallback))
end

function DlgBossWar:onCloseClicked()
	closeDlgByType(e_dlg_index.bosswar, false)
end

--解析界面回调
function DlgBossWar:onParseViewCallback( pView )
	--设置穿透事件
	self:setContentView(pView)
	pView:setViewTouched(false)
	self.eDlgType = e_dlg_index.bosswar
	self:setCallFunc(handler(self, self.onCloseClicked))
	self:setDialogBgColor(GLOBAL_DIALOG_BG_COLOR_DEFAULT)

	--基本设置
	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgBossWar",handler(self, self.onDlgBossWarDestroy))
end

-- 析构方法
function DlgBossWar:onDlgBossWarDestroy(  )
    self:onPause()
end

function DlgBossWar:regMsgs(  )
	regMsg(self, ghd_world_boss_war_support_used, handler(self, self.onSupportUsed))
end

function DlgBossWar:unregMsgs(  )
	unregMsg(self, ghd_world_boss_war_support_used)
end

function DlgBossWar:onResume(  )
	self:regMsgs()
end

function DlgBossWar:onPause(  )
	self:unregMsgs()
	unregUpdateControl(self)
end

function DlgBossWar:setupViews(  )
	self.pLayContent = self:findViewByName("lay_content")	
    self.pItemBossWars = {}
end

function DlgBossWar:updateViews(  )
end


function DlgBossWar:refreshItemPoses( )
	if self.nItemNum ~= #self.pItemBossWars then
		self.nItemNum = #self.pItemBossWars
		local nY = self.pLayContent:getContentSize().height
		for i=1,#self.pItemBossWars do
			local pItem = self.pItemBossWars[i]
			nY = nY - pItem:getContentSize().height
			pItem:setPosition(0, nY)
		end
	end
end

--倒计时函数
function DlgBossWar:updateCd(  )
	--倒序
	local nCount = #self.pItemBossWars
	for i=nCount, 1, -1 do
		local pItemBossWar = self.pItemBossWars[i]
		pItemBossWar:updateCd()
		--到达倒计时就移除掉
		if pItemBossWar:getBeginFightCd() <= 0 then
			pItemBossWar:removeFromParent(true) --从父类移出
			table.remove(self.pItemBossWars, i)
		end
	end

	self:refreshItemPoses()

	--全部倒计时完就关掉
	if #self.pItemBossWars == 0 then
		unregUpdateControl(self)
		closeDlgByType(e_dlg_index.bosswar, false)
	end

end

--tBossWarVOs: BossWarVO列表
--tViewDotMsg: ViewDotMsg
function DlgBossWar:setData( tBossWarVOs, tViewDotMsg)
	self.tBossWarVOs = tBossWarVOs
	self.tViewDotMsg = tViewDotMsg

	--初始化
	--删除所有
	for i=1,#self.pItemBossWars do
		self.pItemBossWars[i]:removeFromParent(true)
	end
	self.pItemBossWars = {}
	--添加新的
	if self.tBossWarVOs then
		local isMyCountryJoin=false
		for i=1,#self.tBossWarVOs do
			if self.tBossWarVOs[i].nSenderCountry == Player:getPlayerInfo().nInfluence then
				isMyCountryJoin=true
			end
		end
		for i=1,#self.tBossWarVOs do
			local pItem = ItemBossWar.new(self.tBossWarVOs[i], self.tViewDotMsg,isMyCountryJoin)
			self.pLayContent:addView(pItem)
			table.insert(self.pItemBossWars, pItem)
		end
		self:refreshItemPoses()
	end

	regUpdateControl(self, handler(self, self.updateCd))
	self:updateCd()
end

--更新当前列表
function DlgBossWar:onSupportUsed( sMsgName, pMsgObj )
	--救援次数
	for i=1,#self.pItemBossWars do
		self.pItemBossWars[i]:setUsedSupport()
	end
end

return DlgBossWar
