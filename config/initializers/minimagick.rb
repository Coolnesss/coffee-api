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
      #too big area ((202*400+188)..(386*400+264))
      #good_pixels = ((254*400+200)..(389*400+200)).step(14*400).to_a #vertical
      #good_pixels = ((254*400+195)..(367*400+292)).step(8*412).to_a #diagonal;
      good_pixels = [87711, 95716, 102082, 116098, 127705, 118095, 89322, 89323, 89321, 91708, 96116, 117296, 86121, 102310, 96637, 144209, 102713, 149094, 118896, 117298]#, 118512, 127303, 101682, 127304, 89324, 102712, 91707, 131335, 148299, 90524, 104926, 101910, 115283, 133736] #Lasso
      image=get_pixels
      good_pixels.map{|x| image[x-1]}

    end
  end

end
