--
-- Author: Jiangruichao
-- Date: 2016-03-17 15:42:54
-- 自定义特效对象
----------------------------------------------------

-- 特效数据
-- {
--      sPlist          : "tx/fight/p2_fight_boss_s", -- 图集
--      nImgType        : 2, --1：png 2：pvr.ccz 3：jpg
-- 		nFrame 			: 特效总帧数
-- 		pos 			: {x, y}特效的x,y轴位置（相对中心锚点的偏移）
-- 		fScale 			: 初始的缩放值
-- 		nBlend 			: 是否需要混合颜色 1需要，其他不需要（暂时只有一种加亮的模式）
-- 		nPerFrameTime 	: 每帧播放时间
-- 		tActions 		: 特效动作列表
-- 			{
-- 				{
-- 					nType 		: 特效类型（e_cust_armature_t）								
-- 					sImgName 	: 展示的图片名字(序列帧不带序号)，不需要后缀且是.png图片
--					sImgFormat 	: 图片格式，.png,.jpg，默认使用.png
-- 					nSFrame 	: 开始帧数下标
--  				nEFrame 	: 结束帧数下标
-- 					tValues 	: 数值（使用table存储），按类型赋值，参考(e_cust_armature_t)
-- 						{
-- 							{
-- 								-- 透明度{255, 0}、缩放{1, 0.5}、旋转{0, 180}
-- 								1：开始值
-- 								2：结束值
-- 								-----------------------------
-- 								-- 移动：{{0, 0}, {20, 20}}表示从(0, 0)移动到(20, 20)
-- 								1：x坐标
-- 								2：y坐标
-- 								-----------------------------
-- 								-- 缩放+透明度{{0.5, 1}, {250, 0}}
-- 								{1:开始值, 2:结束值},
-- 								{1:开始值, 2:结束值}
-- 							},
-- 							......
-- 						}
-- 				},
-- 			}
-- 		tFrameEvents 	: 帧事件回调列表
-- 						{1, 4, ... , n} 定义需要回调的帧数
-- }

require("cocos.myui.mviewutils.MArmaturePlistUtils")


local g_MArmatureFrame = {}

local MArmature = class("MArmature", function ( _tData, _pView, _nZorder, _tPos, _callback, _mode )
	local pS = nil
	if(_mode == nil) then
		pS = cc.Sprite:create()
	else
		pS = cc.BillBoard:create("ui/daitu.png", _mode)
	end
	pS.setPositionC = pS.setPosition
	pS.setScaleC = pS.setScale
	pS.setScaleCX = pS.setScaleX
	pS.setScaleCY = pS.setScaleY

	pS.setAnchorPointC = pS.setAnchorPoint
	pS.setRotationC = pS.setRotation
	pS.setTagC = pS.setTag

    pS:onNodeEvent("enter", function(...)
		pS:onEnter(...)
	end)

    pS:onNodeEvent("exit", function(...)
		pS:onExit(...)
	end)

	return pS
end)

function MArmature:onEnter()
    local tFramData = self.tFramData
    if self.isExit == true and tFramData and tFramData.sPlist then
        -- 移除plist引用
	    MArmaturePlistUtils.retainPlist(tFramData.sPlist)        
        self.isExit = false
    end
end

function MArmature:onExit()
    local tFramData = self.tFramData
    if self.isExit == false and tFramData and tFramData.sPlist then
        -- 移除plist引用
	    MArmaturePlistUtils.releasePlist(tFramData.sPlist) 
        self.isExit = true       
    end
end

-- _tData: 特效数据
-- _pView: 父层
-- _nZorder: 层级
-- _tPos: 坐标
-- _callback: 播放结束回调
function MArmature:ctor( _tData, _pView, _nZorder, _tPos, _callback )
    self.isExit = false
	self:baseInit()
	-- 创建特效
	self:initSprite(_tData, _pView, _nZorder, _tPos, _callback)
