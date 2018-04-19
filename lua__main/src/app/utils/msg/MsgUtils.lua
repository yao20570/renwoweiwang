----------------------------------------------------- 
-- author: xieruidong
-- updatetime: 2017-01-12 18:12:52 
-- Description: 游戏发送消息的工具类
-----------------------------------------------------
-- 引入全局的消息名字
import(".MsgName1")
import(".MsgName2")
import(".MsgName3")
import(".MsgName5")
import(".MsgName5")
import(".MsgName6")
import(".MsgName7")
import(".MsgName8")
import(".MsgName9")
import(".MagName10")

Gt_MsgController = { -- 消息管理者
	-- ["消息名称"] = {{"id"={target=CCObject, handler=nHandler}}} 
}
Gt_UpdateController = { -- 刷新表管理者
	-- ["update_xxxx"] = {target=xxxx, handler=xxxx}
}
-----每秒刷新的注册的监听--------------------------------------------------------------------
local fCurUpdateControlValue = 0
-- 注册刷新消息
-- pTarget(CCNode): 要刷新的界面
-- nHandler(function): 需要执行的函数
function regUpdateControl( _pTarget, _nHandler )
	if(_pTarget == nil or _nHandler == nil) then
		return
	end
    Gt_UpdateController[_pTarget] = _nHandler
end
-- 注销刷新消息
-- pTarget(CCNode): 要取消刷新的界面
function unregUpdateControl( _pTarget )
	if(_pTarget == nil) then
		return
	end
    Gt_UpdateController[_pTarget] = nil
end
-- 执行定时刷新
function doUpdateControl(  )
	if(Gt_UpdateController) then
		for i, v in pairs(Gt_UpdateController) do
            if tolua.isnull(i) then
                Gt_UpdateController[i] = nil
            else
                v()
            end
		end
	end
end

----lua类型的版本-------------------------------------------------------------------
local fCurMsgControlValue = 0
local nMaxDeliverCount = 1 -- 每帧发送消息的最多个数
local tMsgStackDatas = {} -- 消息队列的所有数据
local fCurMsgStackIndex = 0 -- 当前正在发送的消息的tag值
local fMaxMsgStackIndex = 0 -- 当前消息队列列表的最大tag值
local fDisForMsgStack = 0.0001 -- tag标识的间隔
local fLeftMsgStackCount = 0 -- 当前消息队列的个数
tMsgReconnectDatas = {} --重连时消息的缓存表
-- 判断队列是否为空
function checkMsgNameEmpty( _msgName )
	-- 如果消息队列不存在，新建一个消息队列表
	if(not Gt_MsgController[_msgName]) then
		Gt_MsgController[_msgName] = {}
	end
	return Gt_MsgController[_msgName]
end
-- 销毁所有注册好的消息
function destroyAllMsg(  )
	if(Gt_MsgController) then
		for i, v in pairs(Gt_MsgController) do
			Gt_MsgController[i] = nil
		end
		Gt_MsgController = {}
	end
end
--注册消息
--pTarget(CCObject)：消息的接收者，CCObject类型
--msgName(string)：消息的名字
--mHandler(function(sMsgName, table))：消息的接收函数
function regMsg(_pTarget, _msgName, _mHandler)
	-- 判空处理
	local tSeq = checkMsgNameEmpty(_msgName)
	-- 用消息名字和当前id描述唯一标识
	if(_pTarget._fMsgControlIndex == nil) then
		-- 增加一个小点
		fCurMsgControlValue = fCurMsgControlValue + 0.01
		_pTarget._fMsgControlIndex = fCurMsgControlValue
	end
	-- 增加到队列中
	tSeq["msg_" .. tostring(_pTarget._fMsgControlIndex)] = {target=_pTarget, handler=_mHandler}
