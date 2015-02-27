module PlainWiki
    class Parser
        def self.parse wikitext
            ps = "detect"
            out = ""
            helper = ""
            linkhelper = ""
            toparse = ""
            linktext = false
            intlinkpiped = false
            speciallev = 0
            wikitext.each_char do |c|
                case ps
                when "detect"
                    if c == "'"
                        next
                    elsif c == "<"
                        ps = "markup"
                    elsif c == "["
                        ps = "link"
                    elsif c == "]"
                        next
                    elsif c == "{"
                        ps = "tabledetect"
                    else
                        out += c
                    end
                when "markup"
                    if c == ">"
                        if helper == "strike"
                            ps = "strike"
                        elsif helper == "nowiki/" || helper == "nowiki /"
                            ps = "detect"
                        elsif helper == "nowiki"
                            ps = "nowiki"
                        elsif helper == "ins" || helper == "u"
                            ps = "underline"
                        elsif helper == "s" || helper == "del"
                            ps = "strike"
                        elsif helper == "code" || helper == "tt" || helper == "pre"
                            ps = "nowiki"
                        elsif helper == "blockquote"
                            ps = "blockquote"
                        elsif helper == "br" || helper == "br /"
                            out += "/n"
                            ps = "detect"
                        elsif helper.include?("!--")
                            ps = "detect"
                        elsif helper.match(/ref .*\//) != nil
                            ps = "detect"
                        elsif helper.match(/ref .*/) != nil
                            ps = "ref"
                        else
                            ps = "detect"
                        end
                        helper = ""
                    else
                        helper += c
                    end
                when "strike"
                    if c == "<"
                        ps = "strikeend"
                    else
                        toparse += c
                    end
                when "strikeend"
                    if c == ">"
                        if helper == "/strike" || helper == "/s" || helper == "/del"
                            out += self.parse(toparse)
                            toparse = ""
                            helper = ""
                            ps = "detect"
                        else
                            toparse += "<"
                            toparse += helper
                            toparse += ">"
                            ps = "strike"
                        end
                        helper = ""
                    else
                        helper += c
                    end
                when "underline"
                    if c == "<"
                        ps = "underlineend"
                    else
                        toparse += c
                    end
                when "underlineend"
                    if c == ">"
                        if helper == "/u" || helper == "/ins"
                            out += self.parse(toparse)
                            toparse = ""
                            helper = ""
                            ps = "detect"
                        else
                            toparse += "<"
                            toparse += helper
                            toparse += ">"
                            ps = "strike"
                        end
                        helper = ""
                    else
                        helper += c
                    end
                when "nowiki"
                    if c == "<"
                        ps = "nowikiend"
                    else
                        out += c
                    end
                when "nowikiend"
                    if c == ">"
                        if helper == "/nowiki" || helper == "/code" || helper == "/tt" || helper == "/pre"
                            helper = ""
                            ps = "detect"
                        else
                            out += "<"
                            out += helper
                            out += ">"
                            ps = "nowiki"
                        end
                        helper = ""
                    else
                        helper += c
                    end
                when "ref"
                    if c == "<"
                        ps = "refend"
                    end
                when "refend"
                    if c == ">"
                        if helper == "/ref"
                            helper = ""
                            ps = "detect"
                        else
                            ps = "ref"
                        end
                    else
                        helper += c
                    end
                when "link"
                    if c == "["
                        ps = "intlink"
                    elsif c == "]"
                        linktext = false
                        out += linkhelper
                        out += " "
                        out += helper
                        linkhelper = ""
                        helper = ""
                        ps = "detect"
                    elsif c == " " && !linktext
                        linktext = true
                    else
                        if !linktext
                            linkhelper += c
                        else
                            helper += c
                        end
                    end
                when "intlink"
                    if c == "]"
                        ps = "intlinkend"
                    elsif c == "|"
                        intlinkpiped = true
                    else
                        if !intlinkpiped
                            linkhelper += c
                        else
                            helper += c
                        end
                    end
                when "intlinkend"
                    if c == "]"
                        if !["Kategoria", "Category", "Plik", "File"].include?(linkhelper.split(":").first)
                            if intlinkpiped
                                if helper == ""
                                    hout = ""
                                    helper.split(":").last.split(" ").each do |s|
                                        if s.match(/\(.*\)/) == nil
                                            hout += " "
                                            hout += s
                                        else
                                            next
                                        end
                                    end
                                    hout.strip!
                                    out += hout
                                else
                                    out += helper
                                end
                            else
                                out += linkhelper
                            end
                        end
                        linkhelper = ""
                        helper = ""
                        intlinkpiped = false
                        ps = "detect"
                    else
                        if !intlinkpiped
                            linkhelper += "]"
                            linkhelper += c
                        else
                            helper += "]"
                            helper += c
                        end
                    end
                when "tabledetect"
                    if c == "|"
                        ps = "table"
                    elsif c == "{"
                        ps = "special"
                        speciallev += 1
                    end
                when "table"
                    ps = "special"
                    speciallev += 1
                when "special"
                    if c == "}"
                        ps = "specialend"
                    elsif c == "{"
                        ps = "tabledetect"
                    end
                when "specialend"
                    if c == "}"
                        speciallev -= 1
                        if speciallev == 0
                            ps = "detect"
                        else
                            ps = "special"
                        end
                    else
                        ps = "special"
                    end
                else
                    ps = "detect"
                end
            end
            out.strip
        end
    end
end