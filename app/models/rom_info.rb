# -*- coding: utf-8 -*-
require 'ebyaml'

class ROMInfo < ApplicationModel
  attr_reader :processor, :platform, :title, :country, :series, :text_tables

  def initialize(**attributes)
    super
    @processor = EBYAML.info['processor']
    @platform = EBYAML.info['platform']
    @title = EBYAML.info['title']
    @country = EBYAML.info['country']
    @series = EBYAML.info['series']
    @text_tables = EBYAML.info['texttables']
    # fix up text tables
    replacements = @text_tables['standardtext']['replacements']
    replacements.delete(0x00)
    replacements.delete(0x03)
    replacements[0x52] = '"'
    replacements[0x52] = '#'
    replacements[0x55] = '%'
    replacements[0x56] = '&'
    replacements[0x5b] = '+'
    replacements[0x5f] = '/'
    replacements[0x6a] = ':'
    replacements[0x6b] = ';'
    replacements[0x6c] = '<'
    replacements[0x6d] = '='
    replacements[0x6e] = '>'
    replacements[0x8b] = 'α'
    replacements[0x8c] = 'β'
    replacements[0x8d] = 'γ'
    replacements[0x8e] = 'Σ'
    replacements[0x90] = '`'
    replacements[0xab] = '{'
    replacements[0xac] = '|'
    replacements[0xad] = '}'
    replacements[0xae] = '~'
    replacements[0xaf] = '◯'
    staffreplacements = @text_tables['stafftext']['replacements']
    staffreplacements.delete(0x00)
    staffreplacements[0x41] = '!'
    staffreplacements[0x43] = '#'
    staffreplacements[0x4c] = ','
    staffreplacements[0x4d] = '-'
    staffreplacements[0x4e] = '.'
    staffreplacements[0x4f] = '/'
    staffreplacements[0x58] = 'j'
    staffreplacements[0x60] = '0'
    staffreplacements[0x61] = '1'
    staffreplacements[0x62] = '2'
    staffreplacements[0x63] = '3'
    staffreplacements[0x64] = '4'
    staffreplacements[0x65] = '5'
    staffreplacements[0x66] = '6'
    staffreplacements[0x67] = '7'
    staffreplacements[0x68] = '8'
    staffreplacements[0x69] = '9'
    staffreplacements[0x6a] = 'q'
    staffreplacements[0x7e] = 'z'
    staffreplacements[0x80] = '_'
    staffreplacements[0xad] = ';'
    staffreplacements[0xcc] = '|'
    staffreplacements[0xce] = '~'
    staffreplacements[0xcf] = '◯'
  end
end
