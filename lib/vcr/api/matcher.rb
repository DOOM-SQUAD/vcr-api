module VCR
  class API
    class Matcher
      def call(request1, request2)
        request1.method == request2.method &&
        params_equal?(request1.parsed_uri.query.to_s, request2.parsed_uri.query.to_s) &&
        request1.body == request2.body &&
        request1.headers == request2.headers
      end

      def params_equal?(query_string1, query_string2)
        VCR.configuration.query_parser.call(query_string1) ==
          VCR.configuration.query_parser.call(query_string2)
      end
    end
  end
end