end
-- 初始化成员变量
function MArmature:baseInit()

    local framData = {}
    framData.sPlist = nil
    framData.sImgName = nil
	framData.sFlag = "1"
	framData.nFrameNum = 0 -- 特效的总帧数
	framData.tActions = nil -- 动作列表
	framData.tFrameEvents = nil -- 帧事件回调列表（需要回调的帧数列表）
	framData.fOffsetX = 0 -- 精灵对于中心锚点的偏移值（x坐标）
	framData.fOffsetY = 0 -- 精灵对于中心锚点的偏移值（y坐标）
	framData.fScale = 1.0 -- 初始缩放值
	framData.fScaleX = 1.0 -- 初始缩放值
	framData.fScaleY = 1.0 -- 初始缩放值

	framData.nRotation = 0 -- 初始旋转角度
	framData.nOpacity = 255 -- 初始透明度
	framData.tPos = {x = 0, y = 0} -- 精灵在父层上的坐标
	framData.nRepeat = 1 -- 重复播放次数（小于等于0为无限循环播放）
	framData.nDir = 1
	framData.fPerFTime = 1 / 24  -- 每帧播放时间
	framData.nPlayEndCallback = nil -- 播放结束回调
	framData.nFrameEventCallback = nil -- 帧事件回调函数
	framData.nBlend = 0 -- 是否加亮
	framData.nRandomPause = 0 -- 是否随机暂停
	framData.bRPState = false -- 随机暂停状态

	framData.bPState = false -- 当前播放状态 true为正在播放，false为停止播放
	framData.nCurFrame = -1 -- 当前播放的帧数
	framData.nCurRepeat = 1 -- 当前已重复播放的次数
	framData.nLastPTime = 0 -- 上一帧播放的时间
	framData.nPauseFrame = nil -- 暂停在第几帧
	framData.nPauseFrameCount = nil -- 停止播放的帧数个数

    self.tFramData = framData
end
----------------------------------------------------------------------
-- 创建特效精灵对象
-- _tData(table): 特效数据
-- _pView(MView): 父层
-- _nZorder(int): 层级
-- _tPos(cc.p): 坐标
-- _callback(function): 播放结束回调
function MArmature:initSprite( _tData, _pView, _nZorder, _tPos, _callback )
	self:setData(_tData)
	self:addToView(_pView, _nZorder)
	self:setPosition(_tPos)
	self:setMovementEventCallFunc(_callback)
end

-- 播放特效
-- _nRepeat(int): 重复播放次数，小于0为无限循环, 0为只播放1次
function MArmature:play( _nRepeat )
	self:setRepeat(_nRepeat)

    local framData = self.tFramData

	framData.bPState = true
	framData.nCurFrame = 1
	framData.nCurRepeat = 1
end
-- 停止播放特效
function MArmature:stop(  )
    
    local framData = self.tFramData

	framData.bPState = false
	framData.nCurFrame = 0
	framData.nCurRepeat = 1
end
-- 停止播放特效并设置特效最后显示的图片
-- _sImgName(string)：停止特效后显示的图片
function MArmature:stopForImg( _sImgName )
	self:stop()
	self:setFrameByImg(_sImgName)
end
-- 暂停
function MArmature:pause(  )
	self.tFramData.bPState = false
end
-- 继续播放
function MArmature:continue(  )
	self.tFramData.bPState = true
end

---------------------------------------------------------------
-- 设置特效的数据
-- _tData(table): 特效数据
function MArmature:setData( _tData )
	if (not _tData) then
        self.tFramData = nil
		return 
	end

    local framData = self.tFramData

    if framData.sPlist ~= _tData.sPlist then
        if framData.sPlist ~= nil then
            MArmaturePlistUtils.releasePlist(framData.sPlist)
        end        
        if _tData.sPlist ~= nil then
            MArmaturePlistUtils.retainPlist(_tData.sPlist, _tData.nImgType)  
        end
    end
    
    framData.sPlist = _tData.sPlist -- 动画图集
	framData.nFrameNum = _tData.nFrame or self.nFrameNum -- 特效总帧数
	framData.tActions = _tData.tActions -- 特效动作列表
	framData.tFrameEvents = _tData.tFrameEvents -- 帧事件回调帧数列表
	if (_tData.pos) then
		framData.fOffsetX = _tData.pos[1] or framData.fOffsetX
		framData.fOffsetY = _tData.pos[2] or framData.fOffsetY
	end
	self:setScale(_tData.fScale)
	self:setScaleX(_tData.fScaleX or framData.fScale)
	self:setScaleY(_tData.fScaleY or framData.fScale)

	framData.nBlend = _tData.nBlend or framData.nBlend
	self:setPerFrameTime(_tData.nPerFrameTime) -- 设置每帧播放时间
end
-- 添加到父层
-- _pParentView(MView): 父层
-- _nZorder(int): 层级
function MArmature:addToView( _pParentView, _nZorder )
	if (not _pParentView) then
		return 
	end
	_pParentView:addChild(self, _nZorder or 0)
end
-- 设置位置
-- _tPos(cc.p): 位置
-- _nDir(int): 方向 1为原始方向，-1为反向
function MArmature:setPosition( _tPos, _nDir )
	if (not _tPos) then
		return
	end

    local framData = self.tFramData

	framData.nDir = _nDir or framData.nDir
	framData.tPos.x = _tPos.x or framData.tPos.x
	framData.tPos.y = _tPos.y or framData.tPos.y
	self:setPositionC(framData.fOffsetX * framData.nDir + framData.tPos.x, framData.fOffsetY * framData.nDir + framData.tPos.y)
