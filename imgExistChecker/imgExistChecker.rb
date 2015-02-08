# coding: utf-8
#
# Phase1
#
# オプション
# -f => ターゲットファイル復数化
# -d => マッチングさせるディレクトリ
# -o => 非マッチングファイルのコピー先（指定なしなら同ディレクトリでリネーム P2）
#
require 'pry'

# require 'optparse'
# params = ARGV.getopts("tr:")
# OPTS = {}
# opt = OptionParser.new
# opt.on('-f','--file TARGET_FILE',Array) {|v| OPTS[:f] = v }
# opt.on('-o','--output OUTPUT_FILE',String) {|v| OPTS[:o] = v }
# opt.parse(ARGV)
# puts OPTS

targetfile = {}
useimage = {}
chkimage = {}

# オプション引数を配列で取得するメソッド
#
def wai_parse
  @targetfile = {}
  @simpol = ''
  ARGV.each do |v|
    if v =~ /^\-/
      @simbol = ':'+v.gsub('-','')
      @targetfile[@simbol] = []
    else
      @targetfile[@simbol].push(v)
    end
  end
  return @targetfile
end

targetfile = wai_parse()

# 画像パスだけ取得するメソッド
#
def wai_imgpicker(target)
  @useimage = []
  target.each do |t|
    html = File.open(t,'r')
    code = html.read
    html.close
    match = code.scan(/img\/(.+\.(png|gif|jpg|jpeg))/i)
    match.each { |e|
      @useimage.push( e[0] )
    }
  end
  return @useimage
end

useimage = wai_imgpicker(targetfile[':f'])

# 使われていない画像だけ洗い出し
#
def wai_imgsplit(target)
  @result = [[],[]]
  Dir::glob(target[0]+"*"){ |f|
    unless File.directory? f
      img = File.basename(f)
      unless @useimage.include?(img)
        @result[0].push(img)
        @result[1].push(f)
      end
    end
  }
  return @result
end

chkimage = wai_imgsplit(targetfile[':d'])

# 更新処理
#
if targetfile[':o'].nil?
  # -oオプションがない場合
  outdir = targetfile[':d'][0]+'out/'
  FileUtils.mkdir_p(outdir) unless FileTest.exist?(outdir)
  chkimage[0].each_with_index{ |c,i|
    FileUtils.mv(chkimage[1][i],outdir+c)
  }
else
  # -oオプションがある場合
  FileUtils.mkdir_p(targetfile[':o']) unless FileTest.exist?("#{targetfile[':o']}")
  FileUtils.mv(chkimage[1],targetfile[':o'])
end
