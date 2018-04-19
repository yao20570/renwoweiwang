-- DlgNotice.lua
-----------------------------------------------------
-- author: dshulan
-- updatetime:  2017-05-26 14:01:23 星期五
-- Description: 公告列表窗口
-----------------------------------------------------

local NoticeItem = require("app.layer.notice.NoticeItem")
local MCommonView = require("app.common.MCommonView")

local DlgNotice = class("DlgNotice", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)

function DlgNotice:ctor(_tSize)
	-- body
	self:setContentSize(_tSize)
	self:myInit()
	parseView("dlg_notice", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgNotice:myInit(  )
	-- body
	self.tNoticeMsgList = {}
	self:reqLoadNotice()
end

--解析布局回调事件
function DlgNotice:onParseViewCallback( pView )
	-- body
	self.pView = pView
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("DlgNotice",handler(self, self.onDlgNoticeDestroy))
end

--初始化控件
function DlgNotice:setupViews()
	-- body
	--列表层
	-- self.tHelpData = getHelpData()
	-- self.tNoticeMsgList = Player:getNoticeData():getNoticeMsgList()
	self.pLayList = self:findViewByName("lay_gg_list")
	self.pListView = MUI.MListView.new{
	bgColor = cc.c4b(255, 255, 255, 250),
        viewRect = cc.rect(0, 0, 600, 1050),
        direction = MUI.MScrollView.DIRECTION_VERTICAL,
        itemMargin = {left =  0,
        right =  0,
        top =  5,
        bottom =  5},
	}
	self.pLayList:addView(self.pListView)
	self.pListView:setBounceable(true)
    self.pListView:setItemCount(0)      
    self.pListView:setItemCallback(function ( _index, _pView )
        local pTempView = _pView
        local tNoticeData = self.tNoticeMsgList[_index]
    	if pTempView == nil then
    		if tNoticeData then
	        	pTempView = NoticeItem.new(_index)                        
	        	pTempView:setViewTouched(true)
	        end
        end
        if _index and tNoticeData then
	        -- 设置单项数据
	        pTempView:setItemData(tNoticeData)

	        -- 必须在这里执行，不能在创建的时候执行，不然_index的值会是错误的
	        pTempView:onMViewClicked(function ()
	        	local tObject = {}
				tObject.nType = e_dlg_index.dlgnoticecontent --dlg类型
				tObject.nId   = _index                       --下标
				sendMsg(ghd_show_dlg_by_type,tObject)
				--请求读取公告
				SocketManager:sendMsg("reqReadNoticeData", {tNoticeData.nNoticeId, tNoticeData.nVersion})
	        end)
		end
        return pTempView
    end)
    self.pListView:reload()
end

function DlgNotice:refreshNoticeList()
	if not self.pListView then
		return
	end

	self.tNoticeMsgList = Player:getNoticeData():getNoticeMsgList()
	local nCount = #self.tNoticeMsgList
	self.pListView:notifyDataSetChange(false, nCount)
end

function DlgNotice:updateViews()
	-- body
end

-- 析构方法
function DlgNotice:onDlgNoticeDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgNotice:regMsgs(  )
	-- body
	--请求加载公告
	regMsg(self, gud_refresh_notice, handler(self, self.refreshNoticeList))
end
--注销消息
function DlgNotice:unregMsgs(  )
	-- body
	--邮件请求加载
	unregMsg(self, gud_refresh_notice)
end

-- 暂停方法
function DlgNotice:onPause()
	self:unregMsgs()	
end

--继续方法
function DlgNotice:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

--请求加载公告列表
function DlgNotice:reqLoadNotice()
	SocketManager:sendMsg("loadNoticeData", {})
end

--加载邮件返回
function DlgNotice:onNoticeLoadReq( )
	self:updateMailSaveCnt()
end

return DlgNotice