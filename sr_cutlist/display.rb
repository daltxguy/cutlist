module SteveR
	module CutList
#########################
# Display_class superclass      #
#########################
class Display_class

  def initialize(inRenderer, inMetric)
    @renderer = inRenderer
    @metric = inMetric
    @roundToNumOfDigits = 2
    @roundToNumOfDigits = 4 if(@metric)
  end ## end initialize

  def getTitle(title)
    return @renderer.getTitle(title)
  end ## end getTitle

  def getHeaderRow(headers)
    return @renderer.getHeaderRow(headers)
  end ## end getHeaderRow

  def getFooterRow()
    return @renderer.getFooterRow()
  end ## end getFooterRow

  def getRow(columns)
    return @renderer.getRow(columns)
  end ## end getRow

  def getAmount(amount)
    return @renderer.getAmount(amount)
  end ## end getArea

  def getBlankLine()
    return @renderer.getBlankLine()
  end ## end getBlankLine

  def to_s(inList)
  end ## end to_s

end ##Display_class

#########################
# Display                                              #
#########################
class Display < Display_class
  
  def initialize(inRenderer, inMetric)
    super(inRenderer, inMetric)
      @measureLabel = getMeasureLabel
      @measureUnits = getMeasureUnits
  end
  
  def getMeasureLabel
    if @metric
      return "Cubic m"
    else
      return "Board Foot"
    end
  end
  
  def getMeasureUnits
    if @metric
      return "m"
    else
      return "Feet"
    end
  end
  
  def getPartPrefix()
    return "C-"
  end

  def getTitleName()
    return "Components";
  end

  def getHeadingArray()
      headings=["Part #","Sub-Assembly","Description","Length(L)","Width(W)","Thickness(T)",@measureLabel,"Material"]
   return headings
  end

  def getAmountTitleName()
      return "Total Component " + @measureLabel
  end

  def getMaterialTitleName()
    return "Component Materials"
  end

  def isAmountEnabled()
    return true
  end

  def isMaterialEnabled()
    return true
  end
  
  def processRows(inList)

    component=""
    cols = Array.new
    i = 1
    ii = 0
    ix = ""
    cx = ""
    
    for c in inList
      i = i + 1 if c.getName != cx and cx != ""
      ii = 1 if c.getName != cx
      ix = CutList::integer_to_fws(3,i) + "-" + CutList::integer_to_fws(2,ii)
      cols[0]=getPartPrefix()+ix
      cols[1]=c.getSubAssemblyName
      cols[2]=c.getName
      cols[3]=c.getLengthString
      cols[4]=c.getWidthString
      cols[5]=c.getThicknessString
      # the next  line is modified specifically for european users who default to an English version
      # of Sketchup - as Sketchup does not seem to convert these numericals to have comma as the decimal
      # When I find a way to automatically discover which way the user needs to have this, then this can
      # be replaced with some external check - or else decimal to comma can return the string 
      # unchanged.
      #cols[6]=c.getBoardFeet.to_s
      cols[6]=CutList::decimal_to_comma(c.getBoardFeet.to_s)
      
      cols[7]=c.getMaterial
      component = component + getRow(cols)
      ### gives sub-part numbers to same named compos; last = total
      ii = ii + 1
      cx = c.getName
      ## Add the board feet
      @totalBF = @totalBF + c.getBoardFeet
      inList = false
      for d in @materialList
        if(d[0]==c.getMaterial)
          d[1] = d[1]+c.getBoardFeet
          inList = true
        end  ## end if
      end  ## end for

      if(!inList)
            @materialList = @materialList.push([c.getMaterial,c.getBoardFeet])
      end
          
    end ## end for
                          
    return component
  end ## end processRows

  def to_s(inList)

    @materialList = []
    @totalBF = 0
    @totalLength = 0
    tempFloat = 0
      
    component = ""
    component = component + getTitle(getTitleName())
    headings = getHeadingArray()
    component = component + getHeaderRow(headings)
    component = component + processRows(inList)
    component = component + getFooterRow()
    component = component + getBlankLine()

    ## Total Board Feet Table
    if(isAmountEnabled())
      component = component + getTitle(getAmountTitleName())
      cols = Array.new
      tempFloat = CutList::float_round_to(@roundToNumOfDigits, @totalBF)
      # the next  line is modified specifically for european users who default to an English version
      # of Sketchup - as Sketchup does not seem to convert these numericals to have comma as the decimal
      # When I find a way to automatically discover which way the user needs to have this, then this can
      # be replaced with some external check - or else decimal to comma can return the string 
      # unchanged.
      #cols[0] = tempFloat.to_s
      cols[0] = CutList::decimal_to_comma(tempFloat.to_s)
      component = component + getRow(cols)
      component = component + getFooterRow()
      component = component + getBlankLine()
    end

    ## Materials Table
    if(isMaterialEnabled())
      component = component + getTitle(getMaterialTitleName())
      headings=["Material",@measureLabel]
      component = component + getHeaderRow(headings)
      for d in @materialList
        cols = Array.new
        cols[0] = d[0]
	tempFloat =  CutList::float_round_to(@roundToNumOfDigits, d[1])
        # the next  line is modified specifically for european users who default to an English version
	# of Sketchup - as Sketchup does not seem to convert these numericals to have comma as the decimal
	# When I find a way to automatically discover which way the user needs to have this, then this can
        # be replaced with some external check - or else decimal to comma can return the string 
        # unchanged.
        #cols[1] = tempFloat.to_s
        cols[1] = CutList::decimal_to_comma(tempFloat.to_s)
        component = component + getRow(cols)
      end ## end for
      component = component + getFooterRow()
      component = component + getBlankLine()
    end

    return component

  end ## end to_s

