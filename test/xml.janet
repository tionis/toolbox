(import ../toolbox/xml)
(use spork/test)

(start-suite)
(assert
  (deep=
    (peg/match
      xml/grammar
      ``
      <html>
      <body>
      <a href="https://janet-lang.org/">Janet Home Page</a>
      </body>
      </html>
      ``)
    @[{:content @["\n"
                  {:content @["\n"
                              {:attrs @{"href" "https://janet-lang.org/"}
                               :content @["Janet Home Page"]
                               :tag "a"}
                              "\n"]
                   :tag "body"}
                  "\n"]
       :tag "html"}]))

(assert
  (deep=
    (peg/match
      xml/grammar
      ``
      <!doctype html>
      <html>
      <body>
      <a href="https://janet-lang.org/">Janet Home Page</a>
      </body>
      </html>
      ``)
    @[{:content @["\n"
                  {:content @["\n"
                              {:attrs @{"href" "https://janet-lang.org/"}
                               :content @["Janet Home Page"]
                               :tag "a"}
                              "\n"]
                   :tag "body"}
                  "\n"]
       :tag "html"}]))

(assert
  (deep=
    (peg/match
      xml/grammar
      ``
      <?xml version='1.0' encoding="utf-8"?>
      <some>
        <xml>
        here
        </xml>
      </some>
      ``)
    @[{:content @["\n  "
                  {:content @["\n  here\n  "]
                   :tag "xml"}
                  "\n"]
       :tag "some"}]))

(assert
  (deep=
    (peg/match
      xml/grammar
      ``
      <?xml version="1.0" encoding="UTF-8" standalone="no" ?>
      <hi>hello</hi>
      ``)
    @[{:content @["hello"] :tag "hi"}]))

(assert
  (deep=
    (peg/match
      xml/grammar
      ``
      <hi/>
      ``)
    @[{:tag "hi"}]))

(assert
  (deep=
    (peg/match xml/grammar
               ``<hi a="1" b="2"/>``)
    @[{:tag "hi"
       :attrs @{"a" "1" "b" "2"}}]))

(assert
  (deep=
    (peg/match xml/grammar
               ``<hi a="smile" b="breath" >hello</hi>``)
    @[{:content @["hello"]
       :tag "hi"
       :attrs @{"a" "smile" "b" "breath"}}]))

(assert
  (deep=
    (peg/match
      xml/grammar
      ``
      <ho></ho>
      ``)
    @[{:tag "ho"}]))

(assert
  (deep=
    (peg/match xml/grammar
               "<bye><hi>there</hi></bye>")
    @[{:content @[{:content @["there"]
                   :tag "hi"}]
       :tag "bye"}]))

(assert
  (deep=
    (peg/match xml/grammar
               "<bye><hi>the<smile></smile>re</hi></bye>")
    @[{:content @[{:content @["the"
                              {:tag "smile"}
                              "re"]
                   :tag "hi"}]
       :tag "bye"}]))

(assert
  (deep=
    (peg/match
      xml/grammar
      ``
      <hi>hello<bye></bye></hi>
      ``)
    @[{:content @["hello" {:tag "bye"}]
       :tag "hi"}]))

(assert
  (deep=
    (peg/match xml/grammar "<a><a></a></a>")
    @[{:content @[{:tag "a"}]
       :tag "a"}]))

(assert
  (deep=
    (peg/match xml/grammar ``<a b="0"><a c="8"></a></a>``)
    @[{:content @[{:tag "a"
                   :attrs @{"c" "8"}}]
       :tag "a"
       :attrs @{"b" "0"}}]))

(assert
  (deep=
    (peg/match
      xml/grammar
      ``
      <?xml version="1.0" encoding="UTF-8" standalone="no" ?>
      <a><!-- b --><c><!-- d --><e/></c></a>
      ``)
    @[{:content @[{:content @[{:tag "e"}]
                   :tag "c"}]
       :tag "a"}]))

(assert
  (deep=
    (peg/match
      xml/grammar
      ``
      <?xml version="1.0" encoding="UTF-8" standalone="no" ?>
      <oops>💩</oops>
      ``)
    @[{:content @["\xF0\x9F\x92\xA9"]
       :tag "oops"}]))

(assert
  (deep=
    # pushing the bounds of reasonableness for expressing this way?
    (peg/match
      xml/grammar
      ``
      <?xml version="1.0" encoding="UTF-8" standalone="no" ?>
      <rss version="2.0">
      <channel>
        <title>RSS Title</title>
        <description>This is an example of an RSS feed</description>
        <link>http://www.example.com/main.html</link>
        <lastBuildDate>Mon, 06 Sep 2010 00:01:00 +0000 </lastBuildDate>
        <pubDate>Sun, 06 Sep 2009 16:20:00 +0000</pubDate>
        <ttl>1800</ttl>
        <item>
          <title>Example entry</title>
          <description>Here is some text containing an interesting description.</description>
          <link>http://www.example.com/blog/post/1</link>
          <guid isPermaLink="false">7bd204c6-1655-4c27-aeee-53f933c5395f</guid>
          <pubDate>Sun, 06 Sep 2009 16:20:00 +0000</pubDate>
        </item>
      </channel>
      </rss>
      ``)
    # =>
    @[{:content
       @["\n"
         {:content
          @["\n  "
            {:content @["RSS Title"]
             :tag "title"}
            "\n  "
            {:content @["This is an example of an RSS feed"]
             :tag "description"}
            "\n  "
            {:content @["http://www.example.com/main.html"]
             :tag "link"}
            "\n  "
            {:content @["Mon, 06 Sep 2010 00:01:00 +0000 "]
             :tag "lastBuildDate"}
            "\n  "
            {:content @["Sun, 06 Sep 2009 16:20:00 +0000"]
             :tag "pubDate"}
            "\n  "
            {:content @["1800"]
             :tag "ttl"}
            "\n  "
            {:content
             @["\n    "
               {:content @["Example entry"]
                :tag "title"}
               "\n    "
               {:content
                @["Here is some text containing an interesting description."]
                :tag "description"}
               "\n    "
               {:content @["http://www.example.com/blog/post/1"]
                :tag "link"}
               "\n    "
               {:content @["7bd204c6-1655-4c27-aeee-53f933c5395f"]
                :tag "guid"
                :attrs @{"isPermaLink" "false"}}
               "\n    "
               {:content @["Sun, 06 Sep 2009 16:20:00 +0000"]
                :tag "pubDate"}
               "\n  "]
             :tag "item"}
            "\n"]
          :tag "channel"}
         "\n"]
       :tag "rss"
       :attrs @{"version" "2.0"}}]))
(end-suite)
