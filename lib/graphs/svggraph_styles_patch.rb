module SVG
  module Graph
    include REXML
    Graph.class_eval do
      def start_svg
        # Base document
        @doc = Document.new
        @doc << XMLDecl.new
        @doc << DocType.new( %q{svg PUBLIC "-//W3C//DTD SVG 1.0//EN" } +
                                 %q{"http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd"} )
        if style_sheet && style_sheet != '' && inline_style_sheet.to_s.empty?
          @doc << Instruction.new( "xml-stylesheet",
                                   %Q{href="#{style_sheet}" type="text/css"} )
        end
        @root = @doc.add_element( "svg", {
            # "width" => width.to_s,
            # "height" => height.to_s,
            "viewBox" => "0 0 #{width} #{height}",
            "xmlns" => "http://www.w3.org/2000/svg",
            "xmlns:xlink" => "http://www.w3.org/1999/xlink",
            "xmlns:a3" => "http://ns.adobe.com/AdobeSVGViewerExtensions/3.0/",
            "a3:scriptImplementation" => "Adobe"
        })
        # @root << Comment.new( " "+"\\"*66 )
        # @root << Comment.new( " Created with SVG::Graph " )
        # @root << Comment.new( " SVG::Graph by Sean E. Russell " )
        # @root << Comment.new( " Losely based on SVG::TT::Graph for Perl by"+
        #                           " Leo Lapworth & Stephan Morgan " )
        # @root << Comment.new( " "+"/"*66 )

        defs = @root.add_element( "defs" )
        add_defs defs
        if !no_css
          if inline_style_sheet && inline_style_sheet != ''
            style = defs.add_element( "style", {"type"=>"text/css"} )
            style << CData.new( inline_style_sheet )
          else
            # @root << Comment.new(" include default stylesheet if none specified ")
            style = defs.add_element( "style", {"type"=>"text/css"} )
            style << CData.new( get_style )
          end
        end

        # @root << Comment.new( "SVG Background" )
        @root.add_element( "rect", {
            "width" => width.to_s,
            "height" => height.to_s,
            "x" => "0",
            "y" => "0",
            "class" => "svgBackground"
        })
      end

      def get_style
        return <<EOL
/* Copy from here for external style sheet */
.svgBackground{
  fill:#ffffff;
}
.graphBackground{
  fill:#ffffff;
}

/* graphs titles */
.mainTitle{
  text-anchor: middle;
  fill: rgb(75, 75, 75);
  font-size: #{title_font_size}px;
  font-family: "Arial", sans-serif;
  font-weight: bold;
}
.subTitle{
  text-anchor: middle;
  fill: #999999;
  font-size: #{subtitle_font_size}px;
  font-family: "Arial", sans-serif;
  font-weight: normal;
}

.axis{
  stroke: #000000;
  stroke-width: 1px;
}

.guideLines{
  stroke: #CCCCCC;
  stroke-width: 0.3px;
  stroke-dasharray: 0 0;
}

.xAxisLabels{
  text-anchor: middle;
  fill: rgb(75, 75, 75);
  font-size: #{x_label_font_size}px;
  font-family: "Arial", sans-serif;
  font-weight: normal;
}

.yAxisLabels{
  text-anchor: end;
  fill: rgb(75, 75, 75);
  font-size: #{y_label_font_size}px;
  font-family: "Arial", sans-serif;
  font-weight: normal;
}

.xAxisTitle{
  text-anchor: middle;
  fill: rgb(75, 75, 75);
  font-size: #{x_title_font_size}px;
  font-family: "Arial", sans-serif;
  font-weight: normal;
}

.yAxisTitle{
  fill: rgb(75, 75, 75);
  text-anchor: middle;
  font-size: #{y_title_font_size}px;
  font-family: "Arial", sans-serif;
  font-weight: normal;
}

.dataPointLabel{
  fill: #000000;
  text-anchor:middle;
  font-size: 20px;
  font-family: "Arial", sans-serif;
  font-weight: normal;
}

.staggerGuideLine{
  fill: none;
  stroke: #000000;
  stroke-width: 0.5px;
}

#{get_css}