end ##Display class

#########################
# CompactDisplay                                   #
#########################
class CompactDisplay < Display

  def getHeadingArray()
    #headings=["Part#","Quantity","Sub-Assembly","Description","Length(L)","Width(W)","Thickness(T)",@measureLabel + " (per)",
    headings=["Part#","Quantity","Description","Length(L)","Width(W)","Thickness(T)",@measureLabel + " (per)",
    @measureLabel + " (total)", "Total Length (" + @measureUnits + ")", "Material"]
    return headings
  end

  def processRows(inList)

    component=""
    partId = 1
    partCount = 1
    #firstPart = ["","",0,0,0,""]
    firstPart = ["",0,0,0,""]
    lastPart = firstPart
    cols = Array.new
    row=""

    for c in inList

# If parts match the name and dimensions and material, then they are considered the
# same and will be displayed in the compact form
      if (  ( c.getName            == lastPart[0] ) &&
            #( c.getSubAssemblyName == lastPart[1] ) &&
            ( c.getLengthString    == lastPart[1] ) &&
            ( c.getWidthString     == lastPart[2] ) &&
            ( c.getThicknessString == lastPart[3] ) &&
            ( c.getMaterial        == lastPart[4] ) )
        puts "parts matched " + c.getName + " l=" + c.getLength.to_s  + " w=" + c.getWidth.to_s + " t=" + c.getThickness.to_s + " m=" + c.getMaterial
        partCount = partCount + 1
      elsif(lastPart != firstPart)
        puts "parts did not match " + c.getName + " l=" + c.getLength.to_s  + " w=" + c.getWidth.to_s + " t=" + c.getThickness.to_s + " m=" + c.getMaterial
        component = component + row
        partId = partId + 1
        partCount = 1
      end ##if

      cols[0]=getPartPrefix() + CutList::integer_to_fws(3,partId)
      cols[1]=partCount.to_s
      #cols[2]=c.getSubAssemblyName
      cols[2]=c.getName
      cols[3]=c.getLengthString
      cols[4]=c.getWidthString
      cols[5]=c.getThicknessString
      # the next three lines are modified specifically for european users who default to an English version
      # of Sketchup - as Sketchup does not seem to convert these numericals to have comma as the decimal
      # When I find a way to automatically discover which way the user needs to have this, then this can
      # be replaced with some external check - or else decimal to comma can return the string 
      # unchanged.
      #cols[6]=c.getBoardFeet.to_s
      #cols[7]=((c.getBoardFeet)*(partCount)).to_s
      #cols[8]=((c.getTotalLength)*(partCount)).to_s
      cols[6]=CutList::decimal_to_comma(c.getBoardFeet.to_s)
      # Multiply the quantity of the same part by the board feet and lengths to get the totals for that part
      # The results will be a float so needs to be rounded to produce reasonable sized decimal numbers
      roundedBoardFeetTotal =  CutList::float_round_to(@roundToNumOfDigits,(c.getBoardFeet * partCount))
      roundedTotalLengthTotal =  CutList::float_round_to(@roundToNumOfDigits,(c.getTotalLength * partCount))
      cols[7]=CutList::decimal_to_comma(roundedBoardFeetTotal.to_s)
      cols[8]=CutList::decimal_to_comma(roundedTotalLengthTotal.to_s)
      
      cols[9]=c.getMaterial
      row = getRow(cols)
      lastPart = [c.getName,c.getLengthString,c.getWidthString,c.getThicknessString, c.getMaterial]
      #lastPart = [c.getName,c.getSubAssemblyName,c.getLengthString,c.getWidthString,c.getThicknessString, c.getMaterial]

      ## Add the square feet
      @totalBF = @totalBF + c.getBoardFeet
      inList = false
      for d in @materialList
        if(d[0]==c.getMaterial)
          d[1] = d[1]+c.getBoardFeet
          inList = true
        end
      end

      if(!inList)
        @materialList = @materialList.push([c.getMaterial,c.getBoardFeet])
      end

    end#for c

    ##Output last row
    component = component + row

    return component
  end ## end processRows


