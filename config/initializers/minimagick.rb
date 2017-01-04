module MiniMagick
  class Image
    def get_pixels(*args)
      convert = MiniMagick::Tool::Convert.new
      if args.any?
        raise ArgumentError, "must provide 4 arguments: (x, y, columns, rows)" if args.size != 4
        x, y, columns, rows = args
        convert << path
      else
        columns = width
        convert << path
      end
      convert.depth(8)
      convert.crop("300x390+90+40")
      convert.scale("150x195")
      convert << "RGB:-"
      content = convert.call
      pixels = content.unpack("C*")
      pixels.each_slice(3).map{|x| x.sum / 3.0}
    end
  end
end
