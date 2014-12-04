# coding: utf-8
require 'nokogiri'
require 'open-uri'
require 'uri'
require 'csv'

search_term = URI.encode(ARGV[0])
search_page = ARGV[1] ? ARGV[1] : 1
csv_mode = ARGV[2] ? ARGV[2] : 'w'

urls = []

if csv_mode=="w"
  datas = [['URL','タイトル','閲覧数']]
else
  datas = []
end

accessurl = "https://www.youtube.com/results?search_query=#{search_term}&page=#{search_page}"

doc = Nokogiri::HTML(open(accessurl))
elements = doc.xpath("//h3[@class='yt-lockup-title']/a")
elements.each do |a|
  code = a.attributes['href'].value
  urls << "https://www.youtube.com"+code if code.include?('watch')
end

urls.each.with_index {|url,count|
#   puts url
  doc = Nokogiri::HTML(open(url),nil,"UTF-8")
  title = doc.xpath("//h1['watch-headline-title']/span").text.gsub(/\n/,'').strip
  vcount = doc.xpath("//div[@class='watch-view-count']").text
#   puts title
#   puts count
  datas << [url,title,vcount]
  puts "#{count+1}番目まで取得完了"
}

CSV.open('youtube.csv',csv_mode) do |csv|
  datas.each do |d|
    csv << d
  end
end