end ##class CompactDisplay

#-----------------------------------------------------------------------------
#########################
# CompactPart           #
#########################
class CompactDisplayPart < CompactDisplay

  def getPartPrefix()
    return "P-"
  end

  def getTitleName()
    return "Other Parts";
  end

  def getHeadingArray()
   headings=["Part #","Quantity","Description"]
   return headings
  end

  def getAmountTitleName()
    return ""
  end

  def getMaterialTitleName()
    return ""
  end

  def isAmountEnabled()
    return false
  end

  def isMaterialEnabled()
    return false
  end
  
  def processRows(inList)

    component=""
    cols = Array.new

    if(inList.parts.length > 0)
      for e in 0..(inList.parts.length-1)
        cols[0]=getPartPrefix() + CutList::integer_to_fws(3,(e+1))
        cols[1]=inList.partCount[e].to_s
        cols[2]=inList.parts[e]
        component = component + getRow(cols)
      end  ###for
    end ###if
    return component

  end ## end processRows


end ## CompactDisplayPart



#########################
# CompactDisplaySheet                           #
#########################
class CompactDisplaySheet < CompactDisplay
  
  def getMeasureLabel
    if @metric
      return "Square m"
    else
      return "Square Foot"
    end
  end
  
  def getPartPrefix()
    return "S-"
  end
  
  def getHeadingArray()
    headings=["Part#","Quantity","Description","Length(L)","Width(W)","Thickness(T)",@measureLabel + " (per)",
    @measureLabel + " (total)", "Total Length (" + @measureUnits + ")", "Material"]
    return headings
  end
  
  def getTitleName()
    return "Sheet Goods";
  end

  def getAmountTitleName()
      return "Total Sheet " + @measureLabel
  end

  def getMaterialTitleName()
    return "Sheet Materials"
  end

end ##class CompactDisplaySheet


