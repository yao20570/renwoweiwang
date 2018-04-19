----------------------------------------------------
-- author: liangzhaowei
-- Date: 2017-06-30 15:05:16
-- Description: 王宫升级
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local ItemUpdatePlace = require("app.layer.activityb.updateplace.ItemUpdatePlace")



local DlgUpdatePlace = class("DlgUpdatePlace", function()
	-- body
	return DlgBase.new(e_dlg_index.updateplace)
end)

function DlgUpdatePlace:ctor(  )
	-- body
	self:myInit()
	self:refreshData()
	parseView("dlg_update_palace", handler(self, self.onParseViewCallback))

	
	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgUpdatePlace",handler(self, self.onDestroy))
end

--初始化成员变量
function DlgUpdatePlace:myInit()
	-- body
end

--更新数据
function DlgUpdatePlace:refreshData()
	-- body
	self.tActData = Player:getActById(e_id_activity.updateplace)
end

--解析布局回调事件
function DlgUpdatePlace:onParseViewCallback( pView )
	-- body
	self.pView = pView
	self:addContentView(pView) --加入内容层
	self:addContentTopSpace()


end

--初始化控件
function DlgUpdatePlace:setupViews( )
	--ly
	self.pLyTitle     			= 		self.pView:findViewByName("ly_title")
	self.pLyList     			= 		self.pView:findViewByName("ly_list")

	--设置banner图
	self.pLayBannerBg = self:findViewByName("lay_banner_bg")
	setMBannerImage(self.pLayBannerBg,TypeBannerUsed.fl_wgsj)

    self.pListView = createNewListView(self.pLyList)
    if table.nums(self.tActData.tConf )> 0  then
    	self.pListView:setItemCount(table.nums(self.tActData.tConf))
    	self.pListView:setItemCallback(handler(self, self.onEveryCallback))
    	--上下箭头
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)
    	self.pListView:reload(true)
    end  

    if self.tActData.sName then
		self:setTitle(self.tActData.sName)
    end



end


-- 修改控件内容或者是刷新控件数据
function DlgUpdatePlace:updateViews()

	if not self.tActData then
		self:closeDlg(false)
		return
	end

	if not self.pActTime then
		--活动时间
		self.pActTime = createActTime(self.pLyTitle,self.tActData,cc.p(0,240))
	else
		self.pActTime:setCurData(self.tActData)
	end

    --刷新listView
    if self.pListView:getItemCount() then
        -- if self.pListView:getItemCount() > 0 then
        --     self.pListView:removeAllItems()
        -- end
        if self.tActData.tConf then
        	self.tActData:resetSort()
            -- self.pListView:setItemCount(table.nums(self.tActData.tConf) or 0)
            -- self.pListView:reload()
			self.pListView:notifyDataSetChange(true, table.nums(self.tActData.tConf))
        end
    end
end



-- 每帧回调 _index 下标 _pView 视图
function DlgUpdatePlace:onEveryCallback( _index, _pView )
    local pView = _pView
    if not pView then
        if self.tActData.tConf[_index] then
            pView = ItemUpdatePlace.new()
            pView:setHandler(handler(self, self.clickItem))
        end
    end

    if _index and self.tActData then
 		pView:setCurData(self.tActData,_index)
    end


    return pView
end

--点击引导item回调
function DlgUpdatePlace:clickItem(_pData)
    if _pData then
    	SocketManager:sendMsg("getUpdatePlace", {_pData},handler(self, self.onGetDataFunc))	
    end
end

--接收服务端发回的登录回调
function DlgUpdatePlace:onGetDataFunc( __msg )
    if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.getUpdatePlace.id then
       		-- self:updateViews()
       		if __msg.body.o then
       			showGetAllItems(__msg.body.o)
       		end
        end
    else
        --弹出错误提示语
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end



--刷新界面
function DlgUpdatePlace:updateLayer()
	self:refreshData()
	self:updateViews()	
end


-- 析构方法
function DlgUpdatePlace:onDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function DlgUpdatePlace:regMsgs( )
	-- body
	regMsg(self, gud_refresh_activity, handler(self, self.updateLayer))

end

-- 注销消息
function DlgUpdatePlace:unregMsgs(  )
	-- body
	unregMsg(self, gud_refresh_activity)
end


--暂停方法
function DlgUpdatePlace:onPause( )
	-- body
	self:unregMsgs()
	local pActData = Player:getActById(e_id_activity.updateplace)
	if pActData and pActData.bClose and pActData:bClose() then --已经领取
		Player:removeActById(e_id_activity.updateplace)
	end
end

--继续方法
function DlgUpdatePlace:onResume()
	-- body
	self:updateViews()
	self:regMsgs()
	
end

return DlgUpdatePlace