-----------------------------------------------------
-- author: wenzongyao
-- updatetime: 2018-1-17 14:25:11
-- Description: 每日答题数据
-----------------------------------------------------

-- 玩家状态
e_exam_join_state = {}
e_exam_join_state.join      = 1 -- 进入答题
e_exam_join_state.exit      = 0 -- 退出答题
                                    
-- 活动状态
e_exam_state = {}
e_exam_state.ready          = 0 -- 准备阶段(0点后 -- 开始答题)
e_exam_state.question       = 1 -- 问题阶段
e_exam_state.result         = 2 -- 结果阶段
e_exam_state.over           = 3 -- 结束阶段(答题结束 -- 0点前)

-- 奖励领取状态
e_exam_reward_state = {}
e_exam_reward_state.none    = 0 -- 无法领取
e_exam_reward_state.not_get = 1 -- 未领取
e_exam_reward_state.has_got = 2 -- 已领取

-- 静态变量
local const_OneDaySec       = 3600 * 24     -- 一天的秒数

require("app.data.dbmrg.DBUtils") 
local Activity = require("app.data.activity.Activity")

local DataExam = class("DataExam", function()
    return Activity.new(e_id_activity.snatchturn)
end )

function DataExam:ctor()
    self:myInit()
end

function DataExam:myInit()
    self.bIsConfigReady     = false -- 是否已获得配置
    self.nQuestionId        = 0
    self.nQuestionIndex     = 0
    self.nCorrectIndex      = 0
    self.nAnswerEndLocalTimeStamp    = 0
    self.nResultEndLocalTimeStamp    = 0
    self.nActivityOpenLocalTimeStamp = 0

    self.nJoinState         = e_exam_join_state.exit
    self.nExamState         = e_exam_state.ready

    self.nScore             = 0
    self.nPlayerAnswerId    = 0
    self.tAnswerPlayers     = {{},{},{}}

    self.sFirst             = "" 
    
    self.nCorrectCount      = 0
    self.nWrongCount        = 0
    self.sActivityOpenTime  = "00:00:00"
    self.nMaxCount          = 0
    self.nAnTime            = 0
    self.nCDTime            = 0
    self.nRefreshTime       = 0
    self.nRankRewardState   = e_exam_reward_state.none
    self.nRankd             = 0
    self.tRewards           = {}


    self.tRewardList        = {}

    self.nReadyStart        = false
end


function DataExam:refreshBaseInfo(_tData)

    self.nRankRewardState   = _tData.g      or self.nRankRewardState    -- int 排行奖励领取状态
    self.tRewardList        = _tData.info   or self.tRewardList         -- list 排名奖励
    self.nCorrectCount      = _tData.right  or self.nCorrectCount       -- int 答对题数
    self.nWrongCount        = _tData.err    or self.nWrongCount         -- int 答错题数
    self.sActivityOpenTime  = _tData.ot     or self.sActivityOpenTime   -- string 活动开启时间(格式00:00:00)
    self.nMaxCount          = _tData.mxt    or self.nMaxCount           -- string 题目数量
    self.nAnTime            = _tData.at     or self.nAnTime             -- string 抢答时间
    self.nCDTime            = _tData.cdt    or self.nCDTime            -- string 显示答题结果时间
    self.nRefreshTime       = _tData.rt     or self.nRefreshTime        -- string 答题后刷新答题玩家列表cd

    --fix:红点由8559推送开始，答题结束而结束，但没答过题，后端不会推答题结束（8553）协议，由前端计算。。。
    local nCurLocalTimeStamp = getSystemTime(true)
    local nOpenTime = parseTimeFormatToNum(self.sActivityOpenTime)                          -- 活动每天开始时间
    local nMaxCount = self.nMaxCount
    local nAnTime = self.nAnTime
    local nCDTime = self.nCDTime
    local nCloseTime = nOpenTime + nMaxCount * (nAnTime + nCDTime)                          -- 活动每天关闭时间 
    local nDayPassSec = (math.floor(_tData.ct / 1000) + n_GMT) % const_OneDaySec            -- 当天已过秒数 
    self.nActivityCloseLocalTimeStamp = nCurLocalTimeStamp + nCloseTime - nDayPassSec       -- 活动每天关闭时间 
    self.nActivityOpenLocalTimeStamp = nCurLocalTimeStamp + nOpenTime - nDayPassSec             -- 活动开启时间戳  


    self.bIsConfigReady     = true