#########################
# CutList PLus csv display                       #
#########################
class ClpDisplay < Display

  def getTitleName()
    return "";
  end

  def getHeadingArray()
    headings=["Part #","Sub-Assembly", "Description", "Copies",
    "Thickness(T)","Width(W)","Length(L)","Material Type", "Material Name", "Can Rotate"]
    return headings
  end

  def getAmountTitleName()
    return ""
  end

  def getMaterialTitleName()
    return ""
  end

  def isAmountEnabled()
    return false
  end

  def isMaterialEnabled()
    return false
  end

  def getMaterialType()
    return "DL"
  end
  
  def processRows(inList)
    component=""
    cols = Array.new
    i = 1
    ii = 0
    ix = ""
    cx = ""
    for c in inList
      i = i + 1 if c.getName != cx and cx != ""
      ii = 1 if c.getName != cx
      # construct the part name by concatenating the part type abbreviation (the prefix)
      # with the numbering scheme. The first digit is incremented for each unique part name
      # and then the part after the '-' is the number of the part if there is more than 1
      # Make sure the number of digits generated is the same, regardless of the value,  so that sorting by part number
      # puts it in the correct order. Use 3 digits for part number and 2 digits for subpart number.
      # we do this by extending the integer class to convert to string values.
      ix = CutList::integer_to_fws(3,i) + "-" + CutList::integer_to_fws(2,ii)
      cols[0]=getPartPrefix()+ix
      cols[1]=CutList::string_to_clp(c.getSubAssemblyName)
      cols[2]=CutList::string_to_clp(c.getName)
      cols[3]="1"
      # CutListPlus accepts all sketchup units except meters
      # If inches, then the inches symbol " needs to be stripped with CutList::string_to_clp since clp won't accept it - this is probably a CLP bug
      # If meters then we will convert to inches - this is sorted with the convertMeasureForCLP method
      cols[4]=CutList::string_to_clp(c.convertMeasureForCLP(c.getThickness).to_s)
      cols[5]=CutList::string_to_clp(c.convertMeasureForCLP(c.getWidth).to_s)
      cols[6]=CutList::string_to_clp(c.convertMeasureForCLP(c.getLength).to_s)
      cols[7]=getMaterialType()
      cols[8]=c.getMaterial
      cols[9]="yes"
      component = component + getRow(cols)
      ### gives sub-part numbers to same named compos; last = total
      ii = ii + 1
      cx = c.getName
    end ## end for

    return component
  end ## end processRows


end ##class ClpDisplay

#########################
# ClpDisplaySheet                                  #
#########################
class ClpDisplaySheet < ClpDisplay

  def getPartPrefix()
    return "S-"
  end

  def getMaterialType()
    return "SG"
  end

end ##class ClpDisplaySheet


