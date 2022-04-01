require 'httparty'
require 'dotenv/load'

if ARGV.size != 3
  puts "USAGE: set_pixel X Y COLOR"
  puts
  puts "  COLOR:"
  puts "    red,"
  puts "    orange,"
  puts "    yellow,"
  puts "    dark-green,"
  puts "    light-green,"
  puts "    dark-blue,"
  puts "    blue,"
  puts "    light-blue,"
  puts "    dark-violet,"
  puts "    violet,"
  puts "    rose,"
  puts "    brown,"
  puts "    black,"
  puts "    dark-grey,"
  puts "    light-grey,"
  puts "    white"
  abort
end

BEARER = ENV.fetch('BEARER')

X = ARGV[0].to_i
Y = ARGV[1].to_i

COLOR_INDEX = [
  "red",
  "orange",
  "yellow",
  "dark-green",
  "light-green",
  "dark-blue",
  "blue",
  "light-blue",
  "dark-violet",
  "violet",
  "rose",
  "brown",
  "black",
  "dark-grey",
  "light-grey",
  "white"
].index(ARGV[2]) || abort("Color not found")

pp HTTParty.post(
  'https://gql-realtime-2.reddit.com/query',
  headers: {
    'Content-Type' => 'application/json',
    'Authorization' => "Bearer #{BEARER}"
  },
  body: {
    operationName: 'setPixel',
    variables: {
      input: {
        actionName: 'r/replace:set_pixel',
        PixelMessageData: {
          coordinate: {
            x: X,
            y: Y
          },
          colorIndex: COLOR_INDEX,
          canvasIndex: 0
        }
      }
    },
    query: <<~QUERY
      mutation setPixel($input: ActInput!) {
        act(input: $input) {
          data {
            ... on BasicMessage {
              id
              data {
                ... on GetUserCooldownResponseMessageData {
                  nextAvailablePixelTimestamp
                }
                ... on SetPixelResponseMessageData {
                  timestamp
                }
              }
            }
          }
        }
      }
    QUERY
  }.to_json
)
