
https://build.kinmen.gov.tw/upload/getDocfileAction.do?index_key=1120518112025





move \\192.168.1.166\root\DCGBM_PIC.txt  C:\Users\Administrator\Desktop\查詢書圖目錄\測試\dist\123\replace

include(raw"C:\Users\Administrator\Desktop\常用code\金門抽換\sql\sql.jl")

使用 Text2indexkeynpic(a)        如果要新增圖說才把sql_update 改成sql_insert
     Truepic("1130123170733")


sql_insert(index_key ,constant::String)
sql_update(index_key ,constant::String)

note :: constant要用String
 sql_update(1120518112025,"A101")
sql_inser(1120518112025,"A101")

https://build.kinmen.gov.tw/upload/getDocfileAction.do?index_key=1120518112025
\\192.168.1.166\root\DCGBM_PIC.txt


 sql_update("1121018153858","A2-1、A2-2、A2-3、A2-4")

update  bdmlist_reg set  reedit_date='1130220' where index_key like 'index_key2-00459' and picnum in('A2-1', 'A2-2', 'A2-3', 'A2-4');



 sql_update("1121003144418","61-01、A105、A401")
 sql_update("1120905135647","A1-11、S1-01")
 sql_update("1120821112030","A002、S101、S103、S104、S105")
 sql_inser("1120821112030","19-03")
 sql_update("1120814115520","54-01、A1-01、A2-01、A5-01")
 sql_update("1121121161308","54-01")
 sql_update("1120809104932","54-01")
 sql_update("1121117101513","54-01")
 sql_update("1121206091909","54-01、S101、S102")

使用 Text2indexkeynpic(a)   如果要新增圖說才把sql_update 改成sql_inser

a="""

起造人:聯合金廈物業管理股份有限公司
執照號碼:(112)府建造字第07567號
上傳編號:1121003144418
需修正圖說:61-01、A1-05、A4-01

起造人:國代建設有限公司
執照號碼:(112)府建造字第07574號
上傳編號:1121018153858
需修正圖說:A1-11、S1-01

起造人:吳金添
執照號碼:(112)府建造字第07581號
上傳編號:1120821112030
需修正圖說:19-03、A0-02、S1-01、S1-03、S1-04、S1-05
 
起造人:黃重慶
執照號碼:(112)府建造字第07583號
上傳編號:1120814115520
需修正圖說:54-01、A1-01、A2-01、A5-01
 
起造人:新市鎮建設有限公司
執照號碼:(112)府建造字第07587號
上傳編號:1121121161308
需修正圖說:54-01

起造人:德譯建設開發股份有限公司
執照號碼:(112)府建造字第07592號
上傳編號:1120809104932
需修正圖說:54-01
 
起造人:金門玻璃廠股份有限公司
執照號碼:(112)府建造字第07593號
上傳編號:1121117101513
需修正圖說:54-01

起造人:社團法人金門縣辛氏宗親會
執照號碼:(112)府建造字第07594號
上傳編號:1121206091909
需修正圖說:54-01、S1-01、S1-02
"""


