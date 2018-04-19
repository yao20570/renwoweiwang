-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-04-07 16:40:50 星期五
-- Description: layer进度刷新控件
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")

local MCommonViewBar = class("MCommonViewBar", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

-- _nDir：0,向上；1，向右
function MCommonViewBar:ctor( _nDir )
	-- body
	self:myInit()
	self.nDir = _nDir or self.nDir
	--设置可裁剪
	self:setClipping(true)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("MCommonViewBar",handler(self, self.onMCommonViewBarDestroy))

end

--初始化成员变量
function MCommonViewBar:myInit(  )
	-- body
	self.nDir 				= 		0 		--进度刷新方向
	self.pContentView 		=       nil 	--内容层
	self.nUpdateSpeed 		= 		8 		--进度刷新速度
	self.nUpdateScheduler 	= 		nil 	--刷新进程
	self._nEndHandler 		= 		nil 	--结束回调

end

--初始化控件
function MCommonViewBar:setupViews( )
	-- body
	--初始大小
	self:setLayoutSize(1,1)
end

-- 修改控件内容或者是刷新控件数据
function MCommonViewBar:updateViews(  )
	-- body
end

-- 析构方法
function MCommonViewBar:onMCommonViewBarDestroy(  )
	-- body
	self:cancelProgress()
end

--设置进度刷新速度
function MCommonViewBar:setUpdateSpeed( _nSpeed)
	-- body
	self.nUpdateSpeed = _nSpeed or self.nUpdateSpeed
end

--获得进度刷新速度
function MCommonViewBar:getUpdateSpeed(  )
	-- body
	return self.nUpdateSpeed
end

--设置结束回调方法
function MCommonViewBar:setProgressEndHandler( _handler )
	-- body
	self._nEndHandler = _handler
end

--添加内容层
function MCommonViewBar:addContentView( _pView )
	-- body
	self.pContentView = _pView
	self:addView(_pView)
end

--取消刷新进度
function MCommonViewBar:cancelProgress( )
	-- body
	if self.nUpdateScheduler then
	    MUI.scheduler.unscheduleGlobal(self.nUpdateScheduler)
	    self.nUpdateScheduler = nil
	end
end

--刷新进度
function MCommonViewBar:updateProgress(  )
	-- body
    if not self.pContentView then
        return
    end
    self.nUpdateScheduler = MUI.scheduler.scheduleGlobal(function (  )
    	-- body
	    if self.nDir == 0 then
	        --向上
	       	self:setLayoutSize(self.pContentView:getWidth(), self:getHeight() + self.nUpdateSpeed)
	        if self:getHeight() >= self.pContentView:getHeight() then
	            -- 销毁每帧刷新的消息
				self:cancelProgress()
				if self._nEndHandler then
					self._nEndHandler()
				end
	        end
	    else
	        --向右
	        self:setLayoutSize(pLineView:getWidth() + self.nUpdateSpeed,self.pContentView:getHeight())
	        if self:getWidth() >= pView:getWidth() then
	            -- 销毁每帧刷新的消息
	            self:cancelProgress()
	            if self._nEndHandler then
	            	self._nEndHandler()
	            end
	        end
		end
    end,0.02)
end

return MCommonViewBar