end

-- 和e_exam_state.ready不一样，
-- 这个是在每次公告和推送第一道题时由服务端推送过来，作为红点
function DataExam:setReadyStart(_bIs)
    self.nReadyStart = _bIs
end
function DataExam:isReadyStart()
    return self.nReadyStart
end

-- 刷新题目
function DataExam:refreshQuestion(_tData)
    if not _tData then
        return
    end

    if self.bIsConfigReady == false then
        return
    end

    -- _tData.cas:当前答题的答案 -1为未答题
    if _tData.cas == nil or _tData.cas == -1 then 
        self:setHasAnswer(false)
    else        
        self:setHasAnswer(true)
        self:setPlayerAnswerId(_tData.cas)
    end

    self.nScore                 = _tData.i      or self.nScore          -- long 玩家当前答题积分（上期积分通过排行榜获取）
    self.nQuestionId            = _tData.t      or self.nQuestionId     -- int 题目ID
    self.nCorrectIndex          = _tData.r      or self.nCorrectIndex   -- int 正确答案
    self.nQuestionIndex         = _tData.n      or self.nQuestionIndex  -- int 题目编号
                                         
    -- 玩家状态
    self.nJoinState = _tData.j

    local curServerTime = _tData.ct 
    -- 活动状态
    if _tData.ct == nil then
        myprint("DataExam====>服务器时间是必须发的...状态是根据服务器时间来设置!!!") 
    else                
        local nCurLocalTimeStamp = getSystemTime(true)
        local nOpenTime = parseTimeFormatToNum(self.sActivityOpenTime) -- 活动每天开始时间
        local nMaxCount = self.nMaxCount
        local nAnTime = self.nAnTime
        local nCDTime = self.nCDTime
        local nCloseTime = nOpenTime + nMaxCount * (nAnTime + nCDTime) -- 活动每天关闭时间 

        
        local nDayPassSec = (math.floor(_tData.ct / 1000) + n_GMT) % const_OneDaySec          -- 当天已过秒数 
        self.nActivityOpenLocalTimeStamp = nCurLocalTimeStamp + nOpenTime - nDayPassSec             -- 活动开启时间戳  
          
        local nRoundPassTime = (nDayPassSec - nOpenTime) % (nAnTime + nCDTime)                      -- 回合已过时间    
        self.nAnswerEndLocalTimeStamp = nCurLocalTimeStamp + nAnTime - nRoundPassTime               -- 设置本地抢答结束时间 
        self.nResultEndLocalTimeStamp = nCurLocalTimeStamp + (nAnTime + nCDTime) - nRoundPassTime   -- 设置本地抢答CD剩余时间

        if nDayPassSec < nOpenTime then
            -- 活动未开始
            self:setExamState(e_exam_state.ready)
            self.nScore = 0

        elseif nDayPassSec < nCloseTime then              
            if nRoundPassTime < nAnTime then        
                -- 抢答阶段
                self:setExamState(e_exam_state.question)
                self:setAnswerPlayers(nil)
            else
                -- 显示结果阶段
                self:setExamState(e_exam_state.result)                                
            end
        else
            -- 活动结束
            self:setExamState(e_exam_state.over)
            self.nScore = 0
        end
    end

end

-- 刷新答题结果
function DataExam:refreshAnswerResult(_tData)
    if not _tData then
        return
    end

    _tData.i = _tData.i or 0
    local nTempScore = _tData.i - self.nScore
    self.nScore = _tData.i or self.nScore                       -- long 玩家积分
    self.nPlayerAnswerId = _tData.wa or self.nPlayerAnswerId    -- int 玩家答案

    if self.nCorrectIndex == self.nPlayerAnswerId then
        TOAST(string.format(getTipsByIndex(20100), nTempScore))
    else
        TOAST(getTipsByIndex(20101))
    end

    -- 更新对错数量
    if self.nCorrectIndex == self.nPlayerAnswerId then
        self.nCorrectCount = self.nCorrectCount + 1
    else
        self.nWrongCount = self.nWrongCount + 1
    end

    -- 设置为结果阶段
    self:setExamState(e_exam_state.result)
