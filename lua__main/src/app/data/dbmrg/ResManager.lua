-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-03-15 14:00:44 星期三
-- Description: 数据库管理类
-----------------------------------------------------
require("lsqlite3")
import(".DBUtils")
import(".DBUtils2")

-- 打开数据库
-- dbName(string): 数据库名字
function openDatabase( dbName )
	-- body
	return sqlite3.open(dbName)
end

-- 关闭数据库
-- db: 要关掉的数据库句柄,执行openDatabase后得到的数据库操作者
function closeDatabase( db )
	-- body
	if(db ~= nil and isDBOpened(db)) then
		db:close()
	end
end

-- 判断数据库是否已经打开
-- db: 要判断的数据库句柄,执行openDatabase后得到的数据库操作者
function isDBOpened( db )
	-- body
	if(db == nil) then
		return false
	end
	return db:isopen()
end

-- 执行查询语句，返回每一行的数据（为table类型）
-- db: 所需要操作的数据库句柄,执行openDatabase后得到的数据库操作者
-- sqlStr(string)：所需要操作的sql语句
-- return：返回所有对应的数据，为function类型
function execForRows( db, sqlStr )
	-- body
	if(db == nil or sqlStr == nil or string.len(sqlStr) <= 0) then
		return nil
	end
	return db:nrows(sqlStr)
end

-- 执行查询语句，返回每一行的数据（为table类型）
-- db: 所需要操作的数据库句柄,执行openDatabase后得到的数据库操作者
-- sqlStr(string)：所需要操作的sql语句
-- return(table)：返回所有对应的数据，为table类型
function execForTable( db,  sqlStr)
	-- body
	local tt = {}
	local index = 1
	for row in execForRows(db, sqlStr) do
        tt[index] = row
        index = index + 1
    end
	return tt
end

-- 返回总条数
-- curTable(table)：当前table
function getRowsCountWithTable( curTable )
	-- body
	if(curTable == nil) then
		return 0
	end
	return table.getn(curTable)
end

