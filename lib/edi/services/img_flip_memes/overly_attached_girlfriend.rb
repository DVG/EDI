module ImgFlipMemes
  class OverlyAttachedGirlfriend < BaseMeme
    def template_id
      100952
    end

    def tokenize
      captures = text.match(/overly attached girlfriend(?<text0>.[^,]+),?(?<text1>.[^,]+)?/i)
      self.captures[:text0], self.captures[:text1] = captures[:text0], captures[:text1]
      true
    end
  end
end
