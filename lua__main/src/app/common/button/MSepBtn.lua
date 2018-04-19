-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-04-11 14:59:21 星期二
-- Description: 特殊按钮（比如：+号，-号，？号，刷新箭头）
-----------------------------------------------------

local MSepBtn = class("MSepBtn", function()
	-- body
	--初始化按钮（默认一张图片）
	return MUI.MPushButton.new("#v1_btn_yellow1.png")
end)

--_pContainer：存放按钮的父层
--_nType：按钮样式
function MSepBtn:ctor( _pContainer, _nType )
	-- body
	self:myInit()
	self.pContainer = _pContainer
	self.nType = _nType or self.nType
	self:setupViews()
	self:updateViews()
	self:setDestroyCallback(handler(self, self.onMSepBtnDestroy))
end

--初始化成员变量
function MSepBtn:myInit(  )
	-- body
	self.pContainer 		= nil                      --存放按钮的父层
	self.nType 				= TypeSepBtn.PLUS          --按钮样式
	self.sImgName 			= "#v1_btn_increase.png"   --按钮图片名字
end

--初始化控件
function MSepBtn:setupViews( )
	-- body
	if self.nType == TypeSepBtn.PLUS then            --加号
		self.sImgName = "#v1_btn_increase.png"
	elseif self.nType == TypeSepBtn.MINUS then       --减号
		self.sImgName = "#v1_btn_reduce.png"
	elseif self.nType == TypeSepBtn.HELP then        --帮助
		self.sImgName = "#v1_btn_disaduse.png"
	elseif self.nType == TypeSepBtn.REFRESH then     --刷新		
		self.sImgName = "#v2_btn_change.png"
	elseif self.nType == TypeSepBtn.CROSS then     --刷新	
		self.sImgName = "#v2_btn_close.png"
	end
	--设置按钮图片
	self:setButtonImage(self.sImgName)
	self:setIsPressedNeedScale(false)
end

-- 修改控件内容或者是刷新控件数据
function MSepBtn:updateViews(  )
	-- body
end

-- 析构方法
function MSepBtn:onMSepBtnDestroy(  )
	-- body
end

--设置按钮是否可用
function MSepBtn:setBtnEnable( _bEnabled )
	-- body
	self:setViewEnabled( _bEnabled )
	self.pContainer:setViewEnabled(_bEnabled)
end

return MSepBtn