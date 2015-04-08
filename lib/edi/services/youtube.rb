class Youtube < EDI::Service
  phrases "youtube"

  environment :google_api_key
  before_invoke :extract_search_term

  def run
    response = EDI.get("#{url}?#{params}")
    if response.ok?
      "https://youtu.be/#{response.response["items"].first["id"]["videoId"]}"
    else
      EDI::Logger.debug response.response
    end
  end

private

  def extract_search_term
    captures = text.match /youtube(?<term>.+)/i
    @search_term = EDI.encode_uri(captures[:term])
  end

  def url
    "https://www.googleapis.com/youtube/v3/search"
  end

  def params
    [part, order, q, key].join("&")
  end

  def part
    "part=snippet"
  end

  def order
    "order=relevance"
  end

  def key
    "key=#{google_api_key}"
  end

  def q
    "q=#{@search_term}"
  end
end
