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
      #convert.crop("390x200+10+190")
      #convert.scale("130x150")
      convert << "RGB:-"
      content = convert.call
      pixels = content.unpack("C*")
      pixels.each_slice(3).map{|x| x.sum / 3.0}
      #Math.sqrt(0.299*x[0] + 0.587*x[1] + 0.114*x[2])
    end

    def get_pixels_sum
      [get_pixels.flatten.sum]
    end

    def get_good_pixels
      good_pixels = [87311,95716,102082,89321,99481,101280,127705,116098,101682,95316,102080,119714,87711,144209,87712,116498,128107,144936,113372,102130]
      image=get_pixels
      good_pixels.map{|x| image[x-1]}

    end
  end

end
