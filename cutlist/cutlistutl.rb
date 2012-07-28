# Some utility definitions of a general scope

# add a method to return if the current model units is metric
def metricModel? 
  model = Sketchup.active_model

  # Get the length Units of the active model from the unitsOptions
  # 0=inches,1=feet,2=mm,3=cm,4=m
  unit = model.options["UnitsOptions"]["LengthUnit"]
  return !(unit==0 || unit==1)
end
  
def modelInMeters?
  model = Sketchup.active_model
  unit = model.options["UnitsOptions"]["LengthUnit"]
  return (unit==4)
end
  
# extend class Float to provide rounding to x digits
class Float
  def round_to(x)
    (self * 10**x).round.to_f / 10**x
  end
end

# extend class string to be able to convert the string to an html compliant string
# as well as some manipulations required for CutList Plus compatibility and other string
# filters
class String
#This will html-ise a string so that we don't have problems displaying in html
# returns a copy of the string with problematic characters replaced by escape sequences
  def to_html
    val = self.gsub(/[&]/, "&amp;")  #do & first, so we don't convert the conversions!
    #val = val.gsub(/[']/, "\\\\\'")
    val = val.gsub(/[ ]/, "&#32;")
    val = val.gsub(/[']/, "&#39;")
    val = val.gsub(/["]/, "&quot;")
    val = val.gsub(/[<]/, "&lt;")
    val = val.gsub(/[>]/, "&gt;")
    val = val.gsub(/[-]/, "&#45;")
    return val
  end 
  
  # remove the inch character notation "
  def no_inch
    self.gsub(/["]/,"")
  end
  # remove the foot notation ie : '
  def no_foot
    self.gsub(/[']/,"")
  end
  # remove the mm notation ie :"mm"
  def no_cm
    self.gsub(/[mm]/,"")
  end
  # remove the cm notation ie : "cm"
  def no_mm
    self.gsub(/[cm]/,"")
  end
  
  # cut list plus doesn't like inch character " for inch dimensions on import - these must be
  # escaped by doubling them up
  # feet character ie: "'" is interpreted ok
  # mm characters "mm" are interpreted ok
  # cm characters "cm" are interpreted ok
  # units in m are not allowed, so these must be converted prior to this
  def to_clp
    val = self.gsub(/["]/,"\"\"")
    #val = val.gsub(/[~]/,"")
  end
  
  # 1, remove the '~' for csv text whether it is straight csv or csv for CLP
  # 2, if a value is in a fraction form and less than 1, then it must be converted 
  # to the format "0 y/z"
  # so that programs like excel convert this to a decimal value instead of text or
  # worse, a date
  # Note: since CLP is also a csv file, it also gets this same conversion. Turns out
  # this is a good thing because CLP has the same problem with fractions < 1 and
  # the solution works for both Excel and CLP
  def to_csv
#   1. remove the ~
#     puts "to_csv step 0 val=" + self
     val = self.gsub(/[~]/,"")
#     puts "to_csv step 1 val=" + val
#   2. Determine if this field is a size is in the format "x y/z" and if x="", then insert a 0
#   The pattern matches on any digits and spaces before a fraction, then the fraction which
#   consists of any number of digits + "/" + any number of digits - (\d+\/\d+)
#   (\D*) gobbles up the units at the end and the $ makes sure that the match is at the
#   endof the string
#   on a match, match[0] is always the entire match string and match[1..n] are the 
#   matches of each block, delineated by the brackets.
#   regexp expression was tested using rubular.com - a Ruby regular expression editor
     pattern = /(\S*\s)*(\d+\/\d+)(\D*)$/
     match = val.match pattern
#    if match == nil
#	puts "to_csv step 2 match nil" 
#    else
#	puts "to_csv step 2 match found" 
#	puts "match1 is nil" if match[1] == nil 
#	puts "match1 is " + match[1] if match[1] != nil
#	puts "match2 is " + match[2] if match[2] != nil
#	puts "match3 is " + match[3] if match[3] != nil
#	puts "match4 is " + match[4] if match[4] != nil
#	end	     
     if ( match && match[1] == nil && match[2] != nil )
	val="0 " + self
## DEBUG
#	puts "to_csv step 3 val=" + val
## DEBUG
     end
     return val
  end
  
  #csv files may require units to be removed so provide a way of doing this
  # when measurements are not accurate, SU generates a ~, remove those as well
  def no_Units
    val = self.no_inch
    val = val.no_foot
    val = val.no_cm
    val = val.no_mm
    val = val.gsub(/[~]/,"")
    return val
  end
end

#extend class integer to be able to print fixed width integers
class Integer
  # print an integer as a fixed width field of size width.
  # Pads with 0's if too short, it will truncate if too long.
  def to_fws(width)
    val="%0#{width}d" % self.to_s
  end
end

#extend sketchup class Group so that we can reference the definition from which a 
# group instance has been derived. This makes it analagous to a ComponentInstance
# Sketchup groups also have a component definition but it's not
# directly accessible  so we have to start from the model definitions and search
# looking for the entity which matches ours. Once found we can use it just like
# for Component Instance
class Sketchup::Group
  def definition
    definitions = Sketchup.active_model.definitions
    definitions.each { |definition|
      definition.instances.each { |instance|
        if instance.typename=="Group" && instance == self
          return definition
        end
      }
    }  
    return nil
  end
end