end
-- 设置缩放值
-- _fScale(float): 初始缩放值
function MArmature:setScale( _fScale )
    local framData = self.tFramData
	framData.fScale = _fScale or framData.fScale
	self:setScaleC(framData.fScale)
end

function MArmature:setScaleX( _fScale )
    local framData = self.tFramData
	framData.fScaleX = _fScale or framData.fScaleX
	self:setScaleCX(framData.fScaleX)
end

function MArmature:setScaleY( _fScale )
    local framData = self.tFramData
    if framData.fScaleY ~= _fScale then
	    framData.fScaleY = _fScale or framData.fScaleY
	    self:setScaleCY(framData.fScaleY)
    end
end

-- 设置旋转角度
-- _nRotation(float): 旋转的角度
function MArmature:setRotation( _nRotation )
    local framData = self.tFramData
	framData.nRotation = _nRotation or framData.nRotation 
	self:setRotationC(framData.nRotation)
end
-- 设置锚点
-- _tAncPoint(cc.p): 锚点
function MArmature:setAnchorPoint( _tAncPoint )
	if (not _tAncPoint) then
		return 
	end
	self:setAnchorPointC(_tAncPoint)
end
-- 设置Tag值
-- _nTag(int): tag值
function MArmature:setTag( _nTag )
	if (not _nTag) then
		return
	end
	self:setTagC(_nTag)
end
-- 设置是否重复
-- _nRepeat(int): 重复播放次数，小于0为无限循环, 0为只播放1次
function MArmature:setRepeat( _nRepeat )
    local framData = self.tFramData
	framData.nRepeat = _nRepeat or framData.nRepeat
	if (framData.nRepeat == 0) then
		framData.nRepeat = 1
	end
end
-- 使用图片设置显示的帧
-- _sImgName(string): 图片名字
function MArmature:setFrameByImg( _sImgName, _sImgFormat )
    
    local framData = self.tFramData

	if (not _sImgName) or framData.sImgName == _sImgName then
		return 
	end

    framData.sImgName = _sImgName

	-- 判断是否有后缀，若没有后缀，则加上.png后缀
	local bHas = false
	if (string.find(_sImgName, ".png")) then
		bHas = true
	end
	if (not bHas and string.find(_sImgName, ".jpg")) then
		bHas = true
	end
	if (_sImgFormat and string.len(_sImgFormat) > 0 and not bHas) then
		-- 有指定图片格式，需要加上图片格式后缀
		_sImgName = _sImgName .. _sImgFormat
		bHas = true
	end
	if (not bHas) then
		_sImgName = _sImgName .. ".png"
	end

    local pFrame = g_MArmatureFrame[_sImgName]
    if tolua.isnull(pFrame) then
	    pFrame = MUI.SpriteFrameCache:getSpriteFrame(_sImgName)
	    if(not pFrame and string.find(_sImgName, "#")) then -- 如果找不到图片并且是单图            
	        local pTexture = MUI.TextureCache:addImage(_sImgName)
	        if(pTexture) then
	        	-- 创建帧缓存
                if b_show_load_texture_info == true then
                    myprint("加载纹理-单图(动画)","===========>:", _sName)
                end
                local size = pTexture:getContentSize()
	        	pFrame = cc.SpriteFrame:createWithTexture(pTexture, cc.rect(0, 0, size.width, size.height))
	        	if(pFrame) then
	        		 MUI.SpriteFrameCache:addSpriteFrame(pFrame, _sImgName)
	        	end
	        end
	    end
        g_MArmatureFrame[_sImgName] = pFrame
    end

	if(pFrame) then
		self:setSpriteFrame(pFrame) 
	else
		printMUI("找不到图片帧", _sImgName)
	end

    if (framData.nBlend == 1) then -- 设置混合颜色（高亮）
		self:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	end

end
-- 设置每帧播放的时间
-- _fPerFrameTime(float): 2帧之间播放的时间间隔
function MArmature:setPerFrameTime( _fPerFrameTime )
    local framData = self.tFramData    
	framData.fPerFTime = _fPerFrameTime or framData.fPerFTime
end
-- 设置是否每帧暂停
-- _nRPState(float): 1暂停，其他不暂停
function MArmature:setRandomPause( _nRPState )
    local framData = self.tFramData    
	framData.nRandomPause = _nRPState or framData.nRandomPause
end
-- 设置播放结束回调函数
-- _callback(function): 回调函数
function MArmature:setMovementEventCallFunc( _callback )
	self.tFramData.nPlayEndCallback = _callback
