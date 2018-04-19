-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-04-07 17:17:27 星期五
-- Description: 层进度控件工具类
-----------------------------------------------------

local MCommonViewBar = require("app.common.viewbar.MCommonViewBar")


--每帧刷新view模拟进度条效果
--_pCurView：需要执行模拟进度条的布局
--_pParentView：存放模拟进度条的父层
--_nDir：0,向上；1，向右
function scheduleViewBarEffect( _pCurView, _pParentView, _nDir )
	-- body
	_pCurView:retain()
	local nOldx = _pCurView:getPositionX()
	local nOldy = _pCurView:getPositionY()
	--从父层移出
	_pCurView:removeFromParent(false)
	--创建进度层
	local pViewBar = MCommonViewBar.new()
	_pParentView:addView(pViewBar)
	pViewBar:addContentView(_pCurView)
	_pCurView:setPosition(_pCurView:getWidth()/2,_pCurView:getHeight()/2)
	--设置位置
	pViewBar:setPosition(nOldx - _pCurView:getWidth() / 2,
	    nOldy - _pCurView:getHeight()/2)
	--设置回调
	pViewBar:setProgressEndHandler(function (  )
		-- body
		_pCurView:removeFromParent(false)
		_pParentView:addView(_pCurView)
		_pCurView:setPosition(nOldx, nOldy)
		pViewBar:removeSelf()
		pViewBar = nil
	end)
	--开始执行进度刷新
	pViewBar:updateProgress()
end