#########################
# Compact CutList Plus csv                      #
#########################
class CompactClpDisplay < CompactDisplay

  def getTitleName()
    return "";
  end

  def getHeadingArray()
   headings=["Part #","Sub-Assembly", "Description", "Copies",
   "Thickness(T)","Width(W)","Length(L)","Material Type", "Material Name", "Can Rotate"]
   return headings
  end

  def getAmountTitleName()
    return ""
  end

  def getMaterialTitleName()
    return ""
  end

  def isAmountEnabled()
    return false
  end

  def isMaterialEnabled()
    return false
  end

  def getMaterialType()
    return "DL"
  end

  def processRows(inList)

    component=""
    partId = 1
    partCount = 1
    firstPart = ["","",0,0,0,""]
    lastPart = firstPart
    cols = Array.new
    row=""

    for c in inList
      # combine like parts but only if they are identical ( same name, dimensions and material)
      # If parts match the name and dimensions and material, then they are considered the
      # same and will be displayed in the compact form
      if (  ( c.getName      == lastPart[0] )  &&
            ( c.getSubAssemblyName == lastPart[1] ) &&
            ( c.getLength    == lastPart[2] )  &&
            ( c.getWidth     == lastPart[3] )  &&
            ( c.getThickness == lastPart[4] )  &&
            ( c.getMaterial  == lastPart[5] )     )
        puts "parts matched " + c.getName + " l=" + c.getLength.to_s  + " w=" + c.getWidth.to_s + " t=" + c.getThickness.to_s + " m=" + c.getMaterial
        partCount = partCount + 1
      elsif(lastPart != firstPart)
        puts "parts did not match " + c.getName + " l=" + c.getLength.to_s  + " w=" + c.getWidth.to_s + " t=" + c.getThickness.to_s + " m=" + c.getMaterial
        component = component + row
        partId = partId + 1
        partCount = 1
      end ##if

      cols[0]=getPartPrefix() + CutList::integer_to_fws(3,partId)
      cols[1]=CutList::string_to_clp(c.getSubAssemblyName)
      cols[2]=CutList::string_to_clp(c.getName)
      cols[3]=partCount.to_s
      
      # CutListPlus accepts all sketchup units except meters
      # If inches, then the inches symbol " needs to be stripped with CutList::string_to_clp since clp won't accept it - this is probably a CLP bug
      # If meters then we will convert to inches - this is sorted with the convertMeasureForCLP method
      cols[4]=CutList::string_to_clp(c.convertMeasureForCLP(c.getThickness).to_s)
      cols[5]=CutList::string_to_clp(c.convertMeasureForCLP(c.getWidth).to_s)
      cols[6]=CutList::string_to_clp(c.convertMeasureForCLP(c.getLength).to_s)
      cols[7]=getMaterialType()
      cols[8]=c.getMaterial
      cols[9]="yes"
      row = getRow(cols)
      lastPart = [c.getName, c.getSubAssemblyName, c.getLength, c.getWidth, c.getThickness, c.getMaterial]
    end#for c

    ##Output last row
    component = component + row
    return component
  end ## end processRows

end ##class CompactClpDisplay


#########################
# CompactClpDisplaySheet                       #
#########################
class CompactClpDisplaySheet < CompactClpDisplay

  def getPartPrefix()
    return "S-"
  end

  def getMaterialType()
    return "SG"
  end

end ##class CompactClpDisplaySheet

#########################
# CompactClpDisplayPart                         #
#########################
class CompactClpDisplayPart < CompactClpDisplay

  def getPartPrefix()
    return "P-"
  end

  def getMaterialType()
    return "HW"
  end
  
  def processRows(inList)

    component=""
    cols = Array.new

    if(inList.parts.length > 0)
      for p in 0..(inList.parts.length-1)
        cols[0]= getPartPrefix() + CutList::integer_to_fws(3,(p+1))
	cols[1] = "" 					#subAssemblyName
        cols[2] = ""					# description
        cols[3] = inList.partCount[p].to_s		# copies
	cols[4] = ""					# T
	cols[5] = ""					# W
	cols[6] = ""					# L
	cols[7] = getMaterialType()			# material type
	cols[8]=  inList.parts[p]			# material name - in CLP, material name is actually the description for HW parts
	cols[9] = "yes"					# can rotate
        component = component + getRow(cols)
      end  ###for
    end ###if
    return component

  end ## end processRows

end ##class CompactClpDisplayPart

#########################
# DisplaySheet                                      #
#########################
class DisplaySheet < Display
  
  def getMeasureLabel
    if @metric
      return "Square m"
    else
      return "Square Foot"
    end
  end

  def getPartPrefix()
    return "S-"
  end
  def getTitleName()
    return "Sheet Goods";
  end

  def getHeadingArray()
    headings=["Part #","Sub-Assembly","Description","Length(L)","Width(W)","Thickness(T)",@measureLabel, "Material"]
    return headings
  end

  def getAmountTitleName()
    return "Total Sheet " + @measureLabel
  end

  def getMaterialTitleName()
    return "Sheet Materials"
  end

end ##class DisplaySheet

	end #module CutList
end # module SteveR