end
-- 设置帧数回调函数， 每帧刷新都回调一次，并返回当前帧数
-- _callback(float): 回调函数
function MArmature:setFrameEventCallFunc( _callback )
	self.tFramData.nFrameEventCallback = _callback
end
-- 设置暂停帧数信息
-- nFrame(int): 暂停的帧数
-- nFrameCount(int): 暂停的次数
function MArmature:setRandomPauseParams( nFrame, nFrameCount )
    local framData = self.tFramData    
	framData.nPauseFrame = nFrame
	framData.nPauseFrameCount = nFrameCount
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- 播放结束
function MArmature:playFinish(  )
	self:stop() -- 停止特效    
    local framData = self.tFramData    
	if (framData.nPlayEndCallback) then
		framData.nPlayEndCallback(self)
	end
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- 强制写的引用
function MArmature:retain(  )
	-- 不执行任何操作
end
-- 强制写的释放
function MArmature:release(  )
	-- 不执行任何操作
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- 重置特效状态
function MArmature:resetArmature(  )
    local framData = self.tFramData 
     
	self:setPositionC(framData.fOffsetX * framData.nDir + framData.tPos.x, framData.fOffsetY * framData.nDir + framData.tPos.y)
	self:setScaleC(framData.fScale)
	self:setScaleCX(framData.fScaleX)
	self:setScaleCY(framData.fScaleY)

	self:setRotationC(framData.nRotation)
	self:setOpacity(framData.nOpacity)
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- 每帧刷新特效动作
function MArmature:updateFrame(  )
    
    local framData = self.tFramData 
    
    -- 没数据返回 
    if not framData then
        return
    end

	if (not framData.bPState or not framData.tActions) then -- 特效未播放
		return 
	end

	-- 判断每帧间隔时间是否已经到了
	if (getSystemTime(false) - framData.nLastPTime < framData.fPerFTime * 1000) then
		return 
	end
	framData.nLastPTime = getSystemTime(false)

	if (framData.nRepeat > 0 and framData.nCurRepeat > framData.nRepeat) then
		-- 已经重复播放完毕
		self:playFinish()
		return 
	end

	if (framData.bIsReset) then
		-- 重置特效初始状态
		self:resetArmature() 
	end
	framData.bIsReset = false

	-- 随机暂停
	if (self:randomPause()) then
		return 
	end
	for i=1, #framData.tActions, 1 do
		local pAction = framData.tActions[i]
		if (pAction) then
			-- 若当前帧在此动作的执行帧范围内，则执行动作
			if (framData.nCurFrame >= (pAction.nSFrame or 0) 
					and framData.nCurFrame <= (pAction.nEFrame or 0)) then
				MArmatureUtils:doCstArmAdtions(self, pAction)

			end
		end
	end

	-- 帧事件回调
	if (framData.tFrameEvents) then
		-- 若定义了帧事件列表，则在播放到定义的帧数时回调帧事件回调函数
		for i,v in pairs(framData.tFrameEvents) do
			if (v and v == framData.nCurFrame and framData.nFrameEventCallback) then
				framData.nFrameEventCallback(framData.nCurFrame, self)
			end
		end
	else
		-- 若没有定义帧事件列表，则每帧回调帧事件回调函数
		if (framData.nFrameEventCallback) then
			framData.nFrameEventCallback(framData.nCurFrame, self)
		end
	end

	-- 当前帧加1
	framData.nCurFrame = framData.nCurFrame + 1
	if (framData.nCurFrame > framData.nFrameNum) then
		framData.nCurRepeat = framData.nCurRepeat + 1
		framData.nCurFrame = 1 -- 回到第一帧
		framData.bIsReset = true
	end
end

-- 随机暂停和继续
function MArmature:randomPause(  )
    local framData = self.tFramData  

	if (framData.nRandomPause == 0) then
		return false
	end

	if (not framData.nRPStep) then
		framData.nRPStep = 0
	end
	framData.nRPStep = framData.nRPStep + 1 -- 统计帧数
	if (framData.bRPState) then -- 已经随机暂停
		-- 当当前帧数大于一个随机数时，继续播放
		if (framData.nRPStep > math.random(3, 10)) then
			framData.nRPStep = 0 -- 重新统计帧数
			framData.bRPState = false
		end
	else -- 未随机暂停
		-- 当当前帧数大于一个随机数时，暂停
		if (framData.nRPStep > math.random(5, 20)) then
			framData.nRPStep = 0 -- 重新统计帧数
			framData.bRPState = true
		end
	end

	return framData.bRPState
end

return MArmature