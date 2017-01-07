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
      #convert.gravity("center")
      convert.crop("390x200+10+190")
      #convert.scale("130x150")
      convert << "RGB:-"
      content = convert.call
      pixels = content.unpack("C*")
      pixels.each_slice(3).map{|x| x.sum / 3.0}
      #Math.sqrt(0.299*x[0] + 0.587*x[1] + 0.114*x[2])
    end
  end
end
