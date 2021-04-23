require 'typhoeus'
require 'json'
require 'yaml'
require 'pry'

environments = [
    # "project1-dev", "project1-qa", "project1-uat", "project1-pt", "project1-pp", "project1-prod",
    "project2-dev", "project2-qa", "project2-uat", "project2-pt", "project2-pp", "project2-prod"
]

environments.each do |environment|
    hash = {}
    hash["format_version"] = 3
    
    environment_variables = {}
    secure_variables = {}

    1.upto(100) do |i|
        str = (0...5000).map { ('a'..'z').to_a[rand(26)] }.join
        request = Typhoeus::Request.new(
            "http://gocd.example.com:8153/go/api/admin/encrypt",
            method: :post,
            body: "{\"value\": \"#{str}\"}",
            userpwd: "user:password",
            headers: { "Accept": "application/vnd.go.cd.v1+json", "Content-Type": "application/json" }
        )
        request.run
        json = JSON.parse(request.response.body)
        
        environment_variables["VAR_#{i}"] = str
        secure_variables["SECURE_VAR_#{i}"] = json["encrypted_value"]
    end

    hash["environments"] = {}
    hash["environments"][environment] = {}
    # hash["environments"][environment]["environment_variables"] = environment_variables
    hash["environments"][environment]["secure_variables"] = secure_variables

    File.open("#{environment}.gocd.yaml", "w") {|f| f.write(hash.to_yaml) }
end