end
--注销消息
--pTarget(table)：消息的接收者，table类型
--msgName(string)：消息的名字
function unregMsg(_pTarget, _msgName)
	local tSeq = checkMsgNameEmpty(_msgName)
	if(_pTarget and _pTarget._fMsgControlIndex) then
		-- 用消息名字和当前id描述唯一标识
		tSeq["msg_" .. tostring(_pTarget._fMsgControlIndex)] = nil
		if(tMsgStackDatas) then
			tMsgStackDatas[_msgName.."_"..tostring(_pTarget._fMsgControlIndex)] = nil
		end
	end
end
--发送消息
--msgName(string)：消息的名字
--msgObj(table): 消息携带的数据 是一个 table 类型
function sendMsg(_msgName, _msgObj)



	-- 判断消息类型
	local bImmediate = false
	if(_msgName and string.find(_msgName, "ghd_") == 1) then
		bImmediate = true
	end
	-- 如果是分帧类型，不马上发送消息
	if(bImmediate == false) then
		-- 检查队列中是否存在已经注册了该消息的地方
		local tSeq = checkMsgNameEmpty(_msgName)
		-- 将该消息分帧去刷新不同注册的地方
		local nIndex = 0
		for kk, vv in pairs(tSeq) do
			nIndex = nIndex + 1
			-- 记录当前的刷新需求
			vv.leftc = nIndex
			vv.msgObj = _msgObj
			vv.msgName = _msgName
			tMsgStackDatas[_msgName.."_"..tostring(vv.target._fMsgControlIndex)] = vv
		end
	else -- 如果普通类型，立马执行刷新
	    -- 特地为重连增加的处理
		if(getCurConStatus() == e_network_status.ing) then
			if _msgName and _msgName == ghd_state_for_filldlg_msg then --如果是关闭基地蓝色全屏过渡层，则需要发送出去
				-- 实际发送一条数据
				Gf_doRealSendOneMsg(_msgName, _msgObj)
			elseif _msgName == ghd_APP_ENTER_FOREGROUND_EVENT or _msgName == ghd_APP_ENTER_BACKGROUND_EVENT then --如果是前后台切换，需要发送消息
				-- 实际发送一条数据
				Gf_doRealSendOneMsg(_msgName, _msgObj)
			elseif Player:getUIFightLayer() then --如果存在战斗界面（消息还是可以发出去的）
				-- 实际发送一条数据
				Gf_doRealSendOneMsg(_msgName,_msgObj)
			else
				-- 为重连特地建立的临时表，重连完成后分帧发送消息
				local tT = {}
				tT.tMsgObj = _msgObj
				tT.sMsgName = _msgName
				tMsgReconnectDatas[_msgName] = tT
			end
			
		else
			-- 实际发送一条数据
			Gf_doRealSendOneMsg(_msgName, _msgObj)
		end
		
	end
end

-- 正式的发送数据
function Gf_doRealMsgDeliver(  )
	if(tMsgStackDatas) then
		for i, v in pairs(tMsgStackDatas) do
			v.leftc = v.leftc or 1
			v.leftc = v.leftc - 1
			if(v and v.leftc <= 0) then    
				tMsgStackDatas[i] = nil
				local tTarget = v.target
				local nFunc = v.handler
				if(tTarget and tTarget._fMsgControlIndex) then
					nFunc(v.msgName, v.msgObj)
				end        
			end
		end
	end
end
-- 正式发送一条消息
-- 消息数据
function Gf_doRealSendOneMsg( _sMsgName, _tMsgObj )
	if(_sMsgName) then
		-- 检查队列中是否存在已经注册了该消息的地方
		local tSeq = checkMsgNameEmpty(_sMsgName)
		-- 遍历所有已注册的地方，发送消息
		for kk, vv in pairs(tSeq) do
			if(vv) then
				local tTarget = vv.target
				local nFunc = vv.handler
				if(tTarget and tTarget._fMsgControlIndex) then
					nFunc(_sMsgName, _tMsgObj)
				else
					tSeq[kk] = nil
				end
			end
		end
	end
end