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
      good_pixels = ((254*400+195)..(367*400+292)).step(8*412).to_a #diagonal; Average error in cups: 1.8980726662595289
      image=get_pixels
      good_pixels.map{|x| image[x-1]}

    end
  end

end
