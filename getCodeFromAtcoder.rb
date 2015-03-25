# coding: utf-8
require 'open-uri'

def htmlSpecialCharsDecode(line)#htmlの特殊文字をデコード
  line = line.gsub(/&lt;/,'<');
  line = line.gsub(/&gt;/,'>');
  line = line.gsub(/&amp;/,'&');
  line = line.gsub(/&quot;/,'"');
  line = line.gsub(/&;/,'');
  line = line.gsub(/&;/,'');
  line = line.gsub(/&;/,'');
  line = line.gsub(/&;/,'');
  line = line.gsub(/&;/,'');
  line = line.gsub(/&;/,'');
  
  return line
end

########書き換える###################
ID = "AtCoderID" #AtCoderのID
SAVE_DIR = "./atcoder/" #ソースコードを保存する場所へのパス (注)最後の'/'も書く
CONTEST_NAME = "arc" #"abc" または "arc"を指定
###################################

PAGEMAX = 100 #最大ページ数
CONTESTMAX = 100 #最大コンテスト数
LANG_NAME = ["C\s","C++\s","Java\s","C#\s","PHP\s","D\s","Python\s","Perl\s","Ruby\s","C++11\s","Haskell\s","JavaScript\s","Text\s","Python3\s"]
LANG_EXTENSION = [".c",".cpp",".java",".cs",".php",".d",".py",".pl",".rb",".cpp",".hs",".js",".txt",".py"]





if File.exist?(SAVE_DIR)==false then #指定された保存ディレクトリが存在するか確認
  STDERR.puts "the directory is not found :"+SAVE_DIR
  exit(0) #ディレクトリが存在しなかったら強制終了
end

STDERR.puts "START!"

contest_num = 1 #abc***,arc***の***の部分の数字
contest_continue = true #trueの間次のコンテストからもコードを探す

while contest_num<CONTESTMAX && contest_continue==true do
  page_num = 1 #ページ番号
  continue=true
  while page_num<PAGEMAX && continue==true do
    accepted=false
    contest_url = "http://"+CONTEST_NAME+format("%03d",contest_num)+".contest.atcoder.jp/submissions/all/"+String(page_num)+"?user_screen_name="+ID
    
    open(contest_url) {|f|
      filename=""
      extension=""
      next_lang_name=false #trueの時次の行に言語の情報が来る
      f.each_line {|line|
        if line.include?("There is no submission.") then 
          continue=false
        elsif line.include?("<h1>404</h1>") then
          contest_continue=false

        elsif line.include?("/tasks/") then
          filename = line[/a[r|b]c[0-9][0-9][0-9]\_./]

        elsif line.include?("td-selected") then
          next_lang_name = true
          
        elsif next_lang_name==true then
          for i in 0..LANG_NAME.length-1 do
            if line.include?("<td class=\"table-nwb\">"+LANG_NAME[i])==true then
              extension=LANG_EXTENSION[i]
              break
            end
          end
          next_lang_name=false
          
        elsif line.include?("Accepted") then #この行にAcceptedが含まれていれば
          accepted=true

        elsif line.include?("/submissions/") && accepted==true then 
          accepted=false

          code_page_url="http://"+CONTEST_NAME+format("%03d",contest_num)+".contest.atcoder.jp/"+line[/\/submissions\/[0-9]+/] #ソースコードがあるページへのURL
          
          
          if File.exist?(SAVE_DIR+filename+extension)==true then
            #すでに同名のファイルがある場合，別のファイル名をつけるようにする
            c = 2
            filename.concat("("+String(c)+")")
            while File.exist?(SAVE_DIR+filename+extension)==true do
              c+=1
              filename[/\([0-9]+\)/]="("+String(c)+")"
            end
          end
          file = File.open(SAVE_DIR+filename+extension,"w")#ファイルを書込モードでオープン
          STDERR.puts "CREATE : "+SAVE_DIR+filename+extension
          
          open(code_page_url) {|f2|
            code_start = false #ソースコードが始まったらtrueに
            code_end = false #ソースコードが終わったらtrueに
            f2.each_line {|codeline|
              if codeline.size==1 then
                next
              elsif codeline.include?("Source code") then
                code_start=true
                
              elsif code_start==true then
                code_temp = String.new(codeline)
                code_temp.slice!("<pre class=\"prettyprint linenums\">")
                code_temp.slice!("</pre>")
                code_temp = htmlSpecialCharsDecode(code_temp)
                file.print code_temp
              end
              if codeline.include?("</pre>") then
                code_end=true
                break
              end
            }
            if code_end==true then
              file.close
              break
            end
          }
          
          
        end
      }
    }
    page_num+=1
  end
  contest_num+=1
end
STDERR.puts "FINISH!"
