#crawlers


using PyCall
ENV["PYTHON"]=raw"C:\Users\Administrator\AppData\Local\Programs\Python\Python312\python.exe"

using Pandas
const pd =Pandas

function pyimport_(input::String)
    @eval using Dates
    function install_package(input2::String)
        run(`cmd /C pip install $(input2)`)
        sleep(0.2)
    end
    try

        @eval pyimport(input)
    catch
        println("$input is not installed. Installing...")
        install_package(input)
        @eval import Pkg
        Pkg.build("PyCall")
        @eval using PyCall
        pyimport(input)
    end
end

requests=pyimport_("requests")

r = requests.get("https://ani.gamer.com.tw/")
r.status_code == 200 ? println("請求成功 $(r.status_code)") : println("請求失敗 $(r.status_code)")

headers = Dict(
    "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"
)

r = requests.get("https://ani.gamer.com.tw/",headers=headers)
r.status_code == 200 ? println("請求成功 $(r.status_code)") : println("請求失敗 $(r.status_code)")


print(r.text)

# 存成html
open("output.html", "w") do file
    write(file, r.text)
end

#
bs4=pyimport_( "bs4")
bs4.BeautifulSoup
soup = bs4.BeautifulSoup(r.text, "html.parser")
#一組動畫的元素
newanime_item = soup.select_one(".timeline-ver > .newanime-block")
anime_items = newanime_item.select(".newanime-date-area:not(.premium-block)")

length(anime_items )


for i in anime_items
    anime_name = i.select_one(".anime-name > p")|>PyCall.pybuiltin("list")
    println( "名稱: ",anime_name[1] )
    anime_watch_number = i.select_one(".anime-watch-number > p")|>PyCall.pybuiltin("list")
    println("觀看次數: ",anime_watch_number[1] )
    try anime_episode = i.select_one(".anime-episode > p")|>PyCall.pybuiltin("list")
        println("集數: ",anime_episode )

    catch 
        println("集數缺")

    end

    #println("集數: ",anime_episode )
    anime_href = i.select_one("a.anime-card-block").get("href")
    println("網址: ","https://ani.gamer.com.tw/",anime_href )
    println("###############")
end


#金門
index_key3="1121004162222"
#http://build.kinmen.gov.tw/upload/getDocfileAction.do?index_key=1121004162222
r = requests.get("http://build.kinmen.gov.tw/upload/getDocfileAction.do?index_key=$(index_key3)",headers=headers)

soup = bs4.BeautifulSoup(r.text, "html.parser")

newanime_item = soup.select_one("tr > .form-headup-c")
newanime_item = soup.select("tr > .form-headup-c")
#先看


function vectorstring2string(data)
    f=data|>PyCall.pybuiltin("list")
    return f[1]
end


apple=map(x->vectorstring2string(x),newanime_item )
rows = soup.find_all("tr")
global picdraW=[]
for row in rows
    # 在每个 <tr> 中查找第一个 <td class="form-headup-c">

    first_id = row.find("td", class_="form-headup-c")
    try picmap=vectorstring2string(first_id)
        push!(picdraW,picmap)

    catch 
        nothing
    end
end
#picmap=map(x->vectorstring2string(x.find("td", class_="form-headup-c")),rows )
#抓出每個值

#寫成記事本
# 存成html
open("output.txt", "w") do file
    for line in picdraW
        write(file, line * "\n")
    end
end

#將它變成

pattern = r"(\w+)"
picdraW
matches = eachmatch(pattern,picdraW[1])
matches=[]
first(collect(eachmatch(r"\b[A-Za-z\d、-]+", picdraW[1]))).match

for i in picdraW
    println(i)
    push!(matches,first(collect(eachmatch(r"\b[A-Za-z\d、-]+", i))).match)
end
# Text2indexkeynpic2("""
# 起造人:信譽建設有限公司
# 執照號碼:(112)府建造字第07571號
# 上傳編號:1121004162222
# 需修正圖說:A9-05、A9-06、A9-07、A9-08、A9-09、A9-010、A9-11、A9-12""")
# # 將下列
# A9-05、A9-06、A9-07、A9-08、A9-09、A9-010、A9-11、A9-12

# a=Dict([("AA",2),("VV",3)])

# get(a,"ccc",11)


#mach 照字排列


Classification_A=String[]
Classification_D=String[]
Classification_number=String[]
patternA=r"A.*"
patternD=r"D.*"


for i in matches
    match(patternA,i) != nothing ? push!(Classification_A,i) : (match(patternD,i) != nothing ? push!(Classification_D,i) : push!(Classification_number,i))
end

println("A 類 :",Classification_A)

println("D 類 :"Classification_D)

println("數字 類 :"Classification_D)