.keyText{
  fill: #000000;
  text-anchor:start;
  font-size: #{key_font_size}px;
  font-family: "Arial", sans-serif;
  font-weight: normal;
}
/* End copy for external style sheet */
EOL
      end
    end

    BarBase.class_eval do
      def get_css
        return <<EOL
/* default fill styles for multiple datasets (probably only use a single dataset on this graph though) */
.key1,.fill1{
	fill: rgb(31, 119, 180);
	fill-opacity: 1;
	stroke: none;
	stroke-width: 0.5px;
}
.key2,.fill2{
	fill: rgb(255, 127, 14);
	fill-opacity: 1;
	stroke: none;
	stroke-width: 0.5px;
}
.key3,.fill3{
	fill: rgb(44, 160, 44);
	fill-opacity: 1;
	stroke: none;
	stroke-width: 0.5px;
}
.key4,.fill4{
	fill: rgb(214, 39, 40);
	fill-opacity: 1;
	stroke: none;
	stroke-width: 0.5px;
}
.key5,.fill5{
	fill: #00ccff;
	fill-opacity: 0.5;
	stroke: none;
	stroke-width: 1px;
}
.key6,.fill6{
	fill: #ff00ff;
	fill-opacity: 0.5;
	stroke: none;
	stroke-width: 1px;
}
.key7,.fill7{
	fill: #00ffff;
	fill-opacity: 0.5;
	stroke: none;
	stroke-width: 1px;
}
.key8,.fill8{
	fill: #ffff00;
	fill-opacity: 0.5;
	stroke: none;
	stroke-width: 1px;
}
.key9,.fill9{
	fill: #cc6666;
	fill-opacity: 0.5;
	stroke: none;
	stroke-width: 1px;
}
.key10,.fill10{
	fill: #663399;
	fill-opacity: 0.5;
	stroke: none;
	stroke-width: 1px;
}
.key11,.fill11{
	fill: #339900;
	fill-opacity: 0.5;
	stroke: none;
	stroke-width: 1px;
}
.key12,.fill12{
	fill: #9966FF;
	fill-opacity: 0.5;
	stroke: none;
	stroke-width: 1px;
}
EOL
      end
    end

    Pie.class_eval do
      def get_css
        return <<EOL
.dataPointLabel{
	fill: rgb(75, 75, 75);
	text-anchor:middle;
	font-size: #{datapoint_font_size}px;
	font-family: "Arial", sans-serif;
	font-weight: normal;
}

/* key - MUST match fill styles */
.key1,.fill1{
	fill: rgb(31, 119, 180);
	fill-opacity: 1;
	stroke: none;
	stroke-width: 0.5px;
}
.key2,.fill2{
	fill: rgb(255, 127, 14);
	fill-opacity: 1;
	stroke: none;
	stroke-width: 0.5px;
}
.key3,.fill3{
	fill: rgb(44, 160, 44);
	fill-opacity: 1;
	stroke: none;
	stroke-width: 0.5px;
}
.key4,.fill4{
	fill: rgb(214, 39, 40);
	fill-opacity: 1;
	stroke: none;
	stroke-width: 0.5px;
}
.key5,.fill5{
	fill: #00ccff;
	fill-opacity: 1;
	stroke: none;
	stroke-width: 0.5px;
}
.key6,.fill6{
	fill-opacity: 0.7;
	fill: #ff00ff;
	stroke: none;
	stroke-width: 1px;
}
.key7,.fill7{
	fill-opacity: 0.7;
	fill: #00ff99;
	stroke: none;
	stroke-width: 1px;
}
.key8,.fill8{
	fill-opacity: 0.7;
	fill: #ffff00;
	stroke: none;
	stroke-width: 1px;
}
.key9,.fill9{
	fill-opacity: 0.7;
	fill: #cc6666;
	stroke: none;
	stroke-width: 1px;
}
.key10,.fill10{
	fill-opacity: 0.7;
	fill: #663399;
	stroke: none;
	stroke-width: 1px;
}
.key11,.fill11{
	fill-opacity: 0.7;
	fill: #339900;
	stroke: none;
	stroke-width: 1px;
}
.key12,.fill12{
	fill-opacity: 0.7;
	fill: #9966FF;
	stroke: none;
	stroke-width: 1px;
}
EOL
      end
    end
  end
end