end

-- 刷新今日抢答活动信息
function DataExam:refreshExamEnd(_tData)
    if not _tData then
        return
    end

    self.sFirst                 = _tData.f      or self.sFirst              -- string 第一名
    self.nCorrectCount          = _tData.co     or self.nCorrectCount       -- int 答对题数
    self.nWrongCount            = _tData.er     or self.nWrongCount         -- int 答错题数
    self.nRankRewardState       = _tData.g      or self.nRankRewardState    -- int 领取状态 2已领取 1未领取 0无法领取
    self.nRankd                 = _tData.r      or self.nRankd              -- int 排名
    self.tRewards               = _tData.rw     or self.tRewards            -- List<Pair<Integer,Long>> 获得奖励
    
    self:setExamState(e_exam_state.over)
    self.nScore = 0

    -- 播放获得的奖励
    showGetAllItems(self.tRewards)
end

-- 刷新答题玩家列表
function DataExam:refreshAnswerPlayers(_tData)
    if not _tData then
        return
    end
    self:setAnswerPlayers(_tData.l)      
end

-- 答题玩家列表 
-- _tAnswerPlayers 结构 List<AnsList>
function DataExam:setAnswerPlayers(_tAnswerPlayers)
    if _tAnswerPlayers == nil then
        self.tAnswerPlayers = {{},{},{}}
    else
        self.tAnswerPlayers = {}
        for _, tPlayers in pairs(_tAnswerPlayers) do
            self.tAnswerPlayers[tPlayers.a] = tPlayers.r
        end
    end
end

-- 获取玩家的活动状态
-- return e_exam_join_state
function DataExam:getJosinState()
    return self.nJoinState
end

-- 获取答题状态
-- _nState : e_exam_state
function DataExam:setExamState(_nState)
    self.nExamState = _nState
end
-- return e_exam_state
function DataExam:getExamState()
    return self.nExamState
end

-- 获取本地抢答活动开启时间戳
function DataExam:getActivityOpenLocalTimeStamp()
    return self.nActivityOpenLocalTimeStamp
end

-- 获取本地抢答结束时间戳
function DataExam:getAnswerEndLocalTimeStamp()
    return self.nAnswerEndLocalTimeStamp
end

-- 获取本地抢答结果显示结束时间戳
function DataExam:getResultEndLocalTimeStamp()
    return self.nResultEndLocalTimeStamp
end

-- 答题状态
-- _nState : e_exam_reward_state
function DataExam:setRankRewardState(_nState)
    self.nRankRewardState = _nState
end
-- return e_exam_reward_state
function DataExam:getRankRewardState()
    return self.nRankRewardState
end
-- 能否领取排名奖励
function DataExam:isCanGetRankReward()
    -- 从数据层来说
    if self:isActivityInOpen() == false and self.nRankRewardState == e_exam_reward_state.not_get then
        return true
    end
    return false
end

-- 抢答活动开放中
function DataExam:isActivityInOpen()
    local nExamState = self:getExamState()
    return nExamState == e_exam_state.question or nExamState == e_exam_state.result
end

-- 答题玩家列表
function DataExam:getAnswerPlayers(_nIndex)    
    return self.tAnswerPlayers[_nIndex] or {}
end

-- 获取答对的题数
function DataExam:getCorrectCount()
    return self.nCorrectCount
end

-- 获取答错的题数
function DataExam:getWrongCount()
    return self.nWrongCount
end

-- 获取答题积分
function DataExam:getScore()
    return self.nScore
end

-- 排名奖励列表
function DataExam:getRewardList()
    return self.tRewardList
end

-- 当前回合是否已答题
function DataExam:setHasAnswer(_bIs)
    self.bIsHasAnswer = _bIs or false
end
function DataExam:isHasAnswer()
    return self.bIsHasAnswer
end

-- 答题答案
function DataExam:setPlayerAnswerId(_nId)
    self.nPlayerAnswerId = _nId
end
function DataExam:getPlayerAnswerId()
    return self.nPlayerAnswerId
end

-- 答案对错
-- nAnswerIndex答案序号
function DataExam:isAnswerCorrect(nAnswerIndex)
    return self.nCorrectIndex == nAnswerIndex
end


return DataExam