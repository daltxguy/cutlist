# Copyright 2006-2013 daltxguy, Vendmr
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
require 'sr_cutlist/cutlistutl'  # cutlist utilities

module SteveR
	module CutList
		su_cutlist_extension = SketchupExtension.new "CutList",
		"sr_cutlist/CutListAndMaterials.rb"

		su_cutlist_extension.description = 
		"Produce a materials list from your model and a layout" +
		" of the parts on material of selectable sizes." 
		su_cutlist_extension.version = CutList.version
		su_cutlist_extension.copyright = "2014"
		su_cutlist_extension.creator = "S. Racz"

		Sketchup.register_extension su_cutlist_extension, true
	end
end
