require 'shoes/element_methods'
require 'shoes/color'
require 'tmpdir'
require 'fileutils'

def window(*a, &b)
  Shoes.app(*a, &b)
end


module Shoes
  shoes_icon = File.expand_path("../../../static/shoes-icon.png", __FILE__)
  if shoes_icon.include? '.jar!'
    SHOES_ICON = File.join(Dir.tmpdir, 'shoes-icon.png')
    open SHOES_ICON, 'wb' do |fw|
      open shoes_icon, 'rb' do |fr|
        fw.write fr.read
      end
    end
  else
    SHOES_ICON = shoes_icon
  end

  def self.app(opts={}, &blk)
    Shoes::App.new(opts, &blk)
  end

  class App
    include Shoes::ElementMethods

    attr_reader :gui, :shell, :top_slot, :contents
    attr_reader :app, :mouse_motion
    attr_accessor :elements, :current_slot
    attr_accessor :opts, :blk
    attr_accessor :mouse_button, :mouse_pos

    attr_accessor :resizable, :app_title
    attr_writer   :width, :height

    def initialize(opts={}, &blk)
      opts = default_options.merge(opts)

      self.width      = opts[:width]
      self.height     = opts[:height]
      self.app_title  = opts[:title]
      self.resizable  = opts[:resizable]
      self.opts       = opts

      @app = self
      @style = default_styles
      @contents = []
      @mouse_motion = []
      @mouse_button, @mouse_pos = 0, [0, 0]

      @gui = Shoes.configuration.backend::App.new @app

      @top_slot = Flow.new self, {app: @app, left: 0, top: 0, width: @width, height: @height}, &blk

      Shoes.register self
      @gui.open
    end

    def width
      @top_slot ? @top_slot.width : @width
    end

    def height
      @top_slot ? @top_slot.height : @height
    end

    def left; 0 end
    def top; 0 end

    def quit
      Shoes.unregister self
      @gui.quit
    end

    def add_child(child)
      @top_slot.add_child child
    end

    def default_options
      {
        :width  => 600,
        :height => 500,
        :title  => "Shoes 4",
        :resizable  => true,
        :background => white
      }
    end

    def default_styles
      {
        :stroke      => Shoes::COLORS[:black],
        :strokewidth => 1
      }
    end
  end
end
