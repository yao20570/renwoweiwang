-----------------------------------------------------
-- author: wenzongyao
-- updatetime: 2018-01-17 14:01:05
-- Description: 网络协议的协议号
-----------------------------------------------------
MsgType = MsgType or { }

-- 题目推送
MsgType.pushExamQuestion = { id = - 8551, keys = { } }

-- 每次答题结算推送
MsgType.pushAnswerResult = { id = - 8552, keys = { } }

-- 答题结束推送
MsgType.pushExamActivityEnd = { id = - 8553, keys = { } }

-- 玩家答题
MsgType.reqAnswerQuestion = { id = - 8554, keys = { "answer" } }

-- 领取答题奖励
MsgType.reqExamReward = { id = - 8555, keys = { } }

-- 玩家答题列表刷新
MsgType.reqAnswerPlayers = { id = - 8556, keys = { } }

-- 答题状态请求
MsgType.reqExamState = { id = - 8557, keys = { "state" } }

-- 答题系统登陆请求
MsgType.reqEaxmBaseInfo = { id = - 8558, keys = { } }

-- 答题系统登陆请求
MsgType.pushEaxmRedPoint = { id = - 8559, keys = { } }