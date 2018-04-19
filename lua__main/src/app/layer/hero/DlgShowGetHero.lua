-- author: liangzhaowei
-- Date: 2017-05-05 11:55:38
-- Description: 展示获得英雄
-----------------------------------------------------
local DlgCommon = require("app.common.dialog.DlgCommon")
local ItemBuyHeroInfo = require("app.layer.hero.ItemBuyHeroInfo")

local DlgShowGetHero = class("DlgShowGetHero", function()
	return DlgCommon.new(e_dlg_index.showgethero)
end)

--_tData 英雄列表 
function DlgShowGetHero:ctor(_tData)
	self:myInit()
	self.tData = _tData

	
	parseView("dlg_fuben_buy_hero", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgShowGetHero:onParseViewCallback( pView )

	self.pView =  pView

	self:addContentView(pView) --加入内容层

	self:setTitle(getConvertedStr(5, 10045))


	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgShowGetHero",handler(self, self.onDestroy))
end

--初始化成员变量
function DlgShowGetHero:myInit(  )
	-- body
	self.tData  = {} --招募英雄列表数据

end

-- 析构方法
function DlgShowGetHero:onDestroy(  )
    self:onPause()
end

function DlgShowGetHero:regMsgs(  )
end

function DlgShowGetHero:unregMsgs(  )
end

function DlgShowGetHero:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function DlgShowGetHero:onPause(  )
	self:unregMsgs()
end


function DlgShowGetHero:updateViews(  )
	--ly
	if not self.pLyBtn then
		self.pLyBtn = self:findViewByName("ly_btn")
	end

	if not self.tItemHeroList then
		self.tItemHeroList = {} -- 招募英雄列表详情item
		--创建招募英雄详情
		if self.tData and table.nums(self.tData)> 0 then
			for k,v in pairs(self.tData) do
				self.tItemHeroList[k] = ItemBuyHeroInfo.new(v)
				self.pView:addView(self.tItemHeroList[k],3)
				local nGap = (self.pView:getWidth()-self.tItemHeroList[k]:getWidth()*2)/3
				if table.nums(self.tData) == 2 then
					self.tItemHeroList[k]:setPosition( nGap* k + self.tItemHeroList[k]:getWidth()*(k-1), 200)
				else
					self.tItemHeroList[k]:setPosition(self.pView:getWidth()/2-self.tItemHeroList[k]:getWidth()/2, 200)
				end
			end
		end
	end

	--前往上阵
	if not self.pBtn then
		self.pBtn =  getCommonButtonOfContainer(self.pLyBtn,TypeCommonBtn.L_BLUE,getConvertedStr(5,10046)) 
		self.pBtn:onCommonBtnClicked(handler(self, self.onBtnClick))
	end


end

function DlgShowGetHero:__nShowHandler( )
	--新手引导前往上阵按钮
	Player:getNewGuideMgr():setNewGuideFinger(self.pBtn, e_guide_finer.hero_online_btn1)
end

--按钮点击
function DlgShowGetHero:onBtnClick()
		--todo

	if self.tData and self.tData[1] then
		-- local tObject = {}
		-- tObject.nType = e_dlg_index.selecthero --dlg类型
		-- tObject.tData = self.tData[1]
		-- sendMsg(ghd_show_dlg_by_type,tObject)

		local tObject = {}
		tObject.nType = e_dlg_index.dlgherolineup --dlg类型
		sendMsg(ghd_show_dlg_by_type,tObject)

	end

	closeDlgByType(e_dlg_index.showgethero,false)

		-- SocketManager:sendMsg("fubenConscribeHero", {self.nPostId}, handler(self, self.onGetDataFunc))

	--新手引导前往上阵按钮已点击
	Player:getNewGuideMgr():onClickedNewGuideFinger(self.pBtn)
end

--接收服务端发回的登录回调
function DlgShowGetHero:onGetDataFunc( __msg )
    if  __msg.head.state == SocketErrorType.success then 
      --   if __msg.head.type == MsgType.fubenConscribeHero.id then
      --   	--打开新的界面
      --   	dump(__msg.body,"__msg.body")
		    -- sendMsg(gud_refresh_fuben) --通知刷新界面
	     --    closeDlgByType(e_dlg_index.conscribehero,false)
      --   end
    else
        --弹出错误提示语
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end


return DlgShowGetHero