#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require "rubygems"
require "nokogiri"
require "open-uri"

class XVerror < StandardError
end

class Xvideos
  @@baseurl = "http://www.xvideos.com/video"
  attr_reader :title
  attr_reader :url
  attr_reader :id

  private
  def init(id)
    @url = @@baseurl + id
    @id = id
    begin
      # if "This video has been deleted." then throw a exception
      @page = Nokogiri.HTML(open(@url))
      if (/This\svideo\shas\sbeen\sdeleted\./ =~ @page.to_s) != nil then
        raise XVError
      end

      @title = @page \
        .css("h2")[1] \
        .to_s.sub(/<span\sclass="duration">.*<\/span>/, "") \
        .sub(/<h2>/,"") \
        .sub(/<\/h2>/, "")
    rescue
      raise XVerror
    end
  end

  public
  def initialize(id)
      init(id)
  end

  def getEmbedTag()
    XVEmbed.new(@id).tag
  end
end

class XVEmbed
  @@basetag = '<iframe src="http://flashservice.xvideos.com/embedframe/$videoid$"
frameborder=0 width=$width$ height=$height$ scrolling=no></iframe>'
  attr_reader :tag
  
  def initialize(videoid, width = 510, height = 400)
    @tag = @@basetag.sub(/\$videoid\$/, videoid.to_s).sub(/\$width\$/, width.to_s).sub(/\$height\$/, height.to_s)
  end
end

def idselector()
  baseurl = ""
  videoid = Array.new(7)
  videoid[0] = rand(2)
  1.upto(videoid.size - 1) {|i| videoid[i] = rand(9) }
  videoid.each do |element|
    if element != 0
      baseurl << element.to_s
    end
  end

  return baseurl
end

begin
  xv = Xvideos.new(idselector)
rescue
  retry
end

# HTTP HEADER
print "Content-Type: text/html\n\n"

# HTML value

html = <<"HTML"
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="ja" xml:lang="ja" dir="ltr" xmlns:og="http://ogp.me/ns#" xmlns:fb="http://www.facebook.com/2008/fbml">
  <head>
    <meta property="og:title" content="&#x4eca;&#x6669;&#x306e;&#x304a;&#x304b;&#x305a;" />
    <meta property="og:type" content="sport" />
    <meta property="og:url" content="http://www.byzantion.net/xv.cgi" />
    <meta property="og:image" content="http://www.byzantion.net/len_std.jpg" />
    <meta property="og:site_name" content="&#x4eca;&#x6669;&#x306e;&#x304a;&#x304b;&#x305a;" />
    <meta property="fb:admins" content="100002521159254" />
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>今晩のおかず</title>
  </head>

  <body>
    <h1 style="float: left; margin-top: 0px; margin-bottom: 20px;">今晩のおかず</h1>
    <div style="float: right; margin-top: 0px; margin-bottom: 20px;">
HTML
print html

# twitter tweet button
twstr = '    <a href="https://twitter.com/share?text=今晩のおかずはこれでした. ' + xv.url + '" class="twitter-share-button" data-lang="en">Tweet</a><script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0];if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src="https://platform.twitter.com/widgets.js";fjs.parentNode.insertBefore(js,fjs);}}(document,"script","twitter-wjs");</script>'
print twstr

# facebook like button
fbstr = '<iframe src="//www.facebook.com/plugins/like.php?href=http%3A%2F%2Fwww.byzantion.net%2Fxv.cgi&amp;send=false&amp;layout=standard&amp;width=450&amp;show_faces=false&amp;action=like&amp;colorscheme=light&amp;font&amp;height=25" scrolling="no" frameborder="0" style="border:none; overflow:hidden; width:450px; height:25px;" allowTransparency="true"></iframe>' + "\n"
print fbstr

html = <<"HTML"
    </div>
    <p style="clear: both;">xvideosから今晩のおかずをチョイスします。たまにnot foundだったり、ゲイ動画だったりしますがそこは許してくださいm(__)m</p>
HTML
print html
html = "    <p>Title: ", xv.title, "<br>"
print html
html = '<a href="', xv.url, '">', xv.url, '</a></p>', "\n"
print html
html = '    <div id="embedvideo">' + xv.getEmbedTag + '</div>' + "\n"
print html
html = <<"HTML"
    <p style="margin-top:50px; font-size: 10pt;">このCGIのソースコードは<a href="xv.txt">ここ!</a></p>
  </body>
</html>
HTML
print html
