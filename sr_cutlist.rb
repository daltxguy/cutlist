# Copyright 2006-2014 daltxguy, Vendmr
# Based on CutList.rb, Copyright 2005, CptanPanic

# This extension produces a cutlist from a woodworking model and a layout of the partslist
# on boards or sheet goods.

# Permission to use, copy, modify, and distribute this software for
# any purpose and without fee is hereby granted, provided that the above
# copyright notice appear in all copies.

# THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
#-----------------------------------------------------------------------------
require 'sketchup'
require 'extensions'
require 'sr_cutlist/cutlistutl'  # cutlist utilities for plugin strings and parameters

module SteveR
	module CutList
		@su_cutlist_extension = SketchupExtension.new "CutList",
		"sr_cutlist/CutListAndMaterials.rb"

		@su_cutlist_extension.description = CutList.short_description
		@su_cutlist_extension.version = CutList.version
		@su_cutlist_extension.copyright = CutList.year
		@su_cutlist_extension.creator = CutList.author
		Sketchup.register_extension @su_cutlist_extension, true
	end
